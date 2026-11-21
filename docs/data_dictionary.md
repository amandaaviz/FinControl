# Dicionário de dados — FinControl

Este documento descreve as tabelas, colunas, tipos, nulabilidade e principais
regras definidas em database/sql/02_schema.sql. A estrutura possui dez tabelas.

## Convenções

- PK: chave primária.
- FK: chave estrangeira.
- NN: coluna obrigatória (NOT NULL).
- NULL: coluna que pode ficar sem valor.
- Identity: valor gerado automaticamente pelo PostgreSQL.
- Os valores monetários usam NUMERIC(15,2), evitando tipos numéricos aproximados.

## 1. empresa

Cadastro da organização proprietária dos dados.

| Coluna | Tipo | Regra | Descrição |
|---|---|---|---|
| id_empresa | BIGINT | PK, Identity, NN | Identificador da empresa. |
| razao_social | VARCHAR(150) | NN | Razão social. |
| nome_fantasia | VARCHAR(100) | NN | Nome fantasia. |
| cnpj | CHAR(14) | NN, UNIQUE | CNPJ armazenado com 14 dígitos, sem pontuação. |
| data_cadastro | TIMESTAMPTZ | NN, DEFAULT CURRENT_TIMESTAMP | Data e hora de cadastro. |

**Restrições:** o CNPJ deve conter exatamente 14 caracteres numéricos. A regra
valida o formato, mas não calcula os dígitos verificadores oficiais do CNPJ.

## 2. departamento

Unidades organizacionais pertencentes a uma empresa.

| Coluna | Tipo | Regra | Descrição |
|---|---|---|---|
| id_departamento | BIGINT | PK, Identity, NN | Identificador do departamento. |
| id_empresa | BIGINT | FK, NN | Empresa à qual o departamento pertence. |
| nome | VARCHAR(100) | NN | Nome do departamento. |

**Restrições:** o nome é único dentro da empresa. Existe também uma chave
UNIQUE composta por (id_empresa, id_departamento), utilizada por FKs compostas.

## 3. centro_custo

Agrupador gerencial vinculado a um departamento.

| Coluna | Tipo | Regra | Descrição |
|---|---|---|---|
| id_centro_custo | BIGINT | PK, Identity, NN | Identificador do centro de custo. |
| id_empresa | BIGINT | FK composta, NN | Empresa proprietária do centro de custo. |
| id_departamento | BIGINT | FK composta, NN | Departamento ao qual está vinculado. |
| codigo | VARCHAR(20) | NN | Código do centro de custo. |
| nome | VARCHAR(100) | NN | Nome do centro de custo. |
| descricao | TEXT | NULL | Descrição complementar. |

**Restrições:** a combinação empresa + código é única. A FK composta
(id_empresa, id_departamento) impede associar o centro de custo a um
departamento de outra empresa.

## 4. usuario

Usuários cadastrados para operar ou consultar o sistema.

| Coluna | Tipo | Regra | Descrição |
|---|---|---|---|
| id_usuario | BIGINT | PK, Identity, NN | Identificador do usuário. |
| id_empresa | BIGINT | FK, NN | Empresa à qual o usuário pertence. |
| id_departamento | BIGINT | FK composta, NULL | Departamento do usuário; pode não ser informado. |
| nome | VARCHAR(120) | NN | Nome do usuário. |
| email | VARCHAR(150) | NN | E-mail, único por empresa. |
| senha_hash | TEXT | NN | Campo destinado ao hash da senha; não deve armazenar senha em texto puro. |
| perfil | VARCHAR(20) | NN | Perfil funcional do usuário. |
| ativo | BOOLEAN | NN, DEFAULT TRUE | Indica se o usuário está ativo. |

**Restrições:** perfil aceita ADMIN, FINANCEIRO ou CONSULTA. A combinação
(id_empresa, email) é única. Existe também UNIQUE (id_empresa, id_usuario)
para suportar relacionamentos compostos.

**Observação:** a API atual é somente de leitura e ainda não implementa
autenticação. O campo senha_hash é parte do modelo de dados, não evidência de
um fluxo de autenticação concluído.

## 5. categoria

Classificação utilizada para distinguir receitas e despesas.

| Coluna | Tipo | Regra | Descrição |
|---|---|---|---|
| id_categoria | BIGINT | PK, Identity, NN | Identificador da categoria. |
| id_empresa | BIGINT | FK, NN | Empresa proprietária da categoria. |
| nome | VARCHAR(100) | NN | Nome da categoria. |
| tipo | VARCHAR(10) | NN | Tipo da categoria: RECEITA ou DESPESA. |
| ativa | BOOLEAN | NN, DEFAULT TRUE | Indica se a categoria está ativa. |

**Restrições:** tipo aceita RECEITA ou DESPESA. A combinação empresa + nome +
tipo é única.

## 6. conta_financeira

Contas bancárias ou financeiras utilizadas nos pagamentos.

| Coluna | Tipo | Regra | Descrição |
|---|---|---|---|
| id_conta | BIGINT | PK, Identity, NN | Identificador da conta. |
| id_empresa | BIGINT | FK, NN | Empresa proprietária da conta. |
| nome | VARCHAR(100) | NN | Nome interno da conta. |
| banco | VARCHAR(100) | NULL | Instituição financeira. |
| agencia | VARCHAR(20) | NULL | Agência bancária. |
| numero_conta | VARCHAR(30) | NULL | Número da conta. |
| saldo_inicial | NUMERIC(15,2) | NN, DEFAULT 0 | Saldo inicial informado para a conta. |
| ativa | BOOLEAN | NN, DEFAULT TRUE | Indica se a conta está ativa. |

**Restrições:** saldo_inicial deve ser maior ou igual a zero. O nome da conta
é único dentro da empresa.

## 7. orcamento

Valores planejados por empresa, centro de custo, categoria e período.

| Coluna | Tipo | Regra | Descrição |
|---|---|---|---|
| id_orcamento | BIGINT | PK, Identity, NN | Identificador do orçamento. |
| id_empresa | BIGINT | FK, NN | Empresa proprietária do orçamento. |
| id_centro_custo | BIGINT | FK composta, NN | Centro de custo contemplado. |
| id_categoria | BIGINT | FK composta, NN | Categoria contemplada. |
| ano | SMALLINT | NN | Ano de referência. |
| mes | SMALLINT | NN | Mês de referência, de 1 a 12. |
| valor_previsto | NUMERIC(15,2) | NN | Valor planejado para o período. |

**Restrições:** ano entre 2000 e 2200; mês entre 1 e 12; valor_previsto
maior ou igual a zero. A combinação centro de custo + categoria + ano + mês
é única.

## 8. transacao

Lançamentos financeiros de receita ou despesa.

| Coluna | Tipo | Regra | Descrição |
|---|---|---|---|
| id_transacao | BIGINT | PK, Identity, NN | Identificador da transação. |
| id_empresa | BIGINT | FK, NN | Empresa proprietária da transação. |
| id_centro_custo | BIGINT | FK composta, NN | Centro de custo associado. |
| id_categoria | BIGINT | FK composta, NN | Categoria associada. |
| id_usuario | BIGINT | FK composta, NN | Usuário que registrou a transação. |
| descricao | VARCHAR(200) | NN | Descrição do lançamento. |
| tipo | VARCHAR(10) | NN | RECEITA ou DESPESA. |
| valor | NUMERIC(15,2) | NN | Valor total da transação, maior que zero. |
| data_competencia | DATE | NN | Data de competência. |
| data_vencimento | DATE | NULL | Data prevista para vencimento. |
| status | VARCHAR(15) | NN, DEFAULT PENDENTE | Situação da transação. |
| criada_em | TIMESTAMPTZ | NN, DEFAULT CURRENT_TIMESTAMP | Data e hora de criação. |

**Restrições:** tipo aceita RECEITA ou DESPESA; status aceita PENDENTE, PARCIAL,
PAGO ou CANCELADO; valor deve ser maior que zero. As FKs compostas mantêm
empresa, centro de custo, categoria e usuário no mesmo contexto empresarial.

## 9. pagamento

Liquidações totais ou parciais de uma transação.

| Coluna | Tipo | Regra | Descrição |
|---|---|---|---|
| id_pagamento | BIGINT | PK, Identity, NN | Identificador do pagamento. |
| id_empresa | BIGINT | FK, NN | Empresa proprietária do pagamento. |
| id_transacao | BIGINT | FK composta, NN | Transação liquidada. |
| id_conta | BIGINT | FK composta, NN | Conta financeira utilizada. |
| valor_pago | NUMERIC(15,2) | NN | Valor desta liquidação, maior que zero. |
| data_pagamento | DATE | NN | Data em que o pagamento ocorreu. |
| criado_em | TIMESTAMPTZ | NN, DEFAULT CURRENT_TIMESTAMP | Data e hora de registro do pagamento. |

**Restrições:** valor_pago deve ser maior que zero. As FKs compostas impedem
vincular o pagamento a uma transação ou conta pertencente a outra empresa.
A regra que impede a soma dos pagamentos de ultrapassar o valor da transação
é implementada pelo trigger em database/sql/08_triggers.sql.

## 10. auditoria

Histórico de operações realizadas sobre registros acompanhados pelos triggers.

| Coluna | Tipo | Regra | Descrição |
|---|---|---|---|
| id_auditoria | BIGINT | PK, Identity, NN | Identificador do evento de auditoria. |
| id_empresa | BIGINT | FK, NN | Empresa relacionada ao evento. |
| id_usuario | BIGINT | FK composta, NULL | Usuário responsável, quando identificado. |
| tabela_afetada | VARCHAR(100) | NN | Tabela em que ocorreu a operação. |
| operacao | VARCHAR(10) | NN | INSERT, UPDATE ou DELETE. |
| registro_id | BIGINT | NULL | Identificador do registro afetado. |
| dados_anteriores | JSONB | NULL | Estado anterior do registro, quando aplicável. |
| dados_novos | JSONB | NULL | Novo estado do registro, quando aplicável. |
| data_operacao | TIMESTAMPTZ | NN, DEFAULT CURRENT_TIMESTAMP | Data e hora do evento. |

**Restrições:** operacao aceita INSERT, UPDATE ou DELETE. O trigger atual registra
alterações em transacao e pagamento. A identificação do usuário em operações
de pagamento depende da configuração da variável de sessão app.user_id.

## Views

| View | Finalidade |
|---|---|
| vw_despesas_por_departamento | Soma pagamentos de transações do tipo DESPESA por departamento e mês de pagamento. Considera valores pagos, não o valor integral originalmente lançado. |
| vw_execucao_orcamentaria | Compara o orçamento previsto com o valor integral das despesas registradas por competência, excluindo transações canceladas. Não representa somente o total já pago. |

## Índices definidos no schema

| Índice | Colunas | Objetivo inicial |
|---|---|---|
| idx_centro_departamento | centro_custo(id_departamento) | Apoiar consultas e relacionamentos por departamento. |
| idx_usuario_departamento | usuario(id_departamento) | Apoiar filtros por departamento do usuário. |
| idx_orcamento_periodo | orcamento(ano, mes) | Apoiar filtros por período orçamentário. |
| idx_transacao_competencia | transacao(data_competencia) | Apoiar filtros por data de competência. |
| idx_transacao_status_vencimento | transacao(status, data_vencimento) | Apoiar buscas por status e vencimento. |
| idx_transacao_centro_categoria | transacao(id_centro_custo, id_categoria) | Apoiar consultas por centro de custo e categoria. |
| idx_pagamento_data | pagamento(data_pagamento) | Apoiar filtros por data de pagamento. |
| idx_auditoria_data | auditoria(data_operacao) | Apoiar consultas do histórico por data. |

Os índices são uma configuração inicial. A utilidade de cada um deve ser
avaliada com consultas representativas, EXPLAIN (ANALYZE, BUFFERS) e estatísticas
de uso. Chaves primárias e constraints UNIQUE também criam índices próprios
no PostgreSQL.

## Regras e limitações conhecidas

- O schema verifica que CNPJ tenha 14 dígitos, mas não valida seus dígitos verificadores.
- O schema não impõe uma regra declarativa para que categoria.tipo seja igual a transacao.tipo.
- O schema não define uma regra geral para data_vencimento ser posterior ou igual à data_competencia.
- O saldo de uma conta não é atualizado automaticamente a cada pagamento; saldo_inicial é apenas o valor de abertura cadastrado.
- A API ainda é somente de leitura e não implementa autenticação.
- Os scripts SQL e triggers são demonstrativos e devem ser revistos antes de qualquer uso real.

## Convenções de nomenclatura

- Tabelas e colunas em português, em letras minúsculas e snake_case.
- Chaves primárias no formato id_nome.
- Constraints nomeadas para facilitar manutenção e diagnóstico.
