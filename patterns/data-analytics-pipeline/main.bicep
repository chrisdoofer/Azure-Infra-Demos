// Data Analytics Pipeline
// Data Factory, Synapse Analytics, and Storage for modern data warehousing

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

@description('Storage account SKU')
param storageSku string = 'Standard_LRS'

@description('Synapse SQL Pool SKU')
param synapseSqlPoolSku string = 'DW100c'

@description('Deploy Synapse Dedicated SQL Pool')
param deploySqlPool bool = false

@description('SQL administrator login username')
@secure()
param sqlAdministratorLogin string = 'sqladmin'

@description('SQL administrator password (must meet complexity requirements)')
@secure()
param sqlAdministratorPassword string

@description('Deployment timestamp')
param deploymentTime string = utcNow('u')

// ============================================================================
// VARIABLES
// ============================================================================

var resourceSuffix = '${prefix}-${uniqueString(resourceGroup().id)}'
var commonTags = union(tags, {
  deployedAt: deploymentTime
  pattern: 'data-analytics-pipeline'
})

var dataLakeName = 'dls${replace(resourceSuffix, '-', '')}'
var dataFactoryName = 'adf-${resourceSuffix}'
var synapseWorkspaceName = 'synapse-${resourceSuffix}'
var synapseSqlPoolName = 'sqlpool01'
var keyVaultName = 'kv-${take(replace(resourceSuffix, '-', ''), 24)}'
var logAnalyticsName = 'log-${resourceSuffix}'

// ============================================================================
// STORAGE - DATA LAKE GEN2
// ============================================================================

resource dataLakeStorage 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: dataLakeName
  location: location
  tags: commonTags
  sku: {
    name: storageSku
  }
  kind: 'StorageV2'
  properties: {
    accessTier: 'Hot'
    supportsHttpsTrafficOnly: true
    minimumTlsVersion: 'TLS1_2'
    isHnsEnabled: true // Hierarchical namespace for Data Lake Gen2
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

resource enrichedContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-01-01' = {
  parent: blobServices
  name: 'enriched'
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
      filesystem: 'enriched'
    }
    sqlAdministratorLogin: sqlAdministratorLogin
    sqlAdministratorLoginPassword: sqlAdministratorPassword
    managedVirtualNetwork: 'default'
    publicNetworkAccess: 'Enabled'
  }
}

resource synapseFirewallAllowAll 'Microsoft.Synapse/workspaces/firewallRules@2021-06-01' = {
  parent: synapseWorkspace
  name: 'AllowAllWindowsAzureIps'
  properties: {
    startIpAddress: '0.0.0.0'
    endIpAddress: '0.0.0.0'
  }
}

resource synapseSqlPool 'Microsoft.Synapse/workspaces/sqlPools@2021-06-01' = if (deploySqlPool) {
  parent: synapseWorkspace
  name: synapseSqlPoolName
  location: location
  tags: commonTags
  sku: {
    name: synapseSqlPoolSku
  }
  properties: {
    createMode: 'Default'
    collation: 'SQL_Latin1_General_CP1_CI_AS'
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

// Grant Data Factory access to storage
var storageBlobDataContributorRole = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'ba92f5b4-2d11-453d-a403-e96b0029c9fe')

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

@description('Resource group name')
output resourceGroupName string = resourceGroup().name

@description('Data Lake Storage account name')
output dataLakeStorageName string = dataLakeStorage.name

@description('Data Factory name')
output dataFactoryName string = dataFactory.name

@description('Synapse Workspace name')
output synapseWorkspaceName string = synapseWorkspace.name

@description('Synapse Workspace URL')
output synapseWorkspaceUrl string = 'https://${synapseWorkspace.name}.dev.azuresynapse.net'

@description('Key Vault name')
output keyVaultName string = keyVault.name

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
]

@description('Deployment timestamp')
output deploymentTimestamp string = deploymentTime
