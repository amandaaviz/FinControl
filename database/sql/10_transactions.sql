-- FinControl | Demonstração de transações SQL
-- Execute conectado ao banco fincontrol e depois de instalar 08_triggers.sql.
-- O primeiro exemplo termina com ROLLBACK e não deixa alteração persistente.

-- 1. Pagamento parcial dentro de uma transação.
BEGIN;

INSERT INTO pagamento (
    id_empresa, id_transacao, id_conta, valor_pago, data_pagamento
)
VALUES (1, 2, 1, 100.00, CURRENT_DATE);

-- O trigger recalcula o status e registra a auditoria.
SELECT id_transacao, descricao, valor, status
FROM transacao
WHERE id_empresa = 1 AND id_transacao = 2;

ROLLBACK;

-- 2. Exemplo de COMMIT. Execute somente em dados de teste.
-- BEGIN;
-- INSERT INTO pagamento (
--     id_empresa, id_transacao, id_conta, valor_pago, data_pagamento
-- )
-- VALUES (1, 2, 1, 100.00, CURRENT_DATE);
-- COMMIT;

-- 3. Exemplo de SAVEPOINT.
-- BEGIN;
-- UPDATE transacao
-- SET descricao = 'Descrição temporária de teste'
-- WHERE id_empresa = 1 AND id_transacao = 2;
-- SAVEPOINT antes_da_segunda_alteracao;
-- UPDATE transacao
-- SET descricao = 'Outra descrição temporária'
-- WHERE id_empresa = 1 AND id_transacao = 2;
-- ROLLBACK TO SAVEPOINT antes_da_segunda_alteracao;
-- COMMIT;

-- 4. Teste de pagamento excedente: deve gerar erro.
-- A transação 2 vale R$ 6.500. Teste isoladamente em banco de teste.
-- INSERT INTO pagamento (
--     id_empresa, id_transacao, id_conta, valor_pago, data_pagamento
-- )
-- VALUES (1, 2, 1, 7000.00, CURRENT_DATE);
