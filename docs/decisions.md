# Decisões de modelagem — FinControl

## 1. PostgreSQL

O PostgreSQL foi escolhido por oferecer integridade relacional, tipos robustos,
índices, views, CTEs, JSONB, triggers, controle de acesso e recursos transacionais.
O banco é a parte central do projeto; a API FastAPI funciona como uma camada
de consulta complementar.

## 2. Valores financeiros

As colunas monetárias utilizam `NUMERIC(15,2)`, evitando a imprecisão dos tipos
numéricos aproximados, como `REAL` e `DOUBLE PRECISION`.

## 3. Pagamentos separados de transações

Uma transação pode receber vários pagamentos. Por isso, `pagamento` é uma
entidade própria, relacionada a `transacao` em uma relação um-para-muitos.
Essa separação permite registrar liquidações parciais e consultar o valor
original, o total pago e o saldo em aberto.

## 4. Integridade entre empresas

As tabelas financeiras carregam `id_empresa` e utilizam chaves estrangeiras
compostas quando necessário. As consultas e views também utilizam a
identificação da empresa nos relacionamentos, evitando cruzar registros de
organizações diferentes.

## 5. Auditoria

A tabela `auditoria` utiliza `JSONB` para armazenar os estados anteriores e
posteriores dos registros. O script `08_triggers.sql` cria triggers para
registrar operações em `transacao` e `pagamento`.

A identificação do usuário pode ser informada pela variável de sessão
`app.user_id`. A aplicação deverá defini-la dentro da transação correspondente,
por exemplo com `SET LOCAL app.user_id = 'ID_DO_USUARIO'`. Quando essa informação
não estiver definida, `id_usuario` na auditoria pode permanecer nulo para
eventos originados em pagamentos.

## 6. Regras de pagamentos

O script `08_triggers.sql` impede que a soma dos pagamentos ultrapasse o valor
da transação, recalcula o status conforme o total pago e impede reduzir o
valor original abaixo do total já liquidado. Essas regras são implementadas
por triggers, e não apenas por constraints declarativas.

## 7. Segurança e permissões

O script `09_security.sql` cria dois grupos sem login próprio:
`fincontrol_leitura` e `fincontrol_operacao`. Os usuários individuais devem ser
criados pelo administrador e associados ao grupo correspondente. As permissões
são uma demonstração inicial de menor privilégio e precisam ser revistas antes
de qualquer uso em produção.

A API atual não implementa autenticação ou autorização por usuário. Os papéis
do PostgreSQL e os endpoints da API são mecanismos separados.

## 8. Índices e desempenho

O schema define índices iniciais para datas, status, relacionamentos e filtros
recorrentes. Eles são hipóteses de trabalho: a escolha final depende do perfil
de consultas, volume de dados, frequência de escrita e leitura dos planos de
execução com `EXPLAIN (ANALYZE, BUFFERS)`.

## 9. Views e critérios financeiros

`vw_despesas_por_departamento` soma os valores efetivamente pagos de transações
classificadas como `DESPESA` e agrupa pelo mês de pagamento.

`vw_execucao_orcamentaria` compara o orçamento com o valor total das despesas
registradas por competência, excluindo transações canceladas. Portanto,
as duas views respondem a perguntas diferentes: pagamentos realizados e
despesas lançadas em relação ao orçamento.

## 10. Limitações conhecidas

- A validação de CNPJ confere o formato de 14 dígitos, mas não os dígitos verificadores.
- Não existe constraint ou trigger que obrigue `categoria.tipo` e `transacao.tipo` a coincidirem.
- A tabela `orcamento` permite categorias de receita, mas a view `vw_execucao_orcamentaria` calcula apenas despesas.
- Não existe regra geral que valide a ordem entre `data_competencia` e `data_vencimento`.
- `saldo_inicial` não é um saldo corrente e não é atualizado automaticamente por pagamentos.
- O campo `senha_hash` existe no modelo, mas a API ainda não implementa cadastro, login, hash ou autenticação.
- A auditoria identifica o usuário em pagamentos somente quando `app.user_id` é definido pela aplicação.
- Os scripts e permissões são material de portfólio e precisam de revisão e testes adicionais antes de qualquer uso real.

## 11. Dados de demonstração

Os registros inseridos por `04_seed.sql` são fictícios e destinam-se exclusivamente
a testes e demonstração. O script de seed deve ser executado apenas uma vez em
um banco recém-criado.
