// Web App with Private Endpoint
// Secure App Service deployment with Private Link connectivity

@description('Azure region for deployment')
param location string = resourceGroup().location

@description('Prefix for resource naming')
param prefix string = 'demo'

@description('Resource tags')
param tags object = {
  owner: 'pattern-demo'
  workload: 'web-app-private-endpoint'
  environment: 'demo'
  ttlHours: '24'
}

@description('App Service Plan SKU (B1, B2, B3, S1, S2, S3, P1v2, P1v3)')
param appServiceSku string = 'B1'

@description('Virtual Network address prefix')
param vnetAddressPrefix string = '10.0.0.0/16'

@description('App integration subnet address prefix')
param appSubnetPrefix string = '10.0.1.0/24'

@description('Private Endpoint subnet address prefix')
param privateEndpointSubnetPrefix string = '10.0.2.0/24'

@description('Deployment timestamp')
param deploymentTime string = utcNow('u')

// ============================================================================
// VARIABLES
// ============================================================================

var resourceSuffix = '${prefix}-${uniqueString(resourceGroup().id)}'
var commonTags = union(tags, {
  deployedAt: deploymentTime
  pattern: 'web-app-private-endpoint'
})

var appServiceName = 'app-${resourceSuffix}'
var appServicePlanName = 'asp-${resourceSuffix}'
var vnetName = 'vnet-${resourceSuffix}'
var privateEndpointName = 'pe-${resourceSuffix}'
var privateDnsZoneName = 'privatelink.azurewebsites.net'
var nsgName = 'nsg-${resourceSuffix}'

// ============================================================================
// NETWORKING
// ============================================================================

// NSG for Private Endpoint subnet
resource nsg 'Microsoft.Network/networkSecurityGroups@2023-05-01' = {
  name: nsgName
  location: location
  tags: commonTags
  properties: {
    securityRules: [
      {
        name: 'AllowVnetInbound'
        properties: {
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: 'VirtualNetwork'
          access: 'Allow'
          priority: 100
          direction: 'Inbound'
        }
      }
      {
        name: 'DenyAllInbound'
        properties: {
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Deny'
          priority: 4096
          direction: 'Inbound'
        }
      }
    ]
  }
}

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
        name: 'AppIntegrationSubnet'
        properties: {
          addressPrefix: appSubnetPrefix
          delegations: [
            {
              name: 'appServiceDelegation'
              properties: {
                serviceName: 'Microsoft.Web/serverFarms'
              }
            }
          ]
          privateEndpointNetworkPolicies: 'Enabled'
        }
      }
      {
        name: 'PrivateEndpointSubnet'
        properties: {
          addressPrefix: privateEndpointSubnetPrefix
          networkSecurityGroup: {
            id: nsg.id
          }
          privateEndpointNetworkPolicies: 'Disabled'
        }
      }
    ]
  }
}

resource privateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: privateDnsZoneName
  location: 'global'
  tags: commonTags
}

resource privateDnsZoneLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: privateDnsZone
  name: '${vnetName}-link'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: virtualNetwork.id
    }
  }
}

// ============================================================================
// APP SERVICE
// ============================================================================

resource appServicePlan 'Microsoft.Web/serverfarms@2023-01-01' = {
  name: appServicePlanName
  location: location
  tags: commonTags
  sku: {
    name: appServiceSku
    tier: appServiceSku == 'B1' || appServiceSku == 'B2' || appServiceSku == 'B3' ? 'Basic' : (appServiceSku == 'S1' || appServiceSku == 'S2' || appServiceSku == 'S3' ? 'Standard' : 'PremiumV2')
  }
  kind: 'linux'
  properties: {
    reserved: true
  }
}

resource appService 'Microsoft.Web/sites@2023-01-01' = {
  name: appServiceName
  location: location
  tags: commonTags
  properties: {
    serverFarmId: appServicePlan.id
    httpsOnly: true
    publicNetworkAccess: 'Disabled'
    siteConfig: {
      linuxFxVersion: 'NODE|20-lts'
      ftpsState: 'Disabled'
      minTlsVersion: '1.2'
      http20Enabled: true
      alwaysOn: appServiceSku != 'B1' && appServiceSku != 'F1'
    }
    virtualNetworkSubnetId: virtualNetwork.properties.subnets[0].id
  }
}

// ============================================================================
// PRIVATE ENDPOINT
// ============================================================================

resource privateEndpoint 'Microsoft.Network/privateEndpoints@2023-05-01' = {
  name: privateEndpointName
  location: location
  tags: commonTags
  properties: {
    subnet: {
      id: virtualNetwork.properties.subnets[0].id
    }
    privateLinkServiceConnections: [
      {
        name: privateEndpointName
        properties: {
          privateLinkServiceId: appService.id
          groupIds: [
            'sites'
          ]
        }
      }
    ]
  }
}

resource privateDnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2023-05-01' = {
  parent: privateEndpoint
  name: 'default'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'config1'
        properties: {
          privateDnsZoneId: privateDnsZone.id
        }
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

@description('App Service name')
output appServiceName string = appService.name

@description('Web App URL (public endpoint - disabled)')
output webAppUrl string = 'https://${appService.properties.defaultHostName}'

@description('Web App private IP address')
output webAppPrivateIp string = privateEndpoint.properties.customDnsConfigs[0].ipAddresses[0]

@description('Virtual Network ID')
output vnetId string = virtualNetwork.id

@description('List of deployed resources')
output deployedResources array = [
  {
    type: 'Microsoft.Web/serverfarms'
    name: appServicePlan.name
    id: appServicePlan.id
  }
  {
    type: 'Microsoft.Web/sites'
    name: appService.name
    id: appService.id
  }
  {
    type: 'Microsoft.Network/virtualNetworks'
    name: virtualNetwork.name
    id: virtualNetwork.id
  }
  {
    type: 'Microsoft.Network/privateEndpoints'
    name: privateEndpoint.name
    id: privateEndpoint.id
  }
]

@description('Deployment timestamp')
output deploymentTimestamp string = deploymentTime
