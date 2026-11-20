-- FinControl | Análise de desempenho
-- EXPLAIN ANALYZE executa a consulta; use os exemplos SELECT abaixo.

-- 1. Plano de execução para filtro de despesas por empresa e período.
EXPLAIN (ANALYZE, BUFFERS)
SELECT id_transacao, descricao, valor, data_competencia
FROM transacao
WHERE id_empresa = 1
  AND tipo = 'DESPESA'
  AND data_competencia >= DATE '2026-11-01'
  AND data_competencia < DATE '2026-12-01';

-- 2. Plano de execução para consulta com JOIN.
EXPLAIN (ANALYZE, BUFFERS)
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
WHERE t.id_empresa = 1
  AND t.tipo = 'DESPESA'
GROUP BY d.id_departamento, d.nome;

-- 3. Índices existentes nas tabelas principais.
SELECT schemaname, tablename, indexname, indexdef
FROM pg_indexes
WHERE schemaname = 'public'
  AND tablename IN (
      'transacao', 'pagamento', 'centro_custo',
      'departamento', 'orcamento'
  )
ORDER BY tablename, indexname;

-- 4. Estatísticas de leituras e uso de índices por tabela.
SELECT
    relname AS tabela,
    seq_scan,
    seq_tup_read,
    idx_scan,
    idx_tup_fetch
FROM pg_stat_user_tables
ORDER BY relname;

-- Não crie índices indiscriminadamente. Compare planos antes e depois.
-- Em tabelas pequenas, o PostgreSQL pode preferir uma leitura sequencial.
