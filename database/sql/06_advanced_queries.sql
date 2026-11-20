-- FinControl | Consultas SQL avançadas
-- Execute conectado ao banco fincontrol.

-- 1. JOIN + GROUP BY: total de despesas por departamento.
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
GROUP BY d.id_departamento, d.nome
ORDER BY total_despesas DESC;

-- 2. HAVING: categorias com despesas acima de R$ 5.000.
SELECT
    c.nome AS categoria,
    COUNT(t.id_transacao) AS quantidade,
    SUM(t.valor) AS total
FROM transacao t
JOIN categoria c
    ON c.id_empresa = t.id_empresa
   AND c.id_categoria = t.id_categoria
WHERE t.tipo = 'DESPESA'
  AND t.status <> 'CANCELADO'
GROUP BY c.id_categoria, c.nome
HAVING SUM(t.valor) > 5000
ORDER BY total DESC;

-- 3. Subconsulta: despesas acima da média de todas as despesas.
SELECT descricao, valor, tipo
FROM transacao
WHERE tipo = 'DESPESA'
  AND valor > (
      SELECT AVG(valor)
      FROM transacao
      WHERE tipo = 'DESPESA'
        AND status <> 'CANCELADO'
  )
ORDER BY valor DESC;

-- 4. CTE: departamentos com despesas acima da média das despesas.
WITH media_despesas AS (
    SELECT AVG(valor) AS media
    FROM transacao
    WHERE tipo = 'DESPESA' AND status <> 'CANCELADO'
),
total_departamento AS (
    SELECT
        d.id_departamento,
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
    GROUP BY d.id_departamento, d.nome
)
SELECT td.departamento, td.total_despesas, md.media AS media_despesas
FROM total_departamento td
CROSS JOIN media_despesas md
WHERE td.total_despesas > md.media
ORDER BY td.total_despesas DESC;

-- 5. Window Functions: ROW_NUMBER, RANK e DENSE_RANK.
SELECT
    descricao,
    valor,
    ROW_NUMBER() OVER (ORDER BY valor DESC, id_transacao) AS numero_linha,
    RANK() OVER (ORDER BY valor DESC) AS classificacao,
    DENSE_RANK() OVER (ORDER BY valor DESC) AS classificacao_densa
FROM transacao
WHERE tipo = 'DESPESA';

-- 6. LAG: comparar cada transação com a anterior por data.
SELECT
    descricao,
    data_competencia,
    valor,
    LAG(valor) OVER (ORDER BY data_competencia, id_transacao) AS valor_anterior,
    valor - LAG(valor) OVER (
        ORDER BY data_competencia, id_transacao
    ) AS diferenca_anterior
FROM transacao
ORDER BY data_competencia, id_transacao;

-- 7. Soma acumulada das despesas por data.
SELECT
    descricao,
    data_competencia,
    valor,
    SUM(valor) OVER (
        ORDER BY data_competencia, id_transacao
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS total_acumulado
FROM transacao
WHERE tipo = 'DESPESA'
ORDER BY data_competencia, id_transacao;
