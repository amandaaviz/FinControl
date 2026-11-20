-- 1. Despesas registradas por departamento no período.
SELECT
    d.nome AS departamento,
    SUM(t.valor) AS total_despesas
FROM transacao t
JOIN centro_custo cc ON cc.id_centro_custo = t.id_centro_custo
JOIN departamento d ON d.id_departamento = cc.id_departamento
WHERE t.tipo = 'DESPESA'
  AND t.status <> 'CANCELADO'
  AND t.data_competencia >= DATE '2026-11-01'
  AND t.data_competencia < DATE '2026-12-01'
GROUP BY d.nome
ORDER BY total_despesas DESC;

-- 2. Execução orçamentária.
SELECT *
FROM vw_execucao_orcamentaria
WHERE ano = 2026 AND mes = 11
ORDER BY saldo_orcamentario;

-- 3. Pagamentos realizados por conta financeira.
SELECT
    cf.nome AS conta,
    COUNT(*) AS quantidade_pagamentos,
    SUM(p.valor_pago) AS total_pago
FROM pagamento p
JOIN conta_financeira cf ON cf.id_conta = p.id_conta
GROUP BY cf.nome
ORDER BY total_pago DESC;

-- 4. Transações pendentes ou parciais com vencimento.
SELECT
    id_transacao, descricao, valor, status, data_vencimento
FROM transacao
WHERE status IN ('PENDENTE', 'PARCIAL')
  AND data_vencimento IS NOT NULL
ORDER BY data_vencimento;

-- 5. Exemplo de CTE: total de pagamentos por transação.
WITH total_pago AS (
    SELECT id_transacao, SUM(valor_pago) AS valor_pago
    FROM pagamento
    GROUP BY id_transacao
)
SELECT
    t.id_transacao,
    t.descricao,
    t.valor AS valor_original,
    COALESCE(tp.valor_pago, 0) AS valor_pago,
    t.valor - COALESCE(tp.valor_pago, 0) AS valor_em_aberto
FROM transacao t
LEFT JOIN total_pago tp ON tp.id_transacao = t.id_transacao
ORDER BY t.id_transacao;
