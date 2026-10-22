"""Logging para console e arquivo diário em logs/."""

import logging
import sys
from datetime import date
from pathlib import Path

_arquivo: Path | None = None
FORMATO = "%(asctime)s | %(levelname)s | %(name)s | %(message)s"


def arquivo_atual() -> str | None:
    return str(_arquivo) if _arquivo else None


def configurar(nivel: str = "INFO", diretorio: str = "logs") -> None:
    global _arquivo
    Path(diretorio).mkdir(parents=True, exist_ok=True)
    arquivo = Path(diretorio) / f"faf_carga_{date.today():%Y%m%d}.log"
    _arquivo = arquivo.resolve()
    logging.basicConfig(
        level=nivel,
        format=FORMATO,
        handlers=[
            logging.StreamHandler(sys.stdout),
            logging.FileHandler(arquivo, encoding="utf-8"),
        ],
        force=True,
    )
    logging.getLogger("httpx").setLevel(max(logging.getLevelName(nivel), logging.WARNING))  # uma linha por requisição é ruído
