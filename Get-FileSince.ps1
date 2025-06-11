<#
.SYNOPSIS
    Lists files in the current directory modified since 01/01/2016.

.DESCRIPTION
    Calculates a date range from Jan 1, 2016 to now and filters files
    by LastWriteTime using that start date.
#>

$startDate = Get-Date "01/01/2016 00:00"
$endDate = Get-Date
$daysSpan = ($endDate - $startDate).TotalDays

Write-Verbose "Date range: $startDate to $endDate ($([math]::Round($daysSpan, 2)) days)"

# Get files modified since $startDate
Get-ChildItem -File | Where-Object { $_.LastWriteTime -ge $startDate }
