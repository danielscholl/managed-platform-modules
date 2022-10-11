# User Managed Identity

This module deploys a User Managed Identity.

## Description

{{ Add detailed description for the module. }}

## Parameters

| Name           | Type     | Required | Description                         |
| :------------- | :------: | :------: | :---------------------------------- |
| `resourceName` | `string` | Yes      | Used to name all resources          |
| `location`     | `string` | No       | User Managed Identity Location.     |
| `tags`         | `object` | No       | Tags.                               |
| `lock`         | `string` | No       | Optional. Specify the type of lock. |

## Outputs

| Name        | Type   | Description                                |
| :---------- | :----: | :----------------------------------------- |
| id          | string | The resource ID of the managed identity.   |
| principalId | string | The principal id for the managed identity. |

## Examples


```bicep
module example 'br/managedplatform.azurecr.io:platform/user-identity:1.0.1' = {
  name: 'user_identity'
  params: {
    resourceName: resourceName
    location: location
  }
}
```