# PowerShell script to capture a picture from a webcam using ffmpeg

# Set the path where you want to save the captured image
$savePath = "C:\Windows\Martelo\captured_image.jpg"

# Set the webcam device name (replace with the correct name from the output of the command)
$webcamDeviceName = "GENERAL WEBCAM"

# Set the resolution of the captured image (update with the correct values)
$width = 640
$height = 480

# Set the path to the ffmpeg executable
$ffmpegPath = "C:\Windows\Martelo\ffmpeg-2024-01-20-git-6c4388b468-essentials_build\bin\ffmpeg.exe"

# Set the filename of the temporary video file
$tempVideoFile = "C:\Windows\Martelo\video.mp4"

# Use ffmpeg to capture a video from the webcam
& $ffmpegPath -f dshow -i video="$webcamDeviceName" -s ${width}x${height} -t 10 -y $tempVideoFile

# Use ffmpeg to extract a single frame (image) from the captured video
& $ffmpegPath -i $tempVideoFile -vf "select=eq(n\,0)" -vframes 1 -q:v 2 -y "$savePath"

Write-Host "Image captured and saved to: $savePath"
Write-Host "Video captured and saved to: $tempVideoFile"



# Declare global variables
$global:EmailFrom = "a061423049123@hotmail.com"
$global:EmailTo = "a061423049123@hotmail.com"
$global:Password = "SimplePassword123"
$global:Subject = "Login Failed"
$global:Body = "There was a failed login attempt on your computer"
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
    $file = "C:\Windows\Martelo\captured_image.jpg"
    $Attachment = New-Object Net.Mail.Attachment($file)

    $file2 = "C:\Windows\Martelo\video.mp4"
    $Attachment2 = New-Object Net.Mail.Attachment($file2)
    
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
        write-host "[+] Error sending Email to $global:EmailTo [+]"
        return false
    }
}

# Call the sendMail function to initiate the process

if (sendMail) {
    write-host "`n[+] Email sent to -> $global:EmailTo [+]`n"
}