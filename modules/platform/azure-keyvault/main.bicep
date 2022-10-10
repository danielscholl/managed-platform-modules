targetScope = 'resourceGroup'

@minLength(3)
@maxLength(20)
@description('Used to name all resources')
param resourceName string

@description('Resource Location.')
param location string = resourceGroup().location

@description('Enable lock to prevent accidental deletion')
param enableDeleteLock bool = false

@description('Tags.')
param tags object = {}

@description('Key Vault SKU.')
param sku string = 'Standard'

@description('Specify Identity to provide Network Contributor Role Access (Optional).')
param principalId string = 'null'

@description('Key Vault Defined Access Policies.')
param permissions object = {
  secrets: [
    'get'
    'list'
  ]
}

@description('Key Vault Retention Days.')
@minValue(7)
@maxValue(14)
param softDeleteRetentionInDays int = 7

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


var name = 'kv-${replace(resourceName, '-', '')}${uniqueString(resourceGroup().id, resourceName)}'

// Create Azure Key Vault
resource keyvault 'Microsoft.KeyVault/vaults@2022-07-01' = {
  name: length(name) > 24 ? substring(name, 0, 24) : name
  location: location
  tags: tags
  properties: {
    tenantId: subscription().tenantId
    sku: {
      family: 'A'
      name: sku
    }
    accessPolicies: principalId == 'null' ? [] : [
      {
        objectId: principalId
        tenantId: subscription().tenantId
        permissions: permissions
      }
    ]
    softDeleteRetentionInDays: softDeleteRetentionInDays
    enabledForDeployment: false
    enabledForDiskEncryption: false
    enabledForTemplateDeployment: false

    enableRbacAuthorization: false
    networkAcls: enablePrivateLink ? {
      bypass: 'AzureServices'
      defaultAction: 'Deny'
    } : {}
    publicNetworkAccess: enablePrivateLink ? 'Disabled' : 'Enabled'
  }
}

resource lock 'Microsoft.Authorization/locks@2017-04-01' = if (enableDeleteLock) {
  scope: keyvault

  name: '${keyvault.name}-lock'
  properties: {
    level: 'CanNotDelete'
  }
}

// Add role assignments
resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = [for item in rbacPermissions: if (item.enabled) {
  name: guid(keyvault.id, item.principalId, item.roleDefinitionResourceId)
  scope: keyvault
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
param privateEndpointName string = 'kvPrivateEndpoint'

var privateDNSZoneName = 'privatelink.vaultcore.azure.net'

resource privateEndpoint 'Microsoft.Network/privateEndpoints@2021-02-01' = if (enablePrivateLink) {
  name: privateEndpointName
  location: location
  properties: {
    subnet: {
      id: privateLinkSettings.subnetId
    }
    privateLinkServiceConnections: [
      {
        name: privateEndpointName
        properties: {
          privateLinkServiceId: keyvault.id
          groupIds: [
            'vault'
          ]
        }
      }
    ]
    customDnsConfigs: [
      {
        fqdn: privateDNSZoneName
      }
    ]
  }
  dependsOn: [
    keyvault
  ]
}

resource virtualNetworkLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = if (enablePrivateLink) {
  name: '${privateDNSZone.name}/${privateDNSZone.name}-link'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: privateLinkSettings.vnetId
    }
  }
}

resource privateDNSZone 'Microsoft.Network/privateDnsZones@2020-06-01' = if (enablePrivateLink) {
  name: privateDNSZoneName
  location: 'global'
}

resource privateDNSZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2022-01-01' = if (enablePrivateLink) {
  name: '${privateEndpoint.name}/dnsgroupname'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'config1'
        properties: {
          privateDnsZoneId: privateDNSZone.id
        }
      }
    ]
  }
}

@description('The name of the azure keyvault.')
output name string = keyvault.name

@description('The resourceId of the azure keyvault.')
output id string = keyvault.id
