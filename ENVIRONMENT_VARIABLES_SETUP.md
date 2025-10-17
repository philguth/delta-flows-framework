# Power Platform Environment Variables Setup Guide

## Overview
This solution now uses **Environment Variables** instead of hardcoded connection references, making it portable across environments and more secure.

## Environment Variables Created

| Variable Name | Type | Purpose |
|---------------|------|---------|
| `envvar_SourceDatabaseConnection` | Connection Reference | WSSA source database connection |
| `envvar_TargetDatabaseConnection_SQL90` | Connection Reference | WSDWH_R target database connection (SQL Server 2019/SQL90) |
| `envvar_TargetDatabaseConnection_SQL83` | Connection Reference | WSDWH_R target database connection (SQL Server 2008/SQL83) |
| `envvar_DataverseConnection` | Connection Reference | Microsoft Dataverse connection |

## Security Improvements Made

✅ **Changed from `embedded` to `invoker` runtime source** - Better security isolation
✅ **Removed hardcoded connection names** - Environment-specific configuration
✅ **Added environment variables** - Centralized configuration management

## Pre-Deployment Setup

### Step 1: Install Power Platform CLI
```powershell
# Install Power Platform CLI if not already installed
winget install Microsoft.PowerPlatformCLI
```

### Step 2: Connect to Your Environment
```powershell
# Connect to your target environment
pac auth create --url https://[yourorgname].crm.dynamics.com
pac env list
pac env select --environment [your-environment-id]
```

### Step 3: Create SQL Server Connections

#### Source Database Connection (WSSA)
```powershell
# Create connection for source database
pac connection create --connector shared_sql --name "Source-WSSA-Connection" --display-name "Source WSSA Database"
# Note the connection reference logical name from the output
```

#### Target Database Connection (WSDWH_R)
```powershell
# Create connection for target database
pac connection create --connector shared_sql --name "Target-WSDWHR-Connection" --display-name "Target WSDWH_R Database"
# Note the connection reference logical name from the output
```

#### Dataverse Connection
```powershell
# Create Dataverse connection
pac connection create --connector shared_commondataserviceforapps --name "Dataverse-Connection" --display-name "Dataverse Environment"
# Note the connection reference logical name from the output
```

## Deployment Process

### Step 1: Deploy the Solution
```powershell
# Import the solution (this will create the environment variables)
pac solution import --path "TestHRDeltaFlowsforWSDWH_R_1_0_0_5.zip"
```

### Step 2: Configure Environment Variables
After deployment, you need to set the environment variable values to point to your connections:

```powershell
# Set Source Database Connection
pac env var set --name "envvar_SourceDatabaseConnection" --connection-reference "[source-connection-logical-name]"

# Set Target Database Connection for SQL90 (SQL Server 2019)
pac env var set --name "envvar_TargetDatabaseConnection_SQL90" --connection-reference "[target-sql90-connection-logical-name]"

# Set Target Database Connection for SQL83 (SQL Server 2008)
pac env var set --name "envvar_TargetDatabaseConnection_SQL83" --connection-reference "[target-sql83-connection-logical-name]"

# Set Dataverse Connection
pac env var set --name "envvar_DataverseConnection" --connection-reference "[dataverse-connection-logical-name]"
```

## Alternative: Manual Setup via Power Platform Admin Center

### Option 1: Using Power Platform Admin Center

1. **Go to Power Platform Admin Center** → Your Environment → Settings → Environment Variables
2. **Set values for each environment variable:**
   - `envvar_SourceDatabaseConnection` → Select your source SQL connection
   - `envvar_TargetDatabaseConnection_SQL90` → Select your target SQL connection (SQL Server 2019)
   - `envvar_TargetDatabaseConnection_SQL83` → Select your target SQL connection (SQL Server 2008)
   - `envvar_DataverseConnection` → Select your Dataverse connection

### Option 2: Using Power Apps Maker Portal

1. **Go to make.powerapps.com** → Your Environment → Solutions → Default Solution
2. **Navigate to Environment Variables**
3. **Edit each variable and set the connection reference values**

## Validation Steps

### 1. Verify Environment Variables
```powershell
# List all environment variables
pac env var list

# Check specific variable values
pac env var get --name "envvar_SourceDatabaseConnection"
pac env var get --name "envvar_TargetDatabaseConnection_SQL90"
pac env var get --name "envvar_TargetDatabaseConnection_SQL83"
pac env var get --name "envvar_DataverseConnection"
```

### 2. Test Flow Connections
1. Open Power Automate maker portal
2. Navigate to your flows
3. Check that connection references resolve correctly
4. Run a test execution

## Troubleshooting

### Common Issues

**Issue:** Environment variable not found
**Solution:** Ensure the solution was imported successfully and environment variables are visible in the environment

**Issue:** Connection reference not resolving
**Solution:** Verify the connection exists and the environment variable value is set correctly

**Issue:** Permission errors
**Solution:** Ensure you have System Administrator or Environment Maker permissions

### Verification Script
```powershell
# Complete verification script
function Test-EnvironmentSetup {
    Write-Host "Testing Environment Variable Setup..." -ForegroundColor Yellow

    $envVars = @(
        "envvar_SourceDatabaseConnection",
        "envvar_TargetDatabaseConnection_SQL90",
        "envvar_TargetDatabaseConnection_SQL83",
        "envvar_DataverseConnection"
    )

    foreach ($var in $envVars) {
        try {
            $result = pac env var get --name $var 2>$null
            if ($result) {
                Write-Host "✅ $var - Configured" -ForegroundColor Green
            } else {
                Write-Host "❌ $var - Not configured" -ForegroundColor Red
            }
        } catch {
            Write-Host "❌ $var - Error checking" -ForegroundColor Red
        }
    }
}

# Run the test
Test-EnvironmentSetup
```

## Benefits of This Approach

✅ **Environment Portability** - Same solution works across Dev/Test/Prod
✅ **Security** - No hardcoded credentials or connection strings
✅ **Maintainability** - Centralized connection management
✅ **Compliance** - Better separation of configuration from code
✅ **Flexibility** - Easy to change connections without redeploying solution

## Next Steps

1. Deploy using the steps above
2. Test the flows in your environment
3. Consider implementing Azure Key Vault for additional security
4. Set up CI/CD pipeline for automated deployments across environments