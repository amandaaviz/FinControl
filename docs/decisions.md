# Decisões de modelagem — FinControl

## 1. PostgreSQL

Escolhido por oferecer integridade relacional, tipos robustos, índices, views,
CTEs, JSONB, triggers, controle de acesso e recursos transacionais.

## 2. Valores financeiros

Foi utilizado \`NUMERIC(15,2)\` para evitar imprecisão típica de tipos aproximados
como \`REAL\` e \`DOUBLE PRECISION\`.

## 3. Pagamentos separados de transações

Uma transação pode ser paga em parcelas. Por isso, \`pagamento\` é uma entidade
própria, relacionada a \`transacao\` em uma relação um-para-muitos.

## 4. Integridade entre empresas

As tabelas financeiras carregam \`id_empresa\` e utilizam chaves estrangeiras
compostas quando necessário. As consultas e views também usam a identificação
da empresa nos relacionamentos, evitando cruzar registros de organizações
diferentes.

## 5. Auditoria

A tabela \`auditoria\` utiliza \`JSONB\` para armazenar os estados anteriores e
posteriores dos registros. O script \`08_triggers.sql\` cria triggers para
registrar operações em \`transacao\` e \`pagamento\`.

A identificação do usuário que realizou a alteração pode ser informada pela
variável de sessão \`app.user_id\`. A aplicação deve defini-la com
\`SET LOCAL app.user_id = 'ID_DO_USUARIO'\` dentro da transação correspondente.
Quando essa informação não estiver definida, o registro de auditoria mantém
\`id_usuario\` como nulo.

## 6. Regras de pagamentos

O script \`08_triggers.sql\` impede pagamentos que ultrapassem o valor da
transação, recalcula o status conforme o total pago e impede reduzir o valor
original abaixo do total já liquidado.

## 7. Segurança

O script \`09_security.sql\` cria dois grupos sem login próprio:
\`fincontrol_leitura\` e \`fincontrol_operacao\`. Usuários individuais devem ser
criados pelo administrador e associados ao grupo correspondente. As permissões
são exemplos iniciais e devem ser revisadas antes de qualquer uso em produção.

## 8. Limitações conhecidas

- A API é inicial e somente leitura; ainda não implementa autenticação ou
  autorização no nível da aplicação.
- O banco utiliza papéis de exemplo; ainda é necessário provisionar usuários
  reais e validar as permissões no ambiente local.
- O contexto \`app.user_id\` precisa ser configurado pela aplicação dentro de
  cada transação para identificar o usuário na auditoria.
- Os índices iniciais são hipóteses e devem ser avaliados com
  \`EXPLAIN (ANALYZE, BUFFERS)\` usando consultas e volume representativos.
- Os scripts de trigger e segurança devem ser executados e testados em um banco
  de desenvolvimento antes de qualquer utilização real.
- O projeto é educacional e não deve armazenar informações financeiras reais.
