targetScope = 'resourceGroup'

@minLength(2)
@maxLength(5)
@description('Prefix to use for resource names.')
param prefix string

@description('Resource Location.')
param location string = resourceGroup().location


//  Module --> Create Storage Account
module storage '../main.bicep' = {
  name: 'storage_account'
  params: {
    prefix: prefix
    location: location
    sku: 'Standard_LRS'
  }
}
