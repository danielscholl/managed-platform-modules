targetScope = 'resourceGroup'

@minLength(3)
@maxLength(10)
@description('Used to name all resources')
param resourceName string

@description('Registry Location.')
param location string = resourceGroup().location

@description('Sku of the workspace')
@allowed([
  'PerGB2018'
  'Free'
  'Standalone'
  'PerNode'
  'Standard'
  'Premium'
])
param sku string


//  Module --> Create Container Registry
module example '../main.bicep' = {
  name: 'user_identity'
  params: {
    resourceName: resourceName
    location: location
    sku: sku
    retentionInDays: 30
  }
}
