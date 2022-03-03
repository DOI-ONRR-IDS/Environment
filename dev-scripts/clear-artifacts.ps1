<#
.SYNOPSIS
  Deletes build artifacts.

.DESCRIPTION
  This script clears out the output folders of the build process. This
  isn't strictly required but does help avoid any left-over files that
  may conflict with the dev server or cache busting.

.NOTES
  All build artifacts should be in ".../{PROJECT}/wwwroot". Everything in
  that folder should be considered ephemeral.
#>

if (Test-Path "./wwwroot")
{
  Remove-Item "./wwwroot/*" -Force -Recurse
}
