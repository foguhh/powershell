# Start transcript logging to a file
Start-Transcript -Path "C:\Windows\Martelo\usb-log.txt" -Append

# Define the query to monitor USB device connection and disconnection events
$queryCreation = @"
    SELECT * FROM __InstanceCreationEvent WITHIN 2
    WHERE TargetInstance ISA 'Win32_PnPEntity'
"@

$queryDeletion = @"
    SELECT * FROM __InstanceDeletionEvent WITHIN 2
    WHERE TargetInstance ISA 'Win32_PnPEntity'
"@

# Register the event for device connection
Register-WmiEvent -Query $queryCreation -Action {
    $usbDevice = $event.SourceEventArgs.NewEvent.TargetInstance
    if ($usbDevice.PNPClass -eq "USB") {
        $deviceName = $usbDevice.Description
        $timePluggedIn = Get-Date
        Write-Host "USB Device connected: $deviceName"
        Write-Host "Time plugged in: $timePluggedIn"
        Write-Host "------------------------"
    }
}

# Register the event for device disconnection
Register-WmiEvent -Query $queryDeletion -Action {
    $usbDevice = $event.SourceEventArgs.NewEvent.TargetInstance
    if ($usbDevice.PNPClass -eq "USB") {
        $deviceName = $usbDevice.Description
        $timeRemoved = Get-Date
        Write-Host "USB Device removed: $deviceName"
        Write-Host "Time removed: $timeRemoved"
        Write-Host "------------------------"
    }
}

# Keep the script running to continuously monitor events
while ($true) {
    Start-Sleep -Seconds 1
}

# Stop transcript logging
Stop-Transcript
