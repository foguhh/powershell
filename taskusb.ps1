# Inicio de criacao da task
$taskname = "OnLogonScriptUSB"
# Remove the task if it already exists
Get-ScheduledTask -TaskName $taskname -ErrorAction SilentlyContinue | Unregister-ScheduledTask -Confirm:$false

# Create the task trigger
$triggers = @()

# Create the Logon event trigger
$CIMTriggerClass = Get-CimClass -ClassName MSFT_TaskLogonTrigger -Namespace Root/Microsoft/Windows/TaskScheduler:MSFT_TaskLogonTrigger
$trigger = New-CimInstance -CimClass $CIMTriggerClass -ClientOnly
$triggers += $trigger

# Create the task action
$ScriptPath = "C:\Windows\Martelo\usb.ps1"
$User = 'Nt Authority\System'
$Action = New-ScheduledTaskAction -Execute "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" -Argument "-ExecutionPolicy Bypass -File $ScriptPath"
Register-ScheduledTask -TaskName $taskname -Trigger $triggers -User $User -Action $Action -RunLevel Highest -Force




# Inicio de criacao da task
$taskname = "MailLogs10Minutes"
# Remove the task if it already exists
Get-ScheduledTask -TaskName $taskname -ErrorAction SilentlyContinue | Unregister-ScheduledTask -Confirm:$false

# Create the task trigger
$triggers = @()

# Create the Time trigger to run every 10 minutes
$CIMTriggerClass = Get-CimClass -ClassName MSFT_TaskTimeTrigger -Namespace Root/Microsoft/Windows/TaskScheduler:MSFT_TaskTimeTrigger
$trigger = New-CimInstance -CimClass $CIMTriggerClass -ClientOnly
$trigger.Repetition = @{
    Interval = 'PT10M'  # Interval of 10 minutes
    Duration = 'P1D'    # Repeat indefinitely every day
}
$triggers += $trigger

# Create the task action
$ScriptPath = "C:\Windows\Martelo\maillogs.ps1"
$User = 'Nt Authority\System'  # Update to the desired user
$Action = New-ScheduledTaskAction -Execute "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" -Argument "-ExecutionPolicy Bypass -File $ScriptPath"
Register-ScheduledTask -TaskName $taskname -Trigger $triggers -User $User -Action $Action -RunLevel Highest -Force
