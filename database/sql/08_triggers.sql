-- FinControl | Triggers de validação, status e auditoria
-- Execute conectado ao banco fincontrol, depois de 02_schema.sql e 04_seed.sql.

-- 1. Impede pagamentos acima do valor original da transação.
CREATE OR REPLACE FUNCTION fn_validar_pagamento()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_valor_transacao NUMERIC(15,2);
    v_status_transacao VARCHAR(15);
    v_total_existente NUMERIC(15,2);
BEGIN
    IF TG_OP = 'UPDATE'
       AND (
           OLD.id_empresa IS DISTINCT FROM NEW.id_empresa
           OR OLD.id_transacao IS DISTINCT FROM NEW.id_transacao
       ) THEN
        RAISE EXCEPTION
            'Não é permitido transferir um pagamento para outra transação.';
    END IF;

    SELECT valor, status
      INTO v_valor_transacao, v_status_transacao
    FROM transacao
    WHERE id_empresa = NEW.id_empresa
      AND id_transacao = NEW.id_transacao
    FOR UPDATE;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Transação informada não encontrada.';
    END IF;

    IF v_status_transacao = 'CANCELADO' THEN
        RAISE EXCEPTION 'Não é permitido registrar pagamento em transação cancelada.';
    END IF;

    SELECT COALESCE(SUM(valor_pago), 0)
      INTO v_total_existente
    FROM pagamento
    WHERE id_empresa = NEW.id_empresa
      AND id_transacao = NEW.id_transacao
      AND (TG_OP = 'INSERT' OR id_pagamento <> NEW.id_pagamento);

    IF v_total_existente + NEW.valor_pago > v_valor_transacao THEN
        RAISE EXCEPTION
            'Pagamento excede o valor da transação. Valor: %, já pago: %, novo pagamento: %.',
            v_valor_transacao, v_total_existente, NEW.valor_pago;
    END IF;

    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_pagamento_validar ON pagamento;
CREATE TRIGGER trg_pagamento_validar
BEFORE INSERT OR UPDATE ON pagamento
FOR EACH ROW
EXECUTE FUNCTION fn_validar_pagamento();

-- 2. Impede reduzir o valor de uma transação abaixo do total já pago.
CREATE OR REPLACE FUNCTION fn_validar_valor_transacao()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_total_pago NUMERIC(15,2);
BEGIN
    IF NEW.valor IS DISTINCT FROM OLD.valor THEN
        SELECT COALESCE(SUM(valor_pago), 0)
          INTO v_total_pago
        FROM pagamento
        WHERE id_empresa = OLD.id_empresa
          AND id_transacao = OLD.id_transacao;

        IF NEW.valor < v_total_pago THEN
            RAISE EXCEPTION
                'O novo valor da transação (%) não pode ser inferior ao total já pago (%).',
                NEW.valor, v_total_pago;
        END IF;
    END IF;

    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_transacao_validar_valor ON transacao;
CREATE TRIGGER trg_transacao_validar_valor
BEFORE UPDATE OF valor ON transacao
FOR EACH ROW
EXECUTE FUNCTION fn_validar_valor_transacao();

-- 3. Recalcula o status após inserir, alterar ou excluir um pagamento.
CREATE OR REPLACE FUNCTION fn_recalcular_status_transacao()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $
DECLARE
    v_id_empresa BIGINT;
    v_id_transacao BIGINT;
    v_valor_transacao NUMERIC(15,2);
    v_status_atual VARCHAR(15);
    v_total_pago NUMERIC(15,2);
    v_novo_status VARCHAR(15);
BEGIN
    IF TG_OP = 'DELETE' THEN
        v_id_empresa := OLD.id_empresa;
        v_id_transacao := OLD.id_transacao;
    ELSE
        v_id_empresa := NEW.id_empresa;
        v_id_transacao := NEW.id_transacao;
    END IF;

    SELECT valor, status
      INTO v_valor_transacao, v_status_atual
    FROM transacao
    WHERE id_empresa = v_id_empresa
      AND id_transacao = v_id_transacao
    FOR UPDATE;

    IF NOT FOUND OR v_status_atual = 'CANCELADO' THEN
        RETURN NULL;
    END IF;

    SELECT COALESCE(SUM(valor_pago), 0)
      INTO v_total_pago
    FROM pagamento
    WHERE id_empresa = v_id_empresa
      AND id_transacao = v_id_transacao;

    IF v_total_pago = 0 THEN
        v_novo_status := 'PENDENTE';
    ELSIF v_total_pago >= v_valor_transacao THEN
        v_novo_status := 'PAGO';
    ELSE
        v_novo_status := 'PARCIAL';
    END IF;

    UPDATE transacao
    SET status = v_novo_status
    WHERE id_empresa = v_id_empresa
      AND id_transacao = v_id_transacao
      AND status IS DISTINCT FROM v_novo_status;

    RETURN NULL;
END;
$$;

DROP TRIGGER IF EXISTS trg_pagamento_recalcular_status ON pagamento;
CREATE TRIGGER trg_pagamento_recalcular_status
AFTER INSERT OR UPDATE OR DELETE ON pagamento
FOR EACH ROW
EXECUTE FUNCTION fn_recalcular_status_transacao();

-- 4. Auditoria automática de alterações em transacao e pagamento.
-- SECURITY DEFINER permite inserir em auditoria sem conceder INSERT direto
-- nesse histórico ao usuário operacional.
CREATE OR REPLACE FUNCTION fn_registrar_auditoria()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
    v_anterior JSONB;
    v_novo JSONB;
    v_id_empresa BIGINT;
    v_id_usuario BIGINT;
    v_registro_id BIGINT;
    v_usuario_texto TEXT;
BEGIN
    IF TG_OP = 'DELETE' THEN
        v_anterior := to_jsonb(OLD);
        v_novo := NULL;
    ELSIF TG_OP = 'INSERT' THEN
        v_anterior := NULL;
        v_novo := to_jsonb(NEW);
    ELSE
        v_anterior := to_jsonb(OLD);
        v_novo := to_jsonb(NEW);
    END IF;

    v_id_empresa := COALESCE(
        (v_novo ->> 'id_empresa')::BIGINT,
        (v_anterior ->> 'id_empresa')::BIGINT
    );

    v_usuario_texto := COALESCE(
        v_novo ->> 'id_usuario',
        v_anterior ->> 'id_usuario',
        NULLIF(current_setting('app.user_id', TRUE), '')
    );
    v_id_usuario := NULLIF(v_usuario_texto, '')::BIGINT;

    IF TG_TABLE_NAME = 'transacao' THEN
        v_registro_id := COALESCE(
            (v_novo ->> 'id_transacao')::BIGINT,
            (v_anterior ->> 'id_transacao')::BIGINT
        );
    ELSIF TG_TABLE_NAME = 'pagamento' THEN
        v_registro_id := COALESCE(
            (v_novo ->> 'id_pagamento')::BIGINT,
            (v_anterior ->> 'id_pagamento')::BIGINT
        );
    END IF;

    INSERT INTO public.auditoria (
        id_empresa, id_usuario, tabela_afetada, operacao,
        registro_id, dados_anteriores, dados_novos
    )
    VALUES (
        v_id_empresa, v_id_usuario, TG_TABLE_NAME, TG_OP,
        v_registro_id, v_anterior, v_novo
    );

    RETURN NULL;
END;
$$;

DROP TRIGGER IF EXISTS trg_transacao_auditoria ON transacao;
CREATE TRIGGER trg_transacao_auditoria
AFTER INSERT OR UPDATE OR DELETE ON transacao
FOR EACH ROW
EXECUTE FUNCTION fn_registrar_auditoria();

DROP TRIGGER IF EXISTS trg_pagamento_auditoria ON pagamento;
CREATE TRIGGER trg_pagamento_auditoria
AFTER INSERT OR UPDATE OR DELETE ON pagamento
FOR EACH ROW
EXECUTE FUNCTION fn_registrar_auditoria();
