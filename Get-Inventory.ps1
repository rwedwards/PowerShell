<#
.SYNOPSIS
    Generates hardware and software inventory reports to Excel.

.DESCRIPTION
    Gathers CPU, memory, BIOS, network, patches, software, and service info
    from local or remote machines using WMI/CIM and exports results into
    an Excel workbook with separate sheets for each category.

.NOTES
    - Requires Admin permissions and Excel installed.
    - Modular design with re-usable functions.
    - Replace Excel COM with database or CSV outputs for automation alternatives.
#>

function Get-InventoryData {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline)]
        [string[]]$ComputerNames = @('localhost'),

        [PSCredential]$Credential
    )

    foreach ($computer in $ComputerNames) {
        Write-Verbose "Collecting data from $computer"

        $sessionOptions = @{ ComputerName = $computer }
        if ($Credential) { $sessionOptions.Credential = $Credential }

        $cim = @{
            class   = @(
                'Win32_ComputerSystem','Win32_OperatingSystem','Win32_BIOS',
                'Win32_Processor','Win32_PhysicalMemory',
                'Win32_LogicalDisk','Win32_NetworkAdapterConfiguration',
                'Win32_QuickFixEngineering','Win32_Product','Win32_Service'
            )
            filter = { $_ -ne 'Win32_NetworkAdapterConfiguration' } # special IP filter
        }

        # Get data
        $cs    = Get-CimInstance -ClassName Win32_ComputerSystem @sessionOptions
        $os    = Get-CimInstance -ClassName Win32_OperatingSystem @sessionOptions
        $bios  = Get-CimInstance -ClassName Win32_BIOS @sessionOptions
        $cpu   = Get-CimInstance -ClassName Win32_Processor @sessionOptions
        $mem   = Get-CimInstance -ClassName Win32_PhysicalMemory @sessionOptions
        $disk  = Get-CimInstance -ClassName Win32_LogicalDisk @sessionOptions
        $net   = Get-CimInstance -ClassName Win32_NetworkAdapterConfiguration @sessionOptions | Where-Object IPEnabled
        $patch = Get-CimInstance -ClassName Win32_QuickFixEngineering @sessionOptions
        $soft  = Get-CimInstance -ClassName Win32_Product @sessionOptions
        $svc   = Get-CimInstance -ClassName Win32_Service @sessionOptions | Where-Object State -eq 'Running'

        [PSCustomObject]@{
            Computer     = $computer
            System       = $cs
            OS           = $os
            BIOS         = $bios
            Processor    = $cpu
            Memory       = $mem
            Disk         = $disk
            Network      = $net
            Patches      = $patch
            Software     = $soft
            Services     = $svc
        }
    }
}

function Export-ToExcel {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [PSObject[]]$InventoryData,

        [Parameter(Mandatory)]
        [string]$ExcelPath
    )

    $excel = New-Object -ComObject Excel.Application
    $excel.Visible = $false
    $workbook = $excel.Workbooks.Add()

    $sheets = 'System','OS','BIOS','Processor','Memory','Disk','Network','Patches','Software','Services'
    for ($i = 0; $i -lt $sheets.Length; $i++) {
        $ws = $workbook.Worksheets.Item($i + 1)
        $ws.Name = $sheets[$i]
        $ws.UsedRange.Clear()
    }

    $rowIndexes = @{}
    foreach ($ws in $workbook.Worksheets) { $rowIndexes[$ws.Name] = 2 }

    foreach ($inv in $InventoryData) {
        $computer = $inv.Computer

        # Example: Write System Data
        $system = $inv.System
        $ws = $workbook.Worksheets.Item('System')
        $ws.Cells.Item($rowIndexes['System'], 1).Value2 = $computer
        $ws.Cells.Item($rowIndexes['System'], 2).Value2 = $system.Manufacturer
        # … Add more columns as needed …
        $rowIndexes['System']++

        # Repeat for other sheets…
    }

    # Format columns, autofit
    foreach ($ws in $workbook.Worksheets) {
        $ws.UsedRange.EntireColumn.AutoFit()
    }

    $workbook.SaveAs($ExcelPath)
    $excel.Quit()
    [System.Runtime.Interopservices.Marshal]::ReleaseComObject($excel) | Out-Null
    Write-Host "Inventory exported to $ExcelPath"
}

# --- Script Execution ---

# Get credentials and target list
$useCred = Read-Host "Use alternate credentials? (Y/N)"
if ($useCred -match '^[Yy]') {
    $cred = Get-Credential
}

$choice = Read-Host "Choose targets: 1) All Domain DCs  2) From file  3) Manual"
switch ($choice) {
    '1' { $computers = (Get-ADComputer -Filter 'OperatingSystem -like "*Server*"').Name }
    '2' { $computers = Get-Content -Path (Read-Host "Path to file") }
    '3' { $computers = Read-Host 'Enter computer name or IP' }
    default { Write-Warning 'Invalid option'; return }
}

$data = Get-InventoryData -ComputerNames $computers -Credential $cred
Export-ToExcel -InventoryData $data -ExcelPath "C:\Temp\Inventory-$((Get-Date).ToString('yyyyMMdd')).xlsx"
