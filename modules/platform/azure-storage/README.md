# Azure Storage Module

This module deploys an Azure Storage Account.

## Description

{{ Add detailed description for the module. }}

## Parameters

| Name                  | Type     | Required | Description                                                                                                                                                                                                                                                         |
| :-------------------- | :------: | :------: | :------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `prefix`              | `string` | No       | Prefix to use for the Storage Account Name.                                                                                                                                                                                                                         |
| `location`            | `string` | No       | Resource Location.                                                                                                                                                                                                                                                  |
| `enableDeleteLock`    | `bool`   | No       | Enable lock to prevent accidental deletion                                                                                                                                                                                                                          |
| `tags`                | `object` | No       | Tags.                                                                                                                                                                                                                                                               |
| `sku`                 | `string` | No       | Specifies the storage account sku type.                                                                                                                                                                                                                             |
| `rbacPermissions`     | `array`  | No       | Array of objects that describe RBAC permissions, format { roleDefinitionResourceId (string), principalId (string), principalType (enum), enabled (bool) }. Ref: https://docs.microsoft.com/en-us/azure/templates/microsoft.authorization/roleassignments?tabs=bicep |
| `privateLinkSettings` | `object` | No       | Settings Required to Enable Private Link                                                                                                                                                                                                                            |
| `privateEndpointName` | `string` | No       | Specifies the name of the private link to the Azure Container Registry.                                                                                                                                                                                             |

## Outputs

| Name | Type | Description |
| :--- | :--: | :---------- |

## Examples

### Example 1

```bicep
module storage 'br/managedplatform.azurecr.io:platform/azure-storage:1.0.1' = {
  name: 'container_registry'
  params: {
    resourceName: resourceName
    location: location
    sku: 'Standard'
    rbacPermissions: [
      {
        roleDefinitionResourceId: '/providers/Microsoft.Authorization/roleDefinitions/ba92f5b4-2d11-453d-a403-e96b0029c9fe' // Storage Blob Data Contributor
        principalId: '222222-2222-2222-2222-2222222222'
        principalType: 'ServicePrincipal'
        enabled: true
      }
    ]
  }
}
```