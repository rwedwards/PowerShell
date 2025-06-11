<#
.SYNOPSIS
    Determines the executable associated with a file type based on file extension.

.DESCRIPTION
    Wraps the Windows API call to FindExecutable (shell32.dll) and returns the program
    that would launch a given file. Useful for investigating extension-handler mappings.

.EXAMPLE
    Find-ExtensionAssociation -FullPath "C:\Windows\windowsupdate.log"

.OUTPUTS
    String with executable path or error message.
#>

function Find-ExtensionAssociation {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, Position = 0)]
        [ValidateScript({ Test-Path $_ -PathType Leaf })]
        [string]$FullPath
    )

    $apiCode = @"
using System;
using System.Text;
using System.Runtime.InteropServices;

public class FileAssociationHelper {
    [DllImport("shell32.dll", EntryPoint = "FindExecutable")]
    public static extern long FindExecutableA(string lpFile, string lpDirectory, StringBuilder lpResult);

    public static string GetAssociatedExecutable(string filePath) {
        StringBuilder result = new StringBuilder(1024);
        long code = FindExecutableA(filePath, string.Empty, result);

        return code >= 32 
            ? result.ToString() 
            : $"Error: Unable to find associated executable (Code {code})";
    }
}
"@

    # Add type only once per session
    if (-not ("FileAssociationHelper" -as [type])) {
        Add-Type -TypeDefinition $apiCode -ErrorAction Stop
    }

    try {
        $exe = [FileAssociationHelper]::GetAssociatedExecutable($FullPath)
        Write-Output "$FullPath will be launched by $exe"
    } catch {
        Write-Error "Failed to determine associated executable: $_"
    }
}
