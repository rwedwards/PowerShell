<#
.SYNOPSIS
    Searches all currently loaded .NET assemblies for types matching a pattern.

.DESCRIPTION
    Useful for exploring which types are exposed by .NET assemblies currently loaded
    in the PowerShell AppDomain.

.EXAMPLE
    Find-ExportedDotNetTypes -SearchText "*sql*" -IgnoreCase
#>

function Find-ExportedDotNetTypes {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0)]
        [string]$SearchText = "*",

        [switch]$IgnoreCase
    )

    $assemblies = [AppDomain]::CurrentDomain.GetAssemblies()

    $bindingFlag = if ($IgnoreCase) { 'IgnoreCase' } else { 'None' }

    $types = foreach ($assembly in $assemblies) {
        try {
            $assembly.GetExportedTypes()
        } catch [System.Reflection.ReflectionTypeLoadException] {
            $_.Exception.Types | Where-Object { $_ -ne $null }
        } catch {
            Write-Verbose "Skipped assembly $($assembly.FullName): $_"
        }
    }

    $filteredTypes = $types |
        Where-Object {
            $_.FullName -like $SearchText -or
            ($IgnoreCase -and $_.FullName.ToLower() -like $SearchText.ToLower())
        } |
        Select-Object -ExpandProperty FullName |
        Sort-Object -Unique

    return $filteredTypes
}

# Example usage:
Find-ExportedDotNetTypes -SearchText "*sql*" -IgnoreCase
