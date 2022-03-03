<#
.SYNOPSIS
  Builds the frontend in production mode.

.DESCRIPTION
  This script builds the frontend files with all production
  flags turned on. This produces files with all optimzations.

.NOTES
  All build artifacts should be in ".../{PROJECT}/wwwroot". Everything in
  that folder should be considered ephemeral.
#>

$env:NODE_ENV='production'

& "$PSScriptRoot\clear-artifacts.ps1"

webpack --mode production --config webpack.production.js