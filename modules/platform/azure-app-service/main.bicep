targetScope = 'resourceGroup'

@minLength(3)
@maxLength(20)
@description('Used to name all resources')
param resourceName string 

@description('Resource Location.')
param location string = resourceGroup().location

@description('SKU for the App Service Plan')
@allowed([
  'F1'
  'B1'
])
param sku string = 'F1'

@description('Enable lock to prevent accidental deletion')
param enableDeleteLock bool = false

@description('The Runtime stack of current web app')
param linuxFxVersion string = 'NODE|10.15'

var appServicePlanName = 'plan-${replace(resourceName, '-', '')}${uniqueString(resourceGroup().id, resourceName)}'
var appServiceName = 'web-${replace(resourceName, '-', '')}${uniqueString(resourceGroup().id, resourceName)}'

resource appServicePlan 'Microsoft.Web/serverfarms@2021-02-01' = {
  name: appServicePlanName
  location: location
  sku: {
    name: sku
  }
  kind: 'linux'
  properties: {
    reserved: true
  }
}

resource appService 'Microsoft.Web/sites@2021-02-01' = {
  name: appServiceName
  location: location
  properties: {
    httpsOnly: true
    serverFarmId: appServicePlan.id
    siteConfig: {
      linuxFxVersion: linuxFxVersion
      minTlsVersion: '1.2'
      ftpsState: 'FtpsOnly'
    }
  }
  identity: {
    type: 'SystemAssigned'
  }
}

resource appServicePlanLock 'Microsoft.Authorization/locks@2017-04-01' = if (enableDeleteLock) {
  scope: appServicePlan

  name: '${appServicePlan.name}-lock'
  properties: {
    level: 'CanNotDelete'
  }
}

resource appServiceLock 'Microsoft.Authorization/locks@2017-04-01' = if (enableDeleteLock) {
  scope: appService

  name: '${appService.name}-lock'
  properties: {
    level: 'CanNotDelete'
  }
}

@description('The name of the App Service Plan')
output appServicePlanName string = appServicePlan.name

@description('The resourceId of the App Service Plan')
output appServicePlanId string = appServicePlan.id

@description('The name of the App Service')
output appServiceName string = appService.name

@description('The resourceId of the App Service')
output appServiceId string = appService.id
