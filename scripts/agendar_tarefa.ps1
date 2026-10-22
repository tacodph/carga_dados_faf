<#
.SYNOPSIS
  Cria/atualiza a tarefa agendada "FAF - Carga Transferegov" (diária 07:30, com novas tentativas 10:30 e 14:30).
.DESCRIPTION
  A origem atualiza por volta das 06:00. As tentativas extras são seguras: se a data de atualização já foi
  carregada, a rotina se auto-ignora (status IGNORADA); se uma carga ainda estiver rodando, sai com código 2.

  Para rodar MESMO SEM USUÁRIO LOGADO a tarefa precisa das credenciais do Windows do usuário. O script pede a
  senha com Get-Credential (janela segura), usa-a apenas em memória no registro da tarefa e não a grava em
  arquivo nem em log. Use -SomenteLogado para dispensar a senha (a tarefa só roda com o usuário conectado).
  Requer PowerShell elevado (Administrador).
.EXAMPLE
  .\scripts\agendar_tarefa.ps1
  .\scripts\agendar_tarefa.ps1 -Usuario "DOMINIO\svc_carga"
  .\scripts\agendar_tarefa.ps1 -SomenteLogado
  .\scripts\agendar_tarefa.ps1 -Remover
#>
param(
    [string]$Usuario = "$env:USERDOMAIN\$env:USERNAME",
    [switch]$SomenteLogado,
    [switch]$Remover
)
$ErrorActionPreference = 'Stop'
$nome = 'FAF - Carga Transferegov'

if ($Remover) { Unregister-ScheduledTask -TaskName $nome -Confirm:$false; Write-Host "Tarefa removida."; return }

$raiz = Split-Path -Parent $PSScriptRoot
$script = Join-Path $raiz 'scripts\executar_carga.ps1'
$acao = New-ScheduledTaskAction -Execute 'powershell.exe' -WorkingDirectory $raiz `
    -Argument "-NoProfile -ExecutionPolicy Bypass -File `"$script`""
$gatilhos = '07:30', '10:30', '14:30' | ForEach-Object { New-ScheduledTaskTrigger -Daily -At $_ }
$config = New-ScheduledTaskSettingsSet -StartWhenAvailable -MultipleInstances IgnoreNew `
    -ExecutionTimeLimit (New-TimeSpan -Hours 3) -RestartCount 0

if ($SomenteLogado) {
    $principal = New-ScheduledTaskPrincipal -UserId $Usuario -LogonType Interactive
    Register-ScheduledTask -TaskName $nome -Action $acao -Trigger $gatilhos -Settings $config -Principal $principal -Force | Out-Null
} else {
    $cred = Get-Credential -UserName $Usuario -Message 'Conta do Windows que executará a tarefa'
    Register-ScheduledTask -TaskName $nome -Action $acao -Trigger $gatilhos -Settings $config `
        -User $cred.UserName -Password $cred.GetNetworkCredential().Password -RunLevel Limited -Force | Out-Null
}
Write-Host "Tarefa '$nome' registrada (07:30, 10:30, 14:30). Teste agora com: Start-ScheduledTask -TaskName '$nome'"
