targetScope = 'subscription'

@minLength(1)
@maxLength(64)
@description('Name of the the environment which is used to generate a short unique hash used in all resources.')
param environmentName string

@minLength(1)
@description('Primary location for all resources')
param location string

@description('Id of the user or app to assign application roles')
param principalId string = ''

@description('Relative Path of ASA Jar')
param relativePath string

var abbrs = loadJsonContent('./abbreviations.json')
var resourceToken = toLower(uniqueString(subscription().id, environmentName, location))
var keyVaultName = '${abbrs.keyVaultVaults}${resourceToken}'
var serviceBusNamespaceName = '${environmentName}-${abbrs.serviceBusNamespaces}${resourceToken}'
var asaInstanceName = '${environmentName}-${abbrs.springApps}${resourceToken}'
var appName = 'simple-event-driven-app'
var serviceBusConnectionStringSecretName = 'SERVICE-BUS-CONNECTION-STRING'
var tags = {
  'azd-env-name': environmentName
  'spring-cloud-azure': 'true'
}

resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: '${abbrs.resourcesResourceGroups}${environmentName}-${resourceToken}'
  location: location
  tags: tags
}

module keyVault 'modules/keyvault/keyvault.bicep' = {
  name: '${deployment().name}--kv'
  scope: resourceGroup(rg.name)
  params: {
  	keyVaultName: keyVaultName
  	location: location
	tags: tags
	principalId: principalId
  }
}

module serviceBus 'modules/servicebus/servicebus.bicep' = {
  name: '${deployment().name}--sb'
  scope: resourceGroup(rg.name)
  params: {
    serviceBusNamespaceName: serviceBusNamespaceName
    location: location
    tags: tags
    keyVaultName: keyVault.outputs.name
    secretName: serviceBusConnectionStringSecretName
    subscriptionId: subscription().id
    resourceGroupName: rg.name
  }
}

module springApps 'modules/springapps/springapps.bicep' = {
  name: '${deployment().name}--asa'
  scope: resourceGroup(rg.name)
  params: {
    location: location
    appName: appName
    tags: union(tags, { 'azd-service-name': appName })
    asaInstanceName: asaInstanceName
    relativePath: relativePath
    keyVaultName: keyVault.outputs.name
  }
}

module apiKeyVaultAccess './modules/keyvault/keyvault-access.bicep' = {
  name: 'api-keyvault-access'
  scope: resourceGroup(rg.name)
  params: {
    keyVaultName: keyVault.outputs.name
    principalId: springApps.outputs.identityPrincipalId
  }
}

output AZURE_KEY_VAULT_NAME string = keyVault.outputs.name
output AZURE_KEY_VAULT_ENDPOINT string = keyVault.outputs.endpoint