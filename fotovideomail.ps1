# onde guarda a foto e o video
$savePath = "C:\Windows\Martelo\captured_image.jpg"
$tempVideoFile = "C:\Windows\Martelo\video.mp4"

# Nome da webcam
$webcamDeviceName = "GENERAL WEBCAM"

# resolucao para a foto
$width = 640
$height = 480

# path do ffmpeg.exe
$ffmpegPath = "C:\Windows\Martelo\ffmpeg-2024-01-17-git-8e23ebe6f9-essentials_build\bin\ffmpeg.exe"

# grava um video de 10 segundos com o ffmpeg
& $ffmpegPath -f dshow -i video="$webcamDeviceName" -s ${width}x${height} -t 10 -y $tempVideoFile

# usa o ffmpeg para extrair um frame do video gravado
& $ffmpegPath -i $tempVideoFile -vf "select=eq(n\,0)" -vframes 1 -q:v 2 -y "$savePath"

Write-Host "Imagem guardada: $savePath"
Write-Host "Video guardado: $tempVideoFile"



# Declare global variables
$global:EmailFrom = "a061423049123@hotmail.com"
$global:EmailTo = "a061423049123@hotmail.com"
$global:Password = "SimplePassword123"
$global:Subject = "Fail Login"
$global:Body = "Failed Login attempt"
$global:SMTPServer = "smtp.outlook.com"
$global:SMTPClient = New-Object Net.Mail.SmtpClient($global:SMTPServer, 587)
$global:SMTPClient.EnableSsl = $true
$global:SMTPClient.Credentials = New-Object System.Net.NetworkCredential($global:EmailFrom, $global:Password)

# Create a MailMessage object
function createMailMessage {
    # Use global variables
    $global:MailMessage = New-Object Net.Mail.MailMessage
    $global:MailMessage.From = $global:EmailFrom
    $global:MailMessage.To.Add($global:EmailTo)
    $global:MailMessage.Subject = $global:Subject
    $global:MailMessage.Body = $global:Body
}

# Create an Attachment
function createAttachment {
    createMailMessage
    # Create an Attachment object and add it to the MailMessage
    $Attachment = New-Object Net.Mail.Attachment($savePath)

    $Attachment2 = New-Object Net.Mail.Attachment($tempVideoFile)
    
    $global:MailMessage.Attachments.Add($Attachment)
    $global:MailMessage.Attachments.Add($Attachment2)
}

# Send the email
function sendMail {
    createAttachment
    try {
        $global:SMTPClient.Send($global:MailMessage)
        return $true
    } catch {
        #cls
        write-host "`n[+] Error sending Email to $global:EmailTo [+]`n"
        return $false
    }
}

# Call the sendMail function to initiate the process

if (sendMail) {
    #cls
    write-host "`n[+] Email sent to -> $global:EmailTo [+]`n"
}