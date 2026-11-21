-- Dados inteiramente fictícios para desenvolvimento e demonstração.
-- Execute apenas uma vez em um banco recém-criado.

INSERT INTO empresa (razao_social, nome_fantasia, cnpj)
VALUES ('Horizonte Soluções Empresariais Ltda.', 'Horizonte', '12345678000195');

INSERT INTO departamento (id_empresa, nome)
VALUES
(1, 'Administrativo'),
(1, 'Comercial'),
(1, 'Tecnologia'),
(1, 'Operações');

INSERT INTO centro_custo (id_empresa, id_departamento, codigo, nome, descricao)
VALUES
(1, 1, 'ADM-001', 'Administração Geral', 'Despesas administrativas'),
(1, 2, 'COM-001', 'Vendas', 'Custos da área comercial'),
(1, 3, 'TI-001', 'Infraestrutura de TI', 'Infraestrutura e serviços de tecnologia'),
(1, 4, 'OPE-001', 'Operação', 'Custos operacionais');

-- Hashes fictícios de demonstração. Não são credenciais utilizáveis.
INSERT INTO usuario (id_empresa, id_departamento, nome, email, senha_hash, perfil)
VALUES
(1, 1, 'Usuário Administrador Demo', 'admin.demo@fincontrol.local', 'HASH_DEMO_NAO_UTILIZAVEL', 'ADMIN'),
(1, 1, 'Analista Financeiro Demo', 'financeiro.demo@fincontrol.local', 'HASH_DEMO_NAO_UTILIZAVEL', 'FINANCEIRO'),
(1, 3, 'Consulta Demo', 'consulta.demo@fincontrol.local', 'HASH_DEMO_NAO_UTILIZAVEL', 'CONSULTA');

INSERT INTO categoria (id_empresa, nome, tipo)
VALUES
(1, 'Venda de produtos', 'RECEITA'),
(1, 'Serviços prestados', 'RECEITA'),
(1, 'Salários', 'DESPESA'),
(1, 'Infraestrutura', 'DESPESA'),
(1, 'Marketing', 'DESPESA'),
(1, 'Materiais de escritório', 'DESPESA');

INSERT INTO conta_financeira (id_empresa, nome, banco, agencia, numero_conta, saldo_inicial)
VALUES
(1, 'Conta principal', 'Banco Exemplo', '0001', '12345-6', 50000.00),
(1, 'Conta operacional', 'Banco Exemplo', '0001', '98765-4', 15000.00);

INSERT INTO orcamento (id_empresa, id_centro_custo, id_categoria, ano, mes, valor_previsto)
VALUES
(1, 1, 6, 2026, 11, 2500.00),
(1, 2, 5, 2026, 11, 8000.00),
(1, 3, 4, 2026, 11, 12000.00),
(1, 4, 3, 2026, 11, 30000.00);

INSERT INTO transacao
(id_empresa, id_centro_custo, id_categoria, id_usuario, descricao, tipo, valor,
 data_competencia, data_vencimento, status)
VALUES
(1, 1, 6, 2, 'Compra de materiais de escritório', 'DESPESA', 1800.00, '2026-11-05', '2026-11-20', 'PAGO'),
(1, 2, 5, 2, 'Campanha de marketing digital', 'DESPESA', 6500.00, '2026-11-08', '2026-11-25', 'PENDENTE'),
(1, 3, 4, 2, 'Licenças e infraestrutura de tecnologia', 'DESPESA', 10000.00, '2026-11-10', '2026-11-28', 'PARCIAL'),
(1, 4, 3, 2, 'Folha de pagamento operacional', 'DESPESA', 28000.00, '2026-11-01', '2026-11-30', 'PENDENTE'),
(1, 2, 1, 2, 'Receita de vendas do período', 'RECEITA', 42000.00, '2026-11-12', NULL, 'PAGO');

INSERT INTO pagamento (id_empresa, id_transacao, id_conta, valor_pago, data_pagamento)
VALUES
(1, 1, 1, 1800.00, '2026-11-18'),
(1, 3, 2, 4000.00, '2026-11-19'),
(1, 5, 1, 42000.00, '2026-11-19');

-- Os status iniciais foram definidos explicitamente para ilustrar os cenários.
-- Os triggers de 08_triggers.sql recalculam o status quando novos pagamentos são registrados.
