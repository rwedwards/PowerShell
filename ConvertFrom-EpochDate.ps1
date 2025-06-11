<#
.SYNOPSIS
    Converts a Unix Epoch time (seconds since 1/1/1970) to a local DateTime.

.DESCRIPTION
    Accepts a Unix Epoch time as input (supports fractional seconds) and returns
    the equivalent local DateTime object.

.EXAMPLE
    PS> Convert-FromEpochTime -Epoch 1327084231.40557
    Friday, January 20, 2012 1:30:31 PM

.EXAMPLE
    PS> Convert-FromEpochTime
    Enter the Unix Epoch Time: 1327084231
    Friday, January 20, 2012 1:30:31 PM
#>
function Convert-FromEpochTime {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false, Position = 0)]
        [ValidateScript({ $_ -as [double] })]
        [double]$Epoch
    )

    if (-not $PSBoundParameters.ContainsKey('Epoch')) {
        $inputStr = Read-Host 'Enter the Unix Epoch Time'
        if (-not [double]::TryParse($inputStr, [ref]$Epoch)) {
            Write-Error "Invalid input. Please enter a numeric Unix timestamp."
            return
        }
    }

    try {
        $baseDate = [datetime]'1970-01-01T00:00:00Z'
        $convertedDate = $baseDate.AddSeconds($Epoch).ToLocalTime()
        return $convertedDate
    } catch {
        Write-Error "Failed to convert epoch time: $($_.Exception.Message)"
    }
}

# Call the function if script is executed directly
if ($MyInvocation.InvocationName -eq '.') {
    Convert-FromEpochTime
}
