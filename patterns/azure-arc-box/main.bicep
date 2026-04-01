@description('Azure region for all resources')
param location string = resourceGroup().location

@description('Prefix for resource names')
param prefix string = 'arcbox'

@description('Tags to apply to all resources')
param tags object = {
  owner: 'demo-user'
  workload: 'azure-arc-box'
  environment: 'dev'
  ttlHours: '48'
}

@description('Administrator username for VMs')
param adminUsername string = 'arcadmin'

@description('Administrator password for VMs')
@secure()
param adminPassword string

@description('Deploy Linux VM for Arc Servers demonstration')
param deployLinuxVM bool = true

@description('Deploy SQL Server VM for Arc-enabled SQL demonstration')
param deploySqlVM bool = true

@description('VM size for all VMs')
param vmSize string = 'Standard_B2ms'

@description('Virtual network address prefix')
param vnetAddressPrefix string = '10.0.0.0/16'

@description('Subnet address prefix')
param subnetAddressPrefix string = '10.0.1.0/24'

// Variables
var uniqueSuffix = uniqueString(resourceGroup().id)
var vnetName = '${prefix}-vnet'
var subnetName = 'default'
var nsgName = '${prefix}-nsg'
var workspaceName = '${prefix}-law-${uniqueSuffix}'
var windowsVmName = '${prefix}-win-vm'
var linuxVmName = '${prefix}-linux-vm'
var sqlVmName = '${prefix}-sql-vm'
var windowsPublicIpName = '${prefix}-win-pip'
var linuxPublicIpName = '${prefix}-linux-pip'
var sqlPublicIpName = '${prefix}-sql-pip'
var windowsNicName = '${prefix}-win-nic'
var linuxNicName = '${prefix}-linux-nic'
var sqlNicName = '${prefix}-sql-nic'

// Network Security Group
resource nsg 'Microsoft.Network/networkSecurityGroups@2023-05-01' = {
  name: nsgName
  location: location
  tags: tags
  properties: {
    securityRules: [
      {
        name: 'AllowRDP'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '3389'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 100
          direction: 'Inbound'
          description: 'Allow RDP for demo purposes. WARNING: This is insecure for production. Restrict sourceAddressPrefix to your IP or use Azure Bastion.'
        }
      }
      {
        name: 'AllowSSH'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '22'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 110
          direction: 'Inbound'
          description: 'Allow SSH for demo purposes. WARNING: This is insecure for production. Restrict sourceAddressPrefix to your IP or use Azure Bastion.'
        }
      }
      {
        name: 'AllowHTTPS'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '443'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 120
          direction: 'Inbound'
          description: 'Allow HTTPS for Arc agent connectivity'
        }
      }
    ]
  }
}

// Virtual Network
resource vnet 'Microsoft.Network/virtualNetworks@2023-05-01' = {
  name: vnetName
  location: location
  tags: tags
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetAddressPrefix
      ]
    }
    subnets: [
      {
        name: subnetName
        properties: {
          addressPrefix: subnetAddressPrefix
          networkSecurityGroup: {
            id: nsg.id
          }
        }
      }
    ]
  }
}

// Log Analytics Workspace
resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: workspaceName
  location: location
  tags: tags
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: 30
    features: {
      enableLogAccessUsingOnlyResourcePermissions: true
    }
  }
}

// Windows VM Public IP
resource windowsPublicIp 'Microsoft.Network/publicIPAddresses@2023-05-01' = {
  name: windowsPublicIpName
  location: location
  tags: tags
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
    publicIPAddressVersion: 'IPv4'
    dnsSettings: {
      domainNameLabel: '${windowsVmName}-${uniqueSuffix}'
    }
  }
}

// Windows VM NIC
resource windowsNic 'Microsoft.Network/networkInterfaces@2023-05-01' = {
  name: windowsNicName
  location: location
  tags: tags
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: windowsPublicIp.id
          }
          subnet: {
            id: '${vnet.id}/subnets/${subnetName}'
          }
        }
      }
    ]
  }
}

// Windows Server VM
resource windowsVm 'Microsoft.Compute/virtualMachines@2023-09-01' = {
  name: windowsVmName
  location: location
  tags: tags
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    osProfile: {
      computerName: windowsVmName
      adminUsername: adminUsername
      adminPassword: adminPassword
      windowsConfiguration: {
        provisionVMAgent: true
        enableAutomaticUpdates: true
        patchSettings: {
          patchMode: 'AutomaticByPlatform'
          automaticByPlatformSettings: {
            rebootSetting: 'IfRequired'
          }
        }
      }
    }
    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: '2022-datacenter-azure-edition'
        version: 'latest'
      }
      osDisk: {
        name: '${windowsVmName}-osdisk'
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'Premium_LRS'
        }
        deleteOption: 'Delete'
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: windowsNic.id
          properties: {
            deleteOption: 'Delete'
          }
        }
      ]
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
      }
    }
  }
}

// Linux VM Public IP
resource linuxPublicIp 'Microsoft.Network/publicIPAddresses@2023-05-01' = if (deployLinuxVM) {
  name: linuxPublicIpName
  location: location
  tags: tags
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
    publicIPAddressVersion: 'IPv4'
    dnsSettings: {
      domainNameLabel: '${linuxVmName}-${uniqueSuffix}'
    }
  }
}

// Linux VM NIC
resource linuxNic 'Microsoft.Network/networkInterfaces@2023-05-01' = if (deployLinuxVM) {
  name: linuxNicName
  location: location
  tags: tags
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: linuxPublicIp.id
          }
          subnet: {
            id: '${vnet.id}/subnets/${subnetName}'
          }
        }
      }
    ]
  }
}

// Linux Ubuntu VM
resource linuxVm 'Microsoft.Compute/virtualMachines@2023-09-01' = if (deployLinuxVM) {
  name: linuxVmName
  location: location
  tags: tags
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    osProfile: {
      computerName: linuxVmName
      adminUsername: adminUsername
      adminPassword: adminPassword
      linuxConfiguration: {
        disablePasswordAuthentication: false
        provisionVMAgent: true
        patchSettings: {
          patchMode: 'AutomaticByPlatform'
          automaticByPlatformSettings: {
            rebootSetting: 'IfRequired'
          }
        }
      }
    }
    storageProfile: {
      imageReference: {
        publisher: 'Canonical'
        offer: '0001-com-ubuntu-server-jammy'
        sku: '22_04-lts-gen2'
        version: 'latest'
      }
      osDisk: {
        name: '${linuxVmName}-osdisk'
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'Premium_LRS'
        }
        deleteOption: 'Delete'
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: linuxNic.id
          properties: {
            deleteOption: 'Delete'
          }
        }
      ]
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
      }
    }
  }
}

// SQL Server VM Public IP
resource sqlPublicIp 'Microsoft.Network/publicIPAddresses@2023-05-01' = if (deploySqlVM) {
  name: sqlPublicIpName
  location: location
  tags: tags
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
    publicIPAddressVersion: 'IPv4'
    dnsSettings: {
      domainNameLabel: '${sqlVmName}-${uniqueSuffix}'
    }
  }
}

// SQL Server VM NIC
resource sqlNic 'Microsoft.Network/networkInterfaces@2023-05-01' = if (deploySqlVM) {
  name: sqlNicName
  location: location
  tags: tags
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: sqlPublicIp.id
          }
          subnet: {
            id: '${vnet.id}/subnets/${subnetName}'
          }
        }
      }
    ]
  }
}

// SQL Server VM
resource sqlVm 'Microsoft.Compute/virtualMachines@2023-09-01' = if (deploySqlVM) {
  name: sqlVmName
  location: location
  tags: tags
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    osProfile: {
      computerName: sqlVmName
      adminUsername: adminUsername
      adminPassword: adminPassword
      windowsConfiguration: {
        provisionVMAgent: true
        enableAutomaticUpdates: true
        patchSettings: {
          patchMode: 'AutomaticByPlatform'
          automaticByPlatformSettings: {
            rebootSetting: 'IfRequired'
          }
        }
      }
    }
    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftSQLServer'
        offer: 'sql2022-ws2022'
        sku: 'sqldev-gen2'
        version: 'latest'
      }
      osDisk: {
        name: '${sqlVmName}-osdisk'
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'Premium_LRS'
        }
        deleteOption: 'Delete'
      }
      dataDisks: [
        {
          name: '${sqlVmName}-datadisk'
          createOption: 'Empty'
          diskSizeGB: 128
          lun: 0
          managedDisk: {
            storageAccountType: 'Premium_LRS'
          }
          deleteOption: 'Delete'
        }
      ]
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: sqlNic.id
          properties: {
            deleteOption: 'Delete'
          }
        }
      ]
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
      }
    }
  }
}

// SQL VM Configuration
resource sqlVmConfig 'Microsoft.SqlVirtualMachine/sqlVirtualMachines@2022-08-01-preview' = if (deploySqlVM) {
  name: sqlVmName
  location: location
  tags: tags
  properties: {
    virtualMachineResourceId: sqlVm.id
    sqlManagement: 'Full'
    sqlServerLicenseType: 'PAYG'
    storageConfigurationSettings: {
      diskConfigurationType: 'NEW'
      storageWorkloadType: 'GENERAL'
      sqlDataSettings: {
        luns: [0]
        defaultFilePath: 'F:\\Data'
      }
      sqlLogSettings: {
        luns: [0]
        defaultFilePath: 'F:\\Log'
      }
    }
  }
}

// Outputs
output resourceGroupName string = resourceGroup().name
output vnetId string = vnet.id
output vnetName string = vnet.name
output workspaceId string = logAnalyticsWorkspace.id
output workspaceName string = logAnalyticsWorkspace.name
output windowsVmName string = windowsVm.name
output windowsVmPublicIp string = windowsPublicIp.properties.ipAddress
output windowsVmFqdn string = windowsPublicIp.properties.dnsSettings.fqdn
output linuxVmName string = deployLinuxVM ? linuxVm.name : 'not-deployed'
output linuxVmPublicIp string = deployLinuxVM ? reference(linuxPublicIp.id, '2023-05-01').ipAddress : 'not-deployed'
output linuxVmFqdn string = deployLinuxVM ? reference(linuxPublicIp.id, '2023-05-01').dnsSettings.fqdn : 'not-deployed'
output sqlVmName string = deploySqlVM ? sqlVm.name : 'not-deployed'
output sqlVmPublicIp string = deploySqlVM ? reference(sqlPublicIp.id, '2023-05-01').ipAddress : 'not-deployed'
output sqlVmFqdn string = deploySqlVM ? reference(sqlPublicIp.id, '2023-05-01').dnsSettings.fqdn : 'not-deployed'
output adminUsername string = adminUsername
