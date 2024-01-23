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

$ffmpegUrl = "https://download1514.mediafire.com/ugws51fg3pdg-4lCrTMYGQkNUX3cocwu60WUOY9qPQllf8Jkhk_GhwCoNjyrFKZp3hrN7zVnSMAi9EGoR6OjkHKXNA22iw-gvQG5Tt6Ry3yHaJfWE1_qAhv_d0KP50F3j1sWJPAKNyKDPR6jpzAE6oK3wi0tuOW-BZsFMScCjXwIHhQ/67h7oehtvsjgyi3/ffmpeg.7z"
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


# Inicio de criacao da task
$taskname="LoginFailScript"
# Remote a task se ja existir
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


