# Azure Virtual Network

This module deploys a virtual network.

## Description

This module is responsible for deploying networks.  It has the capability to hookup diagnostics, assign rbac as well as establish network peerings.

## Parameters

| Name                                    | Type     | Required | Description                                                                                                                                                                                                                                                                                                                      |
| :-------------------------------------- | :------: | :------: | :------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `resourceName`                          | `string` | Yes      | Used to name all resources                                                                                                                                                                                                                                                                                                       |
| `location`                              | `string` | No       | Resource Location.                                                                                                                                                                                                                                                                                                               |
| `tags`                                  | `object` | No       | Resource Tags (Optional).                                                                                                                                                                                                                                                                                                        |
| `lock`                                  | `string` | No       | Optional. Specify the type of lock.                                                                                                                                                                                                                                                                                              |
| `virtualNetworkPeerings`                | `array`  | No       | Optional. Virtual Network Peerings configurations                                                                                                                                                                                                                                                                                |
| `diagnosticWorkspaceId`                 | `string` | No       | Optional. Resource ID of the diagnostic log analytics workspace.                                                                                                                                                                                                                                                                 |
| `diagnosticStorageAccountId`            | `string` | No       | Optional. Resource ID of the diagnostic storage account.                                                                                                                                                                                                                                                                         |
| `diagnosticEventHubAuthorizationRuleId` | `string` | No       | Optional. Resource ID of the diagnostic event hub authorization rule for the Event Hubs namespace in which the event hub should be created or streamed to.                                                                                                                                                                       |
| `diagnosticEventHubName`                | `string` | No       | Optional. Name of the diagnostic event hub within the namespace to which logs are streamed. Without this, an event hub is created for each log category.                                                                                                                                                                         |
| `newOrExistingNSG`                      | `string` | No       | Create a new, use an existing, or provide no default NSG.                                                                                                                                                                                                                                                                        |
| `networkSecurityGroupName`              | `string` | No       | Name of default NSG to use for subnets.                                                                                                                                                                                                                                                                                          |
| `dnsServers`                            | `array`  | No       | Optional. DNS Servers associated to the Virtual Network.                                                                                                                                                                                                                                                                         |
| `ddosProtectionPlanId`                  | `string` | No       | Optional. Resource ID of the DDoS protection plan to assign the VNET to. If it's left blank, DDoS protection will not be configured. If it's provided, the VNET created by this template will be attached to the referenced DDoS protection plan. The DDoS protection plan can exist in the same or in a different subscription. |
| `diagnosticLogsRetentionInDays`         | `int`    | No       | Optional. Specifies the number of days that logs will be kept for; a value of 0 will retain data indefinitely.                                                                                                                                                                                                                   |
| `logsToEnable`                          | `array`  | No       | Optional. The name of logs that will be streamed.                                                                                                                                                                                                                                                                                |
| `metricsToEnable`                       | `array`  | No       | Optional. The name of metrics that will be streamed.                                                                                                                                                                                                                                                                             |
| `addressPrefixes`                       | `array`  | No       | Virtual Network Address CIDR                                                                                                                                                                                                                                                                                                     |
| `subnets`                               | `array`  | No       | Virtual Network Subnets                                                                                                                                                                                                                                                                                                          |
| `crossTenant`                           | `bool`   | No       | Optional. Indicates if the module is used in a cross tenant scenario. If true, a resourceId must be provided in the role assignment's principal object.                                                                                                                                                                          |
| `roleAssignments`                       | `array`  | No       | Optional. Array of objects that describe RBAC permissions, format { roleDefinitionResourceId (string), principalId (string), principalType (enum), enabled (bool) }. Ref: https://docs.microsoft.com/en-us/azure/templates/microsoft.authorization/roleassignments?tabs=bicep                                                    |

## Outputs

| Name        | Type   | Description                              |
| :---------- | :----: | :--------------------------------------- |
| id          | string | The resource ID of the virtual network   |
| name        | string | The name of the virtual network          |
| subnetNames | array  | The names of the deployed subnets        |
| subnetIds   | array  | The resource IDs of the deployed subnets |
| nsgName     | string | The network security group id            |

## Examples

### Example 1

A simple network.

```bicep
module network 'br:osdubicep.azurecr.io/public/virtual-network:1.0.5' = {
  name: 'azure_vnet'
  params: {
    resourceName: 'vnet-${uniqueString(resourceGroup().id)}'
    location: 'southcentralus'
    addressPrefixes: [
      '192.168.0.0/24'
    ]
    subnets: [
      {
        name: 'default'
        addressPrefix: '192.168.0.0/24'
        privateEndpointNetworkPolicies: 'Disabled'
        privateLinkServiceNetworkPolicies: 'Enabled'
      }
    ]
  }
}
```

### Example 2

A hub spoke network sample.

```bicep
module hub_vnet 'br:osdubicep.azurecr.io/public/virtual-network:1.0.5' = {
  name: 'azure_vnet_hub'
  params: {
    resourceName: 'hub'
    location: 'southcentralus'
    newOrExistingNSG: 'none'
    addressPrefixes: [
      '10.0.0.0/16'
    ]
    subnets: [
      {
        name: 'GatewaySubnet'
        addressPrefix: '10.0.0.0/26'
      }
      {
        name: 'AzureBastionSubnet'
        addressPrefix: '10.0.0.64/27'
      }
      {
        name: 'AzureFirewallSubnet'
        addressPrefix: '10.0.0.128/26'
      }
    ]
    roleAssignments: [
      {
        roleDefinitionIdOrName: 'Reader'
        principalIds: [
          '222222-2222-2222-2222-2222222222'
        ]
        principalType: 'ServicePrincipal'
      }
    ]
  }
}

module spoke_vnet '../main.bicep' = {
  name: 'azure_vnet_spoke'
  params: {
    resourceName: 'spoke'
    location: 'southcentralus'
    addressPrefixes: [
      '10.1.0.0/16'
    ]
    subnets: [
      {
        name: 'workloads'
        addressPrefix: '10.1.0.0/24'
        privateEndpointNetworkPolicies: 'Disabled'
        privateLinkServiceNetworkPolicies: 'Enabled'
        serviceEndpoints: [
          {
            service: 'Microsoft.Storage'
          }
        ]
      }
    ]
    newOrExistingNSG: 'new'
    virtualNetworkPeerings: [
      {
        remoteVirtualNetworkId: hub_vnet.outputs.id
        allowForwardedTraffic: true
        allowGatewayTransit: false
        allowVirtualNetworkAccess: true
        useRemoteGateways: false
        remotePeeringEnabled: true
        remotePeeringName: 'spoke1'
        remotePeeringAllowVirtualNetworkAccess: true
        remotePeeringAllowForwardedTraffic: true
      }
    ]
  }
}
```