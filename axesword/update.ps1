import-module au
. $PSScriptRoot\..\_scripts\all.ps1

$releases    = 'https://www.axes4.com/en/products-services/axesword/download'

function global:au_SearchReplace {
   @{
        ".\tools\chocolateyInstall.ps1" = @{
            "(?i)(^\s*[$]packageName\s*=\s*)('.*')"= "`$1'$($Latest.PackageName)'"
            "(?i)(^\s*[$]fileType\s*=\s*)('.*')"   = "`$1'$($Latest.FileType)'"
            "(?i)(^\s*[$]url\s*=\s*)('.*')"   = "`$1'$($Latest.Url32)'"
            "(?i)(^\s*[$]checksum\s*=\s*)('.*')"   = "`$1'$($Latest.Checksum32)'"
        }

        "$($Latest.PackageName).nuspec" = @{
        }

        ".\legal\VERIFICATION.txt" = @{
          "(?i)(\s+file:).*"            = "`${1} $($Latest.URL32)"
          "(?i)(checksum:).*"        = "`${1} $($Latest.Checksum32)"
        }
    }
}

function global:au_BeforeUpdate { Get-RemoteFiles -Purge }

function global:au_GetLatest {
     $download_page = Invoke-WebRequest -Uri $releases -UseBasicParsing #1
     $regex   = '.exe$'
     $url     = $download_page.links | ? href -match $regex | select -First 1 -expand href #2
     $version = [regex]::Match($download_page.Content, "Current Version: ([0-9\.]+)").Groups[1].Value
     return @{ Version = $version; URL32 = $url }
}

update