# Azure Keyvault Module

This module deploys an Azure KeyVault.

## Description

{{ Add detailed description for the module. }}

## Parameters

| Name                        | Type     | Required | Description                                                                                                                                                                                                                                                         |
| :-------------------------- | :------: | :------: | :------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `resourceName`              | `string` | Yes      | Used to name all resources                                                                                                                                                                                                                                          |
| `location`                  | `string` | No       | Resource Location.                                                                                                                                                                                                                                                  |
| `enableDeleteLock`          | `bool`   | No       | Enable lock to prevent accidental deletion                                                                                                                                                                                                                          |
| `tags`                      | `object` | No       | Tags.                                                                                                                                                                                                                                                               |
| `sku`                       | `string` | No       | Key Vault SKU.                                                                                                                                                                                                                                                      |
| `principalId`               | `string` | No       | Specify Identity to provide Network Contributor Role Access (Optional).                                                                                                                                                                                             |
| `permissions`               | `object` | No       | Key Vault Defined Access Policies.                                                                                                                                                                                                                                  |
| `softDeleteRetentionInDays` | `int`    | No       | Key Vault Retention Days.                                                                                                                                                                                                                                           |
| `rbacPermissions`           | `array`  | No       | Array of objects that describe RBAC permissions, format { roleDefinitionResourceId (string), principalId (string), principalType (enum), enabled (bool) }. Ref: https://docs.microsoft.com/en-us/azure/templates/microsoft.authorization/roleassignments?tabs=bicep |
| `privateLinkSettings`       | `object` | No       | Settings Required to Enable Private Link                                                                                                                                                                                                                            |
| `privateEndpointName`       | `string` | No       | Specifies the name of the private link to the Azure Container Registry.                                                                                                                                                                                             |

## Outputs

| Name | Type   | Description                           |
| :--- | :----: | :------------------------------------ |
| name | string | The name of the azure keyvault.       |
| id   | string | The resourceId of the azure keyvault. |

## Examples

```bicep
module acr 'br/managedplatform.azurecr.io:platform/container-registry:1.0.1' = {
  name: 'container_registry'
  params: {
    resourceName: resourceName
    location: location
    sku: 'Standard'
  }
}
```