$lsofcontainer = lsof -i |
    Select-Object -Skip 1 |
    ForEach-Object {
        # Normalize spaces to single space
        [regex]::Replace($_.Trim(), '\s+', ' ')
    } |
    ConvertFrom-Csv -Delimiter ' ' -Header 'command', 'pid', 'user', 'fd', 'type', 'device', 'size_off', 'node', 'name' |
    ForEach-Object {
        $procInfo = try { Get-Process -Id $_.pid -ErrorAction Stop } catch { $null }

        # Enrich data with additional fields, safely
        $_ | Select-Object -Property *,
        @{
            Name = 'process_name'
            Expression = { if ($procInfo) { $procInfo.Name } else { 'N/A' } }
        },
        @{
            Name = 'session_id'
            Expression = { if ($procInfo) { $procInfo.SessionId } else { 'N/A' } }
        },
        @{
            Name = 'module_paths'
            Expression = {
                if ($procInfo) {
                    try { ($procInfo.Modules.FileName -join ', ') } catch { 'Access Denied or N/A' }
                } else { 'N/A' }
            }
        }
    }
