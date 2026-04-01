// Data Analytics Pipeline
// Modern data analytics platform with Azure Data Factory, Synapse Analytics, and Data Lake Storage Gen2

@description('Azure region for deployment')
param location string = resourceGroup().location

@description('Prefix for resource naming')
param prefix string = 'demo'

@description('Resource tags')
param tags object = {
  owner: 'pattern-demo'
  workload: 'data-analytics-pipeline'
  environment: 'demo'
  ttlHours: '24'
}

@description('SQL administrator login username')
param sqlAdminLogin string = 'sqladmin'

@description('SQL administrator password (must meet complexity requirements: 12+ chars, upper, lower, number, special)')
@secure()
param sqlAdminPassword string

@description('Enable Synapse Spark Pool (expensive - adds ~$100+/day)')
param enableSynapseSparkPool bool = false

@description('Deployment timestamp')
param deploymentTime string = utcNow('u')

// ============================================================================
// VARIABLES
// ============================================================================

var commonTags = union(tags, {
  deployedAt: deploymentTime
  pattern: 'data-analytics-pipeline'
})

// Globally unique names with shorter suffixes
var uniqueSuffix = uniqueString(resourceGroup().id)
var dataLakeName = '${prefix}adls${uniqueSuffix}'
var synapseWorkspaceName = '${prefix}synw${uniqueSuffix}'
var dataFactoryName = '${prefix}adf${uniqueSuffix}'
var keyVaultName = '${prefix}kv${take(uniqueSuffix, 12)}'
var logAnalyticsName = '${prefix}-law-${uniqueSuffix}'

// Role definitions
var storageBlobDataContributorRole = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'ba92f5b4-2d11-453d-a403-e96b0029c9fe')

// ============================================================================
// STORAGE - DATA LAKE GEN2
// ============================================================================

resource dataLakeStorage 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: dataLakeName
  location: location
  tags: commonTags
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    accessTier: 'Hot'
    supportsHttpsTrafficOnly: true
    minimumTlsVersion: 'TLS1_2'
    isHnsEnabled: true
    allowBlobPublicAccess: false
    publicNetworkAccess: 'Enabled'
    networkAcls: {
      defaultAction: 'Allow'
      bypass: 'AzureServices'
    }
  }
}

resource blobServices 'Microsoft.Storage/storageAccounts/blobServices@2023-01-01' = {
  parent: dataLakeStorage
  name: 'default'
}

resource rawContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-01-01' = {
  parent: blobServices
  name: 'raw'
  properties: {
    publicAccess: 'None'
  }
}

resource curatedContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-01-01' = {
  parent: blobServices
  name: 'curated'
  properties: {
    publicAccess: 'None'
  }
}

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
    enableSoftDelete: true
    softDeleteRetentionInDays: 7
    enablePurgeProtection: false
    publicNetworkAccess: 'Enabled'
  }
}

resource sqlAdminPasswordSecret 'Microsoft.KeyVault/vaults/secrets@2023-07-01' = {
  parent: keyVault
  name: 'sqlAdminPassword'
  properties: {
    value: sqlAdminPassword
  }
}

// ============================================================================
// SYNAPSE WORKSPACE
// ============================================================================

resource synapseWorkspace 'Microsoft.Synapse/workspaces@2021-06-01' = {
  name: synapseWorkspaceName
  location: location
  tags: commonTags
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    defaultDataLakeStorage: {
      accountUrl: dataLakeStorage.properties.primaryEndpoints.dfs
      filesystem: 'curated'
    }
    sqlAdministratorLogin: sqlAdminLogin
    sqlAdministratorLoginPassword: sqlAdminPassword
    managedVirtualNetwork: 'default'
    publicNetworkAccess: 'Enabled'
    managedResourceGroupName: '${resourceGroup().name}-synapse-managed'
  }
}

resource synapseFirewallAllowAzure 'Microsoft.Synapse/workspaces/firewallRules@2021-06-01' = {
  parent: synapseWorkspace
  name: 'AllowAllWindowsAzureIps'
  properties: {
    startIpAddress: '0.0.0.0'
    endIpAddress: '0.0.0.0'
  }
}

resource synapseSparkPool 'Microsoft.Synapse/workspaces/bigDataPools@2021-06-01' = if (enableSynapseSparkPool) {
  parent: synapseWorkspace
  name: 'sparkpool'
  location: location
  tags: commonTags
  properties: {
    nodeSize: 'Small'
    nodeSizeFamily: 'MemoryOptimized'
    autoScale: {
      enabled: true
      minNodeCount: 3
      maxNodeCount: 10
    }
    autoPause: {
      enabled: true
      delayInMinutes: 15
    }
    sparkVersion: '3.4'
    isComputeIsolationEnabled: false
  }
}

resource synapseDiagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'synapse-diagnostics'
  scope: synapseWorkspace
  properties: {
    workspaceId: logAnalytics.id
    logs: [
      {
        category: 'SynapseRbacOperations'
        enabled: true
      }
      {
        category: 'GatewayApiRequests'
        enabled: true
      }
      {
        category: 'SQLSecurityAuditEvents'
        enabled: true
      }
      {
        category: 'BuiltinSqlReqsEnded'
        enabled: true
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
      }
    ]
  }
}

// ============================================================================
// DATA FACTORY
// ============================================================================

resource dataFactory 'Microsoft.DataFactory/factories@2018-06-01' = {
  name: dataFactoryName
  location: location
  tags: commonTags
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    publicNetworkAccess: 'Enabled'
  }
}

resource dataFactoryDiagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'adf-diagnostics'
  scope: dataFactory
  properties: {
    workspaceId: logAnalytics.id
    logs: [
      {
        category: 'ActivityRuns'
        enabled: true
      }
      {
        category: 'PipelineRuns'
        enabled: true
      }
      {
        category: 'TriggerRuns'
        enabled: true
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
      }
    ]
  }
}

// ============================================================================
// ROLE ASSIGNMENTS
// ============================================================================

resource synapseStorageRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(dataLakeStorage.id, synapseWorkspace.id, storageBlobDataContributorRole)
  scope: dataLakeStorage
  properties: {
    roleDefinitionId: storageBlobDataContributorRole
    principalId: synapseWorkspace.identity.principalId
    principalType: 'ServicePrincipal'
  }
}

resource dataFactoryStorageRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(dataLakeStorage.id, dataFactory.id, storageBlobDataContributorRole)
  scope: dataLakeStorage
  properties: {
    roleDefinitionId: storageBlobDataContributorRole
    principalId: dataFactory.identity.principalId
    principalType: 'ServicePrincipal'
  }
}

// ============================================================================
// OUTPUTS
// ============================================================================

@description('Synapse Workspace URL')
output synapseWorkspaceUrl string = 'https://${synapseWorkspace.name}.dev.azuresynapse.net'

@description('Data Factory name')
output dataFactoryName string = dataFactory.name

@description('Data Lake Storage endpoint')
output dataLakeStorageEndpoint string = dataLakeStorage.properties.primaryEndpoints.dfs

@description('Key Vault URI')
output keyVaultUri string = keyVault.properties.vaultUri

@description('Log Analytics workspace ID')
output workspaceId string = logAnalytics.id

@description('Resource group name')
output resourceGroupName string = resourceGroup().name

@description('List of deployed resources')
output deployedResources array = [
  {
    type: 'Microsoft.Storage/storageAccounts'
    name: dataLakeStorage.name
    id: dataLakeStorage.id
  }
  {
    type: 'Microsoft.Synapse/workspaces'
    name: synapseWorkspace.name
    id: synapseWorkspace.id
  }
  {
    type: 'Microsoft.DataFactory/factories'
    name: dataFactory.name
    id: dataFactory.id
  }
  {
    type: 'Microsoft.KeyVault/vaults'
    name: keyVault.name
    id: keyVault.id
  }
  {
    type: 'Microsoft.OperationalInsights/workspaces'
    name: logAnalytics.name
    id: logAnalytics.id
  }
]

@description('Deployment timestamp')
output deploymentTimestamp string = deploymentTime
