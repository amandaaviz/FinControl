# Registro de validação — FinControl

Este documento registra os testes funcionais realizados na versão de portfólio
do FinControl em ambiente local, com dados inteiramente fictícios.

## 1. Banco de dados

| Verificação | Resultado |
|---|---:|
| Tabelas criadas | 10 |
| Transações de demonstração | 5 |
| Pagamentos de demonstração | 3 |
| Views | 2 |
| Triggers | 5 |

## 2. Consultas SQL

Foram executados os scripts de Views, relatórios, consultas avançadas e análise
de desempenho:

- 03_views.sql: criação e consulta das duas views.
- 05_reports.sql: relatórios de despesas, orçamento, pagamentos e valores em aberto.
- 06_advanced_queries.sql: JOIN, GROUP BY, HAVING, subconsulta, CTE e Window Functions.
- 07_performance.sql: exemplos de EXPLAIN ANALYZE, índices e estatísticas do PostgreSQL.

## 3. Triggers e regras de negócio

Foram verificados os seguintes comportamentos:

- Inserção simulada de pagamento parcial atualizou o status da transação para PARCIAL.
- A tabela auditoria registrou a inserção do pagamento e a atualização da transação.
- ROLLBACK desfez a simulação e preservou os dados originais.
- Uma tentativa de pagamento superior ao valor da transação foi bloqueada pelo trigger.
- Os cinco triggers esperados foram encontrados no catálogo do banco.

## 4. Segurança e permissões

Foram criados os grupos fincontrol_leitura e fincontrol_operacao.

Os testes de privilégios confirmaram:

| Verificação | Resultado observado |
|---|---|
| Leitura pode consultar transações | TRUE |
| Leitura pode inserir transações | FALSE |
| Operação pode atualizar diretamente o status | FALSE |
| Operação pode inserir pagamentos | TRUE |

Os grupos são criados como NOLOGIN. Usuários individuais devem ser
provisionados pelo administrador e associados ao grupo apropriado.

## 5. Backup e restauração

Foi criado um backup em formato customizado com pg_dump e restaurado em um
banco separado chamado fincontrol_teste_restore.

A validação da cópia restaurada confirmou:

| Verificação | Resultado observado |
|---|---:|
| Tabelas | 10 |
| Transações | 5 |
| Pagamentos | 3 |
| Views | 2 |
| Triggers | 5 |

A restauração foi testada sem sobrescrever o banco original fincontrol.

## 6. API FastAPI

A API foi iniciada localmente com Uvicorn e conectada ao PostgreSQL usando
Psycopg.

| Endpoint | Resultado observado |
|---|---|
| GET / | API retornou status running |
| GET /health | API e banco retornaram ok |
| GET /departments | 4 departamentos retornados |
| GET /transactions | 5 transações retornadas |

## 7. Escopo dos testes

Estes resultados comprovam os comportamentos testados no ambiente local e no
conjunto de dados de demonstração. Não representam certificação de segurança,
teste de carga ou validação para uso em produção.
