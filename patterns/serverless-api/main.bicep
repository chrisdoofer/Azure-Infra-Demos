// Serverless API with Azure Functions
// Event-driven API with Functions, API Management, Cosmos DB, and Key Vault

@description('Azure region for deployment')
param location string = resourceGroup().location

@description('Prefix for resource naming')
param prefix string = 'demo'

@description('Resource tags')
param tags object = {
  owner: 'pattern-demo'
  workload: 'serverless-api'
  environment: 'demo'
  ttlHours: '24'
}

@description('Function runtime (dotnet, node, python, java)')
param functionRuntime string = 'node'

@description('Function runtime version')
param functionRuntimeVersion string = '18'

@description('Cosmos DB consistency level')
param cosmosDbConsistency string = 'Session'

@description('API Management SKU')
param apimSku string = 'Consumption'

@description('Deployment timestamp')
param deploymentTime string = utcNow('u')

// ============================================================================
// VARIABLES
// ============================================================================

var resourceSuffix = '${prefix}-${uniqueString(resourceGroup().id)}'
var commonTags = union(tags, {
  deployedAt: deploymentTime
  pattern: 'serverless-api'
})

var functionAppName = 'func-${resourceSuffix}'
var storageAccountName = 'st${replace(resourceSuffix, '-', '')}'
var cosmosAccountName = 'cosmos-${resourceSuffix}'
var apimName = 'apim-${resourceSuffix}'
var keyVaultName = 'kv-${take(replace(resourceSuffix, '-', ''), 24)}'
var appInsightsName = 'appi-${resourceSuffix}'
var logAnalyticsName = 'log-${resourceSuffix}'
var databaseName = 'apidb'
var containerName = 'items'

// ============================================================================
// STORAGE ACCOUNT
// ============================================================================

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: storageAccountName
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
  }
}

// ============================================================================
// LOG ANALYTICS & APP INSIGHTS
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

resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: appInsightsName
  location: location
  tags: commonTags
  kind: 'web'
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: logAnalytics.id
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
// COSMOS DB
// ============================================================================

resource cosmosAccount 'Microsoft.DocumentDB/databaseAccounts@2023-11-15' = {
  name: cosmosAccountName
  location: location
  tags: commonTags
  kind: 'GlobalDocumentDB'
  properties: {
    consistencyPolicy: {
      defaultConsistencyLevel: cosmosDbConsistency
    }
    databaseAccountOfferType: 'Standard'
    locations: [
      {
        locationName: location
        failoverPriority: 0
      }
    ]
    capabilities: [
      {
        name: 'EnableServerless'
      }
    ]
    enableAutomaticFailover: false
    enableMultipleWriteLocations: false
    publicNetworkAccess: 'Enabled'
    disableKeyBasedMetadataWriteAccess: false
  }
}

resource cosmosDatabase 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases@2023-11-15' = {
  parent: cosmosAccount
  name: databaseName
  properties: {
    resource: {
      id: databaseName
    }
  }
}

resource cosmosContainer 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers@2023-11-15' = {
  parent: cosmosDatabase
  name: containerName
  properties: {
    resource: {
      id: containerName
      partitionKey: {
        paths: [
          '/id'
        ]
        kind: 'Hash'
      }
      indexingPolicy: {
        indexingMode: 'consistent'
        automatic: true
        includedPaths: [
          {
            path: '/*'
          }
        ]
      }
    }
  }
}

// Store Cosmos connection string in Key Vault
resource cosmosConnectionStringSecret 'Microsoft.KeyVault/vaults/secrets@2023-07-01' = {
  parent: keyVault
  name: 'CosmosDbConnectionString'
  properties: {
    value: cosmosAccount.listConnectionStrings().connectionStrings[0].connectionString
  }
}

// ============================================================================
// FUNCTION APP
// ============================================================================

resource hostingPlan 'Microsoft.Web/serverfarms@2023-01-01' = {
  name: 'asp-${resourceSuffix}'
  location: location
  tags: commonTags
  sku: {
    name: 'Y1'
    tier: 'Dynamic'
  }
  properties: {
    reserved: true
  }
}

resource functionApp 'Microsoft.Web/sites@2023-01-01' = {
  name: functionAppName
  location: location
  tags: commonTags
  kind: 'functionapp,linux'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: hostingPlan.id
    httpsOnly: true
    siteConfig: {
      ftpsState: 'Disabled'
      minTlsVersion: '1.2'
      linuxFxVersion: functionRuntime == 'node' ? 'NODE|${functionRuntimeVersion}' : (functionRuntime == 'python' ? 'PYTHON|3.11' : 'DOTNET-ISOLATED|8.0')
      appSettings: [
        {
          name: 'AzureWebJobsStorage'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};AccountKey=${storageAccount.listKeys().keys[0].value};EndpointSuffix=core.windows.net'
        }
        {
          name: 'WEBSITE_CONTENTAZUREFILECONNECTIONSTRING'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};AccountKey=${storageAccount.listKeys().keys[0].value};EndpointSuffix=core.windows.net'
        }
        {
          name: 'WEBSITE_CONTENTSHARE'
          value: functionAppName
        }
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~4'
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: functionRuntime
        }
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: appInsights.properties.InstrumentationKey
        }
        {
          name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value: appInsights.properties.ConnectionString
        }
        {
          name: 'CosmosDbEndpoint'
          value: cosmosAccount.properties.documentEndpoint
        }
        {
          name: 'CosmosDbConnectionString'
          value: '@Microsoft.KeyVault(SecretUri=${cosmosConnectionStringSecret.properties.secretUri})'
        }
        {
          name: 'KeyVaultUri'
          value: keyVault.properties.vaultUri
        }
      ]
    }
  }
}

// Grant Function App access to Key Vault
resource keyVaultAccessPolicy 'Microsoft.KeyVault/vaults/accessPolicies@2023-07-01' = {
  parent: keyVault
  name: 'add'
  properties: {
    accessPolicies: [
      {
        tenantId: subscription().tenantId
        objectId: functionApp.identity.principalId
        permissions: {
          secrets: [
            'get'
            'list'
          ]
        }
      }
    ]
  }
}

// ============================================================================
// API MANAGEMENT
// ============================================================================

resource apiManagement 'Microsoft.ApiManagement/service@2023-05-01-preview' = {
  name: apimName
  location: location
  tags: commonTags
  sku: {
    name: apimSku
    capacity: 0
  }
  properties: {
    publisherEmail: 'admin@example.com'
    publisherName: 'API Publisher'
  }
}

// Create API in APIM that fronts the Function App
resource apimApi 'Microsoft.ApiManagement/service/apis@2023-05-01-preview' = {
  parent: apiManagement
  name: 'serverless-api'
  properties: {
    displayName: 'Serverless API'
    description: 'API powered by Azure Functions'
    path: 'api'
    protocols: [
      'https'
    ]
    subscriptionRequired: false
    serviceUrl: 'https://${functionApp.properties.defaultHostName}/api'
  }
}

// Create a sample operation
resource apimOperation 'Microsoft.ApiManagement/service/apis/operations@2023-05-01-preview' = {
  parent: apimApi
  name: 'get-items'
  properties: {
    displayName: 'Get Items'
    method: 'GET'
    urlTemplate: '/items'
    description: 'Retrieve items from the API'
    responses: [
      {
        statusCode: 200
        description: 'Success'
      }
    ]
  }
}

// Add backend policy to forward to Function App
resource apimPolicy 'Microsoft.ApiManagement/service/apis/operations/policies@2023-05-01-preview' = {
  parent: apimOperation
  name: 'policy'
  properties: {
    format: 'rawxml'
    value: '<policies><inbound><base /><set-backend-service base-url="https://${functionApp.properties.defaultHostName}/api" /></inbound><backend><base /></backend><outbound><base /></outbound><on-error><base /></on-error></policies>'
  }
}

// ============================================================================
// OUTPUTS
// ============================================================================

@description('Resource group name')
output resourceGroupName string = resourceGroup().name

@description('Function App name')
output functionAppName string = functionApp.name

@description('Function App URL')
output functionAppUrl string = 'https://${functionApp.properties.defaultHostName}'

@description('API Management Gateway URL')
output apimGatewayUrl string = 'https://${apiManagement.properties.gatewayUrl}/api'

@description('Cosmos DB Endpoint')
output cosmosDbEndpoint string = cosmosAccount.properties.documentEndpoint

@description('Application Insights Instrumentation Key')
output appInsightsInstrumentationKey string = appInsights.properties.InstrumentationKey

@description('Cosmos DB account name')
output cosmosAccountName string = cosmosAccount.name

@description('Key Vault name')
output keyVaultName string = keyVault.name

@description('API Management name')
output apiManagementName string = apiManagement.name

@description('List of deployed resources')
output deployedResources array = [
  {
    type: 'Microsoft.Web/sites'
    name: functionApp.name
    id: functionApp.id
  }
  {
    type: 'Microsoft.DocumentDB/databaseAccounts'
    name: cosmosAccount.name
    id: cosmosAccount.id
  }
  {
    type: 'Microsoft.KeyVault/vaults'
    name: keyVault.name
    id: keyVault.id
  }
  {
    type: 'Microsoft.ApiManagement/service'
    name: apiManagement.name
    id: apiManagement.id
  }
]

@description('Deployment timestamp')
output deploymentTimestamp string = deploymentTime
