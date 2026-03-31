// Landing Zone Foundation
// Resource Group-scoped governance building blocks

@description('Azure region for deployment')
param location string = resourceGroup().location

@description('Prefix for resource naming')
param prefix string = 'demo'

@description('Resource tags')
param tags object = {
  owner: 'pattern-demo'
  workload: 'landing-zone-foundation'
  environment: 'demo'
  ttlHours: '48'
}

@description('Email address for alert notifications')
param alertEmail string

@description('Log Analytics retention in days')
param logRetentionDays int = 90

@description('Enable budget alert')
param enableBudgetAlert bool = true

@description('Monthly budget amount in USD')
param monthlyBudgetAmount int = 1000

@description('Deployment timestamp')
param deploymentTime string = utcNow('u')

// ============================================================================
// VARIABLES
// ============================================================================

var resourceSuffix = '${prefix}-${uniqueString(resourceGroup().id)}'
var commonTags = union(tags, {
  deployedAt: deploymentTime
  pattern: 'landing-zone-foundation'
})

var logAnalyticsName = 'log-${resourceSuffix}'
var automationAccountName = 'aa-${resourceSuffix}'
var keyVaultName = 'kv-${take(replace(resourceSuffix, '-', ''), 24)}'
var storageAccountName = 'st${replace(take(resourceSuffix, 17), '-', '')}'
var actionGroupName = 'ag-${resourceSuffix}'
var budgetName = 'budget-${resourceSuffix}'
var recoveryVaultName = 'rsv-${resourceSuffix}'
var networkWatcherName = 'nw-${location}'

// ============================================================================
// LOG ANALYTICS WORKSPACE
// ============================================================================

resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: logAnalyticsName
  location: location
  tags: commonTags
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: logRetentionDays
    features: {
      enableLogAccessUsingOnlyResourcePermissions: true
    }
    workspaceCapping: {
      dailyQuotaGb: 5
    }
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
  }
}

// ============================================================================
// AUTOMATION ACCOUNT
// ============================================================================

resource automationAccount 'Microsoft.Automation/automationAccounts@2023-11-01' = {
  name: automationAccountName
  location: location
  tags: commonTags
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    sku: {
      name: 'Basic'
    }
    publicNetworkAccess: true
  }
}

// Link Automation Account to Log Analytics
resource automationLinkedWorkspace 'Microsoft.OperationalInsights/workspaces/linkedServices@2020-08-01' = {
  parent: logAnalytics
  name: 'Automation'
  properties: {
    resourceId: automationAccount.id
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
    tenantId: subscription().tenantId
    sku: {
      family: 'A'
      name: 'standard'
    }
    enableRbacAuthorization: true
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

// Key Vault Diagnostic Settings
resource keyVaultDiagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'send-to-log-analytics'
  scope: keyVault
  properties: {
    workspaceId: logAnalytics.id
    logs: [
      {
        categoryGroup: 'allLogs'
        enabled: true
        retentionPolicy: {
          enabled: false
          days: 0
        }
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
        retentionPolicy: {
          enabled: false
          days: 0
        }
      }
    ]
  }
}

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
    allowBlobPublicAccess: false
    networkAcls: {
      defaultAction: 'Allow'
      bypass: 'AzureServices'
    }
  }
}

// Storage Account Diagnostic Settings
resource storageDiagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'send-to-log-analytics'
  scope: storageAccount
  properties: {
    workspaceId: logAnalytics.id
    metrics: [
      {
        category: 'Transaction'
        enabled: true
        retentionPolicy: {
          enabled: false
          days: 0
        }
      }
    ]
  }
}

// Blob service diagnostic settings
resource blobService 'Microsoft.Storage/storageAccounts/blobServices@2023-01-01' = {
  parent: storageAccount
  name: 'default'
  properties: {
    deleteRetentionPolicy: {
      enabled: true
      days: 7
    }
  }
}

resource blobDiagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'send-to-log-analytics'
  scope: blobService
  properties: {
    workspaceId: logAnalytics.id
    logs: [
      {
        category: 'StorageRead'
        enabled: true
        retentionPolicy: {
          enabled: false
          days: 0
        }
      }
      {
        category: 'StorageWrite'
        enabled: true
        retentionPolicy: {
          enabled: false
          days: 0
        }
      }
      {
        category: 'StorageDelete'
        enabled: true
        retentionPolicy: {
          enabled: false
          days: 0
        }
      }
    ]
    metrics: [
      {
        category: 'Transaction'
        enabled: true
        retentionPolicy: {
          enabled: false
          days: 0
        }
      }
    ]
  }
}

// ============================================================================
// ACTION GROUP
// ============================================================================

resource actionGroup 'Microsoft.Insights/actionGroups@2023-01-01' = {
  name: actionGroupName
  location: 'global'
  tags: commonTags
  properties: {
    groupShortName: take(prefix, 12)
    enabled: true
    emailReceivers: [
      {
        name: 'AlertEmail'
        emailAddress: alertEmail
        useCommonAlertSchema: true
      }
    ]
  }
}

// ============================================================================
// BUDGET ALERT
// ============================================================================

resource budget 'Microsoft.Consumption/budgets@2023-11-01' = if (enableBudgetAlert) {
  name: budgetName
  properties: {
    category: 'Cost'
    amount: monthlyBudgetAmount
    timeGrain: 'Monthly'
    timePeriod: {
      startDate: '2024-01-01'
    }
    filter: {
      dimensions: {
        name: 'ResourceGroupName'
        operator: 'In'
        values: [
          resourceGroup().name
        ]
      }
    }
    notifications: {
      actual_GreaterThan_80_Percent: {
        enabled: true
        operator: 'GreaterThan'
        threshold: 80
        contactEmails: [
          alertEmail
        ]
        thresholdType: 'Actual'
      }
      actual_GreaterThan_100_Percent: {
        enabled: true
        operator: 'GreaterThan'
        threshold: 100
        contactEmails: [
          alertEmail
        ]
        thresholdType: 'Actual'
      }
    }
  }
}

// ============================================================================
// NETWORK WATCHER
// ============================================================================

// Network Watcher is created automatically by Azure in the NetworkWatcherRG
// but we document it as part of the foundation for completeness
var networkWatcherResourceId = '/subscriptions/${subscription().subscriptionId}/resourceGroups/NetworkWatcherRG/providers/Microsoft.Network/networkWatchers/${networkWatcherName}'

// ============================================================================
// RECOVERY SERVICES VAULT
// ============================================================================

resource recoveryVault 'Microsoft.RecoveryServices/vaults@2023-06-01' = {
  name: recoveryVaultName
  location: location
  tags: commonTags
  sku: {
    name: 'RS0'
    tier: 'Standard'
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    publicNetworkAccess: 'Enabled'
  }
}

// Recovery Vault Diagnostic Settings
resource recoveryVaultDiagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'send-to-log-analytics'
  scope: recoveryVault
  properties: {
    workspaceId: logAnalytics.id
    logs: [
      {
        categoryGroup: 'allLogs'
        enabled: true
        retentionPolicy: {
          enabled: false
          days: 0
        }
      }
    ]
    metrics: [
      {
        category: 'Health'
        enabled: true
        retentionPolicy: {
          enabled: false
          days: 0
        }
      }
    ]
  }
}

// ============================================================================
// ACTIVITY LOG DIAGNOSTIC SETTINGS
// ============================================================================

resource activityLogDiagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'activity-log-to-log-analytics'
  properties: {
    workspaceId: logAnalytics.id
    logs: [
      {
        categoryGroup: 'allLogs'
        enabled: true
        retentionPolicy: {
          enabled: false
          days: 0
        }
      }
    ]
  }
}

// ============================================================================
// OUTPUTS
// ============================================================================

@description('Log Analytics Workspace Resource ID')
output workspaceId string = logAnalytics.id

@description('Key Vault URI')
output keyVaultUri string = keyVault.properties.vaultUri

@description('Storage Account Name')
output storageAccountName string = storageAccount.name

@description('Automation Account Resource ID')
output automationAccountId string = automationAccount.id

@description('Recovery Services Vault Resource ID')
output recoveryVaultId string = recoveryVault.id

@description('Budget Name')
output budgetName string = enableBudgetAlert ? budget.name : 'not-deployed'

@description('Action Group Resource ID')
output actionGroupId string = actionGroup.id

@description('Network Watcher Resource ID')
output networkWatcherId string = networkWatcherResourceId

@description('List of deployed resources')
output deployedResources array = [
  {
    type: 'Microsoft.OperationalInsights/workspaces'
    name: logAnalytics.name
    id: logAnalytics.id
  }
  {
    type: 'Microsoft.Automation/automationAccounts'
    name: automationAccount.name
    id: automationAccount.id
  }
  {
    type: 'Microsoft.KeyVault/vaults'
    name: keyVault.name
    id: keyVault.id
  }
  {
    type: 'Microsoft.Storage/storageAccounts'
    name: storageAccount.name
    id: storageAccount.id
  }
  {
    type: 'Microsoft.Insights/actionGroups'
    name: actionGroup.name
    id: actionGroup.id
  }
  {
    type: 'Microsoft.RecoveryServices/vaults'
    name: recoveryVault.name
    id: recoveryVault.id
  }
]

@description('Deployment timestamp')
output deploymentTimestamp string = deploymentTime
