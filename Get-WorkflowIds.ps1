#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Gets the WorkflowId (GUID) for existing Power Automate flows in the environment.

.DESCRIPTION
    This script helps you find the correct WorkflowId GUIDs for flows that already exist
    in your Power Platform environment, so you can add them to your solution using RootComponents.

.EXAMPLE
    .\Get-WorkflowIds.ps1

.NOTES
    Requires Power Platform CLI (pac) to be installed and authenticated.
    Run 'pac auth list' to verify you're connected to the correct environment.
#>

Write-Host ""
Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "   Getting WorkflowIds for Existing Flows" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

# Check if pac CLI is installed
try {
    $pacVersion = pac --version 2>&1
    Write-Host "✅ Power Platform CLI found: $pacVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ Power Platform CLI (pac) not found!" -ForegroundColor Red
    Write-Host "   Install from: https://aka.ms/PowerPlatformCLI" -ForegroundColor Yellow
    exit 1
}

Write-Host ""
Write-Host "📋 Checking authentication..." -ForegroundColor Yellow

# Check authentication
$authList = pac auth list 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Not authenticated to Power Platform" -ForegroundColor Red
    Write-Host "   Run: pac auth create --environment <your-environment-url>" -ForegroundColor Yellow
    exit 1
}

Write-Host $authList
Write-Host ""
Write-Host "🔍 Fetching workflows from environment..." -ForegroundColor Yellow
Write-Host ""

# Query for workflows (Power Automate flows are category 5)
# This queries the Dataverse workflow table
$query = @"
<fetch>
  <entity name='workflow'>
    <attribute name='workflowid' />
    <attribute name='name' />
    <attribute name='category' />
    <attribute name='statecode' />
    <attribute name='createdon' />
    <filter>
      <condition attribute='category' operator='eq' value='5' />
    </filter>
    <order attribute='name' />
  </entity>
</fetch>
"@

Write-Host "Running FetchXML query to get all Power Automate flows..." -ForegroundColor Cyan
Write-Host ""

# Save query to temp file
$queryFile = "temp_workflow_query.xml"
$query | Out-File -FilePath $queryFile -Encoding UTF8

try {
    # Execute the query using pac data query
    Write-Host "💡 TIP: Look for flows named 'Master' or 'Framework' or 'Batching'" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host ""

    pac data query --fetch-xml $queryFile

    Write-Host ""
    Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "📝 INSTRUCTIONS:" -ForegroundColor Yellow
    Write-Host "   1. Find your flows in the list above" -ForegroundColor White
    Write-Host "   2. Copy their 'workflowid' GUIDs" -ForegroundColor White
    Write-Host "   3. Update solution.xml RootComponent schemaName with those GUIDs" -ForegroundColor White
    Write-Host ""
    Write-Host "   Example RootComponent format:" -ForegroundColor White
    Write-Host "   <RootComponent type='29' schemaName='[GUID-HERE]' behavior='0' />" -ForegroundColor Gray
    Write-Host ""

} catch {
    Write-Host "❌ Error querying workflows: $_" -ForegroundColor Red
    Write-Host ""
    Write-Host "Alternative: Use Power Automate Portal" -ForegroundColor Yellow
    Write-Host "   1. Go to https://make.powerautomate.com" -ForegroundColor White
    Write-Host "   2. Select your environment" -ForegroundColor White
    Write-Host "   3. Go to Solutions and find the solution containing your flows" -ForegroundColor White
    Write-Host "   4. Click on each flow and check the URL" -ForegroundColor White
    Write-Host "   5. The URL contains the WorkflowId GUID" -ForegroundColor White
    Write-Host ""
} finally {
    # Cleanup temp file
    if (Test-Path $queryFile) {
        Remove-Item $queryFile -Force
    }
}

Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
