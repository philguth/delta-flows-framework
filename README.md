# Delta Flows Synchronization Framework

A comprehensive Power Platform solution for orchestrating data synchronization between source systems and data warehouse using environment variables for secure, portable deployments.

## 🎯 Overview

This solution provides:
- **Master Flow**: Orchestrates delta processing across multiple tables with parallel execution
- **Framework with Batching Flow**: Handles individual table data transfers with batching
- **Custom Entities**: Data mapping records and execution logging
- **Environment Variables**: Secure, portable connection management
- **Reusable Framework**: Adaptable for HR, Finance, Sales, or any data synchronization needs

## 🏗️ Architecture

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   Source WSSA   │───▶│   Master Flow    │───▶│ Target WSDWH_R  │
│   Database      │    │  (Orchestrator)  │    │   Database      │
└─────────────────┘    └──────────────────┘    └─────────────────┘
                                │
                                ▼
                       ┌──────────────────┐
                       │ Framework Flow   │
                       │ (Per Table)      │
                       └──────────────────┘
                                │
                                ▼
                       ┌──────────────────┐
                       │   Dataverse      │
                       │ (Logging/Config) │
                       └──────────────────┘
```

## 🚀 Features

### Performance Optimizations
- **Parallel Change Detection**: 20 concurrent change checks
- **Parallel Table Processing**: 5 concurrent child flow executions  
- **Selective Processing**: Only processes tables with actual changes
- **Batching Support**: Efficient handling of large datasets

### Security & Governance
- **Environment Variables**: No hardcoded connections
- **Invoker Runtime**: Enhanced security isolation
- **Comprehensive Logging**: Full audit trail via custom entities
- **Error Isolation**: Individual table failures don't affect others

## 📋 Prerequisites

- Power Platform environment with appropriate licensing
- SQL Server databases (source and target)
- Power Platform CLI installed
- Git and GitHub account

## 🛠️ Quick Start

### 1. Clone Repository
```bash
git clone https://github.com/philguth/delta-flows-framework.git
cd delta-flows-framework
```

### 2. Deploy Solution
```powershell
# Connect to your environment
pac auth create --url https://[yourorg].crm.dynamics.com

# Import solution
pac solution import --path TestHRDeltaFlowsforWSDWH_R_1_0_0_5.zip

# Setup environment variables (automated)
.\Setup-EnvironmentVariables.ps1 -EnvironmentUrl "https://[yourorg].crm.dynamics.com"
```

### 3. Configure Connections
The automated script will:
- Create necessary SQL Server and Dataverse connections
- Configure environment variables
- Validate setup

## 📁 Repository Structure

```
delta-flows-framework/
├── Workflows/                          # Power Automate flow definitions
│   ├── Master-[GUID].json             # Master orchestration flow
│   └── FrameworkwithBatching-[GUID].json # Table processing flow
├── solution.xml                        # Solution manifest
├── customizations.xml                  # Entity and component definitions
├── [Content_Types].xml                # Content type mappings
├── EnvironmentVariables.xml           # Environment variable definitions
├── Setup-EnvironmentVariables.ps1     # Automated deployment script
├── DEPLOYMENT_GUIDE.md               # Deployment instructions
├── ENVIRONMENT_VARIABLES_SETUP.md    # Environment setup guide
└── README.md                         # This file
```

## 🔧 Environment Variables

| Variable | Purpose | Type |
|----------|---------|------|
| `envvar_SourceDatabaseConnection` | Source WSSA database | Connection Reference |
| `envvar_TargetDatabaseConnection` | Target WSDWH_R database | Connection Reference |
| `envvar_DataverseConnection` | Dataverse environment | Connection Reference |

## 📖 Documentation

- [Deployment Guide](DEPLOYMENT_GUIDE.md) - Complete deployment instructions
- [Environment Variables Setup](ENVIRONMENT_VARIABLES_SETUP.md) - Detailed configuration guide

## 🔄 CI/CD Integration

This repository includes GitHub Actions workflows for:
- Solution validation
- Automated testing
- Environment deployment
- Release management

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/your-feature`
3. Commit changes: `git commit -am 'Add your feature'`
4. Push to branch: `git push origin feature/your-feature`
5. Submit a Pull Request

## 📊 Monitoring

The solution includes comprehensive logging through:
- Custom `trz_flowexecutionlog` entity
- Built-in Power Automate run history
- Optional Application Insights integration

## 🛡️ Security

- Environment variables for all connections
- Invoker-based runtime security
- No hardcoded credentials
- Least-privilege database access recommended

## 📞 Support

For issues, questions, or contributions:
- Create an [Issue](https://github.com/philguth/delta-flows-framework/issues)
- Submit a [Pull Request](https://github.com/philguth/delta-flows-framework/pulls)
- Check [Discussions](https://github.com/philguth/delta-flows-framework/discussions)

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🏷️ Version

Current Version: 1.0.0.5

## 🎯 Roadmap

- [ ] Azure Key Vault integration
- [ ] Advanced error handling patterns  
- [ ] Power BI monitoring dashboard
- [ ] Automated performance tuning
- [ ] Multi-tenant support