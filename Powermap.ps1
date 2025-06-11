<#
.SYNOPSIS
    Performs a TCP port scan using System.Net.Sockets.TcpClient.

.DESCRIPTION
    This script initiates full TCP handshakes against specified ports and hosts.
    It reports open, closed, or filtered ports based on connectivity and timeout behavior.

.PARAMETER ComputerName
    Hostnames or IP addresses to scan.

.PARAMETER Port
    Port numbers or ranges to scan.

.PARAMETER Timeout
    Timeout duration in milliseconds (default is 1000ms).

.EXAMPLE
    .\PortScan.ps1 -ComputerName "localhost" -Port 80

.EXAMPLE
    .\PortScan.ps1 -ComputerName "10.10.10.1" -Port (1..1024) -Timeout 2000
#>

[CmdletBinding()]
param (
    [Parameter(Mandatory = $true, Position = 0)]
    [Alias("Host", "Server", "h")]
    [string[]]$ComputerName,

    [Parameter(Mandatory = $true, Position = 1)]
    [Alias("p")]
    [int[]]$Port,

    [Parameter()]
    [Alias("t")]
    [int]$Timeout = 1000
)

function Invoke-PortScan {
    [CmdletBinding()]
    param (
        [string[]]$ComputerName,
        [int[]]$Port,
        [int]$Timeout
    )

    foreach ($Computer in $ComputerName) {
        foreach ($PortNum in $Port) {
            Write-Verbose "Scanning $Computer on port $PortNum"

            $tcpClient = New-Object System.Net.Sockets.TcpClient
            try {
                $asyncResult = $tcpClient.BeginConnect($Computer, $PortNum, $null, $null)
                $waitResult = $asyncResult.AsyncWaitHandle.WaitOne($Timeout, $false)

                if (-not $waitResult) {
                    [PSCustomObject]@{
                        ComputerName = $Computer
                        Port         = $PortNum
                        State        = 'Closed'
                        Notes        = 'Timeout expired'
                    }
                } else {
                    $tcpClient.EndConnect($asyncResult)
                    [PSCustomObject]@{
                        ComputerName = $Computer
                        Port         = $PortNum
                        State        = 'Open'
                        Notes        = $null
                    }
                }
            } catch {
                [PSCustomObject]@{
                    ComputerName = $Computer
                    Port         = $PortNum
                    State        = 'Filtered'
                    Notes        = $_.Exception.Message
                }
            } finally {
                $tcpClient.Close()
                $tcpClient.Dispose()
            }
        }
    }
}

# Main execution
Invoke-PortScan -ComputerName $ComputerName -Port $Port -Timeout $Timeout



Usage:
Scan port 80 on localhost

.\PortScan.ps1 -ComputerName "localhost" -Port 80

Scan a range of ports on a remote IP

.\PortScan.ps1 -ComputerName "192.168.1.100" -Port (1..1024)

Scan multiple hosts on a few common ports

.\PortScan.ps1 -ComputerName "192.168.1.100", "10.0.0.50" -Port 22, 80, 443

Set a longer timeout (5 seconds per port)

.\PortScan.ps1 -ComputerName "example.com" -Port 443 -Timeout 5000

Export the results to CSV

.\PortScan.ps1 -ComputerName "10.1.1.1" -Port (80, 443, 3389) | Export-Csv -Path .\ScanResults.csv -NoTypeInformation
