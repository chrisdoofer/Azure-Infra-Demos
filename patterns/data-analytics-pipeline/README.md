# Data Analytics Pipeline

## Overview

Build a modern data analytics platform with Azure Data Factory, Synapse Analytics, and Data Lake Storage Gen2. This pattern enables enterprise-scale ETL/ELT pipelines, data warehousing, and big data processing with unified analytics capabilities.

**Category**: Solution Architecture  
**Services**: Azure Data Factory, Synapse Analytics, Data Lake Storage Gen2, Key Vault, Log Analytics  
**Complexity**: Advanced  
**Estimated Daily Cost**: $30-50 (serverless only) | $150-300 (with Spark pools)  
**Estimated Monthly Cost**: $900-1,500 (serverless) | $4,500-9,000 (with active Spark)

## Architecture

This pattern implements a modern data warehouse with medallion architecture:

- **Data Lake Storage Gen2**: Hierarchical storage with bronze/silver/gold layers (raw/curated/enriched data)
- **Azure Data Factory**: Visual ETL/ELT pipeline orchestration with 100+ data source connectors
- **Synapse Analytics Serverless SQL**: Query data lake files directly using T-SQL without provisioning
- **Synapse Analytics Dedicated SQL Pool** (optional): MPP data warehouse for high-throughput workloads
- **Synapse Spark Pools** (optional): Distributed big data processing and machine learning
- **Key Vault**: Secure credential and connection string management with managed identity integration
- **Log Analytics**: Centralized monitoring, pipeline diagnostics, and query performance metrics

See `architecture.mmd` for the detailed architecture diagram.

## Business Value

This pattern delivers:

- **Unified analytics workspace**: SQL, Spark, and data integration in a single platform—reduce tool sprawl and training costs
- **Data democratisation**: Enable analysts to query petabyte-scale data using familiar SQL tools
- **Cost-effective big data**: Serverless SQL charges per terabyte scanned ($5/TB), not per hour of provisioned capacity
- **ETL automation**: Visual pipeline designer reduces development time by 60% vs. hand-coded ETL
- **Bronze/silver/gold architecture**: Separate raw ingestion, data quality curation, and analytics-ready datasets for better governance

## Prerequisites

Before deploying this pattern, ensure you have:

- Azure subscription with appropriate permissions (Contributor or Owner role)
- Azure CLI version 2.50.0 or later installed and authenticated (`az login`)
- Resource group created or permissions to create one
- SQL administrator credentials prepared (strong password required)
- Understanding of data lake and ETL concepts
- (Optional) Sample data files for testing pipelines

## Deployment

### Option 1: Azure CLI (Recommended)

```bash
# Set deployment variables
RESOURCE_GROUP="rg-data-analytics-demo"
LOCATION="eastus"
PREFIX="demo"
SQL_PASSWORD="ComplexPassword123!@#"  # Use a strong password

# Create resource group
az group create \
  --name $RESOURCE_GROUP \
  --location $LOCATION

# Deploy infrastructure (serverless only - recommended to start)
az deployment group create \
  --resource-group $RESOURCE_GROUP \
  --template-file main.bicep \
  --parameters @parameters/dev.parameters.json \
  --parameters prefix=$PREFIX \
              location=$LOCATION \
              sqlAdministratorPassword=$SQL_PASSWORD \
              deploySqlPool=false \
              deploySparkPool=false

# Deployment takes 20-30 minutes due to Synapse workspace provisioning
```

**To include Spark pools** (for big data processing):
```bash
az deployment group create \
  --resource-group $RESOURCE_GROUP \
  --template-file main.bicep \
  --parameters @parameters/dev.parameters.json \
  --parameters prefix=$PREFIX \
              location=$LOCATION \
              sqlAdministratorPassword=$SQL_PASSWORD \
              deploySparkPool=true \
              sparkNodeSize=Small \
              sparkAutoScaleMinNodes=3 \
              sparkAutoScaleMaxNodes=10 \
              sparkAutoPauseDelayInMinutes=15
```

### Option 2: Azure Portal

1. Click the **Deploy to Azure** button below
2. Select your subscription and resource group
3. Fill in required parameters:
   - **Prefix**: Unique identifier for resource naming (3-8 characters)
   - **Location**: Azure region (e.g., `eastus`, `westeurope`)
   - **SQL Administrator Password**: Strong password (min 12 chars, mixed case, numbers, symbols)
   - **Deploy SQL Pool**: `false` (start with serverless to minimize costs)
   - **Deploy Spark Pool**: `false` (enable only if needed for big data processing)
4. Review settings and click **Create**

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FYOUR-ORG%2FAzure-Infra-Demos%2Fmain%2Fpatterns%2Fdata-analytics-pipeline%2Fazuredeploy.json)

## Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `location` | string | Resource group location | Azure region for all resources |
| `prefix` | string | `demo` | Prefix for resource naming (3-8 chars, lowercase) |
| `storageSku` | string | `Standard_LRS` | Data Lake storage redundancy (LRS/GRS/ZRS) |
| `deploySqlPool` | bool | `false` | Deploy dedicated SQL pool (adds ~$1,200-3,600/month) |
| `synapseSqlPoolSku` | string | `DW100c` | Dedicated SQL pool compute size (if enabled) |
| `deploySparkPool` | bool | `false` | Deploy Spark pool (adds ~$1,000-2,000/month if actively used) |
| `sparkNodeSize` | string | `Small` | Spark node size: Small (4 vCores), Medium (8), Large (16) |
| `sparkAutoScaleMinNodes` | int | `3` | Minimum Spark cluster nodes |
| `sparkAutoScaleMaxNodes` | int | `10` | Maximum Spark cluster nodes (scales automatically under load) |
| `sparkAutoPauseDelayInMinutes` | int | `15` | Auto-pause Spark pool after idle time (saves costs) |
| `sqlAdministratorLogin` | string | `sqladmin` | Synapse SQL admin username |
| `sqlAdministratorPassword` | securestring | (required) | SQL admin password (min 12 chars, complexity required) |
| `tags` | object | `{Environment: 'dev'}` | Resource tags for cost tracking and governance |

## Cost Estimation

**IMPORTANT**: Costs vary significantly based on data volume and usage patterns. Estimates below assume moderate analytics workloads.

### Serverless Configuration (Recommended for Starting)

| Service | Usage Assumption | Daily Cost | Monthly Cost |
|---------|-----------------|------------|--------------|
| **Data Lake Storage Gen2** | 1 TB hot tier, 5 TB cool tier | $1.50 | $45 |
| **Synapse Workspace** | Serverless SQL only | $0 | $0 (workspace free) |
| **Serverless SQL Queries** | 2 TB scanned per day | $10 | $300 ($5/TB) |
| **Data Factory** | 10 pipeline runs/day, 50 activities | $2 | $60 |
| **Key Vault** | 10,000 operations/day | $0.10 | $3 |
| **Log Analytics** | 5 GB logs/day | $3 | $90 (first 5 GB free, then $2.30/GB) |
| **TOTAL (Serverless Only)** | — | **~$16.60/day** | **~$498/month** |

### With Spark Pools (For Big Data Processing)

| Service | Usage Assumption | Daily Cost | Monthly Cost |
|---------|-----------------|------------|--------------|
| **Spark Pool** | 8 hours/day active, 5 Small nodes average | $16.80 | $504 ($0.42/node-hour) |
| **+ Serverless baseline** | (from above) | $16.60 | $498 |
| **TOTAL (with Spark)** | — | **~$33.40/day** | **~$1,002/month** |

### With Dedicated SQL Pool (For Consistent High-Throughput)

| Service | Usage Assumption | Daily Cost | Monthly Cost |
|---------|-----------------|------------|--------------|
| **Dedicated SQL Pool** | DW100c, paused 12 hours/day | $61 | $1,830 ($122/day if always-on) |
| **+ Serverless baseline** | (from above) | $16.60 | $498 |
| **TOTAL (with Dedicated SQL)** | — | **~$77.60/day** | **~$2,328/month** |

**⚠️ CRITICAL COST NOTES**:

1. **Spark pools are the #1 cost driver**: Leaving Spark pools running overnight can cost $100+/day. **Always enable auto-pause** (15 minutes recommended).
2. **Dedicated SQL pools cost $1,200-3,600/month when running**: Pause when not in use (nights/weekends) to reduce costs by 50-70%.
3. **Serverless SQL charges per TB scanned**: Optimize queries with partitioning and parquet format to reduce scanned data by 80-95%.

## Cost Optimization Strategies

### Immediate Actions (No Code Changes)
1. **Enable Spark pool auto-pause**: Set to 15 minutes idle timeout (already configured in template)
2. **Pause dedicated SQL pool daily**: Use Azure Automation or Data Factory to pause during off-hours
3. **Use parquet format**: Convert CSV/JSON to parquet—reduces storage by 70% and query costs by 80%
4. **Partition data**: Organize Data Lake by date (`/year=2024/month=03/day=15/`)—enables partition pruning to reduce scanned data

### Query Optimization
- **Select only needed columns**: `SELECT col1, col2` instead of `SELECT *` reduces data scanned
- **Filter early**: Apply `WHERE` clauses before joins to minimize processed data
- **Materialize aggregations**: Pre-compute common rollups (daily sales) in gold layer

### Advanced Optimizations
- **Lifecycle policies**: Auto-move data >90 days old to cool tier (saves $13/TB/month)
- **Reserved capacity**: Purchase Synapse Committed Units (SCU) for 20-30% savings on predictable workloads
- **Right-size Spark pools**: Start with Small nodes; most workloads don't need Medium/Large

## Security Considerations

- ✅ **Managed identities**: Data Factory and Synapse authenticate without credentials in code
- ✅ **Key Vault secrets**: Connection strings and API keys stored securely with RBAC access
- ✅ **Data Lake RBAC**: Folder-level permissions control access to bronze/silver/gold layers
- ✅ **Column-level security**: Synapse SQL supports masking sensitive data (PII, credit cards)
- ✅ **Encryption**: All data encrypted at rest (Microsoft-managed keys) and in transit (TLS 1.2)
- ✅ **Audit logging**: Log Analytics captures all data access, pipeline runs, and query activity
- ✅ **Compliance**: Synapse certified for HIPAA, SOC 2, ISO 27001, PCI DSS

**Production Recommendations**:
- Enable private endpoints for Synapse and Data Lake (eliminates public internet exposure)
- Configure Data Lake firewall to allow only trusted Azure services and corporate IP ranges
- Implement Synapse managed virtual network for Spark cluster isolation

## Post-Deployment Steps

### 1. Verify Deployment Success
```bash
# Check resource group
az group show --name $RESOURCE_GROUP

# Get deployment outputs
az deployment group show \
  --resource-group $RESOURCE_GROUP \
  --name main \
  --query properties.outputs

# Get Synapse workspace URL
SYNAPSE_WORKSPACE=$(az deployment group show \
  --resource-group $RESOURCE_GROUP \
  --name main \
  --query properties.outputs.synapseWorkspaceName.value -o tsv)

echo "Synapse Studio: https://$SYNAPSE_WORKSPACE.dev.azuresynapse.net"
```

### 2. Upload Sample Data to Data Lake
```bash
# Get storage account name
STORAGE_ACCOUNT=$(az deployment group show \
  --resource-group $RESOURCE_GROUP \
  --name main \
  --query properties.outputs.dataLakeName.value -o tsv)

# Upload CSV files to bronze layer
az storage blob upload-batch \
  --account-name $STORAGE_ACCOUNT \
  --destination bronze/sales \
  --source ./sample-data/sales \
  --auth-mode login

# Verify upload
az storage blob list \
  --account-name $STORAGE_ACCOUNT \
  --container-name bronze \
  --prefix sales/ \
  --auth-mode login \
  --output table
```

### 3. Create Your First Data Factory Pipeline
1. Open **Data Factory Studio** (from Azure Portal → Data Factory → Author & Monitor)
2. Create **new pipeline**:
   - **Copy activity**: Bronze CSV → Silver Parquet (includes format conversion)
   - **Data Flow activity**: Apply transformations (filter, join, aggregate)
3. **Trigger** pipeline and monitor execution
4. Check **silver container** for transformed parquet files

### 4. Query Data with Serverless SQL
1. Open **Synapse Studio** (URL from step 1)
2. Navigate to **Develop → SQL scripts**
3. Run sample query:
   ```sql
   SELECT TOP 100 *
   FROM OPENROWSET(
       BULK 'https://<storage-account>.dfs.core.windows.net/silver/sales/*.parquet',
       FORMAT = 'PARQUET'
   ) AS sales;
   ```
4. Note **Data processed** metric (cost = data scanned × $5/TB)

### 5. Set Up Monitoring and Alerts
1. Azure Portal → **Log Analytics workspace**
2. Create alert rules:
   - Data Factory pipeline failures
   - Synapse query timeouts (>60 seconds)
   - Cost anomalies (daily spend >$100)
3. Configure **action groups** for email/SMS notifications

## Data Flow Architecture

The bronze/silver/gold medallion architecture provides data quality progression:

```
1. INGEST (Bronze Layer)
   └─ Raw data lands from sources in original format (CSV, JSON, Avro)
   └─ No transformations—preserves lineage and enables reprocessing
   
2. CURATE (Silver Layer)
   └─ Data Factory pipelines clean, validate, deduplicate
   └─ Convert to efficient parquet format (70% smaller than CSV)
   └─ Apply business rules and data quality checks
   
3. ENRICH (Gold Layer)
   └─ Join with dimensions, aggregate, calculate KPIs
   └─ Optimized for analytics queries (partitioned, indexed)
   └─ Power BI and reporting tools consume from here
   
4. ANALYZE
   └─ Synapse serverless SQL queries gold layer
   └─ Spark notebooks for ML model training
   └─ Power BI DirectQuery for real-time dashboards
```

## Monitoring & Operations

### Data Factory Monitoring
- **Pipeline runs**: Track execution status, duration, and data volume processed
- **Activity failures**: Drill into failed activities to see error messages and affected records
- **Trigger history**: Audit scheduled and event-driven pipeline executions

### Synapse Analytics Monitoring
- **Serverless SQL**: Query history, data scanned (cost driver), execution time
- **Spark applications**: Job timeline, resource utilization, auto-scaling events
- **Dedicated SQL pools**: Query performance, tempdb usage, concurrency limits

### Log Analytics Queries (KQL)
```kql
// Failed Data Factory pipelines (last 24 hours)
ADFPipelineRun
| where Status == "Failed"
| where TimeGenerated > ago(24h)
| summarize count() by PipelineName, ErrorMessage

// Slow Synapse serverless SQL queries (>60 seconds)
SynapseSqlPoolExecRequests
| where ExecutionTime > 60000
| summarize avg(ExecutionTime), max(DataProcessedMB) by QueryText
```

### Cost Management
- **Azure Cost Management**: Daily spend by service, forecast vs. budget
- **Budget alerts**: Notify at 50%, 80%, 100% of monthly budget
- **Tag-based allocation**: Track costs by department, project, environment

## Cleanup / Teardown

**⚠️ WARNING**: This deletes all resources and data permanently. Back up important data first.

```bash
# Delete all resources
az group delete \
  --name $RESOURCE_GROUP \
  --yes \
  --no-wait

# Verify deletion (after 5-10 minutes)
az group exists --name $RESOURCE_GROUP
# Output: false
```

**What gets deleted**:
- Data Lake Storage and all data (bronze/silver/gold)
- Synapse workspace, SQL pools, Spark pools
- Data Factory pipelines and linked services
- Key Vault and stored secrets
- Log Analytics workspace and logs

**To preserve data**:
```bash
# Backup critical Data Lake folders before deletion
az storage blob download-batch \
  --account-name $STORAGE_ACCOUNT \
  --source gold \
  --destination ./backup/gold \
  --auth-mode login
```

## Related Patterns

- **Serverless API**: Build APIs that query Data Lake via serverless SQL
- **Azure Monitor Baseline**: Enhanced monitoring for Synapse and Data Factory
- **Landing Zone Foundation**: Enterprise-scale governance and networking
- **Real-Time Analytics**: Combine with Stream Analytics for real-time ingestion

## Additional Resources

- **Documentation**:
  - [Azure Synapse Analytics](https://learn.microsoft.com/azure/synapse-analytics/)
  - [Azure Data Factory](https://learn.microsoft.com/azure/data-factory/)
  - [Data Lake Storage Gen2](https://learn.microsoft.com/azure/storage/blobs/data-lake-storage-introduction)

- **Architecture Guidance**:
  - [Modern Data Warehouse Architecture](https://learn.microsoft.com/azure/architecture/solution-ideas/articles/modern-data-warehouse)
  - [Enterprise Analytics & Reporting](https://learn.microsoft.com/azure/architecture/solution-ideas/articles/enterprise-bi-synapse)
  - [Bronze/Silver/Gold Medallion Architecture](https://learn.microsoft.com/azure/databricks/lakehouse/medallion)

- **Best Practices**:
  - [Synapse SQL Performance Tuning](https://learn.microsoft.com/azure/synapse-analytics/sql/best-practices-dedicated-sql-pool)
  - [Data Factory Pipeline Design Patterns](https://learn.microsoft.com/azure/data-factory/concepts-pipeline-design-patterns)
  - [Cost Optimization Guide](https://learn.microsoft.com/azure/synapse-analytics/overview-costs)

- **Training**:
  - [Microsoft Learn: Synapse Analytics](https://learn.microsoft.com/training/browse/?products=azure-synapse-analytics)
  - [Data Engineering on Azure](https://learn.microsoft.com/training/paths/data-engineering-with-azure-synapse-analytics/)

## Support

For issues, questions, or architecture guidance:
- 📖 Review the **talk track** (`talk-track.md`) for presentation guidance and business value messaging
- 🐛 Open an [issue](https://github.com/YOUR-ORG/Azure-Infra-Demos/issues) in this repository
- 💬 Engage Microsoft Customer Success team for enterprise support
- 🌐 Join [Azure Synapse Analytics community forums](https://learn.microsoft.com/answers/topics/azure-synapse-analytics.html)
