# GPO File Deployment Diagnostic Script
# Validates whether a specific GPO has deployed a Java exceptions file correctly

# Configuration
$logFile = "$env:USERPROFILE\Desktop\JavaGPO_Diagnostic.log"
$src = "\\petevdinafs01\FSLProfileDisk\Java_redirections\exception.sites"
$dst = "$env:USERPROFILE\AppData\LocalLow\Sun\Java\Deployment\security\exception.sites"
$parentDir = Split-Path $dst
$targetGpo = "TEST// RMC JavaSiteExceptions"
$gpResultPath = "$env:TEMP\gpresult.html"

# Logging Function
function Write-Log {
    param ([string]$Message)
    Add-Content -Path $logFile -Value "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] $Message"
}

# Start
Write-Log "`n==== Starting GPO File Deployment Diagnostic ===="

# --- 1. Check if the destination file exists ---
Write-Log "Checking if GPO-deployed file exists..."
if (Test-Path $dst) {
    Write-Log "File exists: $dst"

    # Compare hash with source
    try {
        $srcHash = Get-FileHash $src -Algorithm SHA256
        $dstHash = Get-FileHash $dst -Algorithm SHA256

        if ($srcHash.Hash -eq $dstHash.Hash) {
            Write-Log "File hash matches the source. GPO likely applied successfully."
        } else {
            Write-Log "File exists but HASH mismatch! GPO may have deployed an outdated or different version."
        }
    } catch {
        Write-Log "Error calculating file hashes: $_"
    }
} else {
    Write-Log "File is missing: $dst"

    # Check if the parent directory exists
    if (Test-Path $parentDir) {
        Write-Log "Parent directory exists: $parentDir"
    } else {
        Write-Log "Parent directory is missing: $parentDir — GPO may not have created the folder structure."
    }

    # Check folder permissions
    try {
        Write-Log "Checking ACLs on `${parentDir}`..."
        $acl = Get-Acl $parentDir
        $acl.Access | ForEach-Object {
            Write-Log "→ $($_.IdentityReference) has $($_.FileSystemRights)"
        }
    } catch {
        Write-Log "Could not retrieve ACLs for `${parentDir}`: $_"
    }
}

# --- 2. Run gpresult to check GPO application ---
Write-Log "Running gpresult to validate GPO: '$targetGpo'"
try {
    gpresult /h $gpResultPath /f
    Write-Log "gpresult report saved to: $gpResultPath"

    # Search for the specific GPO in the HTML output
    $gpoMatch = Get-Content $gpResultPath | Select-String -Pattern $targetGpo -Context 3,3

    if ($gpoMatch) {
        Write-Log "GPO '$targetGpo' was found in gpresult output:"
        $gpoMatch | ForEach-Object { Write-Log $_.Line }

        # Look for any denied status around that context
        $deniedCheck = $gpoMatch | Where-Object { $_.Line -match 'Denied' }
        if ($deniedCheck) {
            Write-Log "WARNING: GPO '$targetGpo' appears to be denied (filtered out). Check security or WMI filters."
        } else {
            Write-Log "GPO '$targetGpo' appears to be applied successfully."
        }
    } else {
        Write-Log "GPO '$targetGpo' was NOT found in gpresult. It may not be linked or targeting this user/computer."
    }
} catch {
    Write-Log "Failed to run or parse gpresult: $_"
}

# --- 3. Check recent GPO-related events ---
Write-Log "Scanning Group Policy Event Log (last 60 mins)..."
try {
    $gpEvents = Get-WinEvent -LogName "Microsoft-Windows-GroupPolicy/Operational" -MaxEvents 100 |
        Where-Object { $_.TimeCreated -ge (Get-Date).AddMinutes(-60) }

    if ($gpEvents) {
        foreach ($evt in $gpEvents) {
            Write-Log "Event ID $($evt.Id): $($evt.Message.Split("`n")[0])"
        }
    } else {
        Write-Log "No recent Group Policy events found."
    }
} catch {
    Write-Log "Error reading Group Policy event log: $_"
}

# --- Complete ---
Write-Log "Diagnostic complete. See full log at: $logFile"
Start-Process notepad.exe $logFile