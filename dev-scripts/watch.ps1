<#
.SYNOPSIS
  Builds the frontend in development mode, the dev server
  proxy, and Hot Module Reloading (HMR).

.DESCRIPTION
  This script builds the frontend files with all development
  flags turned on. This produces files with very few optimzations.
  It also starts the webpack-dev-server proxy to enable HMR.

.NOTES
  webpack-dev-server keeps all build artifacts in memory and writes
  nothing to disk.

  The port for the proxy server will be different from the port for the
  IIS Express server.
#>

$env:NODE_ENV='development'

& "$PSScriptRoot\clear-artifacts.ps1"

webpack serve --hot --mode development --config webpack.development.js