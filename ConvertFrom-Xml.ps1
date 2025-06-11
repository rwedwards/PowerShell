<#
.SYNOPSIS
    Converts an XML file into a nested PowerShell object.

.DESCRIPTION
    Useful for processing XML output from tools like CrowdResponse.
    Supports nested elements and attributes and flattens tag-based elements.

.NOTES
    Original logic by Thom Lamb, adapted by Dallas Moore.
    Refactored for modern PowerShell best practices.

.LINK
    https://consciouscipher.wordpress.com/2015/06/05/converting-xml-to-powershell-psobject/

.EXAMPLE
    $psObject = Convert-XmlToPSObject -XmlPath 'C:\CrowdResponse\cr_output.xml'
    $json = $psObject | ConvertTo-Json -Depth 5
#>

function Convert-XmlNodeToHashtable {
    param (
        [Parameter(Mandatory)]
        [System.Xml.XmlNode]$Node
    )

    $result = @{}

    $Node | Get-Member -MemberType Properties | ForEach-Object {
        $name = $_.Name
        $value = $Node.$name

        if ($value -is [string]) {
            $result[$name] = $value
        }
        elseif ($value -is [System.Xml.XmlElement]) {
            if ($value.HasAttributes -and $value.Attributes["tag"]) {
                $result[$name] = ($value | ForEach-Object { $_.tag }) -join "; "
            } else {
                $nested = Convert-XmlNodeToHashtable -Node $value

                if ($value.HasChildNodes) {
                    foreach ($child in $value.ChildNodes) {
                        if ($child -is [System.Xml.XmlElement]) {
                            $nested[$child.Name] = Convert-XmlNodeToHashtable -Node $child
                        }
                    }
                }

                $result[$name] = $nested
            }
        }
    }

    return $result
}

function Convert-XmlToPSObject {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$XmlPath
    )

    try {
        [xml]$xmlContent = Get-Content -Path $XmlPath -ErrorAction Stop
        $root = $xmlContent.DocumentElement

        $data = Convert-XmlNodeToHashtable -Node $root
        return [pscustomobject]$data
    }
    catch {
        Write-Error "Failed to parse XML: $($_.Exception.Message)"
    }
}

# Example usage:
# $converted = Convert-XmlToPSObject -XmlPath 'C:\CrowdResponse\cr_output.xml'
