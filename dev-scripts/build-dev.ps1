<#
.SYNOPSIS
  Builds the frontend in development mode.

.DESCRIPTION
  This script builds the frontend files with all development
  flags turned on. This produces files with very few optimizations.

.NOTES
  All build artifacts should be in ".../{PROJECT}/wwwroot". Everything in
  that folder should be considered ephemeral.
#>

$env:NODE_ENV='development'

& "$PSScriptRoot\clear-artifacts.ps1"

webpack --mode development --config webpack.development.js