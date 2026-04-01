// Microservices on Azure Kubernetes Service
// Complete production-ready AKS cluster with Container Registry, Key Vault, monitoring, and networking

@description('Azure region for deployment')
param location string = resourceGroup().location

@description('Prefix for resource naming')
param prefix string = 'demo'

@description('Resource tags')
param tags object = {
  owner: 'pattern-demo'
  workload: 'microservices-aks'
  environment: 'demo'
  ttlHours: '48'
}

@description('Kubernetes version')
param kubernetesVersion string = '1.29'

@description('Number of nodes in the system node pool')
param nodeCount int = 2

@description('VM size for AKS nodes')
param vmSize string = 'Standard_B2s'

@description('Azure Container Registry SKU')
@allowed(['Basic', 'Standard', 'Premium'])
param acrSku string = 'Basic'

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
var appInsightsName = 'appi-${resourceSuffix}'
var vnetName = 'vnet-${resourceSuffix}'

var vnetAddressPrefix = '10.1.0.0/16'
var aksSubnetPrefix = '10.1.0.0/20'
var servicesSubnetPrefix = '10.1.16.0/24'

// ============================================================================
// LOG ANALYTICS & APPLICATION INSIGHTS
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
    features: {
      enableLogAccessUsingOnlyResourcePermissions: true
    }
  }
}

resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: appInsightsName
  location: location
  tags: commonTags
  kind: 'web'
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: logAnalytics.id
    IngestionMode: 'LogAnalytics'
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
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
          privateEndpointNetworkPolicies: 'Disabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
      }
      {
        name: 'ServicesSubnet'
        properties: {
          addressPrefix: servicesSubnetPrefix
          privateEndpointNetworkPolicies: 'Disabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
      }
    ]
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
    name: acrSku
  }
  properties: {
    adminUserEnabled: false
    publicNetworkAccess: 'Enabled'
    networkRuleBypassOptions: 'AzureServices'
    zoneRedundancy: acrSku == 'Premium' ? 'Enabled' : 'Disabled'
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
    softDeleteRetentionInDays: 90
    enablePurgeProtection: true
    publicNetworkAccess: 'Enabled'
    networkAcls: {
      defaultAction: 'Allow'
      bypass: 'AzureServices'
    }
  }
}

// ============================================================================
// AKS CLUSTER
// ============================================================================

resource aksCluster 'Microsoft.ContainerService/managedClusters@2024-01-01' = {
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
    aadProfile: {
      managed: true
      enableAzureRBAC: true
    }
    oidcIssuerProfile: {
      enabled: true
    }
    securityProfile: {
      workloadIdentity: {
        enabled: true
      }
    }
    networkProfile: {
      networkPlugin: 'azure'
      networkPolicy: 'azure'
      loadBalancerSku: 'standard'
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
        enableAutoScaling: false
        type: 'VirtualMachineScaleSets'
        maxPods: 30
        availabilityZones: []
      }
    ]
    addonProfiles: {
      omsagent: {
        enabled: true
        config: {
          logAnalyticsWorkspaceResourceID: logAnalytics.id
          useAADAuth: 'true'
        }
      }
      azureKeyvaultSecretsProvider: {
        enabled: true
        config: {
          enableSecretRotation: 'true'
          rotationPollInterval: '2m'
        }
      }
    }
    apiServerAccessProfile: {
      enablePrivateCluster: false
    }
    autoScalerProfile: {
      'scale-down-delay-after-add': '10m'
      'scale-down-unneeded-time': '10m'
    }
  }
}

// ============================================================================
// RBAC ROLE ASSIGNMENTS
// ============================================================================

// Grant AKS kubelet identity AcrPull role on Container Registry
resource acrPullRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(containerRegistry.id, aksCluster.id, 'AcrPull')
  scope: containerRegistry
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '7f951dda-4ed3-4680-a7ca-43fe172d538d')
    principalId: aksCluster.properties.identityProfile.kubeletidentity.objectId
    principalType: 'ServicePrincipal'
  }
}

// Grant AKS managed identity Key Vault Secrets User role on Key Vault
resource kvSecretsUserRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(keyVault.id, aksCluster.id, 'KeyVaultSecretsUser')
  scope: keyVault
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '4633458b-17de-408a-b874-0445c86b69e6')
    principalId: aksCluster.identity.principalId
    principalType: 'ServicePrincipal'
  }
}

// ============================================================================
// OUTPUTS
// ============================================================================

@description('AKS cluster name')
output aksClusterName string = aksCluster.name

@description('AKS cluster FQDN')
output aksClusterFqdn string = aksCluster.properties.fqdn

@description('Container Registry login server')
output acrLoginServer string = containerRegistry.properties.loginServer

@description('Key Vault URI')
output keyVaultUri string = keyVault.properties.vaultUri

@description('Log Analytics workspace ID')
output workspaceId string = logAnalytics.id

@description('Application Insights instrumentation key')
output appInsightsInstrumentationKey string = appInsights.properties.InstrumentationKey

@description('Application Insights connection string')
output appInsightsConnectionString string = appInsights.properties.ConnectionString

@description('Virtual Network ID')
output vnetId string = virtualNetwork.id

@description('AKS subnet ID')
output aksSubnetId string = virtualNetwork.properties.subnets[0].id

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
  {
    type: 'Microsoft.OperationalInsights/workspaces'
    name: logAnalytics.name
    id: logAnalytics.id
  }
  {
    type: 'Microsoft.Insights/components'
    name: appInsights.name
    id: appInsights.id
  }
]

@description('Deployment timestamp')
output deploymentTimestamp string = deploymentTime
