<#
.SYNOPSIS
  Audits licenses within NPM dependencies.

.DESCRIPTION
  This script uses that "license-checker" NPM module to audit dependency licenses.
  It only checks production dependencies and ignores any licenses that permit commercial
  use without a share-alike clause.

.NOTES
  This uses an explicit allow-list of known-good licenses. If more are found, they'll need
  to be added to the list. The list can be edited at
  https://github.com/DOI-ONRR-IDS/Environment/blob/master/AllowedLicenses.txt
#>

$AllowList = (Invoke-WebRequest "https://github.com/DOI-ONRR-IDS/Environment/raw/master/AllowedLicenses.txt").Content

license-checker --production --exclude "$AllowList"
