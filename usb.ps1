function Get-USBDevices {
    Get-WmiObject Win32_PnPEntity | Where-Object { $_.Caption -like "*USB*" }
}

$logFilePath = "C:\Windows\Martelo\usb-log.txt"

$previousDevices = Get-USBDevices

while ($true) {
    Start-Sleep -Seconds 2
    $currentDevices = Get-USBDevices

    $newDevices = Compare-Object -ReferenceObject $previousDevices -DifferenceObject $currentDevices -Property Caption -PassThru |
                  Where-Object { $_.SideIndicator -eq '=>' }

    $removedDevices = Compare-Object -ReferenceObject $previousDevices -DifferenceObject $currentDevices -Property Caption -PassThru |
                      Where-Object { $_.SideIndicator -eq '<=' }

    if ($newDevices.Count -gt 0) {
        foreach ($device in $newDevices) {
            $logEntry = "USB device plugged in: $($device.Caption) - $(Get-Date)"
            Write-Host $logEntry
            $logEntry | Out-File -Append -FilePath $logFilePath
        }
    }

    if ($removedDevices.Count -gt 0) {
        foreach ($device in $removedDevices) {
            $logEntry = "USB device unplugged: $($device.Caption) - $(Get-Date)"
            Write-Host $logEntry
            $logEntry | Out-File -Append -FilePath $logFilePath
        }
    }

    $previousDevices = $currentDevices
}
