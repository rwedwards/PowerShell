function Get-LogonFailures {
    [CmdletBinding()]
    param (
        [datetime]$Since = (Get-Date).AddDays(-30),
        [string]$ExportPath = "$env:USERPROFILE\logon_failures.csv"
    )

    $filter = @{
        LogName = 'Security'
        Id = 4625
        StartTime = $Since
    }

    $failures = Get-WinEvent -FilterHashtable $filter | ForEach-Object {
        $properties = $_.Properties

        [PSCustomObject]@{
            TimeCreated         = $_.TimeCreated
            SubjectUserSid      = $properties[0].Value
            SubjectUserName     = $properties[1].Value
            SubjectDomainName   = $properties[2].Value
            SubjectLogonId      = $properties[3].Value
            LogonType           = $properties[8].Value
            FailureReason       = $properties[23].Value
            Status              = $properties[12].Value
            SubStatus           = $properties[13].Value
            ProcessName         = $properties[17].Value
            WorkstationName     = $properties[11].Value
            SourceAddress       = $properties[18].Value
            SourcePort          = $properties[19].Value
        }
    }

    $failures | Export-Csv -Path $ExportPath -NoTypeInformation -Encoding UTF8
    Write-Host "Logon failure events exported to: $ExportPath" -ForegroundColor Green
}








#######
#######
#Example Usage
Get-LogonFailures -Since (Get-Date).AddDays(-7) -ExportPath "C:\Logs\logon_failures_last_7_days.csv"

