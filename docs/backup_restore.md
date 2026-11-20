# Backup e recuperação — FinControl

Este guia usa PostgreSQL no Windows e os utilitários oficiais pg_dump,
pg_restore e psql. Ajuste usuário, host, porta e caminhos conforme a instalação.

## 1. Criar um backup

No PowerShell, a partir da pasta raiz do projeto:

~~~powershell
New-Item -ItemType Directory -Force .\backup | Out-Null

pg_dump -h localhost -p 5432 -U postgres -F c -b -v -f ".\backup\fincontrol.backup" fincontrol
~~~

O formato customizado (-F c) permite restaurar com pg_restore.
O PostgreSQL solicitará a senha do usuário.

## 2. Restaurar em um banco separado

Teste a restauração em outro banco, sem sobrescrever o original:

~~~powershell
createdb -h localhost -p 5432 -U postgres fincontrol_teste_restore

pg_restore -h localhost -p 5432 -U postgres -d fincontrol_teste_restore -v ".\backup\fincontrol.backup"
~~~

Se createdb não estiver disponível no terminal, crie o banco
fincontrol_teste_restore pelo DBeaver e execute somente o pg_restore.

## 3. Validar a restauração

Conecte-se ao banco restaurado e confira:

~~~sql
SELECT current_database();

SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public'
  AND table_type = 'BASE TABLE'
ORDER BY table_name;

SELECT COUNT(*) AS total_transacoes
FROM transacao;
~~~

Compare os resultados com o banco original.

## 4. Cuidados

- Faça backups antes de alterações estruturais importantes.
- Armazene cópias em local separado do computador principal.
- Não publique arquivos .backup, .dump ou dados financeiros no GitHub.
- Um backup só é confiável depois de testar a restauração.
- Defina a frequência de backup conforme a importância e frequência de alteração dos dados.
