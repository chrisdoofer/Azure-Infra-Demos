# Serverless API with Azure Functions

## Overview

Build a scalable, event-driven API using Azure Functions, API Management, Cosmos DB, and Key Vault. This pattern provides a complete serverless architecture for modern API development with built-in security and observability.

**Category**: solution-idea  
**Services**: Azure Functions, API Management, Cosmos DB, Key Vault, Application Insights  
**Complexity**: Intermediate  
**Estimated Monthly Cost**: $50-$500 (varies by usage and scale)

## Architecture

This pattern implements a serverless API solution with:

- **Azure Functions**: Serverless compute for API endpoints (Consumption plan)
- **API Management**: API gateway with rate limiting, caching, and security
- **Cosmos DB**: Globally distributed NoSQL database
- **Key Vault**: Secure secret and connection string management
- **Application Insights**: End-to-end application monitoring and tracing

See `architecture.mmd` for the detailed architecture diagram.

## Prerequisites

Before deploying this pattern, ensure you have:

- Azure subscription with appropriate permissions
- Azure CLI installed and authenticated (`az login`)
- Resource group created or permissions to create one
- Basic understanding of Azure Functions and REST APIs

## Deployment

### Option 1: Azure CLI

```bash
# Set variables
RESOURCE_GROUP="rg-serverless-api-demo"
LOCATION="eastus"
PREFIX="demo"

# Create resource group (if needed)
az group create --name $RESOURCE_GROUP --location $LOCATION

# Deploy the template
az deployment group create \
  --resource-group $RESOURCE_GROUP \
  --template-file main.bicep \
  --parameters @parameters/dev.parameters.json \
  --parameters prefix=$PREFIX location=$LOCATION
```

### Option 2: Azure Portal

1. Click the **Deploy to Azure** button below
2. Fill in the required parameters
3. Review and create

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FYOUR-ORG%2FAzure-Infra-Demos%2Fmain%2Fpatterns%2Fserverless-api%2Fazuredeploy.json)

## Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `location` | string | (resource group location) | Azure region for deployment |
| `prefix` | string | `demo` | Prefix for resource naming |
| `functionRuntime` | string | `node` | Function runtime (dotnet, node, python, java) |
| `functionRuntimeVersion` | string | `18` | Runtime version |
| `cosmosDbConsistency` | string | `Session` | Cosmos DB consistency level |
| `apimSku` | string | `Consumption` | API Management SKU |
| `tags` | object | (see template) | Resource tags |

## Cost Estimation

Estimated monthly costs (East US region, moderate usage):

- **Azure Functions (Consumption)**: First 1M executions free, then $0.20/million
- **API Management (Consumption)**: First 1M calls free, then $3.50/million
- **Cosmos DB**: ~$25/month (400 RU/s provisioned)
- **Key Vault**: ~$0.03/10,000 operations
- **Storage Account**: ~$2/month
- **Application Insights**: First 5 GB free
- **Total**: ~$50-$500/month depending on scale

**Cost Optimization Tips**:
- Use Consumption plans for variable workloads
- Implement caching in API Management to reduce backend calls
- Use Cosmos DB autoscale for cost-effective scaling
- Monitor and optimize Function execution time

## Security Considerations

- **Managed Identity**: Functions use system-assigned identity for Key Vault access
- **Key Vault**: Centralized secret management with RBAC
- **HTTPS Only**: All endpoints enforce HTTPS
- **API Management**: Rate limiting and IP filtering available
- **Cosmos DB**: Connection strings stored in Key Vault

## Monitoring & Operations

After deployment, monitor your API using:

- **Application Insights**: Request tracing, dependency tracking, performance
- **Function Monitoring**: Execution logs and metrics
- **Cosmos DB Metrics**: RU consumption, latency, availability
- **API Management Analytics**: API call statistics and performance

## Next Steps

1. **Deploy Function Code**: Publish your Function app code
2. **Configure APIM**: Import Function API into API Management
3. **Set Up Policies**: Configure rate limiting, caching, and transformation
4. **Add Authentication**: Implement OAuth 2.0 or API keys
5. **Test APIs**: Use Postman or curl to test endpoints

## Cleanup

To remove all deployed resources:

```bash
az group delete --name $RESOURCE_GROUP --yes --no-wait
```

## Related Patterns

- Azure Monitor Baseline
- Microservices on AKS
- Web App with Private Endpoint

## Additional Resources

- [Azure Functions Documentation](https://learn.microsoft.com/azure/azure-functions/)
- [API Management Overview](https://learn.microsoft.com/azure/api-management/)
- [Cosmos DB Documentation](https://learn.microsoft.com/azure/cosmos-db/)
- [Serverless Best Practices](https://learn.microsoft.com/azure/architecture/serverless-quest/serverless-overview)

## Support

For issues or questions:
- Open an issue in this repository
- Review the talk track (`talk-track.md`) for presentation guidance
