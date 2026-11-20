import os

import psycopg
from dotenv import load_dotenv
from fastapi import FastAPI, HTTPException
from psycopg.rows import dict_row

# Carrega backend/.env durante o desenvolvimento local.
load_dotenv()

app = FastAPI(
    title="FinControl API",
    description="API inicial para consulta de informações financeiras institucionais.",
    version="0.1.0",
)


def get_connection():
    database_url = os.getenv("DATABASE_URL")
    if not database_url:
        raise RuntimeError(
            "DATABASE_URL não definida. Crie backend/.env a partir de .env.example."
        )
    return psycopg.connect(database_url, row_factory=dict_row)


@app.get("/", tags=["Geral"])
def root():
    return {"project": "FinControl", "version": "0.1.0", "status": "running"}


@app.get("/health", tags=["Geral"])
def health():
    try:
        with get_connection() as conn:
            with conn.cursor() as cur:
                cur.execute("SELECT 1 AS database_connection")
                result = cur.fetchone()
        return {
            "api": "ok",
            "database": "ok",
            "check": result["database_connection"],
        }
    except Exception as exc:
        raise HTTPException(
            status_code=503,
            detail="Não foi possível conectar ao banco.",
        ) from exc


@app.get("/departments", tags=["Departamentos"])
def list_departments():
    query = """
        SELECT d.id_departamento, d.nome, e.nome_fantasia
        FROM departamento d
        JOIN empresa e ON e.id_empresa = d.id_empresa
        ORDER BY d.nome;
    """
    try:
        with get_connection() as conn:
            with conn.cursor() as cur:
                cur.execute(query)
                return cur.fetchall()
    except Exception as exc:
        raise HTTPException(
            status_code=500,
            detail="Erro ao consultar departamentos.",
        ) from exc


@app.get("/transactions", tags=["Transações"])
def list_transactions(limit: int = 50):
    if not 1 <= limit <= 200:
        raise HTTPException(
            status_code=400,
            detail="limit deve estar entre 1 e 200.",
        )

    query = """
        SELECT
            t.id_transacao, t.descricao, t.tipo, t.valor,
            t.data_competencia, t.data_vencimento, t.status,
            cc.nome AS centro_custo, c.nome AS categoria
        FROM transacao t
        JOIN centro_custo cc
          ON cc.id_empresa = t.id_empresa
         AND cc.id_centro_custo = t.id_centro_custo
        JOIN categoria c
          ON c.id_empresa = t.id_empresa
         AND c.id_categoria = t.id_categoria
        ORDER BY t.data_competencia DESC, t.id_transacao DESC
        LIMIT %s;
    """
    try:
        with get_connection() as conn:
            with conn.cursor() as cur:
                cur.execute(query, (limit,))
                return cur.fetchall()
    except Exception as exc:
        raise HTTPException(
            status_code=500,
            detail="Erro ao consultar transações.",
        ) from exc
