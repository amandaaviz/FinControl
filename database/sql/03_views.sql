-- View: despesas pagas por departamento, por competência.
CREATE OR REPLACE VIEW vw_despesas_por_departamento AS
SELECT
    e.id_empresa,
    e.nome_fantasia AS empresa,
    d.id_departamento,
    d.nome AS departamento,
    DATE_TRUNC('month', p.data_pagamento)::date AS mes_pagamento,
    SUM(p.valor_pago) AS total_pago
FROM pagamento p
JOIN transacao t ON t.id_transacao = p.id_transacao
JOIN centro_custo cc ON cc.id_centro_custo = t.id_centro_custo
JOIN departamento d ON d.id_departamento = cc.id_departamento
JOIN empresa e ON e.id_empresa = t.id_empresa
WHERE t.tipo = 'DESPESA'
GROUP BY e.id_empresa, e.nome_fantasia, d.id_departamento, d.nome,
         DATE_TRUNC('month', p.data_pagamento);

-- View: execução orçamentária por centro de custo e categoria.
-- A comparação usa o valor de despesas registradas por competência.
CREATE OR REPLACE VIEW vw_execucao_orcamentaria AS
SELECT
    o.id_orcamento,
    o.id_empresa,
    cc.nome AS centro_custo,
    c.nome AS categoria,
    o.ano,
    o.mes,
    o.valor_previsto,
    COALESCE(SUM(t.valor) FILTER (WHERE t.tipo = 'DESPESA'
        AND t.status <> 'CANCELADO'), 0) AS valor_registrado,
    o.valor_previsto - COALESCE(SUM(t.valor) FILTER (WHERE t.tipo = 'DESPESA'
        AND t.status <> 'CANCELADO'), 0) AS saldo_orcamentario
FROM orcamento o
JOIN centro_custo cc ON cc.id_centro_custo = o.id_centro_custo
JOIN categoria c ON c.id_categoria = o.id_categoria
LEFT JOIN transacao t
    ON t.id_centro_custo = o.id_centro_custo
   AND t.id_categoria = o.id_categoria
   AND EXTRACT(YEAR FROM t.data_competencia)::int = o.ano
   AND EXTRACT(MONTH FROM t.data_competencia)::int = o.mes
GROUP BY o.id_orcamento, o.id_empresa, cc.nome, c.nome,
         o.ano, o.mes, o.valor_previsto;
