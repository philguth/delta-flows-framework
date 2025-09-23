# Environment Variables Setup Script for Delta Flows Framework
# This script automates the setup of environment variables after solution deployment

param(
    [Parameter(Mandatory=$true)]
    [string]$EnvironmentUrl,

    [Parameter(Mandatory=$false)]
    [string]$SourceConnectionName = "Source-WSSA-Connection",

    [Parameter(Mandatory=$false)]
    [string]$TargetConnectionName = "Target-WSDWHR-Connection",

    [Parameter(Mandatory=$false)]
    [string]$DataverseConnectionName = "Dataverse-Connection"
)

Write-Host "🚀 Delta Flows Framework - Environment Variables Setup" -ForegroundColor Cyan
Write-Host "======================================================" -ForegroundColor Cyan

# Check if Power Platform CLI is installed
try {
    $pacVersion = pac --version
    Write-Host "✅ Power Platform CLI detected: $pacVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ Power Platform CLI not found. Please install it first:" -ForegroundColor Red
    Write-Host "   winget install Microsoft.PowerPlatformCLI" -ForegroundColor Yellow
    exit 1
}

# Connect to environment
Write-Host "`n🔐 Connecting to environment: $EnvironmentUrl" -ForegroundColor Yellow
try {
    pac auth create --url $EnvironmentUrl
    Write-Host "✅ Connected successfully" -ForegroundColor Green
} catch {
    Write-Host "❌ Failed to connect to environment" -ForegroundColor Red
    exit 1
}

# Function to create SQL connection if it doesn't exist
function New-SqlConnection {
    param($ConnectionName, $DisplayName, $Description)

    Write-Host "`n🔌 Creating SQL Server connection: $ConnectionName" -ForegroundColor Yellow

    try {
        # Check if connection already exists
        $existingConnection = pac connection list --filter "name eq '$ConnectionName'" 2>$null

        if ($existingConnection) {
            Write-Host "ℹ️  Connection '$ConnectionName' already exists" -ForegroundColor Blue
            return
        }

        # Create new connection
        pac connection create --connector shared_sql --name $ConnectionName --display-name $DisplayName
        Write-Host "✅ Created connection: $ConnectionName" -ForegroundColor Green

    } catch {
        Write-Host "❌ Failed to create connection: $ConnectionName" -ForegroundColor Red
        Write-Host "   You may need to create this manually in Power Platform admin center" -ForegroundColor Yellow
    }
}

# Function to create Dataverse connection if it doesn't exist
function New-DataverseConnection {
    param($ConnectionName, $DisplayName)

    Write-Host "`n🔌 Creating Dataverse connection: $ConnectionName" -ForegroundColor Yellow

    try {
        # Check if connection already exists
        $existingConnection = pac connection list --filter "name eq '$ConnectionName'" 2>$null

        if ($existingConnection) {
            Write-Host "ℹ️  Connection '$ConnectionName' already exists" -ForegroundColor Blue
            return
        }

        # Create new connection
        pac connection create --connector shared_commondataserviceforapps --name $ConnectionName --display-name $DisplayName
        Write-Host "✅ Created connection: $ConnectionName" -ForegroundColor Green

    } catch {
        Write-Host "❌ Failed to create connection: $ConnectionName" -ForegroundColor Red
        Write-Host "   You may need to create this manually in Power Platform admin center" -ForegroundColor Yellow
    }
}

# Function to set environment variable
function Set-EnvironmentVariable {
    param($VarName, $ConnectionName, $Description)

    Write-Host "`n🔧 Setting environment variable: $VarName" -ForegroundColor Yellow

    try {
        # Get connection reference logical name
        $connections = pac connection list --json | ConvertFrom-Json
        $targetConnection = $connections | Where-Object { $_.name -eq $ConnectionName }

        if (-not $targetConnection) {
            Write-Host "❌ Connection '$ConnectionName' not found" -ForegroundColor Red
            Write-Host "   Available connections:" -ForegroundColor Yellow
            $connections | ForEach-Object { Write-Host "   - $($_.name)" -ForegroundColor Gray }
            return $false
        }

        # Set environment variable value
        pac env var set --name $VarName --connection-reference $targetConnection.logicalName
        Write-Host "✅ Set $VarName to connection: $ConnectionName" -ForegroundColor Green
        return $true

    } catch {
        Write-Host "❌ Failed to set environment variable: $VarName" -ForegroundColor Red
        Write-Host "   Error: $($_.Exception.Message)" -ForegroundColor Gray
        return $false
    }
}

# Main execution
Write-Host "`n📋 Step 1: Creating Connections" -ForegroundColor Cyan

# Create connections
New-SqlConnection -ConnectionName $SourceConnectionName -DisplayName "Source WSSA Database" -Description "Connection to source WSSA database on WSWMDWH01"
New-SqlConnection -ConnectionName $TargetConnectionName -DisplayName "Target WSDWH_R Database" -Description "Connection to target WSDWH_R data warehouse"
New-DataverseConnection -ConnectionName $DataverseConnectionName -DisplayName "Dataverse Environment"

Write-Host "`n📋 Step 2: Configuring Environment Variables" -ForegroundColor Cyan

# Set environment variables
$envVarResults = @()
$envVarResults += Set-EnvironmentVariable -VarName "envvar_SourceDatabaseConnection" -ConnectionName $SourceConnectionName -Description "Source database connection"
$envVarResults += Set-EnvironmentVariable -VarName "envvar_TargetDatabaseConnection" -ConnectionName $TargetConnectionName -Description "Target database connection"
$envVarResults += Set-EnvironmentVariable -VarName "envvar_DataverseConnection" -ConnectionName $DataverseConnectionName -Description "Dataverse connection"

# Summary
Write-Host "`n📊 Setup Summary" -ForegroundColor Cyan
Write-Host "================" -ForegroundColor Cyan

$successCount = ($envVarResults | Where-Object { $_ -eq $true }).Count
$totalCount = $envVarResults.Count

Write-Host "Environment Variables: $successCount/$totalCount configured successfully" -ForegroundColor $(if ($successCount -eq $totalCount) { "Green" } else { "Yellow" })

if ($successCount -eq $totalCount) {
    Write-Host "`n🎉 Setup completed successfully!" -ForegroundColor Green
    Write-Host "Your Delta Flows Framework solution is ready to use." -ForegroundColor Green
} else {
    Write-Host "`n⚠️  Some environment variables need manual configuration." -ForegroundColor Yellow
    Write-Host "Please check the Power Platform admin center or maker portal." -ForegroundColor Yellow
}

Write-Host "`n📚 Next Steps:" -ForegroundColor Cyan
Write-Host "1. Configure connection authentication (usernames/passwords)" -ForegroundColor White
Write-Host "2. Test the flows in Power Automate" -ForegroundColor White
Write-Host "3. Verify data synchronization works correctly" -ForegroundColor White
Write-Host "4. Set up monitoring and alerting" -ForegroundColor White

Write-Host "`n✅ Script completed!" -ForegroundColor Green