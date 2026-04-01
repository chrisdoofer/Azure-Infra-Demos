# Azure Arc Box

A sandbox environment for demonstrating Azure Arc capabilities with Arc-enabled Servers and Arc-enabled SQL Server.

## What This Pattern Deploys

Azure Arc Box deploys a complete sandbox environment with VMs and supporting infrastructure to demonstrate Azure Arc capabilities. This deployment creates the infrastructure; you'll manually onboard VMs to Azure Arc as part of the learning experience.

### Core Infrastructure
- **Virtual Network** (10.0.0.0/16 by default)
  - Single subnet for all VMs (10.0.1.0/24)
- **Network Security Group**
  - RDP (3389) access for Windows VMs
  - SSH (22) access for Linux VMs
  - HTTPS (443) for Arc agent connectivity
  - ⚠️ **Warning:** Open to internet for demo purposes - restrict in production

### Virtual Machines (Candidates for Arc Onboarding)
- **Windows Server VM** (Standard_B2ms)
  - Windows Server 2022 Datacenter
  - Public IP with DNS name
  - Ready to onboard as Arc-enabled Server
  
- **Linux VM** (Standard_B2ms, optional)
  - Ubuntu 22.04 LTS
  - Public IP with DNS name
  - Ready to onboard as Arc-enabled Server
  
- **SQL Server VM** (Standard_B2ms, optional)
  - Windows Server 2022 + SQL Server 2022 Developer Edition
  - 128 GB Premium data disk
  - Public IP with DNS name
  - Ready to onboard as Arc-enabled SQL Server

### Monitoring & Management
- **Log Analytics Workspace**
  - For Arc monitoring and insights
  - 30-day retention
  - PerGB2018 pricing tier

### Architecture Diagram
```
                    ┌─────────────────────────────────────┐
                    │   Azure Arc Control Plane           │
                    │   (After Manual Onboarding)         │
                    │                                     │
                    │   • Arc-enabled Servers             │
                    │   • Arc-enabled SQL                 │
                    │   • Azure Policy & Governance       │
                    │   • Update Management               │
                    └──────────────┬──────────────────────┘
                                   │ HTTPS 443
                                   │ (Outbound from VMs)
                    ┌──────────────┴──────────────────────┐
                    │   Azure Subscription                │
                    │   ┌─────────────────────────────┐   │
                    │   │  Virtual Network            │   │
                    │   │  (10.0.0.0/16)              │   │
                    │   │                             │   │
                    │   │  ┌────────────────────────┐ │   │
                    │   │  │  Windows Server VM     │ │   │
                    │   │  │  (Public IP + RDP)     │ │   │
                    │   │  │  Win Server 2022       │ │   │
                    │   │  └────────────────────────┘ │   │
                    │   │                             │   │
                    │   │  ┌────────────────────────┐ │   │
                    │   │  │  Linux VM (Optional)   │ │   │
                    │   │  │  (Public IP + SSH)     │ │   │
                    │   │  │  Ubuntu 22.04 LTS      │ │   │
                    │   │  └────────────────────────┘ │   │
                    │   │                             │   │
                    │   │  ┌────────────────────────┐ │   │
                    │   │  │  SQL Server VM (Opt.)  │ │   │
                    │   │  │  (Public IP + RDP)     │ │   │
                    │   │  │  SQL Server 2022 Dev   │ │   │
                    │   │  └────────────────────────┘ │   │
                    │   └─────────────────────────────┘   │
                    │                                     │
                    │   ┌─────────────────────────────┐   │
                    │   │  Log Analytics Workspace    │   │
                    │   │  (Arc Monitoring)           │   │
                    │   └─────────────────────────────┘   │
                    └─────────────────────────────────────┘

    Admin Access via RDP/SSH → Public IPs
```

## Prerequisites

- Azure subscription with **Contributor** role or higher
- Azure CLI installed (for CLI deployment)
- Sufficient quota for:
  - 2-3 VMs (Standard_B2ms or larger)
  - 3 Public IP addresses
  - Virtual Network resources
- For Arc onboarding (post-deployment):
  - Service Principal with appropriate permissions, OR
  - User account with **Azure Connected Machine Onboarding** role

## Deploy via Azure Portal

Click the button below to deploy directly from the Azure Portal:

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2F[YOUR-GITHUB-USERNAME].github.io%2FAzure-Infra-Demos%2Fpatterns%2Fazure-arc-box%2Fazuredeploy.json)

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
   - **VM Configuration**: Set admin username and secure password
   - **Optional Components**: Choose whether to deploy Linux VM and/or SQL VM
   - **Tags**: Set owner, workload, environment, and TTL for cost control
4. Review and click "Create"
5. Deployment takes approximately 10-15 minutes

## Deploy via GitHub Actions

Use the repository's GitHub Actions workflow for automated deployment:

1. Navigate to **Actions** → **Deploy Pattern to Azure**
2. Click **Run workflow**
3. Provide the following inputs:
   - **subscriptionId**: Your Azure subscription ID
   - **location**: Azure region (default: `australiaeast`)
   - **prefix**: Resource name prefix (default: `arcbox`)
   - **patternSlug**: `azure-arc-box`
   - **resourceGroupName**: (optional) Leave empty for auto-generated name
   - **extraParamsJson**: (optional) Additional parameters as JSON

**Example JSON for extraParamsJson:**
```json
{
  "adminPassword": "YourSecurePassword123!",
  "deployLinuxVM": true,
  "deploySqlVM": true,
  "vmSize": "Standard_B2ms"
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
PREFIX="arcbox"
LOCATION="australiaeast"
RG_NAME="rg-$PREFIX-demo"
ADMIN_PASSWORD="YourSecurePassword123!"

# Create resource group
az group create \
  --name $RG_NAME \
  --location $LOCATION

# Deploy the template
az deployment group create \
  --name "arcbox-$(date +%Y%m%d-%H%M%S)" \
  --resource-group $RG_NAME \
  --template-file patterns/azure-arc-box/main.bicep \
  --parameters \
    location=$LOCATION \
    prefix=$PREFIX \
    adminPassword=$ADMIN_PASSWORD \
    deployLinuxVM=true \
    deploySqlVM=true
```

**Deploy with parameter file:**
```bash
# Edit parameters file to set your password
az deployment group create \
  --name "arcbox-$(date +%Y%m%d-%H%M%S)" \
  --resource-group $RG_NAME \
  --template-file patterns/azure-arc-box/main.bicep \
  --parameters @patterns/azure-arc-box/parameters/dev.parameters.json
```

## Parameters Reference

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `location` | string | Resource group location | Azure region for all resources |
| `prefix` | string | `arcbox` | Prefix for all resource names |
| `tags` | object | See below | Tags applied to all resources |
| `adminUsername` | string | `arcadmin` | Administrator username for all VMs |
| `adminPassword` | securestring | *Required* | Administrator password for all VMs (must meet complexity requirements) |
| `deployLinuxVM` | bool | `true` | Deploy Linux Ubuntu VM for Arc Servers demo |
| `deploySqlVM` | bool | `true` | Deploy SQL Server VM for Arc-enabled SQL demo |
| `vmSize` | string | `Standard_B2ms` | VM size for all VMs (2 vCPU, 8 GB RAM) |
| `vnetAddressPrefix` | string | `10.0.0.0/16` | Virtual network address space |
| `subnetAddressPrefix` | string | `10.0.1.0/24` | Subnet address prefix |

**Default Tags:**
```json
{
  "owner": "demo-user",
  "workload": "azure-arc-box",
  "environment": "dev",
  "ttlHours": "48"
}
```

**Password Requirements:**
- Minimum 12 characters
- Must contain uppercase, lowercase, numbers, and special characters
- Cannot contain username or common words

## Outputs

The template provides the following outputs:

| Output | Description |
|--------|-------------|
| `resourceGroupName` | Name of the resource group |
| `vnetId` | Resource ID of the virtual network |
| `vnetName` | Name of the virtual network |
| `workspaceId` | Resource ID of the Log Analytics workspace |
| `workspaceName` | Name of the Log Analytics workspace |
| `windowsVmName` | Name of the Windows Server VM |
| `windowsVmPublicIp` | Public IP address of the Windows Server VM |
| `windowsVmFqdn` | Fully qualified domain name of the Windows Server VM |
| `linuxVmName` | Name of the Linux VM (or 'not-deployed') |
| `linuxVmPublicIp` | Public IP address of the Linux VM (or 'not-deployed') |
| `linuxVmFqdn` | Fully qualified domain name of the Linux VM (or 'not-deployed') |
| `sqlVmName` | Name of the SQL Server VM (or 'not-deployed') |
| `sqlVmPublicIp` | Public IP address of the SQL Server VM (or 'not-deployed') |
| `sqlVmFqdn` | Fully qualified domain name of the SQL Server VM (or 'not-deployed') |
| `adminUsername` | Administrator username for all VMs |

## Post-Deployment: Onboarding VMs to Azure Arc

After deployment, you'll manually onboard the VMs to Azure Arc. This is the key learning experience!

### Step 1: Create a Service Principal (Recommended Method)

```bash
# Create service principal with Arc onboarding permissions
az ad sp create-for-rbac \
  --name "ArcBoxOnboarding" \
  --role "Azure Connected Machine Onboarding" \
  --scopes /subscriptions/{subscription-id}/resourceGroups/$RG_NAME

# Save the output - you'll need appId, password, and tenant
```

### Step 2: Onboard Windows Server VM

1. **Connect to the Windows VM:**
   ```bash
   # Get the public IP
   WIN_IP=$(az vm show -d -g $RG_NAME -n $PREFIX-win-vm --query publicIps -o tsv)
   
   # RDP to the VM
   mstsc /v:$WIN_IP
   ```

2. **Run the Arc onboarding script on the Windows VM:**
   ```powershell
   # Download and run the Arc agent installer
   $env:SUBSCRIPTION_ID = "{your-subscription-id}"
   $env:RESOURCE_GROUP = "rg-arcbox-demo"
   $env:TENANT_ID = "{your-tenant-id}"
   $env:LOCATION = "australiaeast"
   $env:AUTH_TYPE = "principal"
   $env:CLOUD = "AzureCloud"
   
   # Service Principal credentials
   $env:SERVICE_PRINCIPAL_ID = "{your-service-principal-app-id}"
   $env:SERVICE_PRINCIPAL_SECRET = "{your-service-principal-password}"
   
   # Download the installation package
   Invoke-WebRequest -Uri https://aka.ms/AzureConnectedMachineAgent -OutFile AzureConnectedMachineAgent.msi
   
   # Install the Arc agent
   msiexec /i AzureConnectedMachineAgent.msi /l*v installationlog.txt /qn
   
   # Connect the machine to Azure Arc
   & "$env:ProgramFiles\AzureConnectedMachineAgent\azcmagent.exe" connect `
     --service-principal-id $env:SERVICE_PRINCIPAL_ID `
     --service-principal-secret $env:SERVICE_PRINCIPAL_SECRET `
     --resource-group $env:RESOURCE_GROUP `
     --tenant-id $env:TENANT_ID `
     --location $env:LOCATION `
     --subscription-id $env:SUBSCRIPTION_ID `
     --cloud $env:CLOUD
   
   # Verify connection
   & "$env:ProgramFiles\AzureConnectedMachineAgent\azcmagent.exe" show
   ```

### Step 3: Onboard Linux VM (Optional)

1. **Connect to the Linux VM:**
   ```bash
   # Get the public IP
   LINUX_IP=$(az vm show -d -g $RG_NAME -n $PREFIX-linux-vm --query publicIps -o tsv)
   
   # SSH to the VM
   ssh arcadmin@$LINUX_IP
   ```

2. **Run the Arc onboarding script on the Linux VM:**
   ```bash
   # Set environment variables
   export SUBSCRIPTION_ID="{your-subscription-id}"
   export RESOURCE_GROUP="rg-arcbox-demo"
   export TENANT_ID="{your-tenant-id}"
   export LOCATION="australiaeast"
   export AUTH_TYPE="principal"
   export CLOUD="AzureCloud"
   
   # Service Principal credentials
   export SERVICE_PRINCIPAL_ID="{your-service-principal-app-id}"
   export SERVICE_PRINCIPAL_SECRET="{your-service-principal-password}"
   
   # Download the installation package
   wget https://aka.ms/azcmagent -O ~/install_linux_azcmagent.sh
   
   # Install the Arc agent
   bash ~/install_linux_azcmagent.sh
   
   # Connect the machine to Azure Arc
   sudo azcmagent connect \
     --service-principal-id "${SERVICE_PRINCIPAL_ID}" \
     --service-principal-secret "${SERVICE_PRINCIPAL_SECRET}" \
     --resource-group "${RESOURCE_GROUP}" \
     --tenant-id "${TENANT_ID}" \
     --location "${LOCATION}" \
     --subscription-id "${SUBSCRIPTION_ID}" \
     --cloud "${CLOUD}"
   
   # Verify connection
   sudo azcmagent show
   ```

### Step 4: Onboard SQL Server to Arc-enabled SQL (Optional)

After onboarding the SQL VM as an Arc-enabled Server:

1. **Install the SQL Server extension:**
   ```powershell
   # On the SQL VM, after Arc agent is installed
   # Install SQL Server extension via Azure Portal:
   # 1. Navigate to the Arc-enabled Server in Azure Portal
   # 2. Go to Extensions
   # 3. Add "Windows Admin Center" or "SQL Server Extension - Windows"
   # 4. Follow the wizard to discover SQL instances
   ```

2. **Or use Azure CLI:**
   ```bash
   # Install SQL Server extension on Arc-enabled server
   az connectedmachine extension create \
     --name "WindowsAgent.SqlServer" \
     --machine-name $PREFIX-sql-vm \
     --resource-group $RG_NAME \
     --type "WindowsAgent.SqlServer" \
     --publisher "Microsoft.AzureData" \
     --settings '{"SqlManagement":{"IsEnabled":true}}' \
     --location $LOCATION
   ```

### Step 5: Verify Arc Onboarding

```bash
# List Arc-enabled servers
az connectedmachine list \
  --resource-group $RG_NAME \
  --output table

# View Arc-enabled server details
az connectedmachine show \
  --name $PREFIX-win-vm \
  --resource-group $RG_NAME

# List Arc-enabled SQL servers
az sql server-arc list \
  --resource-group $RG_NAME \
  --output table
```

### Step 6: Explore Arc Capabilities

After onboarding, explore these Azure Arc features:

1. **Azure Policy**: Apply governance policies to Arc-enabled servers
2. **Update Management**: Manage OS updates across hybrid environments
3. **Azure Monitor**: Collect logs and metrics in Log Analytics workspace
4. **VM Extensions**: Deploy agents (Log Analytics, Dependency Agent, etc.)
5. **Microsoft Defender for Cloud**: Enable security posture management
6. **Azure Automation**: Run automation runbooks on Arc-enabled servers
7. **Change Tracking**: Track configuration changes across servers
8. **Inventory**: View installed software, services, and configurations

## Cost Drivers and Estimates

**Hourly Costs (approximate, Australia East region):**
- **Standard_B2ms VM** (2 vCPU, 8 GB RAM): ~$0.096/hour (~$2.30/day)
- **Premium SSD 128 GB** (for SQL data): ~$0.29/day
- **Public IP address**: ~$0.005/hour (~$0.12/day) per IP
- **Log Analytics Workspace**: ~$2.76/GB ingested (first 5 GB free per month)
- **Virtual Network and NSG**: No charge

**Total Estimated Daily Cost:**
- **Windows VM only**: ~$2.50/day
- **Windows + Linux VMs**: ~$5.00/day
- **All 3 VMs (Windows + Linux + SQL)**: ~$7.50-10/day

**Cost for Arc-enabled Servers:**
- **Arc-enabled Servers**: **Free** for management (Policy, Update Management, Extensions)
- **Monitoring and Defender**: Additional charges based on usage
  - Log Analytics: Pay per GB ingested
  - Microsoft Defender for Servers: ~$15/server/month if enabled

**Cost Optimization Tips:**
- Set the `ttlHours` tag to enable automatic cleanup after testing (48 hours recommended)
- Use `deployLinuxVM: false` or `deploySqlVM: false` if you only need specific scenarios
- Use B-series burstable VMs (already configured) for cost savings
- Stop VMs when not in use (but note: Arc connection status will show disconnected)
- Delete the resource group immediately after learning to minimize costs

**Pricing Calculator:**
- [Azure VMs Pricing](https://azure.microsoft.com/pricing/details/virtual-machines/windows/)
- [Azure Arc Pricing](https://azure.microsoft.com/pricing/details/azure-arc/)
- [Log Analytics Pricing](https://azure.microsoft.com/pricing/details/monitor/)

## Teardown Instructions

### Option 1: Delete via Azure Portal
1. Navigate to **Resource Groups** in the Azure Portal
2. Find your resource group (e.g., `rg-arcbox-demo`)
3. Click **Delete resource group**
4. Type the resource group name to confirm
5. Click **Delete**

### Option 2: Delete via Azure CLI
```bash
# Delete the entire resource group (including Arc-enabled servers)
az group delete \
  --name rg-arcbox-demo \
  --yes \
  --no-wait

# Note: Arc-enabled servers will be automatically cleaned up when VMs are deleted
```

### Option 3: Delete via GitHub Actions
1. Navigate to **Actions** → **Destroy Azure Resources**
2. Click **Run workflow**
3. Provide:
   - **subscriptionId**: Your Azure subscription ID
   - **patternSlug**: `azure-arc-box`
   - **resourceGroupName**: Your resource group name
   - **deleteResourceGroup**: `true`
4. Click **Run workflow**

**Note:** VM deletion can take 3-5 minutes. Arc-enabled server resources are automatically removed.

## Use Cases

This pattern is ideal for:

- **Learning Azure Arc**: Hands-on experience onboarding servers and SQL to Azure Arc
- **Arc Servers Demo**: Demonstrate hybrid server management capabilities
- **Arc-enabled SQL Demo**: Show SQL Server management across hybrid environments
- **Azure Policy Testing**: Test governance policies on Arc-enabled resources
- **Update Management Testing**: Validate patch management across hybrid infrastructure
- **Security Posture Testing**: Explore Microsoft Defender for Cloud on Arc servers
- **Training and Workshops**: Provide sandbox environments for Arc training

## Next Steps

After deployment and onboarding:

1. **Enable Azure Monitor**: Configure Log Analytics for metrics and logs collection
2. **Apply Azure Policies**: Test governance policies on Arc-enabled servers
3. **Enable Update Management**: Configure automatic patching and compliance reporting
4. **Deploy VM Extensions**: Install monitoring agents, dependency agents, etc.
5. **Enable Defender for Cloud**: Turn on security posture management and threat detection
6. **Test Automation**: Run Azure Automation runbooks on Arc-enabled servers
7. **Explore Arc-enabled SQL**: View SQL assessments, backups, and performance metrics
8. **Try Change Tracking**: Enable configuration change tracking and alerting

## Security Considerations

⚠️ **Important Security Notes:**

1. **Public IP Exposure**: VMs have public IPs with RDP/SSH open to the internet
   - **For Production**: Use Azure Bastion or restrict NSG rules to your IP only
   - **Recommendation**: Update NSG `sourceAddressPrefix` from `*` to your IP address

2. **Password Management**: 
   - Use a strong, unique password (not the example from parameters file)
   - Consider using Azure Key Vault for password management
   - Rotate credentials regularly

3. **Arc Agent Security**:
   - Arc agents use outbound HTTPS (443) only - no inbound ports required
   - Service Principal credentials should be stored securely
   - Use Managed Identity where possible (for Azure-based onboarding tools)

4. **SQL Server Security**:
   - SQL Server 2022 Developer Edition is for non-production use only
   - Configure SQL authentication and firewall rules appropriately
   - Enable SQL Server auditing and send logs to Log Analytics

## Troubleshooting

### VM Deployment Issues
- **Quota exceeded**: Check VM quota in your subscription and region
- **Password validation**: Ensure password meets complexity requirements (12+ chars, mixed case, numbers, symbols)

### Arc Onboarding Issues
- **Connection failures**: Verify outbound HTTPS (443) connectivity from VM
- **Service Principal errors**: Verify Service Principal has correct permissions and credentials
- **Region mismatch**: Ensure Arc resource location matches your VM's region

### Useful Commands
```bash
# Check Arc agent status on Windows
azcmagent show

# Check Arc agent status on Linux
sudo azcmagent show

# View Arc agent logs on Windows
Get-Content "C:\ProgramData\AzureConnectedMachineAgent\Log\azcmagent.log" -Tail 50

# View Arc agent logs on Linux
sudo journalctl -u himdsd -f
```

## Related Patterns

- [Azure Monitor Baseline](../azure-monitor-baseline/) - Monitoring and observability foundation
- [Landing Zone Foundation](../landing-zone-foundation/) - Enterprise-scale landing zone
- [Zero Trust Network](../zero-trust-network/) - Secure network with Bastion and Private Link

## Additional Resources

- [Azure Arc Documentation](https://docs.microsoft.com/azure/azure-arc/)
- [Azure Arc Jumpstart](https://azurearcjumpstart.io/)
- [Azure Arc-enabled Servers Overview](https://docs.microsoft.com/azure/azure-arc/servers/overview)
- [Azure Arc-enabled SQL Server Overview](https://docs.microsoft.com/azure/azure-arc/data/overview)
- [Azure Arc Learning Paths](https://docs.microsoft.com/learn/paths/manage-hybrid-infrastructure-with-azure-arc/)

## Support

For issues or questions:
- Open an issue in the [GitHub repository](https://github.com/{owner}/Azure-Infra-Demos/issues)
- Refer to [Azure Arc documentation](https://docs.microsoft.com/azure/azure-arc/)
- Join the [Azure Arc community](https://techcommunity.microsoft.com/t5/azure-arc/ct-p/AzureArc)
