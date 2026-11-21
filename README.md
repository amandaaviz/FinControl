# FinControl

Sistema de gestão e análise financeira para uma empresa privada de médio porte.

> Projeto de portfólio com foco em modelagem relacional, PostgreSQL, SQL, integridade dos dados, segurança e administração de banco de dados.

## Objetivo

O FinControl organiza departamentos, centros de custo, categorias, orçamentos,
contas financeiras e movimentações. A versão de portfólio utiliza dados
inteiramente fictícios e tem finalidade educacional.

## Tecnologias

- PostgreSQL
- SQL
- Python 3.11+
- FastAPI
- Psycopg 3
- DBeaver
- Git e GitHub

## Estrutura do projeto

~~~text
FinControl/
├── backend/
│   ├── app/
│   │   ├── __init__.py
│   │   └── main.py
│   └── requirements.txt
├── database/
│   ├── diagrams/
│   │   └── der.md
│   └── sql/
│       ├── 01_create_database.sql
│       ├── 02_schema.sql
│       ├── 03_views.sql
│       ├── 04_seed.sql
│       ├── 05_reports.sql
│       ├── 06_advanced_queries.sql
│       ├── 07_performance.sql
│       ├── 08_triggers.sql
│       ├── 09_security.sql
│       └── 10_transactions.sql
├── docs/
│   ├── backup_restore.md
│   ├── data_dictionary.md
│   ├── decisions.md
│   └── validation.md
├── .env.example
├── .gitignore
└── README.md
~~~

## Pré-requisitos

1. PostgreSQL instalado e em execução.
2. DBeaver Community ou outro cliente SQL.
3. Python 3.11 ou superior.
4. Git para versionamento.

## Como criar o banco

No DBeaver, conecte-se ao servidor PostgreSQL usando um usuário administrador.

1. Abra database/sql/01_create_database.sql conectado a outro banco, normalmente postgres, e execute para criar fincontrol.
2. Abra uma conexão com o banco fincontrol.
3. Execute 02_schema.sql para criar tabelas, constraints e índices iniciais.
4. Execute 04_seed.sql para inserir os dados fictícios. Execute apenas uma vez em um banco recém-criado.
5. Execute 03_views.sql para criar as views.
6. Execute 05_reports.sql para consultar relatórios demonstrativos.
7. Execute 06_advanced_queries.sql para exemplos de SQL avançado.
8. Execute 07_performance.sql para analisar planos e estatísticas.
9. Execute 08_triggers.sql para instalar validação de pagamentos, atualização de status e auditoria automática.
10. Execute 09_security.sql conectado como administrador para criar os grupos de permissões.
11. Execute 10_transactions.sql para demonstrar transações; o primeiro exemplo termina com ROLLBACK.

Os scripts de 02 a 10 devem ser executados no banco fincontrol. Os scripts de
trigger e permissões são evoluções do projeto e devem ser aplicados depois de
criar o schema e carregar os dados de demonstração.

**Atenção:** não execute 04_seed.sql novamente em um banco que já contém os
dados de demonstração, pois o script não foi projetado para carga repetida.

## Funcionalidades de banco de dados

- Modelo relacional com 10 tabelas.
- Chaves primárias, estrangeiras, constraints e índices iniciais.
- Separação entre transações e pagamentos, permitindo representar liquidações parciais.
- Views de despesas pagas por departamento e execução orçamentária.
- Consultas com JOIN, agregações, subconsultas, CTEs e Window Functions.
- Triggers para impedir pagamentos acima do valor da transação, recalcular status e registrar auditoria.
- Grupos de permissões para consulta e operação.
- Exemplos de transações SQL e procedimentos de backup/recuperação.

## Como executar a API

A partir da pasta raiz do projeto, abra o terminal.

Git Bash:

~~~bash
cd backend
python -m venv .venv
source .venv/Scripts/activate
pip install -r requirements.txt
cp ../.env.example .env
~~~

PowerShell:

~~~powershell
cd backend
python -m venv .venv
.\.venv\Scripts\Activate.ps1
pip install -r requirements.txt
Copy-Item ..\.env.example .env
~~~

Edite backend/.env e informe a senha do PostgreSQL na variável DATABASE_URL:

~~~env
DATABASE_URL=postgresql://postgres:SUA_SENHA@localhost:5432/fincontrol
~~~

Se a senha contiver caracteres reservados em URLs (por exemplo, @), codifique
esses caracteres na URL. Nunca publique o arquivo .env nem compartilhe a senha.

Inicie a API, ainda dentro da pasta backend:

~~~bash
uvicorn app.main:app --reload
~~~

Acesse:

- API: http://127.0.0.1:8000
- Documentação interativa: http://127.0.0.1:8000/docs
- Verificação da conexão: http://127.0.0.1:8000/health

Endpoints iniciais:

- GET /: identificação da API.
- GET /health: verifica a conexão com o banco.
- GET /departments: lista departamentos.
- GET /transactions: lista transações; aceita o parâmetro limit entre 1 e 200.

## Validação realizada

Os testes funcionais da versão atual foram executados em ambiente local com
dados fictícios. Os resultados e procedimentos estão registrados em
docs/validation.md.

## Backup e recuperação

Consulte docs/backup_restore.md para criar um backup com pg_dump e testar
a restauração com pg_restore no Windows.

## Documentação

- Diagrama entidade-relacionamento: database/diagrams/der.md
- Dicionário de dados: docs/data_dictionary.md
- Decisões de modelagem: docs/decisions.md
- Registro de validação: docs/validation.md
- Backup e recuperação: docs/backup_restore.md

## Limitações conhecidas

- A API é inicial e somente leitura; ainda não possui autenticação ou autorização no nível da aplicação.
- A autorização do banco é demonstrada por grupos de permissões; usuários reais devem ser provisionados pelo administrador.
- Os testes foram realizados em ambiente local de desenvolvimento. Antes de qualquer uso real, os scripts e permissões devem passar por revisão de segurança e testes adicionais.
- Os índices iniciais são hipóteses que devem ser avaliadas com planos de execução e carga representativa.
- O projeto não deve ser utilizado para registrar dados financeiros reais.

## Segurança

Não publique o arquivo .env, senhas, backups ou dados financeiros reais.
O arquivo .env.example contém apenas um valor ilustrativo e deve ser ajustado
em sua cópia local.

## Dados de demonstração

Os registros de 04_seed.sql são fictícios e servem exclusivamente para
desenvolvimento, testes e demonstração do projeto.
