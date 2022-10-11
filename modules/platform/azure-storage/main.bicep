targetScope = 'resourceGroup'

@minLength(2)
@maxLength(5)
@description('Prefix to use for the Storage Account Name.')
param prefix string = 'sa'

@description('Resource Location.')
param location string = resourceGroup().location

@description('Enable lock to prevent accidental deletion')
param enableDeleteLock bool = false

@description('Tags.')
param tags object = {}

@description('Specifies the storage account sku type.')
@allowed([
  'Standard_LRS'
  'Premium_LRS'
  'Standard_GRS'
])
param sku string = 'Standard_LRS'

@description('Array of objects that describe RBAC permissions, format { roleDefinitionResourceId (string), principalId (string), principalType (enum), enabled (bool) }. Ref: https://docs.microsoft.com/en-us/azure/templates/microsoft.authorization/roleassignments?tabs=bicep')
param rbacPermissions array = [
  /* example
      {
        roleDefinitionResourceId: '/providers/Microsoft.Authorization/roleDefinitions/00482a5a-887f-4fb3-b363-3b7fe8e74483' // Key Vault Administrator
        principalId: '00000000-0000-0000-0000-000000000000' // az ad signed-in-user show --query objectId --output tsv
        principalType: 'User'
        enabled: false
      }
  */
]


var cleanPrefix = substring(prefix, 0, min(length(prefix), 5))
var unique = uniqueString(resourceGroup().id)
var name = '${cleanPrefix}${unique}'


// Create Storage Account
resource storage 'Microsoft.Storage/storageAccounts@2021-04-01' = {
  name: replace('${name}', '-', '')
  location: location
  tags: tags
  sku: {
    name: sku
  }
  kind: 'StorageV2'
  properties: {
    accessTier: 'Hot'

    networkAcls: enablePrivateLink ? {
      bypass: 'AzureServices'
      defaultAction: 'Deny'
    } : {}
  }
}

// Lock Resource
resource lock 'Microsoft.Authorization/locks@2017-04-01' = if (enableDeleteLock) {
  scope: storage

  name: '${storage.name}-lock'
  properties: {
    level: 'CanNotDelete'
  }
}

// Add role assignments
resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = [for item in rbacPermissions: if (item.enabled) {
  name: guid(storage.id, item.principalId, item.roleDefinitionResourceId)
  scope: storage
  properties: {
    roleDefinitionId: item.roleDefinitionResourceId
    principalId: item.principalId
    principalType: item.principalType
  }
}]

////////////////
// Private Link
////////////////

@description('Settings Required to Enable Private Link')
param privateLinkSettings object = {
  subnetId: '1' // Specify the Subnet for Private Endpoint
  vnetId: '1'  // Specify the Virtual Network for Virtual Network Link
}

var enablePrivateLink = privateLinkSettings.vnetId != '1' && privateLinkSettings.subnetId != '1'


@description('Specifies the name of the private link to the Azure Container Registry.')
param privateEndpointName string = 'storagePrivateEndpoint'

var publicDNSZoneForwarder = 'blob.${environment().suffixes.storage}'
var privateDnsZoneName = 'privatelink.${publicDNSZoneForwarder}'

resource privateDNSZone 'Microsoft.Network/privateDnsZones@2020-06-01' = if (enablePrivateLink) {
  name: privateDnsZoneName
  location: 'global'
  properties: {}
}

resource privateEndpoint 'Microsoft.Network/privateEndpoints@2022-01-01' = if (enablePrivateLink) {
  name: privateEndpointName
  location: location
  properties: {
    privateLinkServiceConnections: [
      {
        name: privateEndpointName
        properties: {
          privateLinkServiceId: storage.id
          groupIds: [
            'blob'
          ]
        }
      }
    ]
    subnet: {
      id: privateLinkSettings.subnetId
    }
  }
  dependsOn: [
    storage
  ]
}

resource privateDNSZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2022-01-01' = if (enablePrivateLink) {
  name: '${privateEndpoint.name}/dnsgroupname'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'dnsConfig'
        properties: {
          privateDnsZoneId: privateDNSZone.id
        }
      }
    ]
  }
  dependsOn: [
    privateDNSZone
  ]
}

#disable-next-line BCP081
resource virtualNetworkLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = if (enablePrivateLink) {
  parent: privateDNSZone
  name: 'link_to_vnet'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: privateLinkSettings.vnetId
    }
  }
  dependsOn: [
    privateDNSZone
  ]
}
