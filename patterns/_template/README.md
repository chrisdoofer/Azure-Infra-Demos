# {PATTERN_NAME}

## Overview

{PATTERN_SUMMARY}

**Category**: {PATTERN_CATEGORY}  
**Services**: {PATTERN_SERVICES}  
**Complexity**: Intermediate  
**Estimated Monthly Cost**: $XXX-$XXX (varies by region and usage)

## Architecture

This pattern implements a production-ready solution for [describe the scenario]. The architecture includes:

- **Component 1**: [Purpose and role]
- **Component 2**: [Purpose and role]
- **Component 3**: [Purpose and role]

See `architecture.mmd` for the detailed architecture diagram.

## Prerequisites

Before deploying this pattern, ensure you have:

- Azure subscription with appropriate permissions
- Azure CLI installed and authenticated (`az login`)
- Resource group created or permissions to create one
- [Any pattern-specific prerequisites]

## Deployment

### Option 1: Azure CLI

```bash
# Set variables
RESOURCE_GROUP="rg-{PATTERN_SLUG}-demo"
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

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FYOUR-ORG%2FAzure-Infra-Demos%2Fmain%2Fpatterns%2F{PATTERN_SLUG}%2Fazuredeploy.json)

### Option 3: GitHub Actions

This repository includes a GitHub Actions workflow for automated deployment. See `.github/workflows/deploy-pattern.yml`.

## Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `location` | string | (resource group location) | Azure region for deployment |
| `prefix` | string | `demo` | Prefix for resource naming |
| `tags` | object | (see template) | Resource tags |

## Cost Estimation

Estimated monthly costs (East US region):

- **Component 1**: $XX/month
- **Component 2**: $XX/month
- **Component 3**: $XX/month
- **Total**: $XXX-$XXX/month

**Cost Optimization Tips**:
- [Tip 1]
- [Tip 2]
- [Tip 3]

## Security Considerations

- **Identity & Access**: [IAM approach]
- **Network Security**: [Network isolation approach]
- **Data Protection**: [Encryption and data protection]
- **Compliance**: [Relevant compliance certifications]

## Monitoring & Operations

After deployment, monitor your resources using:

- **Azure Monitor**: Metrics and alerts for all resources
- **Application Insights**: [If applicable]
- **Log Analytics**: Centralized logging and diagnostics

## Cleanup

To remove all deployed resources:

```bash
az group delete --name $RESOURCE_GROUP --yes --no-wait
```

## Related Patterns

- [Related Pattern 1]
- [Related Pattern 2]

## Additional Resources

- [Azure Architecture Center - Original Pattern](#)
- [Microsoft Learn Documentation](#)
- [Customer Success Stories](#)

## Support

For issues or questions:
- Open an issue in this repository
- Review the talk track (`talk-track.md`) for presentation guidance
- Contact: [your contact method]
