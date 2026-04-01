# Microservices on Azure Kubernetes Service (AKS)

Deploy a production-ready Kubernetes cluster with integrated Container Registry, Key Vault, Application Insights, and network isolation. This pattern provides enterprise-grade container orchestration for microservices architectures.

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FYOUR-ORG%2FAzure-Infra-Demos%2Fmain%2Fpatterns%2Fmicroservices-aks%2Fazuredeploy.json)

## Overview

**Category**: Reference Architecture  
**Services**: Azure Kubernetes Service, Container Registry, Key Vault, Application Insights, Log Analytics, Virtual Network  
**Complexity**: Advanced  
**Estimated Cost**: $80-150/day ($2,400-4,500/month)

### Use Cases

- **Microservices Applications**: Run independently deployable services with isolated scaling and release cycles
- **Container Consolidation**: Centralize disparate container deployments onto unified orchestration platform
- **DevOps Acceleration**: Enable self-service infrastructure and automated deployments for development teams
- **Cloud-Native Migration**: Modernize legacy applications with containerization and Kubernetes-native patterns

### What Gets Deployed

- **AKS Cluster**: Managed Kubernetes control plane with auto-scaling and auto-upgrades
- **Container Registry**: Private Docker image repository with vulnerability scanning and geo-replication
- **Key Vault + CSI Driver**: Secrets, certificates, and keys mounted directly into pods
- **Application Insights**: Distributed tracing, dependency mapping, and APM for microservices
- **Log Analytics**: Centralized log aggregation for containers, nodes, and Kubernetes events
- **Virtual Network**: Isolated subnets for AKS nodes with Network Security Groups

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│ Azure Virtual Network                                       │
│                                                              │
│  ┌────────────────────────────────────────────────────┐    │
│  │ AKS Cluster Subnet                                  │    │
│  │                                                      │    │
│  │  ┌──────────────┐  ┌──────────────┐  ┌──────────┐ │    │
│  │  │ Ingress      │  │ Service A    │  │ Service B│ │    │
│  │  │ Controller   │  │ (3 replicas) │  │ (2 reps) │ │    │
│  │  └──────┬───────┘  └──────┬───────┘  └────┬─────┘ │    │
│  │         │                  │                │        │    │
│  │  ┌──────▼──────────────────▼────────────────▼────┐ │    │
│  │  │  Kubernetes Service Layer                     │ │    │
│  │  └───────────────────────────────────────────────┘ │    │
│  └────────────────────────────────────────────────────┘    │
│                                                              │
│  ┌─────────────────┐      ┌──────────────────────────┐     │
│  │ Container       │      │ Key Vault                │     │
│  │ Registry (ACR)  │      │ (CSI Driver Mounted)     │     │
│  └─────────────────┘      └──────────────────────────┘     │
└─────────────────────────────────────────────────────────────┘
           │                           │
           ▼                           ▼
  ┌─────────────────┐       ┌──────────────────────┐
  │ Application     │       │ Log Analytics        │
  │ Insights        │       │ Workspace            │
  └─────────────────┘       └──────────────────────┘
```

See `architecture.mmd` for detailed Mermaid diagram.

## Prerequisites

- **Azure Subscription** with Contributor or Owner role
- **Azure CLI** version 2.50.0 or later ([install](https://learn.microsoft.com/cli/azure/install-azure-cli))
- **kubectl** for Kubernetes management ([install](https://kubernetes.io/docs/tasks/tools/))
- **Kubernetes Knowledge**: Understanding of pods, deployments, services, and namespaces
- **Quota Availability**: Minimum 12 vCPUs in target region for Standard_D2s_v3 VMs

Verify prerequisites:
```bash
az --version
kubectl version --client
az account show
```

## Quick Start

### Option 1: Deploy via Azure CLI

```bash
# Clone repository
git clone https://github.com/YOUR-ORG/Azure-Infra-Demos.git
cd Azure-Infra-Demos/patterns/microservices-aks

# Authenticate to Azure
az login
az account set --subscription "YOUR_SUBSCRIPTION_NAME"

# Set deployment variables
RESOURCE_GROUP="rg-aks-microservices-prod"
LOCATION="eastus"
ENVIRONMENT="prod"

# Create resource group
az group create \
  --name $RESOURCE_GROUP \
  --location $LOCATION

# Deploy infrastructure (10-15 minutes)
az deployment group create \
  --resource-group $RESOURCE_GROUP \
  --template-file main.bicep \
  --parameters @parameters/${ENVIRONMENT}.parameters.json \
  --parameters location=$LOCATION

# Get deployment outputs
AKS_NAME=$(az deployment group show \
  --resource-group $RESOURCE_GROUP \
  --name main \
  --query properties.outputs.aksClusterName.value -o tsv)

# Connect to cluster
az aks get-credentials \
  --resource-group $RESOURCE_GROUP \
  --name $AKS_NAME \
  --overwrite-existing

# Verify cluster access
kubectl get nodes
kubectl get pods --all-namespaces
```

### Option 2: Deploy via Azure Portal

1. Click **Deploy to Azure** button above
2. Select subscription and create/select resource group
3. Configure parameters:
   - **Location**: Azure region (e.g., East US)
   - **Environment**: dev, staging, or prod
   - **Node Count**: Number of worker nodes (3 recommended)
4. Review + Create (deployment takes 10-15 minutes)
5. After deployment, open Cloud Shell and run:
   ```bash
   az aks get-credentials --resource-group <your-rg> --name <aks-name>
   ```

## Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `location` | string | `resourceGroup().location` | Azure region for all resources |
| `environment` | string | `dev` | Environment name (dev, staging, prod) |
| `prefix` | string | `aks` | Prefix for resource naming (3-8 chars) |
| `nodeCount` | int | `3` | Initial number of AKS worker nodes |
| `nodeVmSize` | string | `Standard_D2s_v3` | VM size for AKS nodes |
| `kubernetesVersion` | string | `1.28.3` | Kubernetes version (auto-upgrade enabled) |
| `enableAutoScaling` | bool | `true` | Enable cluster autoscaler |
| `minNodeCount` | int | `2` | Minimum nodes for autoscaler |
| `maxNodeCount` | int | `10` | Maximum nodes for autoscaler |
| `enableAzurePolicy` | bool | `true` | Enable Azure Policy for governance |
| `enableContainerInsights` | bool | `true` | Enable Container Insights monitoring |
| `acrSku` | string | `Standard` | Container Registry SKU (Basic, Standard, Premium) |
| `logAnalyticsRetentionDays` | int | `30` | Log retention in days |
| `tags` | object | `{}` | Resource tags for cost tracking |

### Parameter Files

Pre-configured parameter files in `parameters/` directory:

- **dev.parameters.json**: 2 nodes, B-series VMs, Basic ACR, 7-day logs
- **staging.parameters.json**: 3 nodes, D-series VMs, Standard ACR, 30-day logs
- **prod.parameters.json**: 5 nodes, D-series VMs, Premium ACR, 90-day logs, multi-zone

## Cost Breakdown

**Daily Costs** (East US, 3-node cluster):

| Service | SKU/Config | Daily Cost | Monthly Cost |
|---------|------------|------------|--------------|
| AKS Control Plane | Managed | $0 | $0 (Microsoft-managed) |
| Worker Nodes (VMs) | 3x Standard_D2s_v3 | $15-24 | $450-720 |
| Azure Load Balancer | Standard | $0.75 | $23 |
| Container Registry | Standard | $0.67 | $20 |
| Log Analytics | 5GB/day ingestion | $10-30 | $300-900 |
| Application Insights | 2GB/day | $2-3 | $60-90 |
| Managed Disks | 3x 128GB Premium SSD | $1-2 | $30-60 |
| Key Vault | 10K operations | $0.10 | $3 |
| Bandwidth | 100GB egress | $5-15 | $150-450 |
| **TOTAL** | | **$80-150/day** | **$2,400-4,500/month** |

### Cost Optimization

**Reduce costs by 40-60%**:

1. **Use Spot Nodes**: 70-90% discount for fault-tolerant workloads
   ```bash
   az aks nodepool add --cluster-name $AKS_NAME --name spotnp --priority Spot --eviction-policy Delete --spot-max-price -1
   ```

2. **Enable Autoscaling**: Scale to 0-1 nodes overnight for dev/test
   ```yaml
   minNodeCount: 0  # Dev environments only
   maxNodeCount: 10
   ```

3. **Right-Size VMs**: Start with B-series for dev ($2/day/node vs. $8/day)
   ```
   nodeVmSize: Standard_B2s  # Dev/test
   ```

4. **Reserved Instances**: 30-60% discount with 1-year or 3-year commitment

5. **Optimize Log Retention**: Keep 7 days hot, archive rest to storage
   ```
   logAnalyticsRetentionDays: 7  # vs. default 30
   ```

6. **ACR Tier**: Use Basic for dev ($0.17/day vs. $0.67 Standard)

**Example Savings**:
- Dev environment with spot nodes + autoscaling + Basic ACR = **$30/day** (70% reduction)
- Prod with reserved instances + optimized logging = **$90/day** (40% reduction)

## Post-Deployment

### 1. Verify Cluster Health

```bash
# Check node status
kubectl get nodes -o wide

# Verify system pods
kubectl get pods -n kube-system

# Check Container Insights
kubectl get pods -n kube-system -l app=oms-agent
```

### 2. Deploy Sample Application

```bash
# Deploy Azure Voting App (frontend + Redis)
kubectl apply -f https://raw.githubusercontent.com/Azure-Samples/azure-voting-app-redis/master/azure-vote-all-in-one-redis.yaml

# Watch deployment
kubectl get pods -w

# Get external IP (may take 2-3 minutes)
kubectl get service azure-vote-front --watch

# Open browser to external IP
```

### 3. Configure Ingress Controller (Optional)

Install NGINX Ingress Controller:
```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.8.1/deploy/static/provider/cloud/deploy.yaml

# Verify ingress controller
kubectl get svc -n ingress-nginx
```

### 4. Set Up CI/CD with GitHub Actions

```yaml
# .github/workflows/deploy-to-aks.yml
name: Deploy to AKS

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: azure/login@v1
        with:
          creds: ${{ secrets.AZURE_CREDENTIALS }}
      
      - uses: azure/aks-set-context@v3
        with:
          resource-group: rg-aks-microservices-prod
          cluster-name: aks-prod
      
      - run: |
          kubectl apply -f k8s/
```

## Security Best Practices

**Implemented in Template**:
- ✅ Azure AD integration for Kubernetes RBAC
- ✅ Managed identity for pod-to-Azure authentication
- ✅ Key Vault CSI driver for secret injection
- ✅ Network policies enabled (Azure CNI)
- ✅ Azure Policy for pod security standards
- ✅ Container Registry vulnerability scanning

**Additional Hardening**:

1. **Enable Azure Defender for Containers**:
   ```bash
   az security pricing create --name Containers --tier Standard
   ```

2. **Restrict API Server Access**:
   ```bash
   az aks update --resource-group $RESOURCE_GROUP --name $AKS_NAME \
     --api-server-authorized-ip-ranges "YOUR_IP/32"
   ```

3. **Enable Pod Identity**:
   ```bash
   az aks update --resource-group $RESOURCE_GROUP --name $AKS_NAME \
     --enable-pod-identity
   ```

4. **Implement Network Policies**:
   ```yaml
   apiVersion: networking.k8s.io/v1
   kind: NetworkPolicy
   metadata:
     name: deny-all-ingress
   spec:
     podSelector: {}
     policyTypes:
     - Ingress
   ```

## Monitoring & Operations

### Container Insights

Access cluster metrics in Azure Portal:
1. Navigate to AKS cluster → Monitoring → Insights
2. View nodes, controllers, containers, and logs
3. Set up alerts for pod restarts, resource exhaustion, or failed deployments

### Application Insights

Automatic dependency mapping:
1. Open Application Insights resource
2. Navigate to Application Map
3. View service topology and performance

### Querying Logs with KQL

```kql
// Pod restart events
KubePodInventory
| where TimeGenerated > ago(24h)
| where ContainerRestartCount > 0
| summarize RestartCount = sum(ContainerRestartCount) by Name, Namespace

// Container CPU throttling
Perf
| where ObjectName == "K8SContainer"
| where CounterName == "cpuUsageNanoCores"
| summarize avg(CounterValue) by bin(TimeGenerated, 5m), InstanceName

// Failed deployments
KubeEvents
| where Reason == "FailedCreate" or Reason == "FailedScheduling"
| project TimeGenerated, Namespace, Name, Reason, Message
```

### Alerts

Pre-configured alert rules (deployed automatically):
- Node not ready > 5 minutes
- Pod restart count > 5 in 1 hour
- Node memory pressure > 80%
- Container CPU throttling > 60%
- Failed pod scheduling

## Troubleshooting

### Common Issues

**Pods stuck in Pending state**:
```bash
kubectl describe pod <pod-name>
# Look for "FailedScheduling" events
# Common causes: insufficient resources, node selector mismatch
```

**ImagePullBackOff errors**:
```bash
# Verify ACR access
az aks check-acr --resource-group $RESOURCE_GROUP --name $AKS_NAME --acr <acr-name>

# Attach ACR to AKS
az aks update --resource-group $RESOURCE_GROUP --name $AKS_NAME --attach-acr <acr-name>
```

**Unable to connect to cluster**:
```bash
# Re-fetch credentials
az aks get-credentials --resource-group $RESOURCE_GROUP --name $AKS_NAME --overwrite-existing

# Verify kubeconfig
kubectl config current-context
```

**Nodes not autoscaling**:
```bash
# Check autoscaler logs
kubectl logs -n kube-system -l app=cluster-autoscaler

# Verify autoscaler configuration
az aks nodepool show --resource-group $RESOURCE_GROUP --cluster-name $AKS_NAME --name nodepool1
```

## Cleanup

### Delete Entire Environment

```bash
# Delete resource group and all resources (2-3 minutes)
az group delete --name $RESOURCE_GROUP --yes --no-wait

# Verify deletion
az group show --name $RESOURCE_GROUP
# Should return "ResourceGroupNotFound"
```

### Selective Cleanup (Keep Images/Logs)

```bash
# Delete AKS cluster only
az aks delete --resource-group $RESOURCE_GROUP --name $AKS_NAME --yes

# Container images remain in ACR
# Logs remain in Log Analytics (per retention policy)
```

### Post-Deletion Costs

After full cleanup:
- **All resources deleted**: $0/day
- **If keeping ACR + logs**: ~$1-2/day for storage

## Related Patterns

- **[Serverless API](../serverless-api/)**: Lightweight alternative for event-driven workloads
- **[Hub-Spoke Networking](../hub-spoke-network/)**: Enterprise network topology for multi-environment AKS
- **[Zero Trust Security](../zero-trust/)**: Enhanced security posture with conditional access and network microsegmentation

## Additional Resources

### Documentation
- [AKS Documentation](https://learn.microsoft.com/azure/aks/) - Official Microsoft docs
- [AKS Best Practices](https://learn.microsoft.com/azure/aks/best-practices) - Production readiness guide
- [AKS Baseline Architecture](https://learn.microsoft.com/azure/architecture/reference-architectures/containers/aks/baseline-aks) - Reference architecture
- [Kubernetes Documentation](https://kubernetes.io/docs/) - Upstream K8s docs

### Learning Paths
- [Introduction to Kubernetes on Azure](https://learn.microsoft.com/training/paths/intro-to-kubernetes-on-azure/)
- [Deploy and manage containers using Azure Kubernetes Service](https://learn.microsoft.com/training/paths/deploy-manage-containers-azure-kubernetes-service/)

### Tools
- [kubectl Cheat Sheet](https://kubernetes.io/docs/reference/kubectl/cheatsheet/)
- [K9s Terminal UI](https://k9scli.io/) - Interactive cluster management
- [Lens IDE](https://k8slens.dev/) - Kubernetes IDE for cluster visibility

## Talk Track

See **[talk-track.md](./talk-track.md)** for:
- Executive summary and business value proposition
- 15-minute demo script with Say/Do/Show segments
- Objection handling and ROI calculations
- Architecture walkthrough with talking points

## Support

- **Issues**: Open an issue in this repository
- **Questions**: Start a discussion in GitHub Discussions
- **Azure Support**: File support ticket via Azure Portal
