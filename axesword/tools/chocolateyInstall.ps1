$ErrorActionPreference = 'Stop'

$packageName = 'axesword'

$fileType      = 'exe'
$url           = 'https://www.axes4.com/_Resources/Persistent/6/c/7/9/6c79692be7af5e9f85129dfaea2579c586234dc6/axesWord.Setup.exe'
$checksum      = 'D3F59F705A7591344082C12746DACDF64454E6F1B30A371DCB5CB2C822676F1C'

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
