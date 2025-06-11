<#
.SYNOPSIS
    Lists processes with a high handle count (>= 500).

.DESCRIPTION
    Filters processes based on handle count and displays the process name,
    handle count, and file description, if accessible.

.NOTES
    Some properties (like `Description`) come from the executable file,
    which may require elevated permissions.
#>

Get-Process |
    Where-Object { $_.Handles -ge 500 } |
    Sort-Object -Property Handles -Descending |
    Select-Object -Property Handles, Name, @{Name='Description';Expression={
        try {
            $_.MainModule.FileVersionInfo.FileDescription
        } catch {
            'Access Denied'
        }
    }} |
    Format-Table -AutoSize
