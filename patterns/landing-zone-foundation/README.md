# Landing Zone Foundation

## Overview

Establish an Azure landing zone foundation with management groups, policies, RBAC, and core infrastructure. This pattern implements Microsoft's Cloud Adoption Framework principles for enterprise-scale Azure deployments.

**Category**: reference-architecture  
**Services**: Management Groups, Azure Policy, RBAC, Log Analytics, Budgets  
**Complexity**: Advanced  
**Estimated Monthly Cost**: $50-$100 (baseline, before workloads)

## Architecture

This pattern implements a landing zone foundation with:

- **Management Groups**: Hierarchical organization structure
- **Azure Policy**: Governance and compliance enforcement
- **Resource Groups**: Separation of concerns (management, connectivity, security)
- **Log Analytics**: Centralized logging and monitoring
- **Budgets**: Cost management and alerts
- **RBAC**: Role-based access control framework

**Note**: This template deploys at the **subscription level**, not resource group level.

See `architecture.mmd` for the detailed architecture diagram.

## Prerequisites

Before deploying this pattern, ensure you have:

- Azure subscription with Owner or User Access Administrator role
- Azure CLI installed and authenticated (`az login`)
- Understanding of Azure governance concepts
- Management Group hierarchy design (if using)

## Deployment

### Option 1: Azure CLI (Subscription-Level Deployment)

```bash
# Set variables
SUBSCRIPTION_ID="your-subscription-id"
LOCATION="eastus"
PREFIX="demo"
NOTIFICATION_EMAIL="your-email@example.com"

# Set subscription context
az account set --subscription $SUBSCRIPTION_ID

# Deploy at subscription level
az deployment sub create \
  --location $LOCATION \
  --template-file main.bicep \
  --parameters @parameters/dev.parameters.json \
  --parameters managementGroupPrefix=$PREFIX \
              location=$LOCATION \
              budgetNotificationEmail=$NOTIFICATION_EMAIL
```

### Important Notes

- This deploys to **subscription scope**, not resource group
- Requires elevated permissions (Owner or User Access Administrator)
- Creates resource groups as part of the deployment
- Policy assignments may take 15-30 minutes to fully apply

## Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `managementGroupPrefix` | string | `demo` | Prefix for management group naming |
| `rootMgDisplayName` | string | `Demo Organization` | Display name for root management group |
| `location` | string | (deployment location) | Primary Azure region |
| `enableDefaultPolicies` | bool | `true` | Enable baseline Azure policies |
| `budgetAmount` | int | `1000` | Monthly budget in USD |
| `budgetNotificationEmail` | string | (required) | Email for budget alerts |
| `tags` | object | (see template) | Resource tags |

## Cost Estimation

Estimated monthly costs (baseline, before workloads):

- **Management Groups**: Free
- **Azure Policy**: Free
- **Log Analytics Workspace**: ~$2.30/GB (~$20/month for 10 GB)
- **Budgets & Alerts**: Free
- **RBAC Assignments**: Free
- **Total**: ~$20-$50/month

**Note**: This is the foundation cost. Actual costs increase with deployed workloads.

## What Gets Deployed

1. **Resource Groups**:
   - `rg-management`: Central logging and monitoring
   - `rg-connectivity`: Network hub resources
   - `rg-security`: Security and compliance tools

2. **Log Analytics Workspace**: Centralized logging

3. **Policy Assignments**:
   - Required tags on resources
   - Allowed Azure regions

4. **Budget**: Monthly cost tracking with alerts

## Security Considerations

- **Least Privilege**: RBAC roles follow least privilege principle
- **Policy Enforcement**: Guardrails prevent misconfigurations
- **Audit Logging**: Activity logs captured in Log Analytics
- **Cost Controls**: Budget alerts prevent cost overruns

## Post-Deployment Steps

1. **Verify Policy Compliance**:
   ```bash
   az policy state list --subscription $SUBSCRIPTION_ID
   ```

2. **Configure Additional Policies** as needed

3. **Deploy Hub Network** in `rg-connectivity`

4. **Enable Azure Defender** in `rg-security`

5. **Create Custom RBAC Roles** if needed

6. **Onboard Workload Subscriptions** to management groups

## Cleanup

To remove deployed resources:

```bash
# Delete resource groups (retains policy assignments)
az group delete --name rg-management --yes
az group delete --name rg-connectivity --yes
az group delete --name rg-security --yes

# Remove policy assignments
az policy assignment delete --name require-tag-on-resources
az policy assignment delete --name allowed-locations
```

## Related Patterns

- Hub-Spoke Network Topology
- Zero Trust Network Access
- Azure Monitor Baseline

## Additional Resources

- [Cloud Adoption Framework](https://learn.microsoft.com/azure/cloud-adoption-framework/)
- [Azure Landing Zones](https://learn.microsoft.com/azure/cloud-adoption-framework/ready/landing-zone/)
- [Management Groups](https://learn.microsoft.com/azure/governance/management-groups/)
- [Azure Policy](https://learn.microsoft.com/azure/governance/policy/)

## Support

For issues or questions:
- Open an issue in this repository
- Review the talk track (`talk-track.md`) for presentation guidance
