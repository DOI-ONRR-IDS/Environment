<#
.SYNOPSIS
  Initializes the project.

.DESCRIPTION
  This script needs to be run once, after the project is first downloaded.
  1. Create an elevated terminal
  2. Install mkcert
  3. Install a local CA
  4. Install a new self-signed certificate

.NOTES
  Certificates are stored in ".../{PROJECT}/ssl".

  This process is required to use https in the local dev environment. If, this
  process cannot be completed on a given machine, https can be circumvented by
  altering ".../{PROJECT}/webpack.development.js", ".../{PROJECT}/Startup.cs",
  and .../{PROJECT}/Properties/launchSettings.json".
#>

$OriginalLocation = "$pwd"
$CertsFolder = "$pwd/ssl"

# Ask for elevated session.
# This may trigger a UAC confirmation.
if (-Not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator'))
{
  if ([int](Get-CimInstance -Class Win32_OperatingSystem | Select-Object -ExpandProperty BuildNumber) -ge 6000)
  {
    $Command = "cd '" + $OriginalLocation + "'; & '" + $MyInvocation.MyCommand.Path + "' " + $MyInvocation.UnboundArguments + ";"
    Start-Process -FilePath PowerShell.exe -Verb Runas -ArgumentList '-Command', $Command
    Exit
  }
}

if (!(Test-Path $CertsFolder))
{
  New-Item -Path $CertsFolder -ItemType "directory"
}

# Install the mkcert utility.
choco install mkcert

# Add the mkcert certificate authority to the machine.
# On first-run, this will generate a confirmation window.
mkcert -install

# Create a local certificate.
mkcert -key-file $CertsFolder/localhost-key.pem -cert-file $CertsFolder/localhost.pem localhost 

# Re-add the certificate to the machine's store.
certutil -delstore -f "ROOT" $CertsFolder/localhost.pem
certutil -addstore -f "ROOT" $CertsFolder/localhost.pem
