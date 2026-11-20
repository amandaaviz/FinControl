# Decisões de modelagem

## 1. PostgreSQL

Escolhido por oferecer integridade relacional, tipos robustos, índices, views, CTEs, JSONB e recursos transacionais.

## 2. Valores financeiros

Foi utilizado `NUMERIC(15,2)` para evitar imprecisão típica de tipos aproximados como `REAL` e `DOUBLE PRECISION`.

## 3. Pagamentos separados de transações

Uma transação pode ser paga em parcelas. Por isso, `pagamento` é uma entidade própria, relacionada a `transacao` em uma relação um-para-muitos.

## 4. Integridade entre empresas

As tabelas financeiras carregam `id_empresa` e utilizam chaves estrangeiras compostas quando necessário. Isso evita associar, por engano, um centro de custo de uma empresa a uma categoria de outra.

## 5. Auditoria

A tabela `auditoria` usa `JSONB` para armazenar snapshots anteriores e posteriores. A automação via trigger e a definição do usuário responsável serão implementadas em uma etapa posterior.

## 6. Limitações conhecidas

- O banco ainda não impede, sozinho, que a soma dos pagamentos ultrapasse o valor da transação. Isso exige regra transacional, trigger ou procedimento controlado.
- O status da transação não é recalculado automaticamente após pagamentos.
- A API inicial é somente leitura e não implementa autenticação.
- Os índices são uma primeira hipótese e devem ser avaliados com `EXPLAIN (ANALYZE, BUFFERS)` usando consultas representativas.
