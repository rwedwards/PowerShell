# PowerShell Automation Toolkit

This repository contains a collection of PowerShell scripts designed to assist with systems administration, diagnostics, security, and automation tasks on modern Windows systems.

## Table of Contents

- [Better-Netstat](#better-netstat)
- [ConvertFrom-EpochDate](#convertfrom-epochdate)
- [ConvertFrom-Xml](#convertfrom-xml)
- [Enumerate-Mutex](#enumerate-mutex)
- [FileOperations](#fileoperations)
- [Find-ADS](#find-ads)
- [Find-ExtensionAssociation](#find-extensionassociation)
- [Get-Assemblies](#get-assemblies)
- [Get-CR](#get-cr)
- [Get-EgressIP](#get-egressip)
- [Get-FileSince](#get-filesince)
- [Get-FWRules](#get-fwrules)
- [Get-Handles](#get-handles)

---

## Script Usage and Descriptions

### Better-Netstat

**Synopsis:** Enhanced netstat-style report using PowerShell and process inspection.  
**Example Usage:**
```powershell
.\Better-Netstat.ps1
```

---

### ConvertFrom-EpochDate

**Synopsis:** Converts a Unix epoch timestamp to a human-readable local time.  
**Example Usage:**
```powershell
.\ConvertFrom-EpochDate.ps1
```

---

### ConvertFrom-Xml

**Synopsis:** Converts an XML file into a structured PowerShell object.  
**Example Usage:**
```powershell
.\ConvertFrom-Xml.ps1
```

---

### Enumerate-Mutex

**Synopsis:** Uses P/Invoke with `ntdll.dll` to enumerate all mutex handles in the system.  
**Example Usage:**
```powershell
.\Enumerate-Mutex.ps1
```

---

### FileOperations

**Synopsis:** Compresses a file into a Base64-encoded GZip stream or decompresses it back to file.  
**Example Usage:**
```powershell
Compress-File -File .\input.txt -outputLoc .\encoded.txt
Decompress-File -memstream "BASE64STRING" -outputloc .\decoded.txt
```

---

### Find-ADS

**Synopsis:** Scans NTFS volumes for Alternate Data Streams.  
**Example Usage:**
```powershell
.\Find-ADS.ps1
```

---

### Find-ExtensionAssociation

**Synopsis:** Determines the executable used to open a specific file type.  
**Example Usage:**
```powershell
.\Find-ExtensionAssociation.ps1
```

---

### Get-Assemblies

**Synopsis:** Searches for loaded .NET assemblies in the current AppDomain matching a pattern.  
**Example Usage:**
```powershell
.\Get-Assemblies.ps1
```

---

### Get-CR

**Synopsis:** Downloads and executes a CR payload script based on system architecture.  
**Example Usage:**
```powershell
.\Get-CR.ps1
```

---

### Get-EgressIP

**Synopsis:** Retrieves the public-facing IP address and geolocation information.  
**Example Usage:**
```powershell
.\Get-EgressIP.ps1
```

---

### Get-FileSince

**Synopsis:** Lists files modified since a specified date (default: since 01/01/2016).  
**Example Usage:**
```powershell
.\Get-FileSince.ps1
```

---

### Get-FWRules

**Synopsis:** Retrieves Windows Firewall rules that are inbound, enabled, and allow traffic.  
**Example Usage:**
```powershell
.\Get-FWRules.ps1
```

---

### Get-Handles

**Synopsis:** Lists processes with high handle counts, which could indicate resource leaks.  
**Example Usage:**
```powershell
.\Get-Handles.ps1
```

---

## Contribution

Feel free to open issues or submit pull requests to improve or expand these scripts.

## License

This project is licensed under the [MIT License](LICENSE).
