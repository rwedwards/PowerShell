<#
.SYNOPSIS
    Retrieves your public IP address and gathers geolocation data from ipinfo.io.

.DESCRIPTION
    This script uses eth0.me to get your public IP, then queries ipinfo.io for IP-related metadata.
#>

try {
    # Get public IP
    $publicIp = (Invoke-RestMethod -Uri "https://eth0.me").Trim()
    Write-Verbose "Detected IP: $publicIp"

    # Get geolocation info
    $geoInfo = Invoke-RestMethod -Uri "https://ipinfo.io/$publicIp/json"

    # Display result
    $geoInfo
} catch {
    Write-Error "Failed to retrieve IP info: $_"
}
