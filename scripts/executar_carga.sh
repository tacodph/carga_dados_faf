#!/usr/bin/env bash
# Executa a carga FaF (faf-carga executar) e devolve o código de saída da CLI.
#
# Usa o .venv da raiz do projeto, grava a saída em logs/execucao_AAAAMMDD_HHMMSS.txt e apaga arquivos de logs/ com mais
# de 90 dias. Argumentos extras vão direto para a CLI, ex.:
#   ./scripts/executar_carga.sh --forcar --endpoints programas
# Códigos de saída: 0 sucesso/ignorada, 1 erro, 2 já em execução, 3 parcial/inconsistente.
set -uo pipefail

RAIZ="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$RAIZ"

EXE="$RAIZ/.venv/bin/faf-carga"
if [ ! -x "$EXE" ]; then
    echo "Ambiente virtual não encontrado em $EXE (veja o README: pip install -e .)" >&2
    exit 1
fi

mkdir -p logs
SAIDA="logs/execucao_$(date +%Y%m%d_%H%M%S).txt"

export PYTHONIOENCODING=utf-8
"$EXE" executar "$@" 2>&1 | tee "$SAIDA"
CODIGO=${PIPESTATUS[0]}

find logs -type f -mtime +90 -delete
exit "$CODIGO"
