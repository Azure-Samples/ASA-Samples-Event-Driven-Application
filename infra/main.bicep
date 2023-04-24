targetScope = 'subscription'

@minLength(1)
@maxLength(64)
@description('Name of the the environment which is used to generate a short unique hash used in all resources.')
param environmentName string

@minLength(1)
@description('Primary location for all resources')
param location string

param applicationName string = 'event-driven'
var resourceToken = toLower(uniqueString(subscription().id, environmentName, location))

var defaultTags = {
  'azd-env-name': environmentName
  'azd-service-name': 'event-driven'
  application: applicationName
}

var abbrs = loadJsonContent('./abbreviations.json')

resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: '${abbrs.resourcesResourceGroups}${environmentName}-${resourceToken}'
  location: location
  tags: defaultTags
}


module serviceBus 'modules/servicebus/service-bus.bicep' = {
  name: '${deployment().name}--servicebus'
  scope: resourceGroup(rg.name)
  params: {
    serviceBusNamespaceName: '${abbrs.serviceBusNamespaces}${resourceToken}'
    location: location
  }
}

module springApps 'modules/springapps/spring-apps.bicep' = {
  name: '${deployment().name}--asa'
  scope: resourceGroup(rg.name)
  params: {
    location: location
    applicationName: applicationName
    resourceTags: defaultTags
    springAppsName: 'asa-${resourceToken}'
    environmentVariables: {
      SERVICE_BUS_CONNECTION_STRING: serviceBus.outputs.SERVICE_BUS_CONNECTION_STRING
    }
  }
}
