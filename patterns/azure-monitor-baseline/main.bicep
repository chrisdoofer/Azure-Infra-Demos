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
  name: '${alertRuleName}-dataingestion'
  location: 'global'
  tags: commonTags
  properties: {
    description: 'Alert when Log Analytics workspace data ingestion exceeds 5 GB/day'
    severity: 2
    enabled: true
    scopes: [
      logAnalyticsWorkspace.id
    ]
    evaluationFrequency: 'PT1H'
    windowSize: 'PT1H'
    criteria: {
      'odata.type': 'Microsoft.Azure.Monitor.SingleResourceMultipleMetricCriteria'
      allOf: [
        {
          name: 'DataIngestion'
          metricName: 'Usage'
          dimensions: []
          operator: 'GreaterThan'
          threshold: 5000
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

// Scheduled Query Alert for error rate spike detection
resource scheduledQueryAlert 'Microsoft.Insights/scheduledQueryRules@2023-03-15-preview' = {
  name: '${alertRuleName}-errors'
  location: location
  tags: commonTags
  properties: {
    displayName: 'Error Rate Spike Detection'
    description: 'Alert when error rate exceeds 10% of total requests in the last hour'
    severity: 2
    enabled: true
    scopes: [
      logAnalyticsWorkspace.id
    ]
    evaluationFrequency: 'PT15M'
    windowSize: 'PT1H'
    criteria: {
      allOf: [
        {
          query: 'AppRequests | summarize Total = count(), Errors = countif(Success == false) | extend ErrorRate = todouble(Errors) / todouble(Total) * 100 | where ErrorRate > 10'
          timeAggregation: 'Count'
          dimensions: []
          operator: 'GreaterThan'
          threshold: 0
          failingPeriods: {
            numberOfEvaluationPeriods: 1
            minFailingPeriodsToAlert: 1
          }
        }
      ]
    }
    actions: {
      actionGroups: [
        actionGroup.id
      ]
    }
  }
}

// ============================================================================
// WORKBOOK
// ============================================================================

resource workbook 'Microsoft.Insights/workbooks@2023-06-01' = {
  name: guid(resourceGroup().id, 'monitoring-workbook')
  location: location
  tags: commonTags
  kind: 'shared'
  properties: {
    displayName: 'Azure Monitor Baseline Dashboard'
    description: 'Overview dashboard for monitoring baseline metrics'
    category: 'sentinel'
    serializedData: '{"version":"Notebook/1.0","items":[{"type":1,"content":{"json":"## Azure Monitor Baseline\\n\\nOverview of Log Analytics workspace and Application Insights metrics"},"name":"text - 0"},{"type":3,"content":{"version":"KqlItem/1.0","query":"Usage | summarize DataIngestion = sum(Quantity) by bin(TimeGenerated, 1h) | order by TimeGenerated desc","size":0,"title":"Data Ingestion (Last 24 Hours)","timeContext":{"durationMs":86400000},"queryType":0,"resourceType":"microsoft.operationalinsights/workspaces"},"name":"query - 1"},{"type":3,"content":{"version":"KqlItem/1.0","query":"AppRequests | summarize TotalRequests = count(), FailedRequests = countif(Success == false) by bin(TimeGenerated, 1h) | extend SuccessRate = (TotalRequests - FailedRequests) * 100.0 / TotalRequests | project TimeGenerated, SuccessRate","size":0,"title":"Request Success Rate (%)","timeContext":{"durationMs":86400000},"queryType":0,"resourceType":"microsoft.insights/components"},"name":"query - 2"},{"type":3,"content":{"version":"KqlItem/1.0","query":"AppDependencies | summarize AvgDuration = avg(DurationMs) by bin(TimeGenerated, 1h) | order by TimeGenerated desc","size":0,"title":"Average Dependency Duration (ms)","timeContext":{"durationMs":86400000},"queryType":0,"resourceType":"microsoft.insights/components"},"name":"query - 3"}],"styleSettings":{},"fromTemplateId":"sentinel-UserWorkbook"}'
    sourceId: logAnalyticsWorkspace.id
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

@description('Workbook ID')
output workbookId string = workbook.id

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
