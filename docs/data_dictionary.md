# Dicionário de dados — FinControl

| Tabela | Finalidade |
|---|---|
| empresa | Organização proprietária dos dados |
| departamento | Unidades organizacionais |
| centro_custo | Agrupador gerencial de receitas/despesas |
| usuario | Usuários do sistema e perfil de acesso |
| categoria | Classificação de receitas e despesas |
| conta_financeira | Contas bancárias/financeiras da empresa |
| orcamento | Valor planejado por centro, categoria e mês |
| transacao | Lançamentos de receita ou despesa |
| pagamento | Liquidações totais ou parciais de transações |
| auditoria | Registro estruturado de alterações |

## Tipos importantes

- `BIGINT GENERATED ALWAYS AS IDENTITY`: chave numérica gerada pelo PostgreSQL.
- `NUMERIC(15,2)`: valor decimal exato, apropriado para quantias monetárias.
- `DATE`: data sem horário.
- `TIMESTAMPTZ`: data/hora com informação de fuso.
- `JSONB`: dados semiestruturados armazenados em formato binário JSON.

## Convenções

- Nomes de tabelas e colunas em português, minúsculos e com `snake_case`.
- Chaves primárias no formato `id_nome`.
- Constraints nomeadas para facilitar manutenção e diagnóstico.
