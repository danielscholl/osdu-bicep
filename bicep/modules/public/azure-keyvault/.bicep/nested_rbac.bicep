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
  'Key Vault Administrator': subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'a4417e6f-fecd-4de8-b567-7b0420556985')
  'Key Vault Certificates Officer': subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'f25e0fa2-a7c8-4377-a976-54943a77a395')
  'Key Vault Contributor': subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '14b46e9e-c2b7-41b4-b07b-48a6ebf60603')
  'Key Vault Crypto Officer': subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'e147488a-f6f5-4113-8e2d-b22465e65bf6')
  'Key Vault Crypto Service Encryption User': subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '')
  'Key Vault Crypto User': subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '12338af0-0e69-4776-bea7-57ae8d297424')
  'Key Vault Reader': subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '21090545-7ca7-4776-b22c-e363652d74d2')
  'Key Vault Secrets Officer': subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'b86a8fe4-44ce-4948-aee5-eccb2c155cd7')
  'Key Vault Secrets User': subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '4633458b-17de-408a-b874-0445c86b69e6')
}

resource kv 'Microsoft.KeyVault/vaults@2022-07-01' existing = {
  name: last(split(resourceId, '/'))
}

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = [for principal in principals: {
  name: guid(kv.name, principal.id, roleDefinitionIdOrName)
  properties: {
    description: description
    roleDefinitionId: contains(builtInRoleNames, roleDefinitionIdOrName) ? builtInRoleNames[roleDefinitionIdOrName] : roleDefinitionIdOrName
    principalId: principal.id
    principalType: !empty(principalType) ? principalType : null
    delegatedManagedIdentityResourceId: crossTenant ? principal.resourceId : null
  }
  scope: kv
}]
