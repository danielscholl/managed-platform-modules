# Container Registry Module

This module deploys a Container Registry.

## Description

Use this module within other Bicep templates to simplify the usage of a Container Registry.

## Parameters

| Name                  | Type     | Required | Description                                                                                                                                                                                                                                                         |
| :-------------------- | :------: | :------: | :------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `resourceName`        | `string` | Yes      | Used to name all resources                                                                                                                                                                                                                                          |
| `location`            | `string` | No       | Registry Location.                                                                                                                                                                                                                                                  |
| `enableDeleteLock`    | `bool`   | No       | Enable lock to prevent accidental deletion                                                                                                                                                                                                                          |
| `tags`                | `object` | No       | Tags.                                                                                                                                                                                                                                                               |
| `acrAdminUserEnabled` | `bool`   | No       | Enable an admin user that has push/pull permission to the registry.                                                                                                                                                                                                 |
| `sku`                 | `string` | No       | Tier of your Azure Container Registry.                                                                                                                                                                                                                              |
| `rbacPermissions`     | `array`  | No       | Array of objects that describe RBAC permissions, format { roleDefinitionResourceId (string), principalId (string), principalType (enum), enabled (bool) }. Ref: https://docs.microsoft.com/en-us/azure/templates/microsoft.authorization/roleassignments?tabs=bicep |
| `privateLinkSettings` | `object` | No       | Settings Required to Enable Private Link                                                                                                                                                                                                                            |
| `privateEndpointName` | `string` | No       | Specifies the name of the private link to the Azure Container Registry.                                                                                                                                                                                             |

## Outputs

| Name        | Type   | Description                                                         |
| :---------- | :----: | :------------------------------------------------------------------ |
| name        | string | The name of the container registry.                                 |
| loginServer | string | Specifies the name of the fully qualified name of the login server. |

## Examples

```bicep
module acr 'br:managedplatform.azurecr.io/bicep/modules/platform/container-registry:1.0.1' = {
  name: 'container_registry'
  params: {
    resourceName: 'acr${uniqueString(resourceGroup().id)}'
    location: 'southcentralus'
  }
}
```