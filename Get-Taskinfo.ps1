function Get-ModuleInfoByName {
    param (
        [Parameter(Mandatory)]
        [string]$ModuleName
    )

    Get-Process | Where-Object {
        $_.Modules | Where-Object { $_.ModuleName -like "*$ModuleName*" }
    } | ForEach-Object {
        [PSCustomObject]@{
            ProcessName = $_.ProcessName
            Id          = $_.Id
            Modules     = ($_.Modules | Where-Object { $_.ModuleName -like "*$ModuleName*" }).ModuleName -join ', '
        }
    } | Format-Table -AutoSize
}

function Get-AllModuleInfo {
    Get-Process | ForEach-Object {
        [PSCustomObject]@{
            ProcessName = $_.ProcessName
            Id          = $_.Id
            Modules     = ($_.Modules | Select-Object -ExpandProperty ModuleName) -join ', '
        }
    } | Where-Object { $_.Modules } | Format-Table -Wrap -AutoSize
}

function Get-VerboseTaskInfo {
    Get-Process | ForEach-Object {
        $owner = try {
            (Get-WmiObject Win32_Process -Filter "ProcessId=$($_.Id)").GetOwner().User
        } catch { "N/A" }

        [PSCustomObject]@{
            ProcessName  = $_.ProcessName
            Id           = $_.Id
            SessionId    = $_.SessionId
            WorkingSetMB = [math]::Round($_.WorkingSet64 / 1MB, 2)
            StartTime    = try { $_.StartTime } catch { "N/A" }
            CPU          = try { $_.TotalProcessorTime } catch { "N/A" }
            UserName     = $owner
            MainWindow   = $_.MainWindowTitle
        }
    } | Sort-Object Id | Format-Table -AutoSize
}

function Get-ServiceInfoByProcess {
    Get-CimInstance Win32_Service | Group-Object -Property ProcessId | ForEach-Object {
        if ($_.Name -ne "") {
            [PSCustomObject]@{
                ProcessId = $_.Name
                Services  = ($_.Group | Select-Object -ExpandProperty Name) -join ', '
            }
        }
    } | Format-Table -AutoSize
}

# Main menu
Clear-Host
do {
    Write-Host @"
---------- Main ----------
1 = Get module info by executable or DLL
2 = Get module info for all executables
3 = Get current task information
4 = Get services grouped by process ID
--------------------------
"@
    $choice = Read-Host "Select a number and press Enter"
} while ($choice -notin '1','2','3','4')

switch ($choice) {
    '1' { 
        $mod = Read-Host "Enter the name of a DLL or executable (e.g., kernel32.dll)"
        Get-ModuleInfoByName -ModuleName $mod 
    }
    '2' { Get-AllModuleInfo }
    '3' { Get-VerboseTaskInfo }
    '4' { Get-ServiceInfoByProcess }
}






