# Azure Service Bus

This module deploys an Azure Service Bus.

## Description

This module supports the following features.

- Queues
- Topics
- Authorization Rules
- Diagnostics

## Parameters

| Name                                    | Type     | Required | Description                                                                                                                                                                                           |
| :-------------------------------------- | :------: | :------: | :---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `resourceName`                          | `string` | Yes      | Used to name all resources                                                                                                                                                                            |
| `location`                              | `string` | No       | Resource Location.                                                                                                                                                                                    |
| `tags`                                  | `object` | No       | Tags.                                                                                                                                                                                                 |
| `enableDeleteLock`                      | `bool`   | No       | Enable lock to prevent accidental deletion                                                                                                                                                            |
| `sku`                                   | `string` | No       | Optional. Name of this SKU. - Basic, Standard, Premium.                                                                                                                                               |
| `zoneRedundant`                         | `bool`   | No       | Optional. Enabling this property creates a Premium Service Bus Namespace in regions supported availability zones.                                                                                     |
| `authorizationRules`                    | `array`  | No       | Optional. Authorization Rules for the Service Bus namespace.                                                                                                                                          |
| `systemAssignedIdentity`                | `bool`   | No       | Optional. Enables system assigned managed identity on the resource.                                                                                                                                   |
| `userAssignedIdentities`                | `object` | No       | Optional. The ID(s) to assign to the resource.                                                                                                                                                        |
| `queues`                                | `array`  | No       | Optional. The queues to create in the service bus namespace.                                                                                                                                          |
| `topics`                                | `array`  | No       | Optional. The topics to create in the service bus namespace.                                                                                                                                          |
| `cMKKeyVaultResourceId`                 | `string` | No       | Conditional. The resource ID of a key vault to reference a customer managed key for encryption from. Required if 'cMKKeyName' is not empty.                                                           |
| `cMKKeyName`                            | `string` | No       | Optional. The name of the customer managed key to use for encryption. If not provided, encryption is automatically enabled with a Microsoft-managed key.                                              |
| `cMKKeyVersion`                         | `string` | No       | Optional. The version of the customer managed key to reference for encryption. If not provided, the latest key version is used.                                                                       |
| `cMKUserAssignedIdentityResourceId`     | `string` | No       | Optional. User assigned identity to use when fetching the customer managed key. If not provided, a system-assigned identity can be used - but must be given access to the referenced key vault first. |
| `requireInfrastructureEncryption`       | `bool`   | No       | Optional. Enable infrastructure encryption (double encryption). Note, this setting requires the configuration of Customer-Managed-Keys (CMK) via the corresponding module parameters.                 |
| `diagnosticLogCategoriesToEnable`       | `array`  | No       | Optional. The name of logs that will be streamed. "allLogs" includes all possible logs for the resource.                                                                                              |
| `diagnosticMetricsToEnable`             | `array`  | No       | Optional. The name of metrics that will be streamed.                                                                                                                                                  |
| `diagnosticLogsRetentionInDays`         | `int`    | No       | Optional. Specifies the number of days that logs will be kept for; a value of 0 will retain data indefinitely.                                                                                        |
| `diagnosticStorageAccountId`            | `string` | No       | Optional. Resource ID of the diagnostic storage account.                                                                                                                                              |
| `diagnosticWorkspaceId`                 | `string` | No       | Optional. Resource ID of the diagnostic log analytics workspace.                                                                                                                                      |
| `diagnosticEventHubAuthorizationRuleId` | `string` | No       | Optional. Resource ID of the diagnostic event hub authorization rule for the Event Hubs namespace in which the event hub should be created or streamed to.                                            |
| `diagnosticEventHubName`                | `string` | No       | Optional. Name of the diagnostic event hub within the namespace to which logs are streamed. Without this, an event hub is created for each log category.                                              |
| `diagnosticSettingsName`                | `string` | No       | Optional. The name of the diagnostic setting, if deployed. If left empty, it defaults to "<resourceName>-diagnosticSettings".                                                                         |
| `privateLinkSettings`                   | `object` | No       | Settings Required to Enable Private Link                                                                                                                                                              |

## Outputs

| Name | Type | Description |
| :--- | :--: | :---------- |

## Examples

### Example 1

```bicep
module servicebus 'br:osdubicep.azurecr.io/public/service-bus:1.0.1' = {
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
```