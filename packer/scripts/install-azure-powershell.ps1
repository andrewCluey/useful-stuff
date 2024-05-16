# See https://docs.microsoft.com/en-us/powershell/azure/install-az-ps-msi?view=azps-7.3.2#install-or-update-on-windows-using-the-msi-package

$ErrorActionPreference = "Stop"

Write-Host "Installing ..."
Install-Module -Name Az -Repository PSGallery -Force
Write-Host "Done."