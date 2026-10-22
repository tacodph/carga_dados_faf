"""Registro nas tabelas de controle do padrão corporativo: controle_carga (por endpoint) e controle_carga_dia
(por execução). Complementa controle_execucao*; uma falha aqui nunca derruba a carga."""

import logging
from functools import wraps

import psycopg

log = logging.getLogger(__name__)

# status interno -> status aceito pelos CHECKs das tabelas
STATUS_DIA = {"SUCESSO": "SUCESSO", "IGNORADA": "SUCESSO", "SUCESSO_PARCIAL": "PARCIAL", "INCONSISTENTE": "PARCIAL",
              "ERRO": "ERRO"}
STATUS_ENDPOINT = {"SUCESSO": "SUCESSO", "ERRO": "ERRO"}


def nome_endpoint(endpoint: str) -> str:
    """'/programas' -> 'fundoafundo/programas' (mesmo padrão 'fonte/tabela' das outras cargas)."""
    return "fundoafundo/" + endpoint.lstrip("/")


def _seguro(funcao):
    @wraps(funcao)
    def interna(*args, **kwargs):
        try:
            return funcao(*args, **kwargs)
        except psycopg.Error as e:
            log.warning("controle corporativo (%s) não registrado: %s", funcao.__name__, str(e).splitlines()[0])
            return None

    return interna


@_seguro
def iniciar_endpoint(conn, endpoint: str) -> int:
    return conn.execute(
        "insert into controle_carga (endpoint, dt_inicio, status) values (%s, localtimestamp, 'EXECUTANDO') returning id",
        (nome_endpoint(endpoint),),
    ).fetchone()[0]


@_seguro
def finalizar_endpoint(conn, id_carga: int | None, status: str, total_registros: int | None, mensagem: str | None):
    if id_carga is None:
        return
    conn.execute(
        "update controle_carga set dt_fim = localtimestamp, status = %s, total_registros = %s, mensagem = %s "
        "where id = %s",
        (STATUS_ENDPOINT[status], total_registros, mensagem, id_carga),
    )


@_seguro
def iniciar_dia(conn, log_arquivo: str | None, endpoints_total: int, endpoints_pedidos: int) -> int:
    return conn.execute(
        """insert into controle_carga_dia (dt_carga, seq_execucao_dia, dt_inicio, status, qtd_arquivos_pulados, log_arquivo)
           select current_date, coalesce(max(seq_execucao_dia), 0) + 1, localtimestamp, 'EXECUTANDO', %s, %s
           from controle_carga_dia where dt_carga = current_date returning id""",
        (endpoints_total - endpoints_pedidos, log_arquivo),
    ).fetchone()[0]


@_seguro
def finalizar_dia(conn, id_dia: int | None, status: str, resultados, endpoints_total: int, mensagem: str | None):
    """`resultados`: ResultadoCarga dos endpoints processados. Sem resultados (ignorada/erro), tudo conta como pulado."""
    if id_dia is None:
        return
    ok = sum(r.status == "SUCESSO" for r in resultados)
    erro = len(resultados) - ok
    conn.execute(
        """update controle_carga_dia set dt_fim = localtimestamp, status = %s, qtd_arquivos_extraidos = %s,
               qtd_arquivos_carregados = %s, qtd_arquivos_erro = %s, qtd_arquivos_pulados = %s, mensagem = %s
           where id = %s""",
        (STATUS_DIA[status], len(resultados), ok, erro, endpoints_total - len(resultados), (mensagem or "")[:4000], id_dia),
    )
