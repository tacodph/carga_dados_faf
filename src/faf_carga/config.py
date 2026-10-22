"""Configuração lida de variáveis de ambiente (e de um .env, se existir)."""

import os
import re
from dataclasses import dataclass, field

from dotenv import load_dotenv


class ErroConfiguracao(Exception):
    pass


def _obrigatoria(nome: str) -> str:
    valor = os.environ.get(nome, "").strip()
    if not valor:
        raise ErroConfiguracao(f"Variável de ambiente obrigatória não definida: {nome}")
    return valor


def _tablespace() -> str:
    nome = os.environ.get("FAF_DB_TABLESPACE", "").strip()
    if nome and not re.fullmatch(r"[A-Za-z_][A-Za-z0-9_]*", nome):
        raise ErroConfiguracao(f"FAF_DB_TABLESPACE inválido: {nome!r}")
    return nome


def _inteiro(nome: str, padrao: int) -> int:
    bruto = os.environ.get(nome, "").strip()
    if not bruto:
        return padrao
    try:
        return int(bruto)
    except ValueError:
        raise ErroConfiguracao(f"{nome} deve ser inteiro, recebido: {bruto!r}") from None


@dataclass(frozen=True)
class Config:
    api_base_url: str
    api_tamanho_pagina: int
    api_timeout: int
    api_max_tentativas: int
    api_concorrencia: int
    api_user_agent: str
    db_host: str
    db_porta: int
    db_nome: str
    db_usuario: str
    db_senha: str = field(repr=False)  # nunca aparece em repr/tracebacks/logs
    db_esquema: str
    db_esquema_stg: str
    db_tablespace: str  # vazio = tablespace padrão do banco
    db_statement_timeout: str  # ex.: 4h; o COPY do download é um único comando longo
    db_merge_timeout: str  # limite de cada comando do merge (normalmente < 1 min; trava = falha rápida)
    log_nivel: str
    log_dir: str

    def resumo(self) -> str:
        """Texto para exibição, com a senha mascarada."""
        campos = {**self.__dict__, "db_senha": "***"}
        return "\n".join(f"{k} = {v}" for k, v in campos.items())


def carregar() -> Config:
    load_dotenv()
    tamanho = _inteiro("FAF_API_TAMANHO_PAGINA", 1000)
    if not 1 <= tamanho <= 1000:
        raise ErroConfiguracao("FAF_API_TAMANHO_PAGINA deve estar entre 1 e 1000")
    return Config(
        api_base_url=os.environ.get(
            "FAF_API_BASE_URL",
            "https://api-publica.transferegov.gestao.gov.br/fundoafundo",
        ).rstrip("/"),
        api_tamanho_pagina=tamanho,
        api_timeout=_inteiro("FAF_API_TIMEOUT", 120),
        api_max_tentativas=_inteiro("FAF_API_MAX_TENTATIVAS", 6),
        api_concorrencia=_inteiro("FAF_API_CONCORRENCIA", 4),
        api_user_agent=os.environ.get("FAF_API_USER_AGENT", "faf-carga/0.1 (transferepro)"),
        db_host=os.environ.get("FAF_DB_HOST", "localhost"),
        db_porta=_inteiro("FAF_DB_PORT", 5432),
        db_nome=os.environ.get("FAF_DB_NOME", "transferepro"),
        db_usuario=_obrigatoria("FAF_DB_USUARIO"),
        db_senha=_obrigatoria("FAF_DB_SENHA"),
        db_esquema=os.environ.get("FAF_DB_ESQUEMA", "base_transferencias_fundo_fundo"),
        db_esquema_stg=os.environ.get("FAF_DB_ESQUEMA_STG", "stg_transferencias_fundo_fundo"),
        db_tablespace=_tablespace(),
        db_statement_timeout=os.environ.get("FAF_DB_STATEMENT_TIMEOUT", "4h").strip(),
        db_merge_timeout=os.environ.get("FAF_DB_MERGE_TIMEOUT", "30min").strip(),
        log_nivel=os.environ.get("FAF_LOG_NIVEL", "INFO").upper(),
        log_dir=os.environ.get("FAF_LOG_DIR", "logs"),
    )
