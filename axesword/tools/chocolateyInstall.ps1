$ErrorActionPreference = 'Stop'

$packageName = 'axesword'

$fileType      = 'exe'
$url           = 'https://www.axes4.com/_Resources/Persistent/0/b/2/b/0b2b984658591aaf49c73985b3b1d57915114c82/axesWord.Setup.exe'
$checksum      = 'BBBAA1F60DB288C2881516B65D8087CC39DB0C07FBAD56D45EDFF056F7A04AEB'

$pp = Get-PackageParameters
$params=@()

$packageArgs = @{
  packageName    = $packageName
  fileType       = $fileType
  url            = $url
  checksum       = $checksum
  checksumType   = 'sha256'
  silentArgs     = '/quiet /noreboot' + ($params -join ' ')
  validExitCodes = @(0)
  softwareName   = "axesWord"
}
Install-ChocolateyPackage @packageArgs

$packageName = $packageArgs.packageName
$installLocation = Get-AppInstallLocation $packageName
if (!$installLocation)  { Write-Warning "Can't find $packageName install location"; return }
Write-Host "$packageName installed to '$installLocation'"

Register-Application "$installLocation\axesPDF-for-Word.dll"
Write-Host "$packageName registered as $packageName"
