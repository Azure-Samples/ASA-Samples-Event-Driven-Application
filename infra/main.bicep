targetScope = 'subscription'

@minLength(1)
@maxLength(64)
@description('Name of the the environment which is used to generate a short unique hash used in all resources.')
param environmentName string

@minLength(1)
@description('Primary location for all resources')
param location string

@allowed([
  'consumption'
  'standard'
])
param plan string = 'consumption'

@description('Id of the user or app to assign application roles')
param principalId string = ''

@description('Relative Path of ASA Jar')
param relativePath string

param logAnalyticsName string = ''
param applicationInsightsName string = ''
param applicationInsightsDashboardName string = ''

var abbrs = loadJsonContent('./abbreviations.json')
var resourceToken = toLower(uniqueString(subscription().id, environmentName, location))
var serviceBusNamespaceName = '${abbrs.serviceBusNamespaces}${resourceToken}'
var asaManagedEnvironmentName = '${abbrs.appContainerAppsManagedEnvironment}${resourceToken}'
var asaInstanceName = '${abbrs.springApps}${resourceToken}'
var appName = 'simple-event-driven-app'
var tags = {
  'azd-env-name': environmentName
  'spring-cloud-azure': 'true'
}

resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: '${abbrs.resourcesResourceGroups}${environmentName}-${resourceToken}'
  location: location
  tags: tags
}

module serviceBus 'modules/servicebus/servicebus.bicep' = {
  name: '${deployment().name}--sb'
  scope: resourceGroup(rg.name)
  params: {
    serviceBusNamespaceName: serviceBusNamespaceName
    location: location
    tags: tags
  }
}

module springAppsConsumption 'modules/springapps/springappsConsumption.bicep' = if (plan == 'consumption') {
  name: '${deployment().name}--asaconsumption'
  scope: resourceGroup(rg.name)
  params: {
    location: location
	appName: appName
	tags: tags
	asaManagedEnvironmentName: asaManagedEnvironmentName
	asaInstanceName: asaInstanceName
	relativePath: relativePath
	appInsightName: monitoring.outputs.applicationInsightsName
	logAnalyticsName: monitoring.outputs.logAnalyticsWorkspaceName
	environmentVariables: {
	  SERVICE_BUS_CONNECTION_STRING: serviceBus.outputs.SERVICE_BUS_CONNECTION_STRING
	}
  }
  dependsOn: [
    serviceBus
  ]
}

module springAppsStandard 'modules/springapps/springappsStandard.bicep' = if (plan == 'standard') {
  name: '${deployment().name}--asastandard'
  scope: resourceGroup(rg.name)
  params: {
    location: location
    appName: appName
    tags: tags
    asaInstanceName: asaInstanceName
    relativePath: relativePath
    appInsightName: monitoring.outputs.applicationInsightsName
    laWorkspaceResourceId: monitoring.outputs.logAnalyticsWorkspaceId
    environmentVariables: {
	  SERVICE_BUS_CONNECTION_STRING: serviceBus.outputs.SERVICE_BUS_CONNECTION_STRING
	}
  }
  dependsOn: [
    serviceBus
  ]
}

// Monitor application with Azure Monitor
module monitoring './modules/monitor/monitoring.bicep' = {
  name: 'monitoring'
  scope: resourceGroup(rg.name)
  params: {
    location: location
    tags: tags
    logAnalyticsName: !empty(logAnalyticsName) ? logAnalyticsName : '${abbrs.operationalInsightsWorkspaces}${resourceToken}'
    applicationInsightsName: !empty(applicationInsightsName) ? applicationInsightsName : '${abbrs.insightsComponents}${resourceToken}'
    applicationInsightsDashboardName: !empty(applicationInsightsDashboardName) ? applicationInsightsDashboardName : '${abbrs.portalDashboards}${resourceToken}'
  }
}

output AZURE_RESOURCE_GROUP string = rg.name