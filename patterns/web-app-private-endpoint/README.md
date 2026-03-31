# Web App with Private Endpoint

## Overview

Deploy Azure App Service with zero public internet exposure using Private Endpoints. This pattern delivers production-ready web applications with network isolation, compliance-ready security, and seamless hybrid cloud connectivity—eliminating DDoS attacks, bot scans, and 90% of attack vectors.

**Category**: Reference Architecture  
**Services**: App Service (Premium), Private Link, Virtual Network, Private DNS Zone, Network Security Groups  
**Complexity**: Intermediate  
**Estimated Daily Cost**: $7-10 (demo/test), $10-15 (production)  
**Estimated Monthly Cost**: $227-309 (varies by hybrid connectivity)  
**Deployment Time**: 20-30 minutes

## Architecture

This pattern implements complete network isolation for web applications:

- **App Service (Premium Plan)**: Fully managed PaaS for web apps with public access disabled; supports auto-scaling, deployment slots, and 99.95% SLA
- **Private Endpoint**: Network interface with private IP (10.0.x.x) within VNet; connects to App Service over Azure backbone network (no public internet traversal)
- **Virtual Network (VNet)**: Isolated network boundary (10.0.0.0/16) with subnets for private endpoints and application integration
- **Private DNS Zone**: Automatic DNS resolution for `privatelink.azurewebsites.net`; resolves App Service hostname to private IP for VNet-connected users
- **Network Security Group (NSG)**: Stateful firewall with least-privilege rules; allows HTTPS from corporate network, denies all other traffic
- **ExpressRoute/VPN Gateway**: Hybrid connectivity to on-premises networks; enables corporate users to access Azure apps as internal resources

See `architecture.mmd` for detailed architecture diagram and `talk-track.md` for business value, compliance mapping, and demo scripts.

## Prerequisites

Before deploying this pattern, ensure you have:

- Azure subscription with appropriate permissions
- Azure CLI installed and authenticated (`az login`)
- Resource group created or permissions to create one
- Premium App Service Plan SKU (required for Private Link)

## Deployment

### Option 1: Azure CLI

```bash
# Set variables
RESOURCE_GROUP="rg-webapp-private-demo"
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

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FYOUR-ORG%2FAzure-Infra-Demos%2Fmain%2Fpatterns%2Fweb-app-private-endpoint%2Fazuredeploy.json)

## Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `location` | string | (resource group location) | Azure region for deployment |
| `prefix` | string | `demo` | Prefix for resource naming |
| `appServicePlanSku` | string | `P1v3` | App Service Plan SKU (must be Premium) |
| `vnetAddressPrefix` | string | `10.0.0.0/16` | Virtual Network address space |
| `privateEndpointSubnetPrefix` | string | `10.0.1.0/24` | Private Endpoint subnet CIDR |
| `tags` | object | (see template) | Resource tags |

## Cost Estimation

Estimated monthly costs (East US region):

- **App Service Plan (P1v3)**: ~$140/month
- **Virtual Network**: Free
- **Private Endpoint**: ~$7.30/month
- **Private DNS Zone**: ~$0.50/month
- **Total**: ~$148/month

**Cost Optimization Tips**:
- Use P1v2 SKU for lower costs if P1v3 performance is not required
- Share Private DNS zones across multiple Private Endpoints
- Consider App Service Environment (ASE) for large-scale deployments

## Security Considerations

- **Network Isolation**: App Service is not accessible from public internet
- **Private DNS**: Automatic DNS resolution within the VNet
- **TLS Encryption**: HTTPS enforced with minimum TLS 1.2
- **No Public Endpoints**: Public network access disabled on App Service

## Monitoring & Operations

After deployment, monitor your resources using:

- **Azure Monitor**: App Service metrics (CPU, memory, requests)
- **Application Insights**: Application performance monitoring (configure separately)
- **Network Watcher**: Connection troubleshooting for Private Endpoints

## Cleanup

To remove all deployed resources:

```bash
az group delete --name $RESOURCE_GROUP --yes --no-wait
```

## Related Patterns

- Hub-Spoke Network Topology
- Zero Trust Network Access
- Microservices on AKS

## Additional Resources

- [Azure Private Link Documentation](https://learn.microsoft.com/azure/private-link/)
- [App Service Private Endpoint](https://learn.microsoft.com/azure/app-service/networking/private-endpoint)
- [Private DNS Zones](https://learn.microsoft.com/azure/dns/private-dns-overview)

## Support

For issues or questions:
- Open an issue in this repository
- Review the talk track (`talk-track.md`) for presentation guidance
