// Landing Zone Foundation
// Subscription-level deployment: Management Groups, Policy, RBAC

targetScope = 'subscription'

@description('Prefix for resource naming')
param prefix string = 'demo'

@description('Management group prefix')
param managementGroupPrefix string = 'demo'

@description('Root management group display name')
param rootMgDisplayName string = 'Demo Organization'

@description('Resource tags')
param tags object = {
  owner: 'pattern-demo'
  workload: 'landing-zone-foundation'
  environment: 'demo'
  ttlHours: '24'
}

@description('Primary Azure region')
param location string = deployment().location

@description('Enable default Azure policies')
param enableDefaultPolicies bool = true

@description('Budget amount in USD')
param budgetAmount int = 1000

@description('Budget notification email')
param budgetNotificationEmail string = 'admin@example.com'

@description('Deployment timestamp')
param deploymentTime string = utcNow('u')

// ============================================================================
// VARIABLES
// ============================================================================

var commonTags = union(tags, {
  deployedAt: deploymentTime
  pattern: 'landing-zone-foundation'
})

// Use prefix for consistency (managementGroupPrefix for MG-specific naming)
var effectivePrefix = managementGroupPrefix

// Management group structure
var managementGroups = {
  platform: '${effectivePrefix}-platform'
  landingZones: '${effectivePrefix}-landingzones'
  sandbox: '${effectivePrefix}-sandbox'
  decommissioned: '${effectivePrefix}-decommissioned'
}

// ============================================================================
// RESOURCE GROUPS FOR SHARED RESOURCES
// ============================================================================

resource rgManagement 'Microsoft.Resources/resourceGroups@2023-07-01' = {
  name: 'rg-management'
  location: location
  tags: commonTags
}

resource rgConnectivity 'Microsoft.Resources/resourceGroups@2023-07-01' = {
  name: 'rg-connectivity'
  location: location
  tags: commonTags
}

resource rgSecurity 'Microsoft.Resources/resourceGroups@2023-07-01' = {
  name: 'rg-security'
  location: location
  tags: commonTags
}

// ============================================================================
// LOG ANALYTICS WORKSPACE
// ============================================================================

module logAnalyticsWorkspace 'br/public:avm/res/operational-insights/workspace:0.3.0' = {
  scope: rgManagement
  name: 'log-analytics-deployment'
  params: {
    name: 'log-${prefix}-${uniqueString(subscription().subscriptionId)}'
    location: location
    tags: commonTags
    dataRetention: 30
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
  }
}

// ============================================================================
// POLICY ASSIGNMENTS (Subscription Level)
// ============================================================================

resource policyAssignmentTags 'Microsoft.Authorization/policyAssignments@2023-04-01' = if (enableDefaultPolicies) {
  name: 'require-tag-on-resources'
  properties: {
    displayName: 'Require tag on resources'
    description: 'Enforces required tags on all resources'
    policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/96670d01-0a4d-4649-9c89-2d3abc0a5025'
    parameters: {
      tagName: {
        value: 'owner'
      }
    }
    enforcementMode: 'Default'
  }
}

resource policyAssignmentLocations 'Microsoft.Authorization/policyAssignments@2023-04-01' = if (enableDefaultPolicies) {
  name: 'allowed-locations'
  properties: {
    displayName: 'Allowed Azure regions'
    description: 'Restricts resource deployment to approved Azure regions'
    policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/e56962a6-4747-49cd-b67b-bf8b01975c4c'
    parameters: {
      listOfAllowedLocations: {
        value: [
          location
          'global'
        ]
      }
    }
    enforcementMode: 'Default'
  }
}

// ============================================================================
// BUDGET
// ============================================================================

resource budget 'Microsoft.Consumption/budgets@2023-11-01' = {
  name: 'monthly-budget'
  properties: {
    category: 'Cost'
    amount: budgetAmount
    timeGrain: 'Monthly'
    timePeriod: {
      startDate: '${utcNow('yyyy-MM')}-01'
    }
    notifications: {
      actual_GreaterThan_80_Percent: {
        enabled: true
        operator: 'GreaterThan'
        threshold: 80
        contactEmails: [
          budgetNotificationEmail
        ]
        thresholdType: 'Actual'
      }
      forecasted_GreaterThan_100_Percent: {
        enabled: true
        operator: 'GreaterThan'
        threshold: 100
        contactEmails: [
          budgetNotificationEmail
        ]
        thresholdType: 'Forecasted'
      }
    }
  }
}

// ============================================================================
// OUTPUTS
// ============================================================================

@description('Subscription ID')
output subscriptionId string = subscription().subscriptionId

@description('Management resource group name')
output managementResourceGroup string = rgManagement.name

@description('Connectivity resource group name')
output connectivityResourceGroup string = rgConnectivity.name

@description('Security resource group name')
output securityResourceGroup string = rgSecurity.name

@description('Log Analytics Workspace ID')
output logAnalyticsWorkspaceId string = logAnalyticsWorkspace.outputs.resourceId

@description('Management group structure')
output managementGroups object = managementGroups

@description('List of deployed resources')
output deployedResources array = [
  {
    type: 'Microsoft.Resources/resourceGroups'
    name: rgManagement.name
    id: rgManagement.id
  }
  {
    type: 'Microsoft.Resources/resourceGroups'
    name: rgConnectivity.name
    id: rgConnectivity.id
  }
  {
    type: 'Microsoft.Resources/resourceGroups'
    name: rgSecurity.name
    id: rgSecurity.id
  }
]

@description('Deployment timestamp')
output deploymentTimestamp string = deploymentTime

@description('Next steps')
output nextSteps string = '''
Landing Zone Foundation deployed successfully!

Next steps:
1. Review policy assignments in Azure Policy
2. Create additional management groups as needed
3. Assign users to appropriate RBAC roles
4. Deploy hub network in rg-connectivity
5. Configure Azure Security Center in rg-security
'''
