$ErrorActionPreference = 'Stop'

$packageName = 'axesword'

$fileType      = 'exe'
$url           = 'https://www.axes4.com/_Resources/Persistent/4/0/4/1/4041d1db9c916234d9f7cd932c60fb9d621cd6e5/axesWord.Setup.exe'
$checksum      = 'D47242EED9BF21B547DDD56F006CA48D5EE3A32A64F1144E53F6CDB4B30709C0'

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
