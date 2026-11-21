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

Se pg_dump não for reconhecido no terminal, use o executável da pasta bin
da versão instalada, por exemplo:

~~~powershell
& "C:\Program Files\PostgreSQL\19\bin\pg_dump.exe" -h localhost -p 5432 -U postgres -F c -b -v -f ".\backup\fincontrol.backup" fincontrol
~~~

## 2. Restaurar em um banco separado no mesmo servidor

Crie um banco de teste vazio, sem sobrescrever o original:

~~~powershell
createdb -h localhost -p 5432 -U postgres fincontrol_teste_restore

pg_restore -h localhost -p 5432 -U postgres -d fincontrol_teste_restore -v ".\backup\fincontrol.backup"
~~~

Se createdb não estiver disponível no terminal, crie o banco
fincontrol_teste_restore pelo DBeaver e execute somente o pg_restore.

No mesmo servidor, os grupos fincontrol_leitura e fincontrol_operacao já
existem se o script 09_security.sql tiver sido executado anteriormente.

## 3. Restaurar em outro servidor PostgreSQL

Um backup de banco feito com pg_dump não inclui, por padrão, a definição
global dos papéis do servidor. Se o servidor de destino ainda não tiver os
grupos usados pelo projeto, há duas opções:

- Criar os grupos no banco de destino executando database/sql/09_security.sql
  como administrador antes de restaurar os privilégios do arquivo.
- Restaurar estrutura e dados sem proprietário nem ACLs, usando --no-owner
  e --no-acl; depois executar 09_security.sql para recriar as permissões.

Exemplo de restauração sem proprietário e sem ACLs:

~~~powershell
pg_restore -h localhost -p 5432 -U postgres --no-owner --no-acl -d fincontrol_teste_restore -v ".\backup\fincontrol.backup"
~~~

Para migrações entre servidores, revise também extensões, versão do PostgreSQL,
proprietários e permissões específicas do ambiente.

## 4. Validar a restauração

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

Compare os resultados com o banco original. Para uma validação mais completa,
consulte docs/validation.md.

## 5. Cuidados

- Faça backups antes de alterações estruturais importantes.
- Armazene cópias em local separado do computador principal.
- Não publique arquivos .backup, .dump ou dados financeiros no GitHub.
- Um backup só é confiável depois de testar sua restauração.
- Defina a frequência de backup conforme a importância e frequência de alteração dos dados.
