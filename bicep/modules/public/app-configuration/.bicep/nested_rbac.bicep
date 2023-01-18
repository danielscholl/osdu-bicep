param description string = ''
param principalType string = ''
param roleDefinitionIdOrName string
param resourceId string

@sys.description('Optional. Indicates if the module is used in a cross tenant scenario. If true, a resourceId must be provided in the role assignment\'s principal object.')
param crossTenant bool = false

@sys.description('Required. The IDs of the principals to assign the role to. A resourceId is required when used in a cross tenant scenario (i.e. crossTenant is true)')
param principals array
  /* example
      [
        {
          id: '222222-2222-2222-2222-2222222222'
          resourceId: '/subscriptions/111111-1111-1111-1111-1111111111/resourcegroups/rg-osdu-bicep/providers/Microsoft.ManagedIdentity/userAssignedIdentities/id-ManagedIdentityName'
        }
      ]
  */

var builtInRoleNames = {
  Owner: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '8e3af657-a8ff-443c-a75c-2fe8c4bcb635')
  Contributor: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'b24988ac-6180-42a0-ab88-20f7382dd24c')
  Reader: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'acdd72a7-3385-48ef-bd42-f606fba81ae7')
  'App Configuration Data Owner': subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '5ae67dd6-50cb-40e7-96ff-dc2bfa4b606b')
  'App Configuration Data Reader': subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '516239f1-63e1-4d78-a4de-a74fb236a071')
}

resource appConfiguration 'Microsoft.AppConfiguration/configurationStores@2022-05-01' existing = {
  name: last(split(resourceId, '/'))
}

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = [for principal  in principals: {
  name: guid(appConfiguration.name, principal.id, roleDefinitionIdOrName)
  properties: {
    description: description
    roleDefinitionId: contains(builtInRoleNames, roleDefinitionIdOrName) ? builtInRoleNames[roleDefinitionIdOrName] : roleDefinitionIdOrName
    principalId: principal.id
    principalType: !empty(principalType) ? principalType : null
    delegatedManagedIdentityResourceId: crossTenant ? principal.resourceId : null
  }
  scope: appConfiguration
}]
