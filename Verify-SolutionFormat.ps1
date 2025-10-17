# Solution Format Verification Script
# Run this before creating any solution package to ensure correct format

param(
    [Parameter(Mandatory=$false)]
    [string]$SolutionPath = "."
)

Write-Host "🔍 VERIFYING SOLUTION FORMAT" -ForegroundColor Cyan
Write-Host "================================" -ForegroundColor Cyan
Write-Host ""

$allGood = $true

# Check if files exist
$requiredFiles = @("solution.xml", "customizations.xml", "[Content_Types].xml")
foreach ($file in $requiredFiles) {
    if ($file -eq "[Content_Types].xml") {
        $filePath = Join-Path $SolutionPath "[Content_Types].xml"
        # Use Get-ChildItem with literal path for files with special characters
        if (Get-ChildItem -LiteralPath $SolutionPath -Filter "[Content_Types].xml" -ErrorAction SilentlyContinue) {
            Write-Host "✅ Found: $file" -ForegroundColor Green
        } else {
            Write-Host "❌ Missing: $file" -ForegroundColor Red
            $allGood = $false
        }
    } else {
        $filePath = Join-Path $SolutionPath $file
        if (Test-Path $filePath) {
            Write-Host "✅ Found: $file" -ForegroundColor Green
        } else {
            Write-Host "❌ Missing: $file" -ForegroundColor Red
            $allGood = $false
        }
    }
}

Write-Host ""
Write-Host "📋 Checking XML Declarations..." -ForegroundColor Yellow
Write-Host ""

# Check solution.xml
$solutionPath = Join-Path $SolutionPath "solution.xml"
if (Test-Path $solutionPath) {
    $firstLine = Get-Content $solutionPath -TotalCount 1
    if ($firstLine -like "*<?xml*") {
        Write-Host "  ❌ solution.xml has XML declaration (should have NONE)" -ForegroundColor Red
        $allGood = $false
    } else {
        Write-Host "  ✅ solution.xml has NO XML declaration" -ForegroundColor Green
    }
}

# Check customizations.xml
$customPath = Join-Path $SolutionPath "customizations.xml"
if (Test-Path $customPath) {
    $firstLine = Get-Content $customPath -TotalCount 1
    if ($firstLine -like "*<?xml*") {
        Write-Host "  ❌ customizations.xml has XML declaration (should have NONE)" -ForegroundColor Red
        $allGood = $false
    } else {
        Write-Host "  ✅ customizations.xml has NO XML declaration" -ForegroundColor Green
    }
}

Write-Host ""
Write-Host "📋 Checking Line Endings..." -ForegroundColor Yellow
Write-Host ""

$xmlFiles = @("solution.xml", "customizations.xml")
foreach ($file in $xmlFiles) {
    $filePath = Join-Path $SolutionPath $file
    if (Test-Path $filePath) {
        $content = Get-Content $filePath -Raw
        $hasCRLF = $content -match "`r`n"
        $hasLF = $content -match "`n" -and $content -notmatch "`r`n"

        if ($hasCRLF) {
            Write-Host "  ✅ $file uses Windows CRLF" -ForegroundColor Green
        } elseif ($hasLF) {
            Write-Host "  ❌ $file uses Unix LF (should be Windows CRLF)" -ForegroundColor Red
            $allGood = $false
        } else {
            Write-Host "  ⚠️  $file has no line endings (single line?)" -ForegroundColor Yellow
        }
    }
}

Write-Host ""
Write-Host "📋 Checking Critical Elements..." -ForegroundColor Yellow
Write-Host ""

# Check for MissingDependencies in solution.xml
if (Test-Path $solutionPath) {
    $solutionContent = Get-Content $solutionPath -Raw

    if ($solutionContent -match "MissingDependencies") {
        Write-Host "  ✅ solution.xml has <MissingDependencies /> element" -ForegroundColor Green
    } else {
        Write-Host "  ❌ solution.xml MISSING <MissingDependencies /> element" -ForegroundColor Red
        Write-Host "     This is REQUIRED and will cause 'object reference not set' error!" -ForegroundColor Red
        $allGood = $false
    }

    if ($solutionContent -match "CustomizationPrefix") {
        Write-Host "  ✅ solution.xml has CustomizationPrefix" -ForegroundColor Green
    } else {
        Write-Host "  ⚠️  solution.xml missing CustomizationPrefix" -ForegroundColor Yellow
    }

    $addressCount = ([regex]::Matches($solutionContent, "<Address>")).Count
    if ($addressCount -eq 2) {
        Write-Host "  ✅ solution.xml has 2 Address entries" -ForegroundColor Green
    } else {
        Write-Host "  ⚠️  solution.xml has $addressCount Address entries (expected 2)" -ForegroundColor Yellow
    }

    # Check for RootComponent entries (NOTE: For NEW workflows being imported for the first time,
    # RootComponents should be EMPTY. Power Platform will auto-register them after import.
    # Only use RootComponents when adding EXISTING workflows to a solution.)
    $rootComponentCount = ([regex]::Matches($solutionContent, '<RootComponent\s+type="29"')).Count
    if ($rootComponentCount -gt 0) {
        Write-Host "  ⚠️  solution.xml has $rootComponentCount RootComponent(s) registered (type=29 for workflows)" -ForegroundColor Yellow
        Write-Host "     NOTE: RootComponents should only reference workflows that ALREADY EXIST in target system!" -ForegroundColor Yellow
        Write-Host "     For NEW workflows, leave RootComponents empty and let Power Platform auto-register them." -ForegroundColor Yellow
    } else {
        Write-Host "  ✅ solution.xml has empty RootComponents (correct for new workflow import)" -ForegroundColor Green
    }
}

Write-Host ""
Write-Host "================================" -ForegroundColor Cyan
if ($allGood) {
    Write-Host "✅ ALL CHECKS PASSED - Solution is ready!" -ForegroundColor Green
} else {
    Write-Host "❌ ISSUES FOUND - Fix errors before packaging!" -ForegroundColor Red
    exit 1
}
