# Cria pasta Martelo

$folderPath = "C:\Windows\Martelo"
#  Verifica se a pasta ja existe
if (-not (Test-Path $folderPath)) {
    # Cria a pasta
    New-Item -ItemType Directory -Path $folderPath -Force
    Write-Host "Pasta Criada: $folderPath"
} else {
    Write-Host "Pasta ja existe: $folderPath"
}


Write-Host "A fazer download de scripts e software extra..."
$url = "https://raw.githubusercontent.com/foguhh/powershell/main/fotovideomail.ps1"
$outFile = "C:\Windows\Martelo\fotovideomail.ps1"
(new-object Net.WebClient).DownloadFile($url, $outFile)

$url = "https://raw.githubusercontent.com/foguhh/powershell/main/usb.ps1"
$outFile = "C:\Windows\Martelo\usb.ps1"
(new-object Net.WebClient).DownloadFile($url, $outFile)

$url = "https://raw.githubusercontent.com/foguhh/powershell/main/maillogs.ps1"
$outFile = "C:\Windows\Martelo\maillogs.ps1"
(new-object Net.WebClient).DownloadFile($url, $outFile)


$ffmpegUrl = "https://www.gyan.dev/ffmpeg/builds/packages/ffmpeg-2024-01-17-git-8e23ebe6f9-essentials_build.7z"
$ffmpegDownloadPath = "C:\Windows\Martelo\ffmpeg.7z"
$ffmpegExtractPath = "C:\Windows\Martelo"
(new-object Net.WebClient).DownloadFile($ffmpegUrl, $ffmpegDownloadPath)


# Verifica se o module 7Zip4PowerShell esta instalado
if (-not (Get-Module -Name 7Zip4PowerShell -ListAvailable)) {
    Install-Module -Name 7Zip4PowerShell -Force -Scope CurrentUser
}

# Importa o module 7Zip4PowerShell 
Import-Module 7Zip4PowerShell

# Extrai o ffmpeg com o 7Zip4PowerShell
Write-Host "A extrair ffmpeg..."
Expand-7Zip -ArchiveFileName $ffmpegDownloadPath -TargetPath $ffmpegExtractPath




# inicio de criacao da task de fail de login
$taskname="LoginFailScript"
# Remove a task se ja existir
Get-ScheduledTask -TaskName $taskname -ErrorAction SilentlyContinue |  Unregister-ScheduledTask -Confirm:$false
# comeca a criacao do trigger
$triggers = @()
# cria o TaskEventTrigger
$CIMTriggerClass = Get-CimClass -ClassName MSFT_TaskEventTrigger -Namespace Root/Microsoft/Windows/TaskScheduler:MSFT_TaskEventTrigger
$trigger = New-CimInstance -CimClass $CIMTriggerClass -ClientOnly
$trigger.Subscription = 
@"
<QueryList><Query Id="0" Path="Security"><Select Path="Security">*[System[(EventID=4625)]]</Select></Query></QueryList>
"@
$trigger.Enabled = $True 
$triggers += $trigger
# cria a task
$ScriptPath = "C:\Windows\Martelo\fotovideomail.ps1"
$User='Nt Authority\System'
$Action=New-ScheduledTaskAction -Execute "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" -Argument "-ExecutionPolicy Bypass -File $ScriptPath "
Register-ScheduledTask -TaskName $taskname -Trigger $triggers -User $User -Action $Action -RunLevel Highest -Force




# inicio de criacao da task que deteta quando sao inseridos ou removidos dispositivos usb
$taskname = "USBDetectScript"
# Remove the task if it already exists
Get-ScheduledTask -TaskName $taskname -ErrorAction SilentlyContinue | Unregister-ScheduledTask -Confirm:$false
# inicio do trigger
$triggers = @()
# cria o event trigger de login
$CIMTriggerClass = Get-CimClass -ClassName MSFT_TaskLogonTrigger -Namespace Root/Microsoft/Windows/TaskScheduler:MSFT_TaskLogonTrigger
$trigger = New-CimInstance -CimClass $CIMTriggerClass -ClientOnly
$triggers += $trigger
# cria a action
$ScriptPath = "C:\Windows\Martelo\usb.ps1"
$User = 'Nt Authority\System'
$Action = New-ScheduledTaskAction -Execute "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" -Argument "-ExecutionPolicy Bypass -File $ScriptPath"
Register-ScheduledTask -TaskName $taskname -Trigger $triggers -User $User -Action $Action -RunLevel Highest -Force


# # inicio de criacao da task para enviar logs de 1 em 1 hora para o mail
# cria o trigger para executar de 1 em 1 hora o script
$trigger1hour = New-ScheduledTaskTrigger -Once -At (Get-Date) -RepetitionInterval ([TimeSpan]::FromHours(1))
# combina os 2 triggers
$triggers = @($trigger1hour)
# define a action para correr o script
$ScriptPath = "C:\Windows\Martelo\maillogs.ps1"
$User = 'Nt Authority\System'
$Action = New-ScheduledTaskAction -Execute "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" -Argument "-ExecutionPolicy Bypass -File $ScriptPath"
# cria a task
$taskname = "MailLogs1h"
Register-ScheduledTask -TaskName $taskname -Trigger $triggers -User $User -Action $Action -RunLevel Highest -Force
