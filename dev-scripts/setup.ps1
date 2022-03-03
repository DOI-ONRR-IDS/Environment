<#
.SYNOPSIS
  Initializes the project.

.DESCRIPTION
  This script needs to be run once, after the project is first downloaded.
  - Create an elevated terminal
  - Download missing scripts from https://github.com/DOI-ONRR-IDS/Environment/tree/master/dev-scripts
  - Create .npmrc, if missing
  - Install dependencies
  - Install mkcert
  - Install a local CA
  - Install a new self-signed certificate

.NOTES
  Certificates are stored in ".../{PROJECT}/ssl".

  This process is required to use https in the local dev environment. If, this
  process cannot be completed on a given machine, https can be circumvented by
  altering ".../{PROJECT}/webpack.development.js", ".../{PROJECT}/Startup.cs",
  and .../{PROJECT}/Properties/launchSettings.json".
#>



function DownloadFilesFromRepo {
  Param(
    [string]$Owner,
    [string]$Repository,
    [string]$Path,
    [string]$DestinationPath
  )

  $baseUri = "https://api.github.com/"
  $args = "repos/$Owner/$Repository/contents/$Path"
  $wr = Invoke-WebRequest -Uri $($baseuri+$args)
  $objects = $wr.Content | ConvertFrom-Json
  $files = $objects | where {$_.type -eq "file"} | Select -exp download_url
  $directories = $objects | where {$_.type -eq "dir"}
  
  $directories | ForEach-Object { 
    DownloadFilesFromRepo -Owner $Owner -Repository $Repository -Path $_.path -DestinationPath $($DestinationPath+$_.name)
  }

  
  if (-not (Test-Path $DestinationPath)) {
    # Destination path does not exist, let's create it
    try {
      New-Item -Path $DestinationPath -ItemType Directory -ErrorAction Stop
    } catch {
      throw "Could not create path '$DestinationPath'!"
    }
  }

  foreach ($file in $files) {
    $fileDestination = Join-Path $DestinationPath (Split-Path $file -Leaf)
    try {
      Invoke-WebRequest -Uri $file -OutFile $fileDestination -ErrorAction Stop -Verbose
      "Grabbed '$($file)' to '$fileDestination'"
    } catch {
      throw "Unable to download '$($file.path)'"
    }
  }
}



<#
  Elevate terminal
#>

$OriginalLocation = "$pwd"

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



<#
  Development scripts
#>

$TempScriptsPath = "$pwd/dev-scripts/temp"

DownloadFilesFromRepo -Owner "DOI-ONRR-IDS" -Repository "Environment" -Path "dev-scripts" -DestinationPath $TempScriptsPath

Get-ChildItem $TempScriptsPath -Filter *.ps1 | 
Foreach-Object {
  $FullName = $_.FullName
  $Name = $_.Name
  $DestinationFilePath = "$pwd/dev-scripts/$Name"

  if (!(Test-Path $DestinationFilePath))
  {
    Write-Host "$Name file not found. Creating..."

    (Get-Content $FullName) | Set-Content ($DestinationFilePath)
  }
}

Remove-Item -Path $TempScriptsPath -Force -Recurse



<#
  .npmrc file
#>

$NPMRCPath = "$pwd/.npmrc"
$NPMRCExamplePath = "$pwd/.npmrc.example"

if (!(Test-Path $NPMRCPath))
{
  Write-Host ".npmrc file not found. Creating..."

  if (!(Test-Path $NPMRCExamplePath))
  {
    Write-Host ".npmrc.example file not found. Aborting..."
    Exit
  }

  $NPMPAT = Read-Host "Enter your GitHub PAT for reading from the organization package registry"

  Copy-Item -Path $NPMRCExamplePath -Destination $NPMRCPath

  (Get-Content $NPMRCPath).replace("_authToken=", "_authToken=$NPMPAT") | Set-Content $NPMRCPath
}



<#
  Install dependencies
#>

dotnet restore

npm install



<#
  SSL certificates
#>

$CertsFolder = "$pwd/ssl"

if (!(Test-Path $CertsFolder))
{
  Write-Host "ssl/ directory not found. Creating..."

  New-Item -Path $CertsFolder -ItemType "directory"
}

# Install the mkcert utility.
Write-Host "Installing mkcert..."
choco install mkcert

# Add the mkcert certificate authority to the machine.
# On first-run, this will generate a confirmation window.
Write-Host "Installing CA..."
mkcert -install

# Create a local certificate.
Write-Host "Generating self-signed certificate..."
mkcert -key-file $CertsFolder/localhost-key.pem -cert-file $CertsFolder/localhost.pem localhost 

# Re-add the certificate to the machine's store.
Write-Host "Installing self-signed certificate..."
certutil -delstore -f "ROOT" $CertsFolder/localhost.pem
certutil -addstore -f "ROOT" $CertsFolder/localhost.pem
