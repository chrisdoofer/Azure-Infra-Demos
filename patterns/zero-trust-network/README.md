# Zero Trust Network Access

## Overview

Implement a zero trust network architecture with layered security controls including Application Gateway with WAF, Azure Firewall, Network Security Groups, and Private Link. This pattern enforces least-privilege access and defense-in-depth principles.

**Category**: reference-architecture  
**Services**: Application Gateway, WAF, Azure Firewall, NSG, Private Link, Virtual Network  
**Complexity**: Advanced  
**Estimated Monthly Cost**: $400-$1,200 (varies by tier and traffic)

## Architecture

This pattern implements zero trust networking with:

- **Application Gateway v2 with WAF**: Web application firewall for OWASP Top 10 protection
- **Azure Firewall** (optional): Network and application layer filtering
- **Network Security Groups**: Subnet-level traffic filtering
- **Private Endpoints**: Eliminate public exposure of PaaS services
- **Virtual Network**: Micro-segmentation with dedicated subnets

See `architecture.mmd` for the detailed architecture diagram.

## Prerequisites

Before deploying this pattern, ensure you have:

- Azure subscription with appropriate permissions
- Azure CLI installed and authenticated (`az login`)
- Resource group created or permissions to create one
- Understanding of networking and security concepts
- Budget for Application Gateway WAF_v2 SKU

## Deployment

### Option 1: Azure CLI

```bash
# Set variables
RESOURCE_GROUP="rg-zero-trust-demo"
LOCATION="eastus"
PREFIX="demo"

# Create resource group (if needed)
az group create --name $RESOURCE_GROUP --location $LOCATION

# Deploy the template (takes 10-15 minutes)
az deployment group create \
  --resource-group $RESOURCE_GROUP \
  --template-file main.bicep \
  --parameters @parameters/dev.parameters.json \
  --parameters prefix=$PREFIX location=$LOCATION
```

### Option 2: Azure Portal

1. Click the **Deploy to Azure** button below
2. Fill in the required parameters
3. Review and create (deployment takes 10-15 minutes)

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FYOUR-ORG%2FAzure-Infra-Demos%2Fmain%2Fpatterns%2Fzero-trust-network%2Fazuredeploy.json)

## Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `location` | string | (resource group location) | Azure region for deployment |
| `prefix` | string | `demo` | Prefix for resource naming |
| `vnetAddressPrefix` | string | `10.0.0.0/16` | Virtual Network address space |
| `appGwSubnetPrefix` | string | `10.0.1.0/24` | Application Gateway subnet |
| `firewallSubnetPrefix` | string | `10.0.2.0/24` | Azure Firewall subnet |
| `privateEndpointSubnetPrefix` | string | `10.0.3.0/24` | Private Endpoint subnet |
| `applicationSubnetPrefix` | string | `10.0.4.0/24` | Application subnet |
| `deployFirewall` | bool | `false` | Deploy Azure Firewall (additional cost) |
| `tags` | object | (see template) | Resource tags |

## Cost Estimation

Estimated monthly costs (East US region):

**Without Azure Firewall**:
- **Application Gateway WAF_v2**: ~$300/month (2 capacity units)
- **Virtual Network**: Free
- **NSGs**: Free
- **Public IP (Standard)**: ~$4/month
- **Total**: ~$304/month

**With Azure Firewall**:
- **Azure Firewall (Standard)**: ~$890/month
- **Firewall Public IP**: ~$4/month
- **Total**: ~$1,198/month

**Cost Optimization Tips**:
- Use autoscaling on Application Gateway to match demand
- Consider Firewall Basic tier for dev/test scenarios
- Disable Azure Firewall if not needed (set deployFirewall=false)

## Security Layers

This pattern implements defense-in-depth with multiple security layers:

1. **Edge Security**: Application Gateway with WAF (OWASP 3.2)
2. **Network Security**: NSGs on all subnets with deny-by-default rules
3. **Perimeter Security**: Azure Firewall for egress filtering (optional)
4. **Service Security**: Private endpoints eliminate public exposure
5. **Monitoring**: All traffic logged to Log Analytics

## Post-Deployment Steps

1. **Configure Backend Pools**: Add your application backends to App Gateway

2. **Test WAF**: Verify WAF is blocking malicious requests
   ```bash
   curl "http://<APP_GW_IP>/?id=<script>alert('XSS')</script>"
   ```

3. **Configure SSL/TLS**: Upload certificates for HTTPS listeners

4. **Set Up Private Endpoints**: Connect PaaS services via Private Link

5. **Review NSG Logs**: Enable NSG flow logs for traffic analysis

## Zero Trust Principles

This pattern enforces:

- ✅ **Verify Explicitly**: WAF validates all requests
- ✅ **Least Privilege Access**: NSGs deny all except explicitly allowed
- ✅ **Assume Breach**: Segmentation limits lateral movement
- ✅ **Continuous Monitoring**: Centralized logging and alerting

## Monitoring & Operations

After deployment, monitor your security posture using:

- **Application Gateway Metrics**: Request count, failed requests, WAF blocks
- **NSG Flow Logs**: Network traffic analysis
- **Azure Firewall Logs**: Application and network rule hits
- **Log Analytics**: Centralized security event correlation

## Cleanup

To remove all deployed resources:

```bash
az group delete --name $RESOURCE_GROUP --yes --no-wait
```

## Related Patterns

- Hub-Spoke Network Topology
- Web App with Private Endpoint
- Landing Zone Foundation

## Additional Resources

- [Zero Trust Security](https://learn.microsoft.com/security/zero-trust/)
- [Application Gateway WAF](https://learn.microsoft.com/azure/web-application-firewall/ag/ag-overview)
- [Azure Firewall Documentation](https://learn.microsoft.com/azure/firewall/)
- [Private Link Overview](https://learn.microsoft.com/azure/private-link/)

## Support

For issues or questions:
- Open an issue in this repository
- Review the talk track (`talk-track.md`) for presentation guidance
