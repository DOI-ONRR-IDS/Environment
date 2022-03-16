<#
.SYNOPSIS
  Analyzes the output artifacts of the production build.

.DESCRIPTION
  This script analyzes the production build for various
  statistics.
#>

npm run unlink

npm install

$env:NODE_ENV='production'

& "$PSScriptRoot\clear-artifacts.ps1"

webpack --mode production --config webpack.analyze.js