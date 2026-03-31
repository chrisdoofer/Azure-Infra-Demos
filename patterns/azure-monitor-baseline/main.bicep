// Azure Monitor Baseline
// Centralized monitoring with Log Analytics, Application Insights, and Alerts

@description('Azure region for deployment')
param location string = resourceGroup().location

@description('Prefix for resource naming')
param prefix string = 'demo'

@description('Resource tags')
param tags object = {
  owner: 'pattern-demo'
  workload: 'azure-monitor-baseline'
  environment: 'demo'
  ttlHours: '24'
}

@description('Log Analytics retention in days')
param retentionDays int = 30

@description('Alert notification email address')
param alertEmail string = 'alerts@example.com'

@description('Daily data ingestion cap in GB')
param dailyQuotaGb int = 1

@description('Deployment timestamp')
param deploymentTime string = utcNow('u')

// ============================================================================
// VARIABLES
// ============================================================================

var resourceSuffix = '${prefix}-${uniqueString(resourceGroup().id)}'
var commonTags = union(tags, {
  deployedAt: deploymentTime
  pattern: 'azure-monitor-baseline'
})

var logAnalyticsName = 'log-${resourceSuffix}'
var appInsightsName = 'appi-${resourceSuffix}'
var actionGroupName = 'ag-${resourceSuffix}'
var alertRuleName = 'alert-${resourceSuffix}'

// ============================================================================
// LOG ANALYTICS WORKSPACE
// ============================================================================

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: logAnalyticsName
  location: location
  tags: commonTags
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: retentionDays
    workspaceCapping: {
      dailyQuotaGb: dailyQuotaGb
    }
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
  }
}

// ============================================================================
// APPLICATION INSIGHTS
// ============================================================================

resource applicationInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: appInsightsName
  location: location
  tags: commonTags
  kind: 'web'
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: logAnalyticsWorkspace.id
    RetentionInDays: retentionDays
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
  }
}

// ============================================================================
// ALERTS & ACTION GROUPS
// ============================================================================

resource actionGroup 'Microsoft.Insights/actionGroups@2023-01-01' = {
  name: actionGroupName
  location: 'global'
  tags: commonTags
  properties: {
    groupShortName: substring(actionGroupName, 0, 12)
    enabled: true
    emailReceivers: [
      {
        name: 'EmailAlert'
        emailAddress: alertEmail
        useCommonAlertSchema: true
      }
    ]
  }
}

resource metricAlert 'Microsoft.Insights/metricAlerts@2018-03-01' = {
  name: alertRuleName
  location: 'global'
  tags: commonTags
  properties: {
    description: 'Alert when Log Analytics workspace data ingestion exceeds threshold'
    severity: 2
    enabled: true
    scopes: [
      logAnalyticsWorkspace.id
    ]
    evaluationFrequency: 'PT5M'
    windowSize: 'PT5M'
    criteria: {
      'odata.type': 'Microsoft.Azure.Monitor.SingleResourceMultipleMetricCriteria'
      allOf: [
        {
          name: 'DataIngestion'
          metricName: 'Usage'
          dimensions: []
          operator: 'GreaterThan'
          threshold: 100
          timeAggregation: 'Total'
        }
      ]
    }
    actions: [
      {
        actionGroupId: actionGroup.id
      }
    ]
  }
}

// ============================================================================
// DIAGNOSTIC SETTINGS
// ============================================================================

resource diagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  scope: logAnalyticsWorkspace
  name: 'workspace-diagnostics'
  properties: {
    workspaceId: logAnalyticsWorkspace.id
    logs: [
      {
        categoryGroup: 'allLogs'
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
// OUTPUTS
// ============================================================================

@description('Resource group name')
output resourceGroupName string = resourceGroup().name

@description('Resource group location')
output location string = location

@description('Log Analytics Workspace ID')
output logAnalyticsWorkspaceId string = logAnalyticsWorkspace.id

@description('Log Analytics Workspace Name')
output logAnalyticsWorkspaceName string = logAnalyticsWorkspace.name

@description('Application Insights Instrumentation Key')
output appInsightsInstrumentationKey string = applicationInsights.properties.InstrumentationKey

@description('Application Insights Connection String')
output appInsightsConnectionString string = applicationInsights.properties.ConnectionString

@description('Action Group ID')
output actionGroupId string = actionGroup.id

@description('List of deployed resources')
output deployedResources array = [
  {
    type: 'Microsoft.OperationalInsights/workspaces'
    name: logAnalyticsWorkspace.name
    id: logAnalyticsWorkspace.id
  }
  {
    type: 'Microsoft.Insights/components'
    name: applicationInsights.name
    id: applicationInsights.id
  }
  {
    type: 'Microsoft.Insights/actionGroups'
    name: actionGroup.name
    id: actionGroup.id
  }
]

@description('Deployment timestamp')
output deploymentTimestamp string = deploymentTime
