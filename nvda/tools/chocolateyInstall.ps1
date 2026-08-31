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
  # NVDA 2026 and later only run on 64 bit Windows. Passing the installer as
  # file64 with no file makes Chocolatey refuse a 32 bit install with
  # "32-bit installation is not supported for nvda" instead of running a
  # launcher that cannot work.
  file64         = $embedded_path
  # --minimal means no sounds, no interface and no start message while the
  # temporary copy of NVDA performs the install. It was added while chasing a
  # verifier hang, which it did not fix, but it keeps an unattended install
  # quiet, so it stays.
  silentArgs     = '--minimal --install-silent',($params -join ' ') -join ' '
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
