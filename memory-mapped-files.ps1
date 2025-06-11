# Load required assembly (works on Windows PowerShell and PowerShell Core)
Add-Type -AssemblyName System.IO.MemoryMappedFiles

# Parameters
$mapName = "MyMappedMemory"
$text = "Hello from memory-mapped file!"
$bytes = [System.Text.Encoding]::UTF8.GetBytes($text)

# Create memory-mapped file
$mmf = [System.IO.MemoryMappedFiles.MemoryMappedFile]::CreateNew($mapName, 1024)

# Write to memory-mapped file
$accessor = $mmf.CreateViewAccessor()
$accessor.WriteArray(0, $bytes, 0, $bytes.Length)

# Read from memory-mapped file
$readerMmf = [System.IO.MemoryMappedFiles.MemoryMappedFile]::OpenExisting($mapName)
$reader = $readerMmf.CreateViewAccessor()
$buffer = New-Object byte[] $bytes.Length
$reader.ReadArray(0, $buffer, 0, $buffer.Length)
$readText = [System.Text.Encoding]::UTF8.GetString($buffer)

Write-Host "Read from memory-mapped file: $readText"

# Clean up
$accessor.Dispose()
$reader.Dispose()
$mmf.Dispose()
$readerMmf.Dispose()
