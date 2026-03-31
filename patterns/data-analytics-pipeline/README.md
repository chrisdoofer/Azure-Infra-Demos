# Data Analytics Pipeline

## Overview

Build a modern data analytics platform with Azure Data Factory, Synapse Analytics, and Data Lake Storage. This pattern enables scalable ETL/ELT pipelines for data warehousing and analytics workloads.

**Category**: solution-idea  
**Services**: Azure Data Factory, Synapse Analytics, Data Lake Storage Gen2, Key Vault  
**Complexity**: Advanced  
**Estimated Monthly Cost**: $200-$2,000 (varies significantly by usage)

## Architecture

This pattern implements a data analytics pipeline with:

- **Data Lake Storage Gen2**: Hierarchical storage with bronze/silver/gold layers (raw/curated/enriched)
- **Azure Data Factory**: Orchestration and ETL pipeline management
- **Synapse Analytics**: Unified analytics with serverless and dedicated SQL pools
- **Key Vault**: Secure credential and connection string management
- **Managed Identities**: Secure service-to-service authentication

See `architecture.mmd` for the detailed architecture diagram.

## Prerequisites

Before deploying this pattern, ensure you have:

- Azure subscription with appropriate permissions
- Azure CLI installed and authenticated (`az login`)
- Resource group created or permissions to create one
- SQL administrator credentials prepared
- Understanding of data pipeline concepts

## Deployment

### Option 1: Azure CLI

```bash
# Set variables
RESOURCE_GROUP="rg-data-analytics-demo"
LOCATION="eastus"
PREFIX="demo"
SQL_PASSWORD="YourSecurePassword123!"

# Create resource group (if needed)
az group create --name $RESOURCE_GROUP --location $LOCATION

# Deploy the template
az deployment group create \
  --resource-group $RESOURCE_GROUP \
  --template-file main.bicep \
  --parameters @parameters/dev.parameters.json \
  --parameters prefix=$PREFIX \
              location=$LOCATION \
              sqlAdministratorPassword=$SQL_PASSWORD
```

### Option 2: Azure Portal

1. Click the **Deploy to Azure** button below
2. Fill in required parameters (especially SQL password)
3. Review and create

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FYOUR-ORG%2FAzure-Infra-Demos%2Fmain%2Fpatterns%2Fdata-analytics-pipeline%2Fazuredeploy.json)

## Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `location` | string | (resource group location) | Azure region for deployment |
| `prefix` | string | `demo` | Prefix for resource naming |
| `storageSku` | string | `Standard_LRS` | Storage account SKU |
| `synapseSqlPoolSku` | string | `DW100c` | Synapse SQL Pool SKU |
| `deploySqlPool` | bool | `false` | Deploy dedicated SQL pool (costs extra) |
| `sqlAdministratorLogin` | string | `sqladmin` | SQL admin username |
| `sqlAdministratorPassword` | securestring | (required) | SQL admin password |
| `tags` | object | (see template) | Resource tags |

## Cost Estimation

Estimated monthly costs (East US region):

**Without Dedicated SQL Pool**:
- **Data Lake Storage**: ~$20/month (100 GB)
- **Synapse Workspace**: Free (serverless only)
- **Data Factory**: ~$25/month (basic pipelines)
- **Key Vault**: ~$1/month
- **Total**: ~$46/month

**With Dedicated SQL Pool (DW100c)**:
- **Dedicated SQL Pool**: ~$1,200/month (if always running)
- Use "Pause" feature when not in use to save costs
- **Total**: ~$46-$1,246/month depending on SQL pool usage

**Cost Optimization Tips**:
- Pause Synapse SQL pools when not in use
- Use serverless SQL for ad-hoc queries
- Implement data lifecycle policies on storage
- Monitor Data Factory pipeline runs

## Security Considerations

- **Managed Identity**: Data Factory and Synapse use managed identities
- **Key Vault**: Store connection strings and credentials securely
- **Storage Firewall**: Configure network rules for production
- **Synapse Managed VNet**: Enable for network isolation
- **RBAC**: Use Azure RBAC for data access control

## Post-Deployment Steps

1. **Upload Sample Data**:
   ```bash
   az storage blob upload-batch \
     --account-name $STORAGE_NAME \
     --destination raw \
     --source ./sample-data/
   ```

2. **Create Data Factory Pipeline**: Build your first ETL pipeline

3. **Configure Synapse**: Set up serverless or dedicated SQL pools

4. **Test Pipeline**: Run a test data transformation

5. **Set Up Monitoring**: Configure alerts and dashboards

## Data Flow

1. **Ingest** → Raw data lands in `raw` container
2. **Transform** → Data Factory pipelines process data
3. **Curate** → Cleaned data stored in `curated` container
4. **Enrich** → Final analytics-ready data in `enriched` container
5. **Analyze** → Synapse SQL queries the enriched data

## Monitoring & Operations

After deployment, monitor your pipeline using:

- **Data Factory Monitoring**: Pipeline runs, activity status
- **Synapse Studio**: Query performance, resource utilization
- **Storage Metrics**: Data ingestion and egress
- **Log Analytics**: Centralized logging and diagnostics

## Cleanup

To remove all deployed resources:

```bash
az group delete --name $RESOURCE_GROUP --yes --no-wait
```

## Related Patterns

- Azure Monitor Baseline
- Serverless API
- Landing Zone Foundation

## Additional Resources

- [Data Factory Documentation](https://learn.microsoft.com/azure/data-factory/)
- [Synapse Analytics Documentation](https://learn.microsoft.com/azure/synapse-analytics/)
- [Data Lake Storage Gen2](https://learn.microsoft.com/azure/storage/blobs/data-lake-storage-introduction)
- [Modern Data Warehouse Architecture](https://learn.microsoft.com/azure/architecture/solution-ideas/articles/modern-data-warehouse)

## Support

For issues or questions:
- Open an issue in this repository
- Review the talk track (`talk-track.md`) for presentation guidance
