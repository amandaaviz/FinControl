# FinControl

Sistema de gestão e análise financeira para uma empresa privada de médio porte.

> Projeto de portfólio com foco em modelagem relacional, PostgreSQL, SQL, integridade dos dados e administração de banco de dados.

## Objetivo

O FinControl organiza departamentos, centros de custo, categorias, orçamentos, contas financeiras e movimentações. A primeira versão é um MVP educacional com dados fictícios.

## Tecnologias

- PostgreSQL 16+
- SQL
- Python 3.11+
- FastAPI
- psycopg (driver PostgreSQL)
- DBeaver (administração visual)

## Estrutura

```text
FinControl/
├── backend/
│   ├── app/
│   │   └── main.py
│   └── requirements.txt
├── database/
│   ├── sql/
│   │   ├── 01_create_database.sql
│   │   ├── 02_schema.sql
│   │   ├── 03_views.sql
│   │   ├── 04_seed.sql
│   │   └── 05_reports.sql
│   └── diagrams/
│       └── der.md
├── docs/
│   ├── data_dictionary.md
│   └── decisions.md
├── .env.example
├── .gitignore
└── README.md
```

## Pré-requisitos

1. Instale o [PostgreSQL](https://www.postgresql.org/download/).
2. Instale o [DBeaver Community](https://dbeaver.io/download/).
3. Instale o [Python](https://www.python.org/downloads/) 3.11 ou superior.
4. (Opcional) Instale o [Git](https://git-scm.com/downloads).

## Como criar o banco

No DBeaver, conecte-se ao servidor PostgreSQL usando o usuário `postgres`.

1. Abra `database/sql/01_create_database.sql` e execute o comando para criar `fincontrol`.
2. Abra uma conexão com o banco `fincontrol`.
3. Execute `02_schema.sql`.
4. Execute `03_views.sql`.
5. Execute `04_seed.sql`.
6. Execute `05_reports.sql` para consultar exemplos de relatórios.

**Importante:** os scripts 02 a 04 devem ser executados no banco `fincontrol`. O script de criação do banco deve ser executado conectado a outro banco, normalmente `postgres`.

## Como executar a API

Entre na pasta `backend`:

```bash
python -m venv .venv
```

Windows PowerShell:

```powershell
.\.venv\Scripts\Activate.ps1
```

Instale as dependências:

```bash
pip install -r requirements.txt
```

Copie `.env.example` para `.env` e ajuste a conexão:

```env
DATABASE_URL=postgresql://postgres:SUA_SENHA@localhost:5432/fincontrol
```

Inicie:

```bash
uvicorn app.main:app --reload
```

Acesse:
- API: http://127.0.0.1:8000
- Documentação interativa: http://127.0.0.1:8000/docs
- Verificação: http://127.0.0.1:8000/health

Não publique o arquivo `.env` nem senhas no GitHub.

## Modelo de dados

O diagrama inicial está em `database/diagrams/der.md`. O dicionário de dados está em `docs/data_dictionary.md`.

## Consultas demonstrativas

O arquivo `database/sql/05_reports.sql` contém exemplos para:
- total de despesas por departamento;
- execução orçamentária por centro de custo;
- pagamentos por período;
- transações pendentes e vencidas.

## Escopo e limitações da versão inicial

Esta é uma base de projeto para estudo e evolução. Antes de uso real, ainda será necessário implementar autenticação e autorização completas, trilha de auditoria automática, validações transacionais de pagamentos, testes automatizados, migrações, política de backup e revisão de segurança.

Os dados de `04_seed.sql` são inteiramente fictícios. Não utilize informações financeiras reais.

## Próximas evoluções sugeridas

1. Testes automatizados com banco de teste.
2. Autenticação e controle de acesso por perfil.
3. Regras transacionais para pagamentos parciais.
4. Auditoria automática via triggers.
5. Índices orientados ao padrão de consultas.
6. Dashboard com Streamlit.
7. Pipeline de integração contínua.
