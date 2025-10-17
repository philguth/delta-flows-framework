# PowerShell script to create proper Power Platform solution ZIP
Add-Type -AssemblyName System.IO.Compression.FileSystem

$zipPath = "DeltaFlowsFramework_v1.0.0.5_FINAL.zip"

# Remove existing ZIP if it exists (with better error handling)
if (Test-Path $zipPath) {
    try {
        Remove-Item $zipPath -Force
        Start-Sleep -Milliseconds 500  # Brief pause to ensure file is released
    }
    catch {
        Write-Warning "Could not remove existing ZIP file. It may be open in another program."
        $zipPath = "DeltaFlowsFramework_v1.0.0.5_FINAL_$(Get-Date -Format 'yyyyMMdd_HHmmss').zip"
        Write-Host "Using alternative filename: $zipPath"
    }
}

# Define files to include
$requiredFiles = @()

# Add individual XML files
if (Test-Path "solution.xml") {
    $requiredFiles += "solution.xml"
    Write-Host "✓ Found solution.xml"
}
if (Test-Path "customizations.xml") {
    $requiredFiles += "customizations.xml"
    Write-Host "✓ Found customizations.xml"
}
if (Test-Path "EnvironmentVariables.xml") {
    $requiredFiles += "EnvironmentVariables.xml"
    Write-Host "✓ Found EnvironmentVariables.xml"
}

# Handle Content_Types.xml with special characters - use literal path
$contentTypesPath = "[Content_Types].xml"
if (Test-Path -LiteralPath $contentTypesPath) {
    $requiredFiles += $contentTypesPath
    Write-Host "✓ Found [Content_Types].xml"
} else {
    Write-Warning "✗ [Content_Types].xml not found!"
}

# Add Workflows folder
if (Test-Path "Workflows") {
    $requiredFiles += "Workflows"
    Write-Host "✓ Found Workflows folder"
}

Write-Host "`nCreating ZIP with files: $($requiredFiles -join ', ')"
Compress-Archive -LiteralPath $requiredFiles -DestinationPath $zipPath -Force
Write-Host "ZIP file created successfully: $zipPath"

# Verify contents
Write-Host "`nZIP Contents:"
Add-Type -AssemblyName System.IO.Compression.FileSystem
[System.IO.Compression.ZipFile]::OpenRead($zipPath).Entries | Select-Object Name, FullName | Format-Table -AutoSize