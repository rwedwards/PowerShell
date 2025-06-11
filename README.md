# PowerShell Automation Toolkit

A collection of PowerShell scripts for systems administration, network diagnostics, Active Directory enumeration, and security auditing. These tools are designed to help IT professionals streamline common administrative tasks and diagnostics.

---

## 🔧 Requirements

- PowerShell 5.1+ or PowerShell 7 (depending on script)
- Windows OS (some scripts use Windows-only cmdlets like `Get-WinEvent`)
- Administrative privileges (some scripts access privileged resources)
- Internet access (for scripts that download external content)

---

## 📂 Script Index

### 1. **Get-Inventory.ps1**
- **Description:** Gathers hardware and software details across remote systems and exports results to Excel.
- **Usage:** 
  ```powershell
  .\Get-Inventory.ps1
  ```
- **Features:**
  - Excel export with hardware, memory, CPU, disk, network, and services info
  - Supports alternate credentials and different selection methods (AD, file, manual)

---

### 2. **Get-ATJobs.ps1**
- **Description:** Parses output from `at.exe` to extract scheduled tasks.
- **Usage:**
  ```powershell
  Get-ATJobs
  ```

---

### 3. **Get-IPConfig.ps1**
- **Description:** Parses output from `ipconfig /all` or modern cmdlets to a PowerShell object.
- **Improved version:** Uses `Get-NetIPConfiguration` and `Get-NetAdapter` for accuracy and structure.
- **Usage:**
  ```powershell
  Get-IPConfig | Format-Table
  ```

---

### 4. **Get-LogonFailures.ps1**
- **Description:** Extracts failed logon attempts (Event ID 4625) from the Security event log.
- **CSV Export:**
  ```powershell
  Get-LogonFailures | Export-Csv .\FailedLogons.csv -NoTypeInformation
  ```

---

### 5. **PortScan.ps1**
- **Description:** Performs TCP port scans using `System.Net.Sockets.TCPClient`.
- **Usage Examples:**
  ```powershell
  .\PortScan.ps1 -ComputerName "192.168.1.10" -Port 80
  .\PortScan.ps1 -ComputerName "10.0.0.1" -Port (1..1024)
  ```

---

### 6. **Get-Taskinfo.ps1**
- **Description:** Converts `tasklist.exe` output into structured objects and shows tasks, modules, and services.
- **Menu Options:**
  1. Modules by DLL
  2. Modules by Process
  3. Verbose Task Info
  4. Services by Process

---

### 7. **NetAssemblySearch.ps1**
- **Description:** Searches loaded .NET assemblies for types matching a pattern.
- **Usage:**
  ```powershell
  $searchtext = "*SQL*"
  [AppDomain]::CurrentDomain.GetAssemblies() | ForEach-Object { $_.GetExportedTypes() } | Where-Object { $_ -like $searchtext }
  ```

---

### 8. **Invoke-ScriptBasedOnOSArch.ps1**
- **Description:** Determines OS architecture and dynamically downloads the correct script from GitHub.
- **Note:** Uses `Invoke-Expression` which should be used with caution.

---

### 9. **MemoryMappedDemo.ps1**
- **Description:** Playground script to experiment with memory-mapped files via .NET APIs.
- **Status:** Experimental; not fully implemented.

---

### 10. **LsofParser.ps1**
- **Description:** Parses `lsof -i` output (on WSL/Linux) into PowerShell objects with process information.
- **Note:** Cross-platform PowerShell required (e.g., PowerShell 7+ with WSL access).

---
### 11. **Get-FWRules.ps1**
**Description:** This PowerShell script audits **inbound Windows Firewall rules** that are:

- Enabled ✅  
- Allowing traffic ✅  
- Active in the current policy ✅  

It generates a clean, formatted report and optionally sends the results via email. The script uses modern cmdlets from the `NetSecurity` module, making it suitable for Windows 8+, Windows 10/11, and Server 2012+ environments.

---
## ⚠️ Security Notes

- Avoid running scripts that use `Invoke-Expression` on remote content unless fully trusted.
- Scripts that query event logs or run WMI may require elevated privileges.

---

## 📦 Contribution

Feel free to fork this repository and contribute improvements, error handling, or additional modules!

---

## 📜 License

MIT License – Use at your own risk. No warranty provided.
