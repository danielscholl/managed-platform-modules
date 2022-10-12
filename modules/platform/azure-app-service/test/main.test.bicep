targetScope = 'resourceGroup'

@minLength(3)
@maxLength(20)
@description('Used to name all resources')
param resourceName string 

@description('Registry Location.')
param location string = resourceGroup().location

//  Module --> Create App Service
module acr '../main.bicep' = {
  name: 'azure_app_service'
  params: {
    resourceName: resourceName
    location: location
  }
}
