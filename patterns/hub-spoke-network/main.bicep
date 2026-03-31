@description('Azure region for all resources')
param location string = resourceGroup().location

@description('Prefix for resource names')
param prefix string = 'demo'

@description('Tags to apply to all resources')
param tags object = {
  owner: 'demo-user'
  workload: 'hub-spoke-network'
  environment: 'dev'
  ttlHours: '24'
}

@description('Deploy Azure Firewall in the hub')
param deployFirewall bool = true

@description('Deploy VPN Gateway in the hub')
param deployVpnGateway bool = false

@description('Hub VNet address prefix')
param hubAddressPrefix string = '10.0.0.0/16'

@description('Spoke 1 VNet address prefix')
param spoke1AddressPrefix string = '10.1.0.0/16'

@description('Spoke 2 VNet address prefix')
param spoke2AddressPrefix string = '10.2.0.0/16'

// Hub Virtual Network
resource hubVnet 'Microsoft.Network/virtualNetworks@2023-05-01' = {
  name: '${prefix}-hub-vnet'
  location: location
  tags: tags
  properties: {
    addressSpace: {
      addressPrefixes: [
        hubAddressPrefix
      ]
    }
    subnets: [
      {
        name: 'AzureFirewallSubnet'
        properties: {
          addressPrefix: cidrSubnet(hubAddressPrefix, 26, 0)
        }
      }
      {
        name: 'GatewaySubnet'
        properties: {
          addressPrefix: cidrSubnet(hubAddressPrefix, 27, 2)
        }
      }
      {
        name: 'ManagementSubnet'
        properties: {
          addressPrefix: cidrSubnet(hubAddressPrefix, 24, 1)
          networkSecurityGroup: {
            id: hubMgmtNsg.id
          }
        }
      }
    ]
  }
}

// Hub Management NSG
resource hubMgmtNsg 'Microsoft.Network/networkSecurityGroups@2023-05-01' = {
  name: '${prefix}-hub-mgmt-nsg'
  location: location
  tags: tags
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

// Spoke 1 Virtual Network
resource spoke1Vnet 'Microsoft.Network/virtualNetworks@2023-05-01' = {
  name: '${prefix}-spoke1-vnet'
  location: location
  tags: tags
  properties: {
    addressSpace: {
      addressPrefixes: [
        spoke1AddressPrefix
      ]
    }
    subnets: [
      {
        name: 'default'
        properties: {
          addressPrefix: cidrSubnet(spoke1AddressPrefix, 24, 0)
          networkSecurityGroup: {
            id: spoke1Nsg.id
          }
          routeTable: deployFirewall ? {
            id: spoke1RouteTable.id
          } : null
        }
      }
    ]
  }
}

// Spoke 1 NSG
resource spoke1Nsg 'Microsoft.Network/networkSecurityGroups@2023-05-01' = {
  name: '${prefix}-spoke1-nsg'
  location: location
  tags: tags
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

// Spoke 1 Route Table
resource spoke1RouteTable 'Microsoft.Network/routeTables@2023-05-01' = if (deployFirewall) {
  name: '${prefix}-spoke1-rt'
  location: location
  tags: tags
  properties: {
    routes: [
      {
        name: 'default-via-firewall'
        properties: {
          addressPrefix: '0.0.0.0/0'
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: firewall.properties.ipConfigurations[0].properties.privateIPAddress
        }
      }
    ]
  }
}

// Spoke 2 Virtual Network
resource spoke2Vnet 'Microsoft.Network/virtualNetworks@2023-05-01' = {
  name: '${prefix}-spoke2-vnet'
  location: location
  tags: tags
  properties: {
    addressSpace: {
      addressPrefixes: [
        spoke2AddressPrefix
      ]
    }
    subnets: [
      {
        name: 'default'
        properties: {
          addressPrefix: cidrSubnet(spoke2AddressPrefix, 24, 0)
          networkSecurityGroup: {
            id: spoke2Nsg.id
          }
          routeTable: deployFirewall ? {
            id: spoke2RouteTable.id
          } : null
        }
      }
    ]
  }
}

// Spoke 2 NSG
resource spoke2Nsg 'Microsoft.Network/networkSecurityGroups@2023-05-01' = {
  name: '${prefix}-spoke2-nsg'
  location: location
  tags: tags
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

// Spoke 2 Route Table
resource spoke2RouteTable 'Microsoft.Network/routeTables@2023-05-01' = if (deployFirewall) {
  name: '${prefix}-spoke2-rt'
  location: location
  tags: tags
  properties: {
    routes: [
      {
        name: 'default-via-firewall'
        properties: {
          addressPrefix: '0.0.0.0/0'
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: firewall.properties.ipConfigurations[0].properties.privateIPAddress
        }
      }
    ]
  }
}

// Hub to Spoke1 Peering
resource hubToSpoke1Peering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2023-05-01' = {
  parent: hubVnet
  name: 'hub-to-spoke1'
  properties: {
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    allowGatewayTransit: deployVpnGateway
    useRemoteGateways: false
    remoteVirtualNetwork: {
      id: spoke1Vnet.id
    }
  }
}

// Spoke1 to Hub Peering
resource spoke1ToHubPeering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2023-05-01' = {
  parent: spoke1Vnet
  name: 'spoke1-to-hub'
  properties: {
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    allowGatewayTransit: false
    useRemoteGateways: deployVpnGateway
    remoteVirtualNetwork: {
      id: hubVnet.id
    }
  }
}

// Hub to Spoke2 Peering
resource hubToSpoke2Peering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2023-05-01' = {
  parent: hubVnet
  name: 'hub-to-spoke2'
  properties: {
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    allowGatewayTransit: deployVpnGateway
    useRemoteGateways: false
    remoteVirtualNetwork: {
      id: spoke2Vnet.id
    }
  }
}

// Spoke2 to Hub Peering
resource spoke2ToHubPeering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2023-05-01' = {
  parent: spoke2Vnet
  name: 'spoke2-to-hub'
  properties: {
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    allowGatewayTransit: false
    useRemoteGateways: deployVpnGateway
    remoteVirtualNetwork: {
      id: hubVnet.id
    }
  }
}

// Firewall Public IP
resource firewallPublicIp 'Microsoft.Network/publicIPAddresses@2023-05-01' = if (deployFirewall) {
  name: '${prefix}-fw-pip'
  location: location
  tags: tags
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
    publicIPAddressVersion: 'IPv4'
  }
}

// Azure Firewall
resource firewall 'Microsoft.Network/azureFirewalls@2023-05-01' = if (deployFirewall) {
  name: '${prefix}-hub-fw'
  location: location
  tags: tags
  properties: {
    sku: {
      name: 'AZFW_VNet'
      tier: 'Standard'
    }
    ipConfigurations: [
      {
        name: 'firewallConfig'
        properties: {
          subnet: {
            id: '${hubVnet.id}/subnets/AzureFirewallSubnet'
          }
          publicIPAddress: {
            id: firewallPublicIp.id
          }
        }
      }
    ]
    networkRuleCollections: [
      {
        name: 'spoke-to-spoke'
        properties: {
          priority: 100
          action: {
            type: 'Allow'
          }
          rules: [
            {
              name: 'allow-spoke-traffic'
              protocols: [
                'Any'
              ]
              sourceAddresses: [
                spoke1AddressPrefix
                spoke2AddressPrefix
              ]
              destinationAddresses: [
                spoke1AddressPrefix
                spoke2AddressPrefix
              ]
              destinationPorts: [
                '*'
              ]
            }
          ]
        }
      }
    ]
  }
}

// VPN Gateway Public IP
resource vpnGatewayPublicIp 'Microsoft.Network/publicIPAddresses@2023-05-01' = if (deployVpnGateway) {
  name: '${prefix}-vpngw-pip'
  location: location
  tags: tags
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
    publicIPAddressVersion: 'IPv4'
  }
}

// VPN Gateway
resource vpnGateway 'Microsoft.Network/virtualNetworkGateways@2023-05-01' = if (deployVpnGateway) {
  name: '${prefix}-hub-vpngw'
  location: location
  tags: tags
  properties: {
    gatewayType: 'Vpn'
    vpnType: 'RouteBased'
    sku: {
      name: 'VpnGw1'
      tier: 'VpnGw1'
    }
    ipConfigurations: [
      {
        name: 'vpnGatewayConfig'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: '${hubVnet.id}/subnets/GatewaySubnet'
          }
          publicIPAddress: {
            id: vpnGatewayPublicIp.id
          }
        }
      }
    ]
  }
}

// Outputs
output hubVnetId string = hubVnet.id
output spoke1VnetId string = spoke1Vnet.id
output spoke2VnetId string = spoke2Vnet.id
output firewallPrivateIp string = deployFirewall ? firewall.properties.ipConfigurations[0].properties.privateIPAddress : 'not-deployed'
output firewallPublicIp string = deployFirewall ? firewallPublicIp.properties.ipAddress : 'not-deployed'
output vpnGatewayId string = deployVpnGateway ? vpnGateway.id : 'not-deployed'
