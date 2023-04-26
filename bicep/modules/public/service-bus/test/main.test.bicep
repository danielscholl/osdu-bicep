targetScope = 'resourceGroup'

@minLength(3)
@maxLength(10)
@description('Used to name all resources')
param resourceName string

@description('Registry Location.')
param location string = resourceGroup().location

//  Module --> Create Resource
module sb '../main.bicep' = {
  name: 'azure_servicebus'
  params: {
    resourceName: resourceName
    location: location
    sku: 'Standard'
    queues: [
      {
        name: 'testqueue'
        maxDeliveryCount: 30
        lockDuration: 'PT5M'
      }
    ]
    topics: [
      {
        name: 'testtopic'
      }
    ]
  }
}
