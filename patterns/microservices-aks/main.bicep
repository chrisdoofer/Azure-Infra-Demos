// Microservices on Azure Kubernetes Service
// AKS cluster with Container Registry, Key Vault, and Application Gateway

@description('Azure region for deployment')
param location string = resourceGroup().location

@description('Prefix for resource naming')
param prefix string = 'demo'

@description('Resource tags')
param tags object = {
  owner: 'pattern-demo'
  workload: 'microservices-aks'
  environment: 'demo'
  ttlHours: '24'
}

@description('AKS node count')
param nodeCount int = 3

@description('AKS VM size')
param vmSize string = 'Standard_D2s_v3'

@description('Kubernetes version')
param kubernetesVersion string = '1.28.3'

@description('Enable Azure Policy for AKS')
param enableAzurePolicy bool = true

@description('Deployment timestamp')
param deploymentTime string = utcNow('u')

// ============================================================================
// VARIABLES
// ============================================================================

var resourceSuffix = '${prefix}-${uniqueString(resourceGroup().id)}'
var commonTags = union(tags, {
  deployedAt: deploymentTime
  pattern: 'microservices-aks'
})

var aksName = 'aks-${resourceSuffix}'
var acrName = 'acr${replace(resourceSuffix, '-', '')}'
var keyVaultName = 'kv-${take(replace(resourceSuffix, '-', ''), 24)}'
var logAnalyticsName = 'log-${resourceSuffix}'
var vnetName = 'vnet-${resourceSuffix}'
var appGwName = 'agw-${resourceSuffix}'
var appGwPublicIpName = 'pip-${resourceSuffix}'

var vnetAddressPrefix = '10.1.0.0/16'
var aksSubnetPrefix = '10.1.0.0/20'
var appGwSubnetPrefix = '10.1.16.0/24'

// ============================================================================
// LOG ANALYTICS
// ============================================================================

resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: logAnalyticsName
  location: location
  tags: commonTags
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: 30
  }
}

// ============================================================================
// NETWORKING
// ============================================================================

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2023-05-01' = {
  name: vnetName
  location: location
  tags: commonTags
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetAddressPrefix
      ]
    }
    subnets: [
      {
        name: 'AksSubnet'
        properties: {
          addressPrefix: aksSubnetPrefix
        }
      }
      {
        name: 'AppGwSubnet'
        properties: {
          addressPrefix: appGwSubnetPrefix
        }
      }
    ]
  }
}

resource publicIp 'Microsoft.Network/publicIPAddresses@2023-05-01' = {
  name: appGwPublicIpName
  location: location
  tags: commonTags
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

// ============================================================================
// CONTAINER REGISTRY
// ============================================================================

resource containerRegistry 'Microsoft.ContainerRegistry/registries@2023-07-01' = {
  name: acrName
  location: location
  tags: commonTags
  sku: {
    name: 'Standard'
  }
  properties: {
    adminUserEnabled: false
    publicNetworkAccess: 'Enabled'
  }
}

// ============================================================================
// KEY VAULT
// ============================================================================

resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' = {
  name: keyVaultName
  location: location
  tags: commonTags
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: subscription().tenantId
    enableRbacAuthorization: true
    enabledForDeployment: false
    enabledForTemplateDeployment: true
    enableSoftDelete: true
    softDeleteRetentionInDays: 7
  }
}

// ============================================================================
// AKS CLUSTER
// ============================================================================

resource aksCluster 'Microsoft.ContainerService/managedClusters@2023-10-01' = {
  name: aksName
  location: location
  tags: commonTags
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    kubernetesVersion: kubernetesVersion
    dnsPrefix: '${aksName}-dns'
    enableRBAC: true
    networkProfile: {
      networkPlugin: 'azure'
      networkPolicy: 'azure'
      serviceCidr: '10.2.0.0/16'
      dnsServiceIP: '10.2.0.10'
    }
    agentPoolProfiles: [
      {
        name: 'systempool'
        count: nodeCount
        vmSize: vmSize
        osType: 'Linux'
        mode: 'System'
        vnetSubnetID: virtualNetwork.properties.subnets[0].id
        enableAutoScaling: true
        minCount: 1
        maxCount: 5
      }
    ]
    addonProfiles: {
      azurepolicy: {
        enabled: enableAzurePolicy
      }
      omsagent: {
        enabled: true
        config: {
          logAnalyticsWorkspaceResourceID: logAnalytics.id
        }
      }
      azureKeyvaultSecretsProvider: {
        enabled: true
      }
    }
  }
}

// Grant AKS access to ACR
resource acrPullRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(resourceGroup().id, aksCluster.id, 'AcrPull')
  scope: containerRegistry
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '7f951dda-4ed3-4680-a7ca-43fe172d538d')
    principalId: aksCluster.properties.identityProfile.kubeletidentity.objectId
    principalType: 'ServicePrincipal'
  }
}

// ============================================================================
// APPLICATION GATEWAY (placeholder - requires additional config)
// ============================================================================

// Note: Full Application Gateway configuration requires additional parameters
// This is a minimal placeholder for the pattern scaffold

// ============================================================================
// OUTPUTS
// ============================================================================

@description('Resource group name')
output resourceGroupName string = resourceGroup().name

@description('AKS cluster name')
output aksClusterName string = aksCluster.name

@description('AKS cluster FQDN')
output aksClusterFqdn string = aksCluster.properties.fqdn

@description('Container Registry name')
output containerRegistryName string = containerRegistry.name

@description('Container Registry login server')
output containerRegistryLoginServer string = containerRegistry.properties.loginServer

@description('Key Vault name')
output keyVaultName string = keyVault.name

@description('Get AKS credentials command')
output getCredentialsCommand string = 'az aks get-credentials --resource-group ${resourceGroup().name} --name ${aksCluster.name}'

@description('List of deployed resources')
output deployedResources array = [
  {
    type: 'Microsoft.ContainerService/managedClusters'
    name: aksCluster.name
    id: aksCluster.id
  }
  {
    type: 'Microsoft.ContainerRegistry/registries'
    name: containerRegistry.name
    id: containerRegistry.id
  }
  {
    type: 'Microsoft.KeyVault/vaults'
    name: keyVault.name
    id: keyVault.id
  }
  {
    type: 'Microsoft.Network/virtualNetworks'
    name: virtualNetwork.name
    id: virtualNetwork.id
  }
]

@description('Deployment timestamp')
output deploymentTimestamp string = deploymentTime
