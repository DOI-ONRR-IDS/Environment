<#
.SYNOPSIS
  Initializes the project.

.DESCRIPTION
  This script needs to be run once, after the project is first downloaded.
  - Download missing scripts from https://github.com/DOI-ONRR-IDS/Environment/tree/master/dev-scripts
  - Create .npmrc, if missing
  - Install dependencies
  - Install mkcert
  - Install a local CA
  - Install a new self-signed certificate

.NOTES
  This script is mostly idempotent. You should be able to safely run it
  multiple times, for instance to regenerate the SSL certs.

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

function RunCommandAsAdmin {
  Param(
    [string]$ExecutionPath,
    [string]$Command
  )

  $Command = "cd '" + $ExecutionPath + "'; " + $Command + ";"
  Start-Process -FilePath PowerShell.exe -Verb Runas -ArgumentList '-Command', $Command
}

function TestCommandExists {
  Param ($command)
  try {
    if(Get-Command $command) {
      return $true;
    }
  } 
  Catch {
    return $false;
  }
}



$OriginalLocation = "$pwd"



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
    Write-Host ".npmrc.example file not found! Exiting..."
    Exit
  }

  $NPMPAT = Read-Host "Enter your GitHub PAT for reading from the organization package registry"

  Copy-Item -Path $NPMRCExamplePath -Destination $NPMRCPath

  (Get-Content $NPMRCPath).replace("_authToken=", "_authToken=$NPMPAT") | Set-Content $NPMRCPath
}
else {
  Write-Host ".npmrc file already present."
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
if(!(TestCommandExists -Command "mkcert")) {
  RunCommandAsAdmin -ExecutionPath $OriginalLocation -Command "choco install mkcert"
}
else {
  Write-Host "mkcert already installed."
}

# Add the mkcert certificate authority to the machine.
# On first-run, this will generate a confirmation window.
Write-Host "Installing CA..."
mkcert -install

# Create a local certificate.
Write-Host "Generating self-signed certificate..."
mkcert -key-file $CertsFolder/localhost-key.pem -cert-file $CertsFolder/localhost.pem localhost 

# Re-add the certificate to the machine's store.
Write-Host "Installing self-signed certificate..."
RunCommandAsAdmin -ExecutionPath $OriginalLocation -Command "certutil -delstore -f ""ROOT"" $CertsFolder/localhost.pem; certutil -addstore -f ""ROOT"" $CertsFolder/localhost.pem;"