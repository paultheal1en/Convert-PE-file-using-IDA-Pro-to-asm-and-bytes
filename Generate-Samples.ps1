<#
.SYNOPSIS
    Generate disassembly and machine code files for the 2015 Microsoft Malware Classification Challenge.
.DESCRIPTION
    Generate disassembly and machine code files for the 2015 Microsoft Malware Classification Challenge.
    This script must be located in the same folder as `generator.py` and `generation_cmd.py`.
    Files that have already been processed (existing .asm and .bytes files) will be skipped.
.PARAMETER InputDirectory
    An input directory containing original executable files.
.PARAMETER OutputDirectory
    An output directory to save disassembly and machine code files.
.EXAMPLE
    PS> .\Generate-Samples.ps1 -InputDirectory . -OutputDirectory .\output
#>
[CmdletBinding()]
param (
    [Parameter(Mandatory)]
    [String]$InputDirectory,
    [Parameter(Mandatory)]
    [String]$OutputDirectory
)

# Create log file
$logFile = "processing_log_$(Get-Date -Format 'yyyyMMdd_HHmmss').txt"
$failedFiles = @()

function Write-Log {
    param($Message, $Color = "White")
    Write-Host $Message -ForegroundColor $Color
    Add-Content -Path $logFile -Value "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss'): $Message"
}

try {
    New-Variable -Name 'Generation' -Value 'generation_cmd.py' -Option Constant
    
    # Check IDA Pro
    if (-not (Test-Path 'C:\Users\Acer\Desktop\IDA7.7\ida.exe')) {
        throw "IDA Pro not found at specified path"
    }
    
    # Check generation script
    $Script = Join-Path -Path $(Get-Location) -ChildPath $Generation
    if (-not (Test-Path $Script)) {
        throw "Generation script not found: $Generation"
    }
    
    # Create output directory
    New-Item -Path $OutputDirectory -ItemType 'Directory' -Force | Out-Null
    
    # Count files
    $totalFiles = (Get-ChildItem -Path (Join-Path -Path $InputDirectory -ChildPath '*') -File -Include '*.exe', '*.dll').Count
    $processedCount = 0
    $skippedCount = 0
    $failedCount = 0
    
    Write-Log "Starting to process $totalFiles files..." "Cyan"
    
    foreach ($File in Get-ChildItem -Path (Join-Path -Path $InputDirectory -ChildPath '*') -File -Include '*.exe', '*.dll') {
        $processedCount++
        Write-Log "[$processedCount/$totalFiles] Processing: $($File.Name)" "Cyan"
        
        # Check existing files
        $asmPath = Join-Path -Path $OutputDirectory -ChildPath "$($File.Name).asm"
        $bytesPath = Join-Path -Path $OutputDirectory -ChildPath "$($File.Name).bytes"
        
        # Fixed the condition syntax
        if ((Test-Path $asmPath) -and (Test-Path $bytesPath)) {
            Write-Log "'$($File.Name)' already processed - skipping..." "Yellow"
            $skippedCount++
            continue
        }
        
        # Process file
        $process = Start-Process -FilePath 'C:\Users\Acer\Desktop\IDA7.7\ida.exe' `
            -ArgumentList '-A', "`"-S$Script`"", "`"$($File.FullName)`"" `
            -NoNewWindow -Wait -PassThru
        
        Start-Sleep -Seconds 2  # Add small delay to ensure files are written
        
        # Check if files were created
        $asmCreated = Test-Path "$($File.FullName).asm"
        $bytesCreated = Test-Path "$($File.FullName).bytes"
        
        if ($asmCreated -and $bytesCreated) {
            # Clean up and move files
            if (Test-Path "$($File.FullName).idb") {
                Remove-Item -Path "$($File.FullName).idb" -Force
            }
            
            Move-Item -Path "$($File.FullName).asm" -Destination $OutputDirectory -Force
            Move-Item -Path "$($File.FullName).bytes" -Destination $OutputDirectory -Force
            
            Write-Log "'$($File.Name)' processed successfully." "Green"
        } else {
            Write-Log "'$($File.Name)' processing failed! ASM: $asmCreated, BYTES: $bytesCreated" "Red"
            $failedFiles += $File.Name
            $failedCount++
            
            # Cleanup temporary files if any
            if (Test-Path "$($File.FullName).idb") {
                Remove-Item -Path "$($File.FullName).idb" -Force
            }
            if ($asmCreated) {
                Remove-Item -Path "$($File.FullName).asm" -Force
            }
            if ($bytesCreated) {
                Remove-Item -Path "$($File.FullName).bytes" -Force
            }
        }
        
        # Add delay between processing files
        Start-Sleep -Seconds 1
    }
    
    # Summary
    Write-Log "`nProcessing Summary:" "Cyan"
    Write-Log "Total files: $totalFiles" "White"
    Write-Log "Successfully processed: $($totalFiles - $skippedCount - $failedCount)" "Green"
    Write-Log "Skipped: $skippedCount" "Yellow"
    Write-Log "Failed: $failedCount" "Red"
    
    if ($failedFiles.Count -gt 0) {
        Write-Log "`nFailed files list:" "Red"
        $failedFiles | ForEach-Object { Write-Log "- $_" "Red" }
        
        # Save failed files list to separate file
        $failedListFile = "failed_files_$(Get-Date -Format 'yyyyMMdd_HHmmss').txt"
        $failedFiles | Out-File -FilePath $failedListFile
        Write-Log "Failed files list saved to: $failedListFile" "Yellow"
    }
    
    Write-Log "`nDetails available in log file: $logFile" "Cyan"
    
} catch {
    Write-Log "Error: $($_.Exception.Message)" "Red"
    Write-Log "Stack Trace: $($_.ScriptStackTrace)" "Red"
}