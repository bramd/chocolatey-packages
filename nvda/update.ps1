import-module au
. $PSScriptRoot\..\_scripts\all.ps1

# This uRL is used by NVDA's update checker and returns a download URL for the latest version
# We request an update from version 2025.3, which returns the latest version as of now. If this changes in the future, we might need to make the version dynamic.
$releases    = 'https://api.nvaccess.org/nvdaUpdateCheck?autoCheck=False&allowUsageStats=False&version=2025.3&versionType=stable&osVersion=&x64=True'

function global:au_SearchReplace {
   @{
        ".\tools\chocolateyInstall.ps1" = @{
            "(?i)(^\s*[$]packageName\s*=\s*)('.*')"= "`$1'$($Latest.PackageName)'"
            "(?i)(^\s*[$]fileType\s*=\s*)('.*')"   = "`$1'$($Latest.FileType)'"
        }

        "$($Latest.PackageName).nuspec" = @{
            "(\<releaseNotes\>).*?(\</releaseNotes\>)" = "`${1}$($Latest.ReleaseNotes)`$2"
        }

        ".\legal\VERIFICATION.txt" = @{
          "(?i)(\s+file:).*"            = "`${1} $($Latest.URL64)"
          "(?i)(checksum type:).*"   = "`${1} $($Latest.ChecksumType64)"
          "(?i)(checksum:).*"        = "`${1} $($Latest.Checksum64)"
        }
    }
}

function global:au_BeforeUpdate { Get-RemoteFiles -Purge }

function global:au_GetLatest {
    $download_page = Invoke-WebRequest -Uri $releases | Select -ExpandProperty Content

    $url = $download_page -split "`n" -match "launcherUrl:" -split ": " | Select -last 1
    # URL contains ?update=1 by default, let's strip this
    $url = $url -split "\?update" | Select -first 1

    $version = $url -split '_|.exe' | Select -Last 1 -Skip 1
    # The Chocolatey community repository rejects non-normalized versions with a
    # 400 Bad Request, so pad two part versions: 2026.2 -> 2026.2.0
    if ($version -notmatch '^\d+\.\d+\.\d+') { $version = "$version.0" }

    # The update check no longer returns a changesUrl line, so fall back to the
    # full change log, which covers every version.
    $releaseNotes = $download_page -split "`n" -match "changesUrl:" -split ": " | Select -Last 1
    if (!$releaseNotes) { $releaseNotes = 'https://download.nvaccess.org/documentation/changes.html' }

    $checksum64 = $download_page -split "`n" -match "launcherHash:" -split ": " | Select -Last 1

    return @{
        # NVDA 2026 and later only run on 64 bit Windows, so the package is a 64
        # bit one even though the launcher itself is still a 32 bit stub.
        URL64        = $url
        # Checksum64/ChecksumType64 are overwritten by Get-RemoteFiles, which
        # hashes the downloaded file with sha256.
        Checksum64   = $checksum64
        Version      = $version
        ReleaseNotes = $releaseNotes
    }
}

update -ChecksumFor none
