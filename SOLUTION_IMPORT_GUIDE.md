# Power Platform Solution Import Guide

## 📦 Solution Package

**File**: `DeltaFlowsFramework_v1.0.0.5.zip`
**Solution Name**: Delta Flows Synchronization Framework
**Version**: 1.0.0.5

## 🚀 How to Import

### Prerequisites
- Power Platform environment with appropriate licensing
- System Administrator or System Customizer role
- Environment Maker permissions

### Step 1: Import Solution
1. Go to [Power Platform Admin Center](https://admin.powerplatform.microsoft.com/)
2. Select your target environment
3. Go to **Solutions** → **Import solution**
4. Click **Browse** and select `DeltaFlowsFramework_v1.0.0.5.zip`
5. Click **Next** → **Import**

### Step 2: Configure Environment Variables
After import, configure the environment variables:

1. **In Power Platform Admin Center**:
   - Go to your environment → **Environment Variables**
   - Set values for:
     - `envvar_SourceDatabaseConnection`
     - `envvar_TargetDatabaseConnection`
     - `envvar_DataverseConnection`

2. **Or use PowerShell** (run from solution folder):
   ```powershell
   .\Setup-EnvironmentVariables.ps1 -EnvironmentUrl "https://yourorg.crm.dynamics.com"
   ```

### Step 3: Create Database Connections
1. Go to [Power Automate](https://make.powerautomate.com)
2. Select your environment
3. Go to **Data** → **Connections** → **New connection**
4. Create SQL Server connections for:
   - Source database (WSSA)
   - Target database (WSDWH_R)
5. Create Dataverse connection

### Step 4: Update Environment Variables
1. In Power Platform Admin Center → Environment Variables
2. Set each environment variable to reference the appropriate connection

## ✅ What Gets Imported

### Custom Entities
- **trz_datamappingrecord** - Data mapping configuration
- **trz_flowexecutionlog** - Execution logging

### Power Automate Flows
- **Master Flow** - Orchestration and change detection
- **Framework with Batching Flow** - Table-level data processing

### Environment Variables
- **envvar_SourceDatabaseConnection** - Source DB connection
- **envvar_TargetDatabaseConnection** - Target DB connection
- **envvar_DataverseConnection** - Dataverse connection

## 🔧 Post-Import Configuration

### 1. Test Connections
1. Go to Power Automate → Your flows
2. Open each flow and verify connections resolve
3. Test with a manual run

### 2. Configure Data Mappings
1. Add records to the `trz_datamappingrecord` entity
2. Define source/target table mappings
3. Set key columns and data types

### 3. Set Up Monitoring
1. Review execution logs in `trz_flowexecutionlog` entity
2. Configure alerts based on your requirements
3. Set up Power BI dashboard (optional)

## 🛡️ Security Considerations

- Environment variables use **invoker** runtime for security
- No hardcoded credentials in the solution
- Database connections require proper authentication setup
- Review and set appropriate connection permissions

## 📞 Support

If you encounter issues:
1. Check the [GitHub repository](https://github.com/philguth/delta-flows-framework) for documentation
2. Review the `DEPLOYMENT_GUIDE.md` for detailed setup
3. Create an issue on GitHub for community support

## 🎯 Success Criteria

After successful import and configuration:
- ✅ All environment variables have connection values
- ✅ Flows run without connection errors
- ✅ Data synchronization executes successfully
- ✅ Execution logs are created properly

Your Delta Flows Framework is ready to synchronize data between your systems! 🚀