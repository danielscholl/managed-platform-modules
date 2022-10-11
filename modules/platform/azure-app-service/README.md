# Azure App Service Module

This module deploys an Azure App Service and Plan

## Description

{{ Add detailed description for the module. }}

## Parameters

| Name               | Type     | Required | Description                                |
| :----------------- | :------: | :------: | :----------------------------------------- |
| `resourceName`     | `string` | Yes      | Used to name all resources                 |
| `location`         | `string` | No       | Resource Location.                         |
| `sku`              | `string` | No       | SKU for the App Service Plan               |
| `enableDeleteLock` | `bool`   | No       | Enable lock to prevent accidental deletion |
| `linuxFxVersion`   | `string` | No       | The Runtime stack of current web app       |

## Outputs

| Name | Type | Description |
| :--- | :--: | :---------- |

## Examples

### Example 1

```bicep
module example 'br/managedplatform.azurecr.io:platform/azure-app-service:1.0.1' = {
  name: 'azure_app_service'
  params: {
    resourceName: resourceName
    location: location
    sku: 'F1'
  }
}
```