$ErrorActionPreference = 'Stop'

$packageName = 'nvda'

$fileType      = 'exe'
$toolsDir      = Split-Path $MyInvocation.MyCommand.Definition
$embedded_path = gi "$toolsDir\*.$fileType"

$pp = Get-PackageParameters
$params=@()
if ($pp.NoLogon)     { Write-Host 'Do not start on the logon screen'; $params += '--enable-start-on-logon False'}

$packageArgs = @{
  packageName    = $packageName
  fileType       = $fileType
  file           = $embedded_path
  silentArgs     = '--install-silent',($params -join ' ') -join ' '
  validExitCodes = @(0)
  softwareName   = $packageName.ToUpper()
}
Install-ChocolateyInstallPackage @packageArgs
rm $embedded_path -ea 0

$packageName = $packageArgs.packageName
$installLocation = Get-AppInstallLocation $packageName
if (!$installLocation)  { Write-Warning "Can't find $packageName install location"; return }
Write-Host "$packageName installed to '$installLocation'"

Register-Application "$installLocation\$packageName.exe"
Write-Host "$packageName registered as $packageName"
