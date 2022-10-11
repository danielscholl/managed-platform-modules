# Log Analytics Module

This module deploys a Log Analytics Workspace.

## Description

{{ Add detailed description for the module. }}

## Parameters

| Name                                    | Type     | Required | Description                                                                        |
| :-------------------------------------- | :------: | :------: | :--------------------------------------------------------------------------------- |
| `resourceName`                          | `string` | Yes      | Used to name all resources                                                         |
| `location`                              | `string` | No       | Workspace Location.                                                                |
| `sku`                                   | `string` | Yes      | Sku of the workspace                                                               |
| `retentionInDays`                       | `int`    | Yes      | The workspace data retention in days, between 30 and 730                           |
| `solutions`                             | `array`  | No       | Solutions to add to workspace                                                      |
| `lock`                                  | `string` | No       | Optional. Specify the type of lock.                                                |
| `automationAccountName`                 | `string` | No       | Name of automation account to link to workspace                                    |
| `dataSources`                           | `array`  | No       | Datasources to add to workspace                                                    |
| `enableDiagnostics`                     | `bool`   | No       | Enable diagnostic logs                                                             |
| `diagnosticStorageAccountName`          | `string` | No       | Storage account name. Only required if enableDiagnostics is set to true.           |
| `diagnosticStorageAccountResourceGroup` | `string` | No       | Storage account resource group. Only required if enableDiagnostics is set to true. |

## Outputs

| Name | Type   | Description |
| :--- | :----: | :---------- |
| Id   | string |             |

## Examples

### Example 1

```bicep
```

### Example 2

```bicep
```