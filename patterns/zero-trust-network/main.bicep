// Zero Trust Network Access
// Comprehensive security with App Gateway, WAF, Private Link, NSG, and Firewall

@description('Azure region for deployment')
param location string = resourceGroup().location

@description('Prefix for resource naming')
param prefix string = 'demo'

@description('Resource tags')
param tags object = {
  owner: 'pattern-demo'
  workload: 'zero-trust-network'
  environment: 'demo'
  ttlHours: '24'
}

@description('Virtual Network address prefix')
param vnetAddressPrefix string = '10.0.0.0/16'

@description('Application Gateway subnet prefix')
param appGwSubnetPrefix string = '10.0.1.0/24'

@description('Firewall subnet prefix')
param firewallSubnetPrefix string = '10.0.2.0/24'

@description('Application subnet prefix (with VNet integration delegation)')
param appSubnetPrefix string = '10.0.3.0/24'

@description('Private Endpoint subnet prefix')
param privateEndpointSubnetPrefix string = '10.0.4.0/24'

@description('Enable WAF in Prevention mode (vs Detection)')
param enableWafPrevention bool = true

@description('Deployment timestamp')
param deploymentTime string = utcNow('u')

// ============================================================================
// VARIABLES
// ============================================================================

var resourceSuffix = '${prefix}-${uniqueString(resourceGroup().id)}'
var commonTags = union(tags, {
  deployedAt: deploymentTime
  pattern: 'zero-trust-network'
})

var vnetName = 'vnet-${resourceSuffix}'
var nsgAppGwName = 'nsg-appgw-${resourceSuffix}'
var nsgAppName = 'nsg-app-${resourceSuffix}'
var nsgPeSubnetName = 'nsg-pe-${resourceSuffix}'
var appGwName = 'agw-${resourceSuffix}'
var appGwPublicIpName = 'pip-agw-${resourceSuffix}'
var firewallName = 'fw-${resourceSuffix}'
var firewallPublicIpName = 'pip-fw-${resourceSuffix}'
var wafPolicyName = 'waf-${resourceSuffix}'
var logAnalyticsName = 'log-${resourceSuffix}'
var routeTableName = 'rt-app-${resourceSuffix}'
var appServicePlanName = 'asp-${resourceSuffix}'
var webAppName = 'app-${uniqueString(resourceGroup().id)}'
var privateEndpointName = 'pe-webapp-${resourceSuffix}'
var privateDnsZoneName = 'privatelink.azurewebsites.net'

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
// NETWORK SECURITY GROUPS
// ============================================================================

resource nsgAppGw 'Microsoft.Network/networkSecurityGroups@2023-05-01' = {
  name: nsgAppGwName
  location: location
  tags: commonTags
  properties: {
    securityRules: [
      {
        name: 'AllowGatewayManager'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '65200-65535'
          sourceAddressPrefix: 'GatewayManager'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 100
          direction: 'Inbound'
        }
      }
      {
        name: 'AllowHTTPS'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '443'
          sourceAddressPrefix: 'Internet'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 110
          direction: 'Inbound'
        }
      }
      {
        name: 'AllowHTTP'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '80'
          sourceAddressPrefix: 'Internet'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 120
          direction: 'Inbound'
        }
      }
    ]
  }
}

resource nsgApp 'Microsoft.Network/networkSecurityGroups@2023-05-01' = {
  name: nsgAppName
  location: location
  tags: commonTags
  properties: {
    securityRules: [
      {
        name: 'AllowVNetInbound'
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

resource nsgPeSubnet 'Microsoft.Network/networkSecurityGroups@2023-05-01' = {
  name: nsgPeSubnetName
  location: location
  tags: commonTags
  properties: {
    securityRules: [
      {
        name: 'AllowVNetInbound'
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

// ============================================================================
// ROUTE TABLE
// ============================================================================

resource routeTable 'Microsoft.Network/routeTables@2023-05-01' = {
  name: routeTableName
  location: location
  tags: commonTags
  properties: {
    routes: []
  }
}

// ============================================================================
// VIRTUAL NETWORK
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
        name: 'AppGatewaySubnet'
        properties: {
          addressPrefix: appGwSubnetPrefix
          networkSecurityGroup: {
            id: nsgAppGw.id
          }
        }
      }
      {
        name: 'AzureFirewallSubnet'
        properties: {
          addressPrefix: firewallSubnetPrefix
        }
      }
      {
        name: 'AppIntegrationSubnet'
        properties: {
          addressPrefix: appSubnetPrefix
          networkSecurityGroup: {
            id: nsgApp.id
          }
          routeTable: {
            id: routeTable.id
          }
          delegations: [
            {
              name: 'delegation'
              properties: {
                serviceName: 'Microsoft.Web/serverFarms'
              }
            }
          ]
        }
      }
      {
        name: 'PrivateEndpointSubnet'
        properties: {
          addressPrefix: privateEndpointSubnetPrefix
          networkSecurityGroup: {
            id: nsgPeSubnet.id
          }
          privateEndpointNetworkPolicies: 'Disabled'
        }
      }
    ]
  }
}

// ============================================================================
// WAF POLICY
// ============================================================================

resource wafPolicy 'Microsoft.Network/ApplicationGatewayWebApplicationFirewallPolicies@2023-05-01' = {
  name: wafPolicyName
  location: location
  tags: commonTags
  properties: {
    policySettings: {
      requestBodyCheck: true
      maxRequestBodySizeInKb: 128
      fileUploadLimitInMb: 100
      mode: enableWafPrevention ? 'Prevention' : 'Detection'
      state: 'Enabled'
    }
    managedRules: {
      managedRuleSets: [
        {
          ruleSetType: 'OWASP'
          ruleSetVersion: '3.2'
        }
      ]
    }
  }
}

// ============================================================================
// APPLICATION GATEWAY
// ============================================================================

resource appGwPublicIp 'Microsoft.Network/publicIPAddresses@2023-05-01' = {
  name: appGwPublicIpName
  location: location
  tags: commonTags
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
    dnsSettings: {
      domainNameLabel: toLower('agw-${uniqueString(resourceGroup().id)}')
    }
  }
}

resource applicationGateway 'Microsoft.Network/applicationGateways@2023-05-01' = {
  name: appGwName
  location: location
  tags: commonTags
  properties: {
    sku: {
      name: 'WAF_v2'
      tier: 'WAF_v2'
      capacity: 2
    }
    gatewayIPConfigurations: [
      {
        name: 'appGwIpConfig'
        properties: {
          subnet: {
            id: '${virtualNetwork.id}/subnets/AppGatewaySubnet'
          }
        }
      }
    ]
    frontendIPConfigurations: [
      {
        name: 'appGwPublicFrontendIp'
        properties: {
          publicIPAddress: {
            id: appGwPublicIp.id
          }
        }
      }
    ]
    frontendPorts: [
      {
        name: 'port80'
        properties: {
          port: 80
        }
      }
      {
        name: 'port443'
        properties: {
          port: 443
        }
      }
    ]
    backendAddressPools: [
      {
        name: 'appBackendPool'
        properties: {
          backendAddresses: [
            {
              fqdn: webApp.properties.defaultHostName
            }
          ]
        }
      }
    ]
    backendHttpSettingsCollection: [
      {
        name: 'appBackendHttpSettings'
        properties: {
          port: 443
          protocol: 'Https'
          cookieBasedAffinity: 'Disabled'
          requestTimeout: 30
          pickHostNameFromBackendAddress: true
          probe: {
            id: resourceId('Microsoft.Network/applicationGateways/probes', appGwName, 'appHealthProbe')
          }
        }
      }
    ]
    httpListeners: [
      {
        name: 'appListener'
        properties: {
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendIPConfigurations', appGwName, 'appGwPublicFrontendIp')
          }
          frontendPort: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendPorts', appGwName, 'port80')
          }
          protocol: 'Http'
        }
      }
    ]
    requestRoutingRules: [
      {
        name: 'appRoutingRule'
        properties: {
          ruleType: 'Basic'
          priority: 100
          httpListener: {
            id: resourceId('Microsoft.Network/applicationGateways/httpListeners', appGwName, 'appListener')
          }
          backendAddressPool: {
            id: resourceId('Microsoft.Network/applicationGateways/backendAddressPools', appGwName, 'appBackendPool')
          }
          backendHttpSettings: {
            id: resourceId('Microsoft.Network/applicationGateways/backendHttpSettingsCollection', appGwName, 'appBackendHttpSettings')
          }
        }
      }
    ]
    probes: [
      {
        name: 'appHealthProbe'
        properties: {
          protocol: 'Https'
          path: '/'
          interval: 30
          timeout: 30
          unhealthyThreshold: 3
          pickHostNameFromBackendHttpSettings: true
        }
      }
    ]
    webApplicationFirewallConfiguration: {
      enabled: true
      firewallMode: enableWafPrevention ? 'Prevention' : 'Detection'
      ruleSetType: 'OWASP'
      ruleSetVersion: '3.2'
    }
    firewallPolicy: {
      id: wafPolicy.id
    }
  }
}

// ============================================================================
// AZURE FIREWALL
// ============================================================================

resource firewallPublicIp 'Microsoft.Network/publicIPAddresses@2023-05-01' = {
  name: firewallPublicIpName
  location: location
  tags: commonTags
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

resource firewall 'Microsoft.Network/azureFirewalls@2023-05-01' = {
  name: firewallName
  location: location
  tags: commonTags
  properties: {
    sku: {
      name: 'AZFW_VNet'
      tier: 'Standard'
    }
    ipConfigurations: [
      {
        name: 'firewallIpConfig'
        properties: {
          subnet: {
            id: '${virtualNetwork.id}/subnets/AzureFirewallSubnet'
          }
          publicIPAddress: {
            id: firewallPublicIp.id
          }
        }
      }
    ]
    networkRuleCollections: [
      {
        name: 'AllowWebTraffic'
        properties: {
          priority: 100
          action: {
            type: 'Allow'
          }
          rules: [
            {
              name: 'AllowHTTP'
              protocols: [
                'TCP'
              ]
              sourceAddresses: [
                appSubnetPrefix
              ]
              destinationAddresses: [
                '*'
              ]
              destinationPorts: [
                '80'
                '443'
              ]
            }
          ]
        }
      }
    ]
    applicationRuleCollections: [
      {
        name: 'AllowAzureServices'
        properties: {
          priority: 200
          action: {
            type: 'Allow'
          }
          rules: [
            {
              name: 'AllowWindowsUpdate'
              protocols: [
                {
                  protocolType: 'Http'
                  port: 80
                }
                {
                  protocolType: 'Https'
                  port: 443
                }
              ]
              sourceAddresses: [
                appSubnetPrefix
              ]
              targetFqdns: [
                '*.microsoft.com'
                '*.windows.com'
                '*.azure.com'
              ]
            }
          ]
        }
      }
    ]
  }
}

// Update route table with firewall IP after firewall is deployed
resource routeToFirewall 'Microsoft.Network/routeTables/routes@2023-05-01' = {
  parent: routeTable
  name: 'route-to-firewall'
  properties: {
    addressPrefix: '0.0.0.0/0'
    nextHopType: 'VirtualAppliance'
    nextHopIpAddress: firewall.properties.ipConfigurations[0].properties.privateIPAddress
  }
}

// ============================================================================
// APP SERVICE PLAN & WEB APP
// ============================================================================

resource appServicePlan 'Microsoft.Web/serverfarms@2023-01-01' = {
  name: appServicePlanName
  location: location
  tags: commonTags
  sku: {
    name: 'B1'
    tier: 'Basic'
    size: 'B1'
    family: 'B'
    capacity: 1
  }
  kind: 'linux'
  properties: {
    reserved: true
  }
}

resource webApp 'Microsoft.Web/sites@2023-01-01' = {
  name: webAppName
  location: location
  tags: commonTags
  kind: 'app,linux'
  properties: {
    serverFarmId: appServicePlan.id
    httpsOnly: true
    virtualNetworkSubnetId: '${virtualNetwork.id}/subnets/AppIntegrationSubnet'
    publicNetworkAccess: 'Disabled'
    siteConfig: {
      linuxFxVersion: 'NODE|20-lts'
      alwaysOn: true
      minTlsVersion: '1.2'
      ftpsState: 'Disabled'
      http20Enabled: true
      vnetRouteAllEnabled: true
    }
  }
}

// ============================================================================
// PRIVATE DNS ZONE
// ============================================================================

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
// PRIVATE ENDPOINT
// ============================================================================

resource privateEndpoint 'Microsoft.Network/privateEndpoints@2023-05-01' = {
  name: privateEndpointName
  location: location
  tags: commonTags
  properties: {
    subnet: {
      id: '${virtualNetwork.id}/subnets/PrivateEndpointSubnet'
    }
    privateLinkServiceConnections: [
      {
        name: 'webapp-connection'
        properties: {
          privateLinkServiceId: webApp.id
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

@description('Virtual Network ID')
output vnetId string = virtualNetwork.id

@description('Application Gateway public IP address')
output appGatewayPublicIp string = appGwPublicIp.properties.ipAddress

@description('Application Gateway FQDN')
output appGatewayFqdn string = appGwPublicIp.properties.dnsSettings.fqdn

@description('Azure Firewall private IP address')
output firewallPrivateIp string = firewall.properties.ipConfigurations[0].properties.privateIPAddress

@description('Web App name')
output webAppName string = webApp.name

@description('Web App default hostname (internal)')
output webAppHostName string = webApp.properties.defaultHostName

@description('Private Endpoint ID')
output webAppPrivateEndpoint string = privateEndpoint.id

@description('Private DNS Zone name')
output privateDnsZoneName string = privateDnsZone.name

@description('WAF Policy mode')
output wafMode string = enableWafPrevention ? 'Prevention' : 'Detection'

@description('List of deployed resources')
output deployedResources array = [
  {
    type: 'Microsoft.Network/virtualNetworks'
    name: virtualNetwork.name
    id: virtualNetwork.id
  }
  {
    type: 'Microsoft.Network/networkSecurityGroups'
    name: nsgAppGw.name
    id: nsgAppGw.id
  }
  {
    type: 'Microsoft.Network/networkSecurityGroups'
    name: nsgApp.name
    id: nsgApp.id
  }
  {
    type: 'Microsoft.Network/networkSecurityGroups'
    name: nsgPeSubnet.name
    id: nsgPeSubnet.id
  }
  {
    type: 'Microsoft.Network/routeTables'
    name: routeTable.name
    id: routeTable.id
  }
  {
    type: 'Microsoft.Network/applicationGateways'
    name: applicationGateway.name
    id: applicationGateway.id
  }
  {
    type: 'Microsoft.Network/ApplicationGatewayWebApplicationFirewallPolicies'
    name: wafPolicy.name
    id: wafPolicy.id
  }
  {
    type: 'Microsoft.Network/azureFirewalls'
    name: firewall.name
    id: firewall.id
  }
  {
    type: 'Microsoft.Web/serverfarms'
    name: appServicePlan.name
    id: appServicePlan.id
  }
  {
    type: 'Microsoft.Web/sites'
    name: webApp.name
    id: webApp.id
  }
  {
    type: 'Microsoft.Network/privateEndpoints'
    name: privateEndpoint.name
    id: privateEndpoint.id
  }
  {
    type: 'Microsoft.Network/privateDnsZones'
    name: privateDnsZone.name
    id: privateDnsZone.id
  }
  {
    type: 'Microsoft.OperationalInsights/workspaces'
    name: logAnalytics.name
    id: logAnalytics.id
  }
]

@description('Deployment timestamp')
output deploymentTimestamp string = deploymentTime
