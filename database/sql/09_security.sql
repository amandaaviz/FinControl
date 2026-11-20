-- FinControl | Perfis de acesso PostgreSQL
-- Execute conectado ao banco fincontrol com um usuário administrador.
-- Os papéis são grupos de permissões (NOLOGIN).

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'fincontrol_leitura') THEN
        CREATE ROLE fincontrol_leitura NOLOGIN;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'fincontrol_operacao') THEN
        CREATE ROLE fincontrol_operacao NOLOGIN;
    END IF;
END
$$;

GRANT CONNECT ON DATABASE fincontrol
TO fincontrol_leitura, fincontrol_operacao;

GRANT USAGE ON SCHEMA public
TO fincontrol_leitura, fincontrol_operacao;

-- Perfil de consulta: somente leitura.
GRANT SELECT ON ALL TABLES IN SCHEMA public TO fincontrol_leitura;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO fincontrol_leitura;

-- Perfil operacional: leitura geral e escrita controlada nas movimentações.
GRANT SELECT ON ALL TABLES IN SCHEMA public TO fincontrol_operacao;
GRANT INSERT, UPDATE ON transacao, pagamento TO fincontrol_operacao;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO fincontrol_operacao;

-- Permissões padrão para novas tabelas criadas pelo usuário executor.
ALTER DEFAULT PRIVILEGES IN SCHEMA public
GRANT SELECT ON TABLES TO fincontrol_leitura;

ALTER DEFAULT PRIVILEGES IN SCHEMA public
GRANT SELECT ON TABLES TO fincontrol_operacao;

-- Exemplos de associação de usuários reais aos grupos:
-- CREATE ROLE usuario_consulta LOGIN;
-- GRANT fincontrol_leitura TO usuario_consulta;
-- CREATE ROLE usuario_financeiro LOGIN;
-- GRANT fincontrol_operacao TO usuario_financeiro;
--
-- Defina senhas individualmente no DBeaver ou usando \password no psql.
-- Nunca coloque senhas reais neste arquivo ou no GitHub.
