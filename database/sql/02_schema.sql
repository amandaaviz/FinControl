-- FinControl | Estrutura relacional inicial
-- Execute conectado ao banco fincontrol.

CREATE TABLE empresa (
    id_empresa BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    razao_social VARCHAR(150) NOT NULL,
    nome_fantasia VARCHAR(100) NOT NULL,
    cnpj CHAR(14) NOT NULL UNIQUE,
    data_cadastro TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT ck_empresa_cnpj CHECK (cnpj ~ '^[0-9]{14}$')
);

CREATE TABLE departamento (
    id_departamento BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_empresa BIGINT NOT NULL REFERENCES empresa(id_empresa),
    nome VARCHAR(100) NOT NULL,
    CONSTRAINT uq_departamento_empresa_nome UNIQUE (id_empresa, nome),
    CONSTRAINT uq_departamento_empresa_id UNIQUE (id_empresa, id_departamento)
);

CREATE TABLE centro_custo (
    id_centro_custo BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_empresa BIGINT NOT NULL,
    id_departamento BIGINT NOT NULL,
    codigo VARCHAR(20) NOT NULL,
    nome VARCHAR(100) NOT NULL,
    descricao TEXT,
    CONSTRAINT fk_centro_departamento_empresa
        FOREIGN KEY (id_empresa, id_departamento)
        REFERENCES departamento(id_empresa, id_departamento),
    CONSTRAINT uq_centro_empresa_codigo UNIQUE (id_empresa, codigo),
    CONSTRAINT uq_centro_empresa_id UNIQUE (id_empresa, id_centro_custo)
);

CREATE TABLE usuario (
    id_usuario BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_empresa BIGINT NOT NULL REFERENCES empresa(id_empresa),
    id_departamento BIGINT,
    nome VARCHAR(120) NOT NULL,
    email VARCHAR(150) NOT NULL,
    senha_hash TEXT NOT NULL,
    perfil VARCHAR(20) NOT NULL,
    ativo BOOLEAN NOT NULL DEFAULT TRUE,
    CONSTRAINT uq_usuario_empresa_email UNIQUE (id_empresa, email),
    CONSTRAINT uq_usuario_empresa_id UNIQUE (id_empresa, id_usuario),
    CONSTRAINT fk_usuario_departamento_empresa
        FOREIGN KEY (id_empresa, id_departamento)
        REFERENCES departamento(id_empresa, id_departamento),
    CONSTRAINT ck_usuario_perfil CHECK (perfil IN ('ADMIN', 'FINANCEIRO', 'CONSULTA'))
);

CREATE TABLE categoria (
    id_categoria BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_empresa BIGINT NOT NULL REFERENCES empresa(id_empresa),
    nome VARCHAR(100) NOT NULL,
    tipo VARCHAR(10) NOT NULL,
    ativa BOOLEAN NOT NULL DEFAULT TRUE,
    CONSTRAINT ck_categoria_tipo CHECK (tipo IN ('RECEITA', 'DESPESA')),
    CONSTRAINT uq_categoria_empresa_nome_tipo UNIQUE (id_empresa, nome, tipo),
    CONSTRAINT uq_categoria_empresa_id UNIQUE (id_empresa, id_categoria)
);

CREATE TABLE conta_financeira (
    id_conta BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_empresa BIGINT NOT NULL REFERENCES empresa(id_empresa),
    nome VARCHAR(100) NOT NULL,
    banco VARCHAR(100),
    agencia VARCHAR(20),
    numero_conta VARCHAR(30),
    saldo_inicial NUMERIC(15,2) NOT NULL DEFAULT 0,
    ativa BOOLEAN NOT NULL DEFAULT TRUE,
    CONSTRAINT ck_conta_saldo CHECK (saldo_inicial >= 0),
    CONSTRAINT uq_conta_empresa_nome UNIQUE (id_empresa, nome),
    CONSTRAINT uq_conta_empresa_id UNIQUE (id_empresa, id_conta)
);

CREATE TABLE orcamento (
    id_orcamento BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_empresa BIGINT NOT NULL REFERENCES empresa(id_empresa),
    id_centro_custo BIGINT NOT NULL,
    id_categoria BIGINT NOT NULL,
    ano SMALLINT NOT NULL,
    mes SMALLINT NOT NULL,
    valor_previsto NUMERIC(15,2) NOT NULL,
    CONSTRAINT fk_orcamento_centro_empresa
        FOREIGN KEY (id_empresa, id_centro_custo)
        REFERENCES centro_custo(id_empresa, id_centro_custo),
    CONSTRAINT fk_orcamento_categoria_empresa
        FOREIGN KEY (id_empresa, id_categoria)
        REFERENCES categoria(id_empresa, id_categoria),
    CONSTRAINT ck_orcamento_mes CHECK (mes BETWEEN 1 AND 12),
    CONSTRAINT ck_orcamento_ano CHECK (ano BETWEEN 2000 AND 2200),
    CONSTRAINT ck_orcamento_valor CHECK (valor_previsto >= 0),
    CONSTRAINT uq_orcamento_periodo UNIQUE (id_centro_custo, id_categoria, ano, mes)
);

CREATE TABLE transacao (
    id_transacao BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_empresa BIGINT NOT NULL REFERENCES empresa(id_empresa),
    id_centro_custo BIGINT NOT NULL,
    id_categoria BIGINT NOT NULL,
    id_usuario BIGINT NOT NULL,
    descricao VARCHAR(200) NOT NULL,
    tipo VARCHAR(10) NOT NULL,
    valor NUMERIC(15,2) NOT NULL,
    data_competencia DATE NOT NULL,
    data_vencimento DATE,
    status VARCHAR(15) NOT NULL DEFAULT 'PENDENTE',
    criada_em TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_transacao_centro_empresa
        FOREIGN KEY (id_empresa, id_centro_custo)
        REFERENCES centro_custo(id_empresa, id_centro_custo),
    CONSTRAINT fk_transacao_categoria_empresa
        FOREIGN KEY (id_empresa, id_categoria)
        REFERENCES categoria(id_empresa, id_categoria),
    CONSTRAINT fk_transacao_usuario_empresa
        FOREIGN KEY (id_empresa, id_usuario)
        REFERENCES usuario(id_empresa, id_usuario),
    CONSTRAINT ck_transacao_tipo CHECK (tipo IN ('RECEITA', 'DESPESA')),
    CONSTRAINT ck_transacao_status CHECK (status IN ('PENDENTE', 'PARCIAL', 'PAGO', 'CANCELADO')),
    CONSTRAINT ck_transacao_valor CHECK (valor > 0),
    CONSTRAINT uq_transacao_empresa_id UNIQUE (id_empresa, id_transacao)
);

CREATE TABLE pagamento (
    id_pagamento BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_empresa BIGINT NOT NULL REFERENCES empresa(id_empresa),
    id_transacao BIGINT NOT NULL,
    id_conta BIGINT NOT NULL,
    valor_pago NUMERIC(15,2) NOT NULL,
    data_pagamento DATE NOT NULL,
    criado_em TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_pagamento_transacao_empresa
        FOREIGN KEY (id_empresa, id_transacao)
        REFERENCES transacao(id_empresa, id_transacao),
    CONSTRAINT fk_pagamento_conta_empresa
        FOREIGN KEY (id_empresa, id_conta)
        REFERENCES conta_financeira(id_empresa, id_conta),
    CONSTRAINT ck_pagamento_valor CHECK (valor_pago > 0)
);

CREATE TABLE auditoria (
    id_auditoria BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_empresa BIGINT NOT NULL REFERENCES empresa(id_empresa),
    id_usuario BIGINT,
    tabela_afetada VARCHAR(100) NOT NULL,
    operacao VARCHAR(10) NOT NULL,
    registro_id BIGINT,
    dados_anteriores JSONB,
    dados_novos JSONB,
    data_operacao TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_auditoria_usuario_empresa
        FOREIGN KEY (id_empresa, id_usuario)
        REFERENCES usuario(id_empresa, id_usuario),
    CONSTRAINT ck_auditoria_operacao CHECK (operacao IN ('INSERT', 'UPDATE', 'DELETE'))
);

-- Índices iniciais para FKs e filtros recorrentes.
CREATE INDEX idx_centro_departamento ON centro_custo(id_departamento);
CREATE INDEX idx_usuario_departamento ON usuario(id_departamento);
CREATE INDEX idx_orcamento_periodo ON orcamento(ano, mes);
CREATE INDEX idx_transacao_competencia ON transacao(data_competencia);
CREATE INDEX idx_transacao_status_vencimento ON transacao(status, data_vencimento);
CREATE INDEX idx_transacao_centro_categoria ON transacao(id_centro_custo, id_categoria);
CREATE INDEX idx_pagamento_data ON pagamento(data_pagamento);
CREATE INDEX idx_auditoria_data ON auditoria(data_operacao);
