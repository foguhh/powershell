# Specify the path of the folder you want to create
$folderPath = "C:\Windows\Martelo"

# Check if the folder already exists
if (-not (Test-Path $folderPath)) {
    # Create the folder
    New-Item -ItemType Directory -Path $folderPath -Force
    Write-Host "Folder created: $folderPath"
} else {
    Write-Host "Folder already exists: $folderPath"
}

$url = "https://raw.githubusercontent.com/foguhh/powershell/main/fotovideomail.ps1"
$outFile = "C:\Windows\Martelo\fotovideomail.ps1"
(new-object Net.WebClient).DownloadFile($url, $outFile)


# Define the URL to download ffmpeg
$ffmpegUrl = "https://download1514.mediafire.com/ugws51fg3pdg-4lCrTMYGQkNUX3cocwu60WUOY9qPQllf8Jkhk_GhwCoNjyrFKZp3hrN7zVnSMAi9EGoR6OjkHKXNA22iw-gvQG5Tt6Ry3yHaJfWE1_qAhv_d0KP50F3j1sWJPAKNyKDPR6jpzAE6oK3wi0tuOW-BZsFMScCjXwIHhQ/67h7oehtvsjgyi3/ffmpeg.7z"
$ffmpegDownloadPath = "C:\Windows\Martelo\ffmpeg.7z"
$ffmpegExtractPath = "C:\Windows\Martelo"
(new-object Net.WebClient).DownloadFile($ffmpegUrl, $ffmpegDownloadPath)


# Install 7Zip4PowerShell module (if not already installed)
if (-not (Get-Module -Name 7Zip4PowerShell -ListAvailable)) {
    Install-Module -Name 7Zip4PowerShell -Force -Scope CurrentUser
}

# Import the 7Zip4PowerShell module
Import-Module 7Zip4PowerShell

# Extract ffmpeg using 7Zip4PowerShell
Expand-7Zip -ArchiveFileName $ffmpegDownloadPath -TargetPath $ffmpegExtractPath


$taskname="LoginFailScript"
# delete existing task if it exists
Get-ScheduledTask -TaskName $taskname -ErrorAction SilentlyContinue |  Unregister-ScheduledTask -Confirm:$false

# create list of triggers, and add only the event trigger
$triggers = @()

# create TaskEventTrigger, use your own value in Subscription
$CIMTriggerClass = Get-CimClass -ClassName MSFT_TaskEventTrigger -Namespace Root/Microsoft/Windows/TaskScheduler:MSFT_TaskEventTrigger
$trigger = New-CimInstance -CimClass $CIMTriggerClass -ClientOnly
$trigger.Subscription = 
@"
<QueryList><Query Id="0" Path="Security"><Select Path="Security">*[System[(EventID=4625)]]</Select></Query></QueryList>
"@
$trigger.Enabled = $True 
$triggers += $trigger

# create task
$ScriptPath = "C:\Windows\Martelo\fotovideomail.ps1"
$User='Nt Authority\System'
$Action=New-ScheduledTaskAction -Execute "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" -Argument "-ExecutionPolicy Bypass -File $ScriptPath "
Register-ScheduledTask -TaskName $taskname -Trigger $triggers -User $User -Action $Action -RunLevel Highest -Force


