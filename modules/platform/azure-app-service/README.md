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
| `skuTier`          | `string` | No       | SKU tier for the App Service Plan          |
| `skuCapacity`      | `int`    | No       | Capacity for the App Service Plan          |
| `enableDeleteLock` | `bool`   | No       | Enable lock to prevent accidental deletion |
| `linuxFxVersion`   | `string` | No       | The Runtime stack of current web app       |

## Outputs

| Name               | Type   | Description                            |
| :----------------- | :----: | :------------------------------------- |
| appServicePlanName | string | The name of the App Service Plan       |
| appServicePlanId   | string | The resourceId of the App Service Plan |
| appServiceName     | string | The name of the App Service            |
| appServiceId       | string | The resourceId of the App Service      |

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