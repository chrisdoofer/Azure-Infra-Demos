// {PATTERN_NAME}
// Azure Infrastructure Pattern Template

@description('Azure region for deployment')
param location string = resourceGroup().location

@description('Prefix for resource naming')
param prefix string = 'demo'

@description('Resource tags')
param tags object = {
  owner: 'pattern-demo'
  workload: '{PATTERN_SLUG}'
  environment: 'demo'
  ttlHours: '24'
}

@description('Deployment timestamp')
param deploymentTime string = utcNow('u')

// ============================================================================
// VARIABLES
// ============================================================================

var resourceSuffix = '${prefix}-${uniqueString(resourceGroup().id)}'
var commonTags = union(tags, {
  deployedAt: deploymentTime
  pattern: '{PATTERN_SLUG}'
})

// ============================================================================
// RESOURCES
// ============================================================================

// Add your Azure resources here
// Example:
// resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
//   name: 'st${replace(resourceSuffix, '-', '')}'
//   location: location
//   tags: commonTags
//   sku: {
//     name: 'Standard_LRS'
//   }
//   kind: 'StorageV2'
//   properties: {
//     accessTier: 'Hot'
//     supportsHttpsTrafficOnly: true
//     minimumTlsVersion: 'TLS1_2'
//   }
// }

// ============================================================================
// OUTPUTS
// ============================================================================

@description('Resource group name')
output resourceGroupName string = resourceGroup().name

@description('Resource group location')
output location string = location

@description('List of deployed resources')
output deployedResources array = [
  // Add resource details here
  // Example:
  // {
  //   type: 'Microsoft.Storage/storageAccounts'
  //   name: storageAccount.name
  //   id: storageAccount.id
  // }
]

@description('Deployment timestamp')
output deploymentTimestamp string = deploymentTime
