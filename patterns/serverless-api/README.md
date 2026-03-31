# Serverless API with Azure Functions

## Overview

Build scalable, event-driven APIs with zero infrastructure management using Azure Functions, API Management, Cosmos DB, and Key Vault. This pattern delivers production-ready serverless APIs with automatic scaling, pay-per-execution billing, enterprise security, and comprehensive observability.

**Category**: Solution Idea  
**Services**: Azure Functions (Consumption), API Management (Consumption), Cosmos DB (Serverless), Key Vault, Application Insights  
**Complexity**: Intermediate  
**Estimated Daily Cost**: $3-5 (demo), $6-15 (production low-traffic)  
**Estimated Monthly Cost**: $90-450 (varies by usage and scale)  
**Deployment Time**: 15-20 minutes

## Architecture

This pattern implements a complete serverless API solution with:

- **Azure Functions (Consumption Plan)**: Serverless compute for HTTP-triggered API endpoints; auto-scales from zero to hundreds of instances; pay only for execution time
- **API Management (Consumption Tier)**: API gateway providing rate limiting, response caching, authentication, and request transformation
- **Cosmos DB (Serverless)**: Globally distributed NoSQL database with automatic scaling; pay-per-request pricing
- **Key Vault**: Centralized secrets management with RBAC; eliminates hardcoded credentials
- **Application Insights**: End-to-end distributed tracing, performance monitoring, and intelligent diagnostics
- **Azure Storage**: Function state management and optional blob storage for API-generated artifacts

See `architecture.mmd` for the detailed architecture diagram and `talk-track.md` for business value, demo scripts, and objection handling.

## Business Value

**For IT Leadership:**
- **Eliminate infrastructure overhead**: Zero servers to manage, patch, or scale; redirect 30-50% of ops time from maintenance to innovation
- **60-80% cost reduction**: Pay-per-execution billing eliminates idle capacity waste; no wasted spend during off-peak hours
- **Instant scalability**: Handle traffic spikes from 10 to 10,000 requests automatically without capacity planning or performance degradation
- **Enterprise security built-in**: Managed identity, Key Vault, and API gateway provide compliance-ready security without custom implementations

**For Development Teams:**
- **Deploy APIs in hours, not weeks**: Infrastructure-as-code templates eliminate provisioning delays; go from concept to production in a single day
- **Focus on business logic**: Write HTTP request handlers in familiar languages (Node.js, Python, .NET, Java); Azure handles scaling, monitoring, and high availability
- **Comprehensive observability**: Application Insights provides end-to-end tracing, performance monitoring, and intelligent diagnostics out-of-the-box

## Prerequisites

Before deploying this pattern, ensure you have:

- **Azure subscription** with Contributor or Owner role on target resource group
- **Azure CLI** installed (version 2.50.0 or later) and authenticated (`az login`)
- **Resource group** created or permissions to create resource groups
- **Basic understanding** of REST APIs, HTTP triggers, and NoSQL databases
- **[Optional]** Function app code ready for deployment (Node.js, Python, .NET, or Java)

## Deployment

### Recommended: Azure CLI (15-20 minutes)

**Step 1: Prepare Environment**
```bash
# Authenticate to Azure
az login

# Set variables (customize as needed)
RESOURCE_GROUP="rg-serverless-api-demo"
LOCATION="eastus"
PREFIX="demo"

# Create resource group
az group create \
  --name $RESOURCE_GROUP \
  --location $LOCATION \
  --tags environment=demo owner=$USER ttlHours=24
```

**Step 2: Deploy Infrastructure**
```bash
# Deploy Bicep template (takes 15-20 minutes; API Management is slowest to provision)
az deployment group create \
  --resource-group $RESOURCE_GROUP \
  --template-file main.bicep \
  --parameters @parameters/dev.parameters.json \
  --parameters prefix=$PREFIX location=$LOCATION

# Capture outputs for later use
FUNCTION_URL=$(az deployment group show \
  --resource-group $RESOURCE_GROUP \
  --name main \
  --query properties.outputs.functionAppUrl.value -o tsv)

FUNCTION_NAME=$(az deployment group show \
  --resource-group $RESOURCE_GROUP \
  --name main \
  --query properties.outputs.functionAppName.value -o tsv)
```

**Step 3: Verify Deployment**
```bash
# Check Functions App status (should show "Running")
az functionapp show \
  --resource-group $RESOURCE_GROUP \
  --name $FUNCTION_NAME \
  --query state -o tsv

# Test default health endpoint
curl $FUNCTION_URL/api/health
# Expected: {"status":"healthy","timestamp":"..."}
```

**Step 4: [Optional] Deploy Function Code**

If you have custom Function code (Node.js, Python, .NET, Java):

```bash
# Example: Deploy Node.js function from zip file
cd your-function-code/
zip -r ../api.zip .
cd ..

az functionapp deployment source config-zip \
  --resource-group $RESOURCE_GROUP \
  --name $FUNCTION_NAME \
  --src api.zip

# Wait 30 seconds for deployment to propagate
sleep 30

# Test your API endpoint
curl $FUNCTION_URL/api/your-endpoint
```

### Alternative: Azure Portal (One-Click Deploy)

1. Click the **Deploy to Azure** button below
2. Fill in required parameters: `prefix`, `location`, `functionRuntime`
3. Review tags (ensure `ttlHours` is set for demo environments)
4. Click **Review + Create**, then **Create**

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FYOUR-ORG%2FAzure-Infra-Demos%2Fmain%2Fpatterns%2Fserverless-api%2Fazuredeploy.json)

**Post-deployment**: Deploy your Function app code via Azure Portal → Functions App → Deployment Center, or use GitHub Actions / Azure DevOps CI/CD pipelines.

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

### Demo Environment (Low Traffic: <100k requests/day)
**Daily costs:**
- Azure Functions: $0.40 (50k executions, 400ms avg)
- API Management: $0.30 (25k calls)
- Cosmos DB: $1.80 (serverless, 5,000 RUs consumed)
- Key Vault: $0.01 (minimal operations)
- Storage Account: $0.10
- Application Insights: $0.60 (0.5 GB telemetry)
- **Total: ~$3.20/day (~$95/month)**

### Production Environment (Moderate Traffic: 1-5M requests/day)
**Monthly costs (30-day estimate, East US):**
- **Azure Functions**: $16 (10M executions, 400ms avg, 512 MB memory) — First 1M free, then $0.20/M + $0.000016/GB-second
- **API Management**: $14 (5M calls) — First 1M free, then $3.50/M calls
- **Cosmos DB**: $35 (500 RU/s average consumption, 10 GB storage) — Serverless: $0.25/M RUs + $0.25/GB/month
- **Key Vault**: $0.15 (50k operations) — $0.03/10k operations
- **Storage Account**: $2 (5 GB blob, 100k operations)
- **Application Insights**: $18 (8 GB telemetry ingestion) — First 5 GB free, then $2.30/GB
- **Log Analytics**: $6 (3 GB logs) — $2/GB after free tier
- **Total: ~$91/month (moderate traffic)**

**High-traffic scenarios** (10-50M requests/day): $200-450/month

### Cost Optimization Strategies
1. **Enable API Management caching**: Cache GET responses for 60-300 seconds; reduce Functions executions by 40-60%
2. **Right-size Functions memory**: Test with 512 MB instead of default 1.5 GB; reduce costs by 50%+ if workload permits
3. **Optimize Cosmos DB queries**: Use partition keys correctly; reduce RU consumption by 30-50%
4. **Reduce Application Insights sampling**: For non-prod environments, enable adaptive sampling (5-10% of requests); cut telemetry costs by 80%
5. **Configure Log Analytics retention**: Reduce from 90 to 30 days for non-compliance workloads; save 66% on log storage
6. **Batch Cosmos DB operations**: Use bulk APIs for multi-document inserts; reduce RU costs by 30-50%

**Compare to VM-based API**: Always-on VMs cost $150-500/month for equivalent availability. Serverless saves 60-80% for variable workloads.

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

## Post-Deployment Configuration

### Configure API Management (5 minutes)

Import Functions API into API Management to expose a stable public endpoint:

1. **Azure Portal** → API Management → APIs → **Add API** → **Function App**
2. Select your Functions App (`func-demo-xyz123`)
3. Import all operations or select specific HTTP triggers
4. Configure **Caching Policy** (for GET endpoints):
   - Duration: 60-300 seconds
   - Vary by query parameters: Yes
5. Test API through **Test Console** in API Management portal

### Deploy Sample Function Code (Optional)

If you don't have existing Function code, deploy a sample API:

```bash
# Clone sample Functions repository
git clone https://github.com/Azure-Samples/functions-quickstart-nodejs.git
cd functions-quickstart-nodejs

# Deploy to your Functions App
func azure functionapp publish $FUNCTION_NAME

# Test deployed function
curl https://$FUNCTION_NAME.azurewebsites.net/api/HttpExample?name=Azure
# Expected: "Hello, Azure!"
```

### Configure Monitoring Alerts (Recommended)

Set up proactive alerts for production APIs:

```bash
# Create alert for high error rate (>5% failures)
az monitor metrics alert create \
  --name "API Error Rate Alert" \
  --resource-group $RESOURCE_GROUP \
  --scopes $(az functionapp show -g $RESOURCE_GROUP -n $FUNCTION_NAME --query id -o tsv) \
  --condition "avg Http5xx > 5" \
  --window-size 5m \
  --evaluation-frequency 1m \
  --action email your-email@example.com

# Create alert for high latency (>2 seconds average)
az monitor metrics alert create \
  --name "API Latency Alert" \
  --resource-group $RESOURCE_GROUP \
  --scopes $(az functionapp show -g $RESOURCE_GROUP -n $FUNCTION_NAME --query id -o tsv) \
  --condition "avg AverageResponseTime > 2000" \
  --window-size 5m \
  --evaluation-frequency 1m \
  --action email your-email@example.com
```

## Monitoring & Operations

### Real-Time Monitoring
- **Application Insights → Live Metrics**: View requests, latencies, and failures in real-time as they occur
- **Functions App → Monitor**: See execution logs, invocation counts, and success/failure rates per function
- **Cosmos DB → Metrics**: Monitor RU consumption, latency, availability, and throttling events
- **API Management → Analytics**: Analyze API call statistics, performance, and geographic distribution

### Troubleshooting Common Issues

**Issue**: Functions return 500 errors
- **Solution**: Check Application Insights → Failures → Select failed request → View exception details and stack trace

**Issue**: Slow API response times (>2 seconds)
- **Solution**: Application Insights → Performance → Identify slow operations → Drill into dependency calls to find bottleneck (usually Cosmos DB queries)

**Issue**: Cosmos DB throttling (429 errors)
- **Solution**: Optimize queries to use partition keys; add composite indexes; scale RU/s if query optimization insufficient

**Issue**: Functions cold start latency
- **Solution**: For latency-sensitive APIs, upgrade to Premium plan with pre-warmed instances; alternatively, implement keep-alive pings

### Log Queries (Kusto/KQL)

**Find failed API requests in last 24 hours:**
```kusto
requests
| where timestamp > ago(24h)
| where success == false
| summarize count() by name, resultCode
| order by count_ desc
```

**Analyze API latency percentiles:**
```kusto
requests
| where timestamp > ago(1h)
| summarize 
    p50=percentile(duration, 50),
    p95=percentile(duration, 95),
    p99=percentile(duration, 99)
    by name
```

**Track Cosmos DB RU consumption:**
```kusto
dependencies
| where type == "Azure DocumentDB"
| extend ru = toreal(customDimensions["Request Charge"])
| summarize totalRUs=sum(ru), avgRU=avg(ru) by bin(timestamp, 5m)
```

## Cleanup

### Immediate Teardown (Demo Environments)

To remove all deployed resources and stop billing:

```bash
# Delete entire resource group (irreversible; use with caution)
az group delete --name $RESOURCE_GROUP --yes --no-wait

# Verify deletion initiated
az group list --query "[?name=='$RESOURCE_GROUP']" -o table
# Should return empty after a few minutes
```

**Cost impact**: Billing stops within 5 minutes for all services.

### Selective Cleanup (Preserve Data/Logs)

To reduce costs while preserving Cosmos DB data and Application Insights logs:

```bash
# Delete Functions App (stops compute costs)
az functionapp delete --resource-group $RESOURCE_GROUP --name $FUNCTION_NAME

# Delete API Management (stops gateway costs)
az apim delete --resource-group $RESOURCE_GROUP --name apim-demo-xyz123

# Cosmos DB and Application Insights remain for analysis
# Reduces daily spend by ~60-70%
```

### Automated Cleanup (Best Practice for Demos)

Resources are tagged with `ttlHours: 24` by default. To automate cleanup:

1. **Azure Automation**: Create runbook to find and delete resource groups with expired `ttlHours` tags
2. **Schedule**: Run daily at off-peak hours (e.g., 2 AM)
3. **Logic**: Calculate resource age from `deployedAt` tag; delete if `currentTime - deployedAt > ttlHours`

See `talk-track.md` Section 15 for detailed teardown procedures and cost control strategies.

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
