-- FinControl | Consultas de relatórios
-- Execute conectado ao banco fincontrol, depois de executar 03_views.sql.

-- 1. Despesas registradas por departamento no período de demonstração (novembro de 2026).
SELECT
    d.nome AS departamento,
    SUM(t.valor) AS total_despesas
FROM transacao t
JOIN centro_custo cc
    ON cc.id_empresa = t.id_empresa
   AND cc.id_centro_custo = t.id_centro_custo
JOIN departamento d
    ON d.id_empresa = cc.id_empresa
   AND d.id_departamento = cc.id_departamento
WHERE t.tipo = 'DESPESA'
  AND t.status <> 'CANCELADO'
  AND t.data_competencia >= DATE '2026-11-01'
  AND t.data_competencia < DATE '2026-12-01'
GROUP BY d.id_departamento, d.nome
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
JOIN conta_financeira cf
    ON cf.id_empresa = p.id_empresa
   AND cf.id_conta = p.id_conta
GROUP BY cf.id_empresa, cf.id_conta, cf.nome
ORDER BY total_pago DESC;

-- 4. Transações pendentes ou parciais com vencimento.
SELECT
    id_transacao, descricao, valor, status, data_vencimento
FROM transacao
WHERE status IN ('PENDENTE', 'PARCIAL')
  AND data_vencimento IS NOT NULL
ORDER BY data_vencimento;

-- 5. Valor pago e saldo em aberto por transação.
WITH total_pago AS (
    SELECT id_empresa, id_transacao, SUM(valor_pago) AS valor_pago
    FROM pagamento
    GROUP BY id_empresa, id_transacao
)
SELECT
    t.id_transacao,
    t.descricao,
    t.valor AS valor_original,
    COALESCE(tp.valor_pago, 0) AS valor_pago,
    t.valor - COALESCE(tp.valor_pago, 0) AS valor_em_aberto
FROM transacao t
LEFT JOIN total_pago tp
    ON tp.id_empresa = t.id_empresa
   AND tp.id_transacao = t.id_transacao
ORDER BY t.id_transacao;
