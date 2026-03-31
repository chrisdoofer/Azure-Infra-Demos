# Microservices on Azure Kubernetes Service

## Overview

Deploy a production-ready Kubernetes cluster on Azure with Container Registry, Key Vault integration, and network isolation. This pattern provides a complete platform for running containerized microservices at scale.

**Category**: reference-architecture  
**Services**: Azure Kubernetes Service (AKS), Container Registry (ACR), Key Vault, Virtual Network, Application Gateway  
**Complexity**: Advanced  
**Estimated Monthly Cost**: $300-$1,500 (varies by node count and SKU)

## Architecture

This pattern implements a microservices platform with:

- **AKS Cluster**: Managed Kubernetes with Azure CNI networking and autoscaling
- **Container Registry**: Private Docker image repository with Azure AD integration
- **Key Vault CSI Driver**: Secure secret injection into pods
- **Virtual Network**: Network isolation with dedicated subnets for AKS and ingress
- **Azure Monitor**: Container Insights for cluster and application monitoring
- **Azure Policy**: Enforce governance and compliance on AKS

See `architecture.mmd` for the detailed architecture diagram.

## Prerequisites

Before deploying this pattern, ensure you have:

- Azure subscription with sufficient quota for AKS nodes
- Azure CLI installed and authenticated (`az login`)
- kubectl installed for cluster management
- Resource group created or permissions to create one
- Understanding of Kubernetes concepts

## Deployment

### Option 1: Azure CLI

```bash
# Set variables
RESOURCE_GROUP="rg-aks-microservices-demo"
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

# Get AKS credentials
az aks get-credentials --resource-group $RESOURCE_GROUP --name aks-demo-xxx
```

### Option 2: Azure Portal

1. Click the **Deploy to Azure** button below
2. Fill in the required parameters
3. Review and create (deployment takes 10-15 minutes)

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FYOUR-ORG%2FAzure-Infra-Demos%2Fmain%2Fpatterns%2Fmicroservices-aks%2Fazuredeploy.json)

## Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `location` | string | (resource group location) | Azure region for deployment |
| `prefix` | string | `demo` | Prefix for resource naming |
| `nodeCount` | int | `3` | Initial number of AKS nodes |
| `vmSize` | string | `Standard_D2s_v3` | VM size for AKS nodes |
| `kubernetesVersion` | string | `1.28.3` | Kubernetes version |
| `enableAzurePolicy` | bool | `true` | Enable Azure Policy for AKS |
| `tags` | object | (see template) | Resource tags |

## Cost Estimation

Estimated monthly costs (East US region, 3 nodes):

- **AKS Control Plane**: Free
- **Virtual Machines (3x D2s_v3)**: ~$210/month
- **Load Balancer (Standard)**: ~$20/month
- **Container Registry (Standard)**: ~$20/month
- **Managed Disk Storage**: ~$15/month
- **Log Analytics**: ~$30/month
- **Total**: ~$295/month (scales with node count)

**Cost Optimization Tips**:
- Use spot instances for non-critical workloads
- Enable cluster autoscaler to scale down during low usage
- Use Azure Reserved Instances for long-term deployments
- Monitor and right-size node VM sizes

## Security Considerations

- **Network Isolation**: AKS nodes in dedicated subnet with NSG rules
- **RBAC Enabled**: Kubernetes RBAC integrated with Azure AD
- **Key Vault Integration**: CSI driver for secure secret injection
- **Container Registry**: Private registry with managed identity access
- **Azure Policy**: Enforce pod security standards and compliance

## Post-Deployment Steps

1. **Get Cluster Credentials**:
   ```bash
   az aks get-credentials --resource-group $RESOURCE_GROUP --name $AKS_NAME
   kubectl get nodes
   ```

2. **Deploy Sample Application**:
   ```bash
   kubectl apply -f https://raw.githubusercontent.com/Azure-Samples/azure-voting-app-redis/master/azure-vote-all-in-one-redis.yaml
   ```

3. **Configure Ingress** (install ingress controller of choice)

4. **Set Up GitOps** (optional, for declarative deployments)

## Monitoring & Operations

After deployment, monitor your cluster using:

- **Container Insights**: Node and pod metrics, logs
- **Azure Monitor**: Cluster health, alerts
- **kubectl**: Real-time cluster inspection
- **Azure Portal**: AKS overview and diagnostics

## Cleanup

To remove all deployed resources:

```bash
az group delete --name $RESOURCE_GROUP --yes --no-wait
```

## Related Patterns

- Serverless API
- Zero Trust Network Access
- Hub-Spoke Network Topology

## Additional Resources

- [AKS Documentation](https://learn.microsoft.com/azure/aks/)
- [AKS Best Practices](https://learn.microsoft.com/azure/aks/best-practices)
- [Container Insights](https://learn.microsoft.com/azure/azure-monitor/containers/container-insights-overview)
- [AKS Baseline Architecture](https://learn.microsoft.com/azure/architecture/reference-architectures/containers/aks/baseline-aks)

## Support

For issues or questions:
- Open an issue in this repository
- Review the talk track (`talk-track.md`) for presentation guidance
