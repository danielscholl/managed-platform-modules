targetScope = 'resourceGroup'

@minLength(3)
@maxLength(10)
@description('Used to name all resources')
param resourceName string

@description('Registry Location.')
param location string = resourceGroup().location

@description('Enable lock to prevent accidental deletion')
param enableDeleteLock bool = false

@description('Tags.')
param tags object = {}

@description('Enable an admin user that has push/pull permission to the registry.')
param acrAdminUserEnabled bool = false

@description('Tier of your Azure Container Registry.')
@allowed([
  'Basic'
  'Standard'
  'Premium'
])
param sku string = 'Standard'

@description('Array of objects that describe RBAC permissions, format { roleDefinitionResourceId (string), principalId (string), principalType (enum), enabled (bool) }. Ref: https://docs.microsoft.com/en-us/azure/templates/microsoft.authorization/roleassignments?tabs=bicep')
param rbacPermissions array = [
  /* example
      {
        roleDefinitionResourceId: '/providers/Microsoft.Authorization/roleDefinitions/8311e382-0749-4cb8-b61a-304f252e45ec' // AcrPush
        principalId: '00000000-0000-0000-0000-000000000000' // az ad signed-in-user show --query objectId --output tsv
        principalType: 'User'
        enabled: false
      }
  */
]

var name = 'acr${replace(resourceName, '-', '')}${uniqueString(resourceGroup().id, resourceName)}'

// Create Azure Container Registry
resource acr 'Microsoft.ContainerRegistry/registries@2022-02-01-preview' = {
  name: length(name) > 50 ? substring(name, 0, 50) : name
  location: location
  tags: tags
  sku: {
    name: sku
  }
  properties: {
    adminUserEnabled: acrAdminUserEnabled
    encryption: {
      status: 'Disabled'
    }
    dataEndpointEnabled: false
  }
}

// ACR Resource Locking
resource lock 'Microsoft.Authorization/locks@2016-09-01' = if (enableDeleteLock) {
  scope: acr

  name: '${acr.name}-lock'
  properties: {
    level: 'CanNotDelete'
  }
}

// Add role assignments
resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = [for item in rbacPermissions: if (item.enabled) {
  name: guid(acr.id, item.principalId, item.roleDefinitionResourceId)
  scope: acr
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
  subnetId: null // Specify the Subnet for Private Endpoint
  vnetId: null // Specify the Virtual Network for Virtual Network Link
}

@description('Specifies the name of the private link to the Azure Container Registry.')
param privateEndpointName string = 'acrPrivateEndpoint'

var privateDnsZoneName = 'privatelink.${publicDNSZoneForwarder}'
var publicDNSZoneForwarder = ((toLower(environment().name) == 'azureusgovernment') ? 'azurecr.us' : 'azurecr.io')

resource privateDNSZone 'Microsoft.Network/privateDnsZones@2020-06-01' = if (sku == 'Premium' && privateLinkSettings.subnetId != null && privateLinkSettings.vnetId != null) {
  name: privateDnsZoneName
  location: 'global'
  properties: {}
}

resource privateEndpoint 'Microsoft.Network/privateEndpoints@2020-07-01' = if (sku == 'Premium' && privateLinkSettings.subnetId != null && privateLinkSettings.vnetId != null) {
  name: privateEndpointName
  location: location
  properties: {
    privateLinkServiceConnections: [
      {
        name: privateEndpointName
        properties: {
          privateLinkServiceId: acr.id
          groupIds: [
            'registry'
          ]
        }
      }
    ]
    subnet: {
      id: privateLinkSettings.subnetId
    }
  }
  dependsOn: [
    acr
  ]
}

resource privateDNSZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2020-06-01' = if (sku == 'Premium' && privateLinkSettings.subnetId != null && privateLinkSettings.vnetId != null) {
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
}

resource virtualNetworkLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = if (sku == 'Premium' && privateLinkSettings.subnetId != null && privateLinkSettings.vnetId != null) {
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

@description('The name of the container registry.')
output name string = acr.name

@description('Specifies the name of the fully qualified name of the login server.')
output loginServer string = acr.properties.loginServer
