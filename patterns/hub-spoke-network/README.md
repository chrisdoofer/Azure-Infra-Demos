# Hub-Spoke Network Topology

A production-ready hub-spoke network architecture in Azure with centralized security and connectivity.

## What This Pattern Deploys

This template deploys a complete hub-spoke network topology with the following resources:

### Core Network Resources
- **Hub Virtual Network** (10.0.0.0/16 by default)
  - AzureFirewallSubnet (/26)
  - GatewaySubnet (/27)
  - ManagementSubnet (/24)
- **Spoke 1 Virtual Network** (10.1.0.0/16 by default)
  - Default subnet (/24)
- **Spoke 2 Virtual Network** (10.2.0.0/16 by default)
  - Default subnet (/24)
- **VNet Peering** - Bidirectional peering between hub and each spoke

### Security Resources
- **Network Security Groups (NSGs)** - Applied to all subnets
  - Allow VNet-to-VNet traffic
  - Deny all other inbound traffic by default
- **Azure Firewall** (optional, enabled by default)
  - Standard tier
  - Public IP
  - Network rules for spoke-to-spoke communication
- **Route Tables** (when firewall is deployed)
  - Force all spoke traffic through firewall

### Connectivity Resources
- **VPN Gateway** (optional, disabled by default)
  - VpnGw1 SKU
  - Public IP
  - For site-to-site or point-to-site VPN connectivity

### Architecture Diagram
```
                    ┌─────────────────────┐
                    │   Hub VNet          │
                    │  (10.0.0.0/16)      │
                    │                     │
                    │  ┌──────────────┐   │
                    │  │ Azure FW     │   │
                    │  │ (Optional)   │   │
                    │  └──────────────┘   │
                    │                     │
                    │  ┌──────────────┐   │
                    │  │ VPN Gateway  │   │
                    │  │ (Optional)   │   │
                    │  └──────────────┘   │
                    └──────┬──────┬───────┘
                           │      │
              ┌────────────┘      └──────────┐
              │                              │
    ┌─────────▼────────┐          ┌─────────▼────────┐
    │  Spoke 1 VNet    │          │  Spoke 2 VNet    │
    │  (10.1.0.0/16)   │          │  (10.2.0.0/16)   │
    │                  │          │                  │
    │  Workload        │          │  Workload        │
    │  Resources       │          │  Resources       │
    └──────────────────┘          └──────────────────┘
```

## Prerequisites

- Azure subscription with Contributor or Owner role
- Azure CLI installed (for CLI deployment)
- Sufficient quota for VNet and Firewall resources

## Deploy via Azure Portal

Click the button below to deploy directly from the Azure Portal:

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2F[YOUR-GITHUB-USERNAME].github.io%2FAzure-Infra-Demos%2Fpatterns%2Fhub-spoke-network%2Fazuredeploy.json)

**Important:** Replace `[YOUR-GITHUB-USERNAME]` in the button URL with your actual GitHub username or organization name.

**Template Hosting Options:**

This repository supports two ways to host ARM templates for Deploy to Azure buttons:

1. **GitHub Pages (Works for Private Repos)** — Recommended
   - Templates served via `https://[your-username].github.io/Azure-Infra-Demos/patterns/{slug}/azuredeploy.json`
   - Works for private repositories on GitHub Enterprise, Pro, or Team plans
   - Requires enabling GitHub Pages (Settings → Pages → GitHub Actions source)
   - The `publish-templates.yml` workflow automatically deploys templates to Pages on push

2. **Raw GitHub URLs (Requires Public Repo)**
   - Templates served via `https://raw.githubusercontent.com/[owner]/Azure-Infra-Demos/main/patterns/{slug}/azuredeploy.json`
   - Only works if the repository is **public** (private repos return 404)
   - No additional setup required

**Setup Steps:**
1. Fork this repository
2. Update `portal/config/site.ts` with your GitHub username
3. Enable GitHub Pages: Settings → Pages → Source: GitHub Actions
4. Push to main/master — the workflow will deploy templates automatically
5. Update the Deploy to Azure button URL in this README with your username

**Portal Deployment Steps:**
1. Click the "Deploy to Azure" button above
2. Sign in to your Azure account
3. Fill in the deployment form:
   - **Basics**: Choose subscription, create/select resource group, set prefix
   - **Network Configuration**: Configure address spaces (or use defaults)
   - **Security Options**: Choose whether to deploy Firewall and/or VPN Gateway
   - **Tags**: Set owner, workload, environment, and TTL for cost control
4. Review and click "Create"
5. Deployment takes approximately 15-20 minutes (Firewall deployment is the longest operation)

## Deploy via GitHub Actions

Use the repository's GitHub Actions workflow for automated deployment:

1. Navigate to **Actions** → **Deploy Pattern to Azure**
2. Click **Run workflow**
3. Provide the following inputs:
   - **subscriptionId**: Your Azure subscription ID
   - **location**: Azure region (default: `australiaeast`)
   - **prefix**: Resource name prefix (default: `demo`)
   - **patternSlug**: `hub-spoke-network`
   - **resourceGroupName**: (optional) Leave empty for auto-generated name
   - **extraParamsJson**: (optional) Additional parameters as JSON

**Example JSON for extraParamsJson:**
```json
{
  "deployFirewall": true,
  "deployVpnGateway": false,
  "hubAddressPrefix": "10.10.0.0/16"
}
```

**Prerequisites for GitHub Actions:**
- Repository secrets configured for OIDC authentication:
  - `AZURE_CLIENT_ID`
  - `AZURE_TENANT_ID`
  - `AZURE_SUBSCRIPTION_ID`

## Deploy via Azure CLI

Deploy using the Azure CLI with a single command:

```bash
# Set variables
PREFIX="demo"
LOCATION="australiaeast"
RG_NAME="rg-$PREFIX-hub-spoke-network"

# Create resource group
az group create \
  --name $RG_NAME \
  --location $LOCATION

# Deploy the template
az deployment group create \
  --name "hub-spoke-$(date +%Y%m%d-%H%M%S)" \
  --resource-group $RG_NAME \
  --template-file patterns/hub-spoke-network/main.bicep \
  --parameters \
    location=$LOCATION \
    prefix=$PREFIX \
    deployFirewall=true \
    deployVpnGateway=false
```

**Deploy with parameter file:**
```bash
az deployment group create \
  --name "hub-spoke-$(date +%Y%m%d-%H%M%S)" \
  --resource-group $RG_NAME \
  --template-file patterns/hub-spoke-network/main.bicep \
  --parameters @patterns/hub-spoke-network/parameters/dev.parameters.json
```

## Parameters Reference

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `location` | string | Resource group location | Azure region for all resources |
| `prefix` | string | `demo` | Prefix for all resource names |
| `tags` | object | See below | Tags applied to all resources |
| `deployFirewall` | bool | `true` | Deploy Azure Firewall in the hub |
| `deployVpnGateway` | bool | `false` | Deploy VPN Gateway in the hub |
| `hubAddressPrefix` | string | `10.0.0.0/16` | Hub VNet address space |
| `spoke1AddressPrefix` | string | `10.1.0.0/16` | Spoke 1 VNet address space |
| `spoke2AddressPrefix` | string | `10.2.0.0/16` | Spoke 2 VNet address space |

**Default Tags:**
```json
{
  "owner": "demo-user",
  "workload": "hub-spoke-network",
  "environment": "dev",
  "ttlHours": "24"
}
```

## Outputs

The template provides the following outputs:

| Output | Description |
|--------|-------------|
| `hubVnetId` | Resource ID of the hub virtual network |
| `spoke1VnetId` | Resource ID of spoke 1 virtual network |
| `spoke2VnetId` | Resource ID of spoke 2 virtual network |
| `firewallPrivateIp` | Private IP address of the Azure Firewall (if deployed) |
| `firewallPublicIp` | Public IP address of the Azure Firewall (if deployed) |
| `vpnGatewayId` | Resource ID of the VPN Gateway (if deployed) |

## Cost Drivers and Estimates

**Hourly Costs (approximate):**
- **Azure Firewall Standard**: ~$1.25/hour (~$30/day)
- **VPN Gateway VpnGw1**: ~$0.19/hour (~$4.50/day)
- **Virtual Networks**: No charge (data transfer may apply)
- **NSGs and Route Tables**: No charge
- **Public IP addresses**: ~$0.005/hour (~$0.12/day) per IP

**Total Estimated Daily Cost:**
- **With Firewall only**: ~$30/day
- **With Firewall + VPN Gateway**: ~$35/day
- **Without Firewall or VPN**: ~$0 (VNets and peering are free, minimal charges for PIPs if any)

**Cost Optimization Tips:**
- Set the `ttlHours` tag to enable automatic cleanup after testing
- Use `deployFirewall: false` for development/testing if firewall is not required
- Use `deployVpnGateway: false` unless you need hybrid connectivity
- Delete the resource group immediately after testing to minimize costs

**Pricing Calculator:**
- [Azure Firewall Pricing](https://azure.microsoft.com/pricing/details/azure-firewall/)
- [VPN Gateway Pricing](https://azure.microsoft.com/pricing/details/vpn-gateway/)

## Teardown Instructions

### Option 1: Delete via Azure Portal
1. Navigate to **Resource Groups** in the Azure Portal
2. Find your resource group (e.g., `rg-demo-hub-spoke-network`)
3. Click **Delete resource group**
4. Type the resource group name to confirm
5. Click **Delete**

### Option 2: Delete via Azure CLI
```bash
# Delete the entire resource group
az group delete \
  --name rg-demo-hub-spoke-network \
  --yes \
  --no-wait
```

### Option 3: Delete via GitHub Actions
1. Navigate to **Actions** → **Destroy Azure Resources**
2. Click **Run workflow**
3. Provide:
   - **subscriptionId**: Your Azure subscription ID
   - **patternSlug**: `hub-spoke-network`
   - **resourceGroupName**: Your resource group name
   - **deleteResourceGroup**: `true`
4. Click **Run workflow**

**Note:** Firewall and VPN Gateway deletion can take 5-10 minutes. The deletion runs asynchronously.

## Use Cases

This pattern is ideal for:

- **Enterprise Hub-Spoke Topology**: Central hub for shared services (firewall, VPN, DNS) with isolated workload spokes
- **Multi-Application Segmentation**: Each spoke can host a different application with network isolation
- **Hybrid Cloud Connectivity**: VPN Gateway in the hub enables on-premises connectivity for all spokes
- **Centralized Security**: All traffic flows through the hub firewall for inspection and policy enforcement

## Next Steps

After deployment:

1. **Deploy workloads to spokes**: Add VMs, App Services, or other resources to spoke subnets
2. **Configure firewall rules**: Add application and network rules to the Azure Firewall
3. **Set up monitoring**: Enable Network Watcher and Azure Monitor for network diagnostics
4. **Add more spokes**: Create additional spoke VNets and peer them to the hub
5. **Configure VPN**: If VPN Gateway is deployed, configure site-to-site or point-to-site connections

## Related Patterns

- Hub-Spoke with Azure Virtual WAN (for large-scale deployments)
- Multi-Region Hub-Spoke
- Hub-Spoke with Private Endpoints

## Support

For issues or questions:
- Open an issue in the [GitHub repository](https://github.com/{owner}/Azure-Infra-Demos/issues)
- Refer to [Azure Networking documentation](https://docs.microsoft.com/azure/virtual-network/)
