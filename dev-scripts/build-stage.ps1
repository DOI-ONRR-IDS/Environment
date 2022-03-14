<#
.SYNOPSIS
  Builds the frontend in staging mode.

.DESCRIPTION
  This script builds the frontend files with all staging
  flags turned on. This produces files with some optimzations.

.NOTES
  All build artifacts should be in ".../{PROJECT}/wwwroot". Everything in
  that folder should be considered ephemeral.
#>

$env:NODE_ENV='staging'

& "$PSScriptRoot\clear-artifacts.ps1"

npm run unlink

npm install

webpack --mode production --config webpack.staging.js
