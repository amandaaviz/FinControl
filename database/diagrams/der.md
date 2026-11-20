# DER — FinControl (modelo inicial)

```mermaid
erDiagram
    EMPRESA ||--o{ DEPARTAMENTO : possui
    EMPRESA ||--o{ USUARIO : cadastra
    EMPRESA ||--o{ CATEGORIA : define
    EMPRESA ||--o{ CONTA_FINANCEIRA : possui
    DEPARTAMENTO ||--o{ CENTRO_CUSTO : organiza
    DEPARTAMENTO o|--o{ USUARIO : aloca
    CENTRO_CUSTO ||--o{ ORCAMENTO : recebe
    CATEGORIA ||--o{ ORCAMENTO : classifica
    CENTRO_CUSTO ||--o{ TRANSACAO : recebe
    CATEGORIA ||--o{ TRANSACAO : classifica
    USUARIO ||--o{ TRANSACAO : registra
    TRANSACAO ||--o{ PAGAMENTO : liquida
    CONTA_FINANCEIRA ||--o{ PAGAMENTO : origina
    USUARIO o|--o{ AUDITORIA : executa
    EMPRESA ||--o{ AUDITORIA : mantém
```

## Observações

- As chaves estrangeiras compostas com `id_empresa` impedem relacionamentos entre registros de empresas diferentes em entidades financeiras.
- Uma transação pode ter vários pagamentos, permitindo representar liquidações parciais.
- O valor total pago e o status da transação ainda precisam de regra transacional/trigger na próxima evolução.
- A auditoria está modelada, mas a gravação automática ainda não foi implementada.
