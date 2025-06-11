<#
.SYNOPSIS
    Retrieves inbound Windows Firewall rules that are enabled and allow traffic.

.DESCRIPTION
    Uses the modern NetSecurity module (`Get-NetFirewallRule`) to get firewall rules,
    filters for:
        - Enabled
        - Inbound Direction
        - Allow Action
    Retrieves port and protocol details using associated objects.

.NOTES
    Author: Jaap Brasser  
    Modified by: Dallas Moore  
    Refactored by: ChatGPT  
#>

[CmdletBinding()]
param ()

# Set up output path
$outputFile = "C:\Temp\FWAudit-$env:COMPUTERNAME--$(Get-Date -Format 'yyyyMMdd').txt"

# Optional: Console formatting
$host.UI.RawUI.BufferSize = New-Object Management.Automation.Host.Size(150, 3000)
$host.UI.RawUI.WindowSize = New-Object Management.Automation.Host.Size(120, 50)
$FormatEnumerationLimit = -1

# Email settings (optional)
$mailParams = @{
    SmtpServer  = 'mailhost.domain.com'
    From        = 'youraccount@yourdomain.com'
    To          = 'youraccount@yourdomain.com'
    Subject     = "Firewall Rules Audit - $env:COMPUTERNAME - $(Get-Date -Format 'yyyy-MM-dd')"
    Body        = "Attached are the firewall rules for $env:COMPUTERNAME"
    Attachments = $outputFile
}

# Start logging
Start-Transcript -Path $outputFile -Append

# Get inbound allow firewall rules
$rules = Get-NetFirewallRule -Direction Inbound -Action Allow -Enabled True |
    Where-Object { $_.Profile -ne 'Any' -or $_.DisplayName } | # Filter out incomplete/inactive rules
    ForEach-Object {
        $rule = $_
        $filter = Get-NetFirewallPortFilter -AssociatedNetFirewallRule $rule
        [PSCustomObject]@{
            'Rule Name'   = $rule.DisplayName
            'Enabled'     = $rule.Enabled
            'Direction'   = $rule.Direction
            'Action'      = $rule.Action
            'Protocol'    = $filter.Protocol
            'LocalPort'   = $filter.LocalPort
            'RemotePort'  = $filter.RemotePort
            'RemoteIP'    = $rule.RemoteAddress -join ', '
            'Profiles'    = $rule.Profile -join ', '
            'Program'     = $rule.Program
            'Service'     = $rule.Service
        }
    } | Sort-Object 'Rule Name'

# Output to console and save
$rules | Format-Table -AutoSize -Wrap | Out-String | Tee-Object -FilePath $outputFile -Append

# End logging
Stop-Transcript

# Send report by email
Send-MailMessage @mailParams
