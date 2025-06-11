function Get-IPConfig {
    [CmdletBinding()]
    param (
        [switch]$Global
    )

    if ($Global) {
        # Global system network info
        Get-NetIPConfiguration |
        Select-Object -First 1 |
        Select-Object -Property InterfaceAlias, InterfaceDescription, IPv4DefaultGateway, DNSServer
    }
    else {
        # Per-adapter info
        $adapters = Get-NetAdapter -Physical | Where-Object { $_.Status -eq 'Up' }

        $adapters | ForEach-Object {
            $adapterConfig = Get-NetIPConfiguration -InterfaceIndex $_.ifIndex

            [PSCustomObject]@{
                Name            = $_.Name
                Type            = $_.InterfaceDescription
                Status          = $_.Status
                MACAddress      = $_.MacAddress
                IPv4Address     = ($adapterConfig.IPv4Address | Select-Object -First 1).IPAddress
                SubnetMask      = ($adapterConfig.IPv4Address | Select-Object -First 1).PrefixLength
                DefaultGateway  = $adapterConfig.IPv4DefaultGateway.NextHop
                DNSServers      = ($adapterConfig.DnsServer.ServerAddresses -join ', ')
            }
        }
    }
}

# Example usage: show adapter-level config
Get-IPConfig | Format-Table -AutoSize
