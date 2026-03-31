# Azure Monitor Baseline

## Overview

Establish a comprehensive monitoring foundation with Azure Monitor, Log Analytics, and Application Insights. This baseline pattern provides centralized logging, application performance monitoring, and alerting for your Azure workloads.

**Category**: reference-architecture  
**Services**: Azure Monitor, Log Analytics, Application Insights, Action Groups  
**Complexity**: Beginner  
**Estimated Monthly Cost**: $50-$200 (varies by data ingestion volume)

## Architecture

This pattern implements a monitoring baseline with:

- **Log Analytics Workspace**: Centralized log collection and analysis
- **Application Insights**: Application performance and usage analytics
- **Action Groups**: Alert notification routing via email, SMS, webhook
- **Metric Alerts**: Automated monitoring of resource health and performance
- **Diagnostic Settings**: Capture platform logs and metrics

See `architecture.mmd` for the detailed architecture diagram.

## Prerequisites

Before deploying this pattern, ensure you have:

- Azure subscription with appropriate permissions
- Azure CLI installed and authenticated (`az login`)
- Resource group created or permissions to create one
- Valid email address for alert notifications

## Deployment

### Option 1: Azure CLI

```bash
# Set variables
RESOURCE_GROUP="rg-monitor-baseline-demo"
LOCATION="eastus"
PREFIX="demo"
ALERT_EMAIL="your-email@example.com"

# Create resource group (if needed)
az group create --name $RESOURCE_GROUP --location $LOCATION

# Deploy the template
az deployment group create \
  --resource-group $RESOURCE_GROUP \
  --template-file main.bicep \
  --parameters @parameters/dev.parameters.json \
  --parameters prefix=$PREFIX location=$LOCATION alertEmail=$ALERT_EMAIL
```

### Option 2: Azure Portal

1. Click the **Deploy to Azure** button below
2. Fill in the required parameters (especially alert email)
3. Review and create

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FYOUR-ORG%2FAzure-Infra-Demos%2Fmain%2Fpatterns%2Fazure-monitor-baseline%2Fazuredeploy.json)

## Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `location` | string | (resource group location) | Azure region for deployment |
| `prefix` | string | `demo` | Prefix for resource naming |
| `retentionDays` | int | `30` | Log retention period in days |
| `alertEmail` | string | (required) | Email address for alert notifications |
| `dailyQuotaGb` | int | `1` | Daily data ingestion cap in GB |
| `tags` | object | (see template) | Resource tags |

## Cost Estimation

Estimated monthly costs (East US region, 1 GB/day ingestion):

- **Log Analytics Workspace**: ~$2.30/GB (~$70/month for 30 GB)
- **Application Insights**: First 5 GB/month free, then ~$2.30/GB
- **Action Groups**: Free for email notifications
- **Metric Alerts**: First 10 rules free, then ~$0.10/rule
- **Total**: ~$50-$200/month depending on data volume

**Cost Optimization Tips**:
- Set daily data cap to control costs
- Use data retention policies (reduce from default 30 days if not needed)
- Archive old logs to Azure Storage for long-term retention
- Review and remove unused alert rules

## Security Considerations

- **Access Control**: Use Azure RBAC to control workspace access
- **Data Encryption**: Data encrypted at rest and in transit
- **Network Access**: Configure private endpoints for enhanced security
- **Audit Logging**: Enable diagnostic settings to track access

## Monitoring & Operations

After deployment:

1. **Verify Log Analytics**: Check workspace is receiving data
2. **Test Application Insights**: Deploy an app and configure instrumentation
3. **Confirm Alerts**: Verify email notifications are received
4. **Create Dashboards**: Build custom dashboards in Azure Portal
5. **Configure Queries**: Set up KQL queries for common scenarios

## Next Steps

1. **Connect Resources**: Configure diagnostic settings on existing resources
2. **Instrument Applications**: Add Application Insights SDK to your apps
3. **Create Dashboards**: Build monitoring dashboards
4. **Define Alerts**: Set up additional alert rules for your workloads
5. **Review Queries**: Explore sample KQL queries in Log Analytics

## Cleanup

To remove all deployed resources:

```bash
az group delete --name $RESOURCE_GROUP --yes --no-wait
```

## Related Patterns

- App Insights Instrumentation
- Web App with Private Endpoint
- Serverless API

## Additional Resources

- [Azure Monitor Documentation](https://learn.microsoft.com/azure/azure-monitor/)
- [Log Analytics Tutorial](https://learn.microsoft.com/azure/azure-monitor/logs/log-analytics-tutorial)
- [Application Insights Overview](https://learn.microsoft.com/azure/azure-monitor/app/app-insights-overview)
- [KQL Query Language](https://learn.microsoft.com/azure/data-explorer/kusto/query/)

## Support

For issues or questions:
- Open an issue in this repository
- Review the talk track (`talk-track.md`) for presentation guidance
