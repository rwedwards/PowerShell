# Define headers for CSV conversion
$headers = 'Proto', 'Src', 'Dst', 'State', 'PID'

# Run netstat and parse the output
$netStats = & netstat.exe -anop tcp |
    Select-Object -Skip 4 |
    ForEach-Object { [regex]::Replace($_.Trim(), '\s+', ' ') } |
    ConvertFrom-Csv -Delimiter ' ' -Header $headers |
    ForEach-Object {
        $pid = $_.PID
        $proc = Get-Process -Id $pid -ErrorAction SilentlyContinue
        $wmiProc = Get-WmiObject -Class Win32_Process -Filter "ProcessId='$pid'" -ErrorAction SilentlyContinue
        $parentWmi = if ($wmiProc) {
            Get-WmiObject -Class Win32_Process -Filter "ProcessId='$($wmiProc.ParentProcessId)'" -ErrorAction SilentlyContinue
        }

        [PSCustomObject]@{
            PID                      = $pid
            Proto                    = $_.Proto
            Dst                      = $_.Dst
            Src                      = $_.Src
            State                    = $_.State
            ProcessName             = $proc.Name
            CommandLine             = $wmiProc.CommandLine
            SessionId               = $proc.SessionId
            WindowTitle             = $proc.MainWindowTitle
            PPID                    = $wmiProc.ParentProcessId
            GPID                    = $parentWmi.ParentProcessId
            GrandparentProcessName  = $parentWmi.Name
            LoadedModules           = ($proc.Modules.ModuleName -join ',')
            ModulePaths             = ($proc.Modules.FileName -join ',')
        }
    }

$netStats
