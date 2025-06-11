<#
.SYNOPSIS
    Scans for files with alternate data streams (ADS) excluding default :$DATA stream.

.DESCRIPTION
    Recursively searches a safer directory (e.g., user profile or a test path).
    Filters for archived files and identifies those with named ADS.

.NOTES
    Scanning entire C:\ drive is discouraged unless done with specific exclusions and at low system load.
#>

$scanRoot = "$env:USERPROFILE"  # Change to a safer path, e.g., 'C:\temp' or test folder

Write-Host "Scanning for ADS in: $scanRoot`n"

try {
    $results = Get-ChildItem -Path $scanRoot -Recurse -Force -ErrorAction SilentlyContinue |
        ForEach-Object {
            try {
                Get-Item -Path $_.FullName -Stream * -ErrorAction SilentlyContinue |
                    Where-Object {
                        $_.Attributes -match 'Archive' -and $_.Stream -ne ':$DATA'
                    }
            } catch {
                # Skip inaccessible files
            }
        }

    if ($results) {
        $results | Select-Object FileName, Stream, Length, Attributes | Format-Table -AutoSize
        Write-Host "`nFound $($results.Count) files with named alternate data streams."
    } else {
        Write-Host "No alternate data streams found."
    }
} catch {
    Write-Error "Error during scan: $_"
}
