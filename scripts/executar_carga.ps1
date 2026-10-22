<#
.SYNOPSIS
  Executa a carga FaF (faf-carga executar) e devolve o código de saída da CLI.
.DESCRIPTION
  Usa o .venv da raiz do projeto, grava a saída em logs\execucao_AAAAMMDD_HHMMSS.txt e apaga arquivos de
  logs\ com mais de 90 dias. Argumentos extras vão direto para a CLI, ex.:
    .\scripts\executar_carga.ps1 --forcar --endpoints programas
  Códigos de saída: 0 sucesso/ignorada, 1 erro, 2 já em execução, 3 parcial/inconsistente.
#>
$ErrorActionPreference = 'Stop'
$raiz = Split-Path -Parent $PSScriptRoot
Set-Location $raiz

$exe = Join-Path $raiz '.venv\Scripts\faf-carga.exe'
if (-not (Test-Path $exe)) { Write-Error "Ambiente virtual não encontrado em $exe (veja o README: pip install -e .)"; exit 1 }

$logs = Join-Path $raiz 'logs'
New-Item -ItemType Directory -Force -Path $logs | Out-Null
$saida = Join-Path $logs ('execucao_{0:yyyyMMdd_HHmmss}.txt' -f (Get-Date))

$env:PYTHONIOENCODING = 'utf-8'
$ErrorActionPreference = 'Continue'   # a CLI escreve só em stdout; evita que stderr vire exceção no PS 5.1
& $exe executar @args *>&1 | Tee-Object -FilePath $saida
$codigo = $LASTEXITCODE

Get-ChildItem -Path $logs -File | Where-Object { $_.LastWriteTime -lt (Get-Date).AddDays(-90) } | Remove-Item -Force
exit $codigo
