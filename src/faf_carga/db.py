"""Acesso ao PostgreSQL: conexão, staging, merge incremental e controle por endpoint."""

import psycopg
from psycopg import sql

from .config import Config


class ErroCarga(Exception):
    pass


def opcoes_conexao(cfg: Config, search_path: bool = True) -> str:
    """Opções de sessão: search_path da base e, se configurado, tablespace para objetos novos e arquivos temporários."""
    opcoes = [f"-c search_path={cfg.db_esquema}"] if search_path else []
    if cfg.db_statement_timeout:
        opcoes.append(f"-c statement_timeout={cfg.db_statement_timeout}")
    if cfg.db_tablespace:
        opcoes += [f"-c default_tablespace={cfg.db_tablespace}", f"-c temp_tablespaces={cfg.db_tablespace}"]
    return " ".join(opcoes)


def conectar(cfg: Config) -> psycopg.Connection:
    """Conexão em autocommit (transações explícitas via `conn.transaction()`), esquema no search_path."""
    return psycopg.connect(
        host=cfg.db_host,
        port=cfg.db_porta,
        dbname=cfg.db_nome,
        user=cfg.db_usuario,
        password=cfg.db_senha,
        autocommit=True,
        options=opcoes_conexao(cfg),
    )


def mover_para_tablespace(conn, esquemas, tablespace: str) -> int:
    """Move para `tablespace` as tabelas e índices dos esquemas que ainda estão em outro. Idempotente."""
    objetos = conn.execute(
        """select n.nspname, c.relname, c.relkind from pg_class c join pg_namespace n on n.oid = c.relnamespace
           where n.nspname = any(%s) and c.relkind in ('r', 'i')
             and c.reltablespace is distinct from (select oid from pg_tablespace where spcname = %s)
           order by c.relkind desc, c.relname""",
        (list(esquemas), tablespace),
    ).fetchall()
    for esquema, nome, tipo in objetos:
        comando = "alter table {} set tablespace {}" if tipo == "r" else "alter index {} set tablespace {}"
        conn.execute(sql.SQL(comando).format(sql.Identifier(esquema, nome), sql.Identifier(tablespace)))
    return len(objetos)


def _ids(nomes) -> sql.Composed:
    return sql.SQL(", ").join(sql.Identifier(n) for n in nomes)


def truncar(conn, esquema_stg: str, tabelas):
    conn.execute(sql.SQL("truncate table {}").format(sql.SQL(", ").join(sql.Identifier(esquema_stg, t) for t in tabelas)))


def comando_copy(esquema_stg: str, tabela: str, colunas) -> sql.Composed:
    return sql.SQL("copy {} ({}) from stdin").format(sql.Identifier(esquema_stg, tabela), _ids(colunas))


def analisar(conn, esquema: str, tabelas):
    """ANALYZE do staging recém-carregado: o planejador não tem estatística de uma tabela que acabou de ser copiada."""
    for t in tabelas:
        conn.execute(sql.SQL("analyze {}").format(sql.Identifier(esquema, t)))


def contar(conn, esquema: str, tabela: str, somente_ativos: bool = False) -> int:
    filtro = sql.SQL(" where dt_remocao_origem is null") if somente_ativos else sql.SQL("")
    return conn.execute(sql.SQL("select count(*) from {}{}").format(sql.Identifier(esquema, tabela), filtro)).fetchone()[0]


def verificar_duplicados(conn, esquema_stg: str, tabela: str, chave):
    """Levanta ErroCarga com até 20 chaves repetidas no staging."""
    consulta = sql.SQL("select {c}, count(*) from {t} group by {c} having count(*) > 1 limit 20").format(
        c=_ids(chave), t=sql.Identifier(esquema_stg, tabela)
    )
    duplicadas = conn.execute(consulta).fetchall()
    if duplicadas:
        exemplos = "; ".join(f"{tuple(l[:-1])} x{l[-1]}" for l in duplicadas)
        raise ErroCarga(f"chave primária duplicada em {tabela} ({', '.join(chave)}): {exemplos}")


def mesclar(conn, esquema: str, esquema_stg: str, tabela: str, colunas, chave, id_execucao: int) -> tuple[int, int, int]:
    """Merge incremental staging -> base. Devolve (inseridos, atualizados, removidos).

    Insere o que é novo, atualiza só o que mudou (comparando `hash_registro`, calculado em SQL dos dois lados) e
    marca como removido (`dt_remocao_origem`) o que não veio mais. Chamar dentro de uma transação: qualquer
    ErroCarga desfaz tudo.
    """
    base, stg = sql.Identifier(esquema, tabela), sql.Identifier(esquema_stg, tabela)
    cols = _ids(colunas)
    s_cols = sql.SQL(", ").join(sql.SQL("s.{}").format(sql.Identifier(c)) for c in colunas)
    hash_s = sql.SQL("md5(row({})::text)").format(s_cols)
    mesma_chave = sql.SQL(" and ").join(
        sql.SQL("b.{c} = s.{c}").format(c=sql.Identifier(c)) for c in chave
    )
    sets = [sql.SQL("{c} = s.{c}").format(c=sql.Identifier(c)) for c in colunas if c not in chave]
    # tabelas só de chave (ex.: programas_natureza_despesa_faf) não têm o que atribuir além das colunas técnicas
    atribuicoes = sql.SQL("{}, ").format(sql.SQL(", ").join(sets)) if sets else sql.SQL("")

    n_stg = conn.execute(sql.SQL("select count(*) from {}").format(stg)).fetchone()[0]
    ativos_antes = contar(conn, esquema, tabela, somente_ativos=True)
    if n_stg == 0 and ativos_antes > 0:
        raise ErroCarga(f"a API devolveu 0 registros para {tabela}, mas a base tem {ativos_antes} ativos; nada foi alterado")

    inseridos = conn.execute(
        sql.SQL(
            "insert into {base} ({cols}, dt_carga, dt_atualizacao, id_execucao, hash_registro) "
            "select {s_cols}, now(), now(), %s, {hash_s} from {stg} s "
            "where not exists (select 1 from {base} b where {on})"
        ).format(base=base, cols=cols, s_cols=s_cols, hash_s=hash_s, stg=stg, on=mesma_chave),
        (id_execucao,),
    ).rowcount
    atualizados = conn.execute(
        sql.SQL(
            "update {base} b set {atrib}hash_registro = {hash_s}, dt_atualizacao = now(), id_execucao = %s, "
            "dt_remocao_origem = null from {stg} s where {on} "
            "and (b.hash_registro is distinct from {hash_s} or b.dt_remocao_origem is not null)"
        ).format(base=base, atrib=atribuicoes, hash_s=hash_s, stg=stg, on=mesma_chave),
        (id_execucao,),
    ).rowcount
    removidos = conn.execute(
        sql.SQL(
            "update {base} b set dt_remocao_origem = now(), dt_atualizacao = now(), id_execucao = %s "
            "where b.dt_remocao_origem is null and not exists (select 1 from {stg} s where {on})"
        ).format(base=base, stg=stg, on=mesma_chave),
        (id_execucao,),
    ).rowcount

    ativos = contar(conn, esquema, tabela, somente_ativos=True)
    if ativos != n_stg:
        raise ErroCarga(f"após o merge, {tabela} tem {ativos} ativos, mas o staging tem {n_stg}")
    return inseridos, atualizados, removidos


def limites_varchar(conn, esquema: str, tabela: str) -> dict:
    consulta = (
        "select column_name, character_maximum_length from information_schema.columns "
        "where table_schema = %s and table_name = %s and character_maximum_length is not null"
    )
    return dict(conn.execute(consulta, (esquema, tabela)).fetchall())


def nova_execucao(conn, mensagem: str | None = None, status: str = "EM_ANDAMENTO") -> int:
    return conn.execute(
        "insert into controle_execucao (status, mensagem) values (%s, %s) returning id_execucao", (status, mensagem)
    ).fetchone()[0]


def registrar_inicio_endpoint(conn, id_execucao: int, endpoint: str, tabela: str):
    conn.execute(
        """insert into controle_execucao_endpoint (id_execucao, endpoint, tabela, dt_inicio, status)
           values (%s, %s, %s, now(), 'EM_ANDAMENTO')
           on conflict (id_execucao, endpoint) do update set tabela = excluded.tabela, dt_inicio = now(),
               dt_fim = null, status = 'EM_ANDAMENTO', paginas = null, total_items_api = null,
               linhas_gravadas = null, qtd_inseridos = null, qtd_atualizados = null, qtd_removidos = null,
               mensagem = null""",
        (id_execucao, endpoint, tabela),
    )


def registrar_fim_endpoint(conn, id_execucao: int, endpoint: str, status: str, paginas, total_items, gravadas, mensagem,
                           inseridos=None, atualizados=None, removidos=None):
    conn.execute(
        """update controle_execucao_endpoint set dt_fim = now(), status = %s, paginas = %s, total_items_api = %s,
               linhas_gravadas = %s, mensagem = %s, qtd_inseridos = %s, qtd_atualizados = %s, qtd_removidos = %s
           where id_execucao = %s and endpoint = %s""",
        (status, paginas, total_items, gravadas, mensagem, inseridos, atualizados, removidos, id_execucao, endpoint),
    )


# --- controle de execução (orquestrador) ---

CHAVE_TRAVA = 7465001  # pg_advisory_lock: impede duas cargas simultâneas


def obter_trava(conn) -> bool:
    return conn.execute("select pg_try_advisory_lock(%s)", (CHAVE_TRAVA,)).fetchone()[0]


def liberar_trava(conn):
    conn.execute("select pg_advisory_unlock(%s)", (CHAVE_TRAVA,))


def marcar_interrompidas(conn) -> int:
    """Com a trava em mãos, qualquer EM_ANDAMENTO é resto de um processo que morreu."""
    return conn.execute(
        "update controle_execucao set status = 'ERRO', dt_fim = now(), "
        "mensagem = 'Execução interrompida (processo encerrado sem finalizar)' where status = 'EM_ANDAMENTO'"
    ).rowcount


def iniciar_execucao(conn, forcada: bool, endpoints: str | None) -> int:
    return conn.execute(
        "insert into controle_execucao (status, forcada, endpoints_solicitados) values ('EM_ANDAMENTO', %s, %s) "
        "returning id_execucao",
        (forcada, endpoints),
    ).fetchone()[0]


def registrar_origem(conn, id_execucao: int, dt_origem):
    conn.execute("update controle_execucao set dt_atualizacao_origem = %s where id_execucao = %s", (dt_origem, id_execucao))


def ultima_origem_sucesso(conn):
    linha = conn.execute(
        "select dt_atualizacao_origem from controle_execucao where status = 'SUCESSO' "
        "order by id_execucao desc limit 1"
    ).fetchone()
    return linha[0] if linha else None


def encerrar_execucao(conn, id_execucao: int, status: str, dt_origem_fim, mensagem: str | None):
    conn.execute(
        "update controle_execucao set status = %s, dt_fim = now(), dt_atualizacao_origem_fim = %s, mensagem = %s "
        "where id_execucao = %s",
        (status, dt_origem_fim, mensagem, id_execucao),
    )
