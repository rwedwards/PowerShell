<#
.SYNOPSIS
    Compresses and Base64-encodes a file, or decompresses and decodes Base64 back to file.

.DESCRIPTION
    Ideal for making text-based transmission of binary data safe and portable.
    Compression reduces size, and Base64 ensures safe text formatting.

.EXAMPLE
    Compress-File -InputPath 'C:\file.txt' -OutputPath 'C:\file_encoded.txt'
    Decompress-File -Base64String (Get-Content -Path 'C:\file_encoded.txt' -Raw) -OutputPath 'C:\decoded.txt'
#>

function Compress-File {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$InputPath,

        [Parameter(Mandatory)]
        [string]$OutputPath
    )

    function Get-Base64GzippedString {
        param (
            [System.IO.FileInfo]$File
        )

        $rawBytes = [System.IO.File]::ReadAllBytes($File.FullName)
        $memoryStream = New-Object System.IO.MemoryStream
        $gzipStream = New-Object System.IO.Compression.GZipStream($memoryStream, [System.IO.Compression.CompressionMode]::Compress)

        $gzipStream.Write($rawBytes, 0, $rawBytes.Length)
        $gzipStream.Close()

        return [Convert]::ToBase64String($memoryStream.ToArray())
    }

    if (-not (Test-Path -Path $InputPath)) {
        Write-Error "File not found: $InputPath"
        return
    }

    try {
        $fileInfo = Get-Item -Path $InputPath
        $hash = Get-FileHash -Path $InputPath -Algorithm SHA256

        $metadata = [PSCustomObject]@{
            FullName          = $fileInfo.FullName
            Length            = $fileInfo.Length
            CreationTimeUtc   = $fileInfo.CreationTimeUtc
            LastAccessTimeUtc = $fileInfo.LastAccessTimeUtc
            LastWriteTimeUtc  = $fileInfo.LastWriteTimeUtc
            Hash              = $hash.Hash
            Content           = Get-Base64GzippedString -File $fileInfo
        }

        $metadata | Out-File -FilePath $OutputPath -Encoding UTF8
        Write-Host "File compressed and encoded to: $OutputPath"
    } catch {
        Write-Error "Compression failed: $_"
    }
}

function Decompress-File {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$Base64String,

        [Parameter(Mandatory)]
        [string]$OutputPath
    )

    function Decompress-ByteArray {
        param (
            [byte[]]$CompressedBytes
        )

        $inputStream = New-Object System.IO.MemoryStream(, $CompressedBytes)
        $outputStream = New-Object System.IO.MemoryStream
        $gzipStream = New-Object System.IO.Compression.GZipStream($inputStream, [System.IO.Compression.CompressionMode]::Decompress)

        $gzipStream.CopyTo($outputStream)
        $gzipStream.Close()
        $inputStream.Close()

        return $outputStream.ToArray()
    }

    try {
        $bytes = [Convert]::FromBase64String($Base64String)
        $decompressed = Decompress-ByteArray -CompressedBytes $bytes
        [System.IO.File]::WriteAllBytes($OutputPath, $decompressed)

        Write-Host "File decompressed and saved to: $OutputPath"
    } catch {
        Write-Error "Decompression failed: $_"
    }
}
