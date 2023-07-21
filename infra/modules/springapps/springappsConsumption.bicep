param location string = resourceGroup().location
param asaManagedEnvironmentName string
param asaInstanceName string
param appName string
param tags object = {}
param relativePath string
param appInsightName string
param logAnalyticsName string
param environmentVariables object = {}

resource asaManagedEnvironment 'Microsoft.App/managedEnvironments@2022-11-01-preview' = {
  name: asaManagedEnvironmentName
  location: location
  tags: tags
  properties: {
	workloadProfiles: [
	  {
	    name: 'Consumption'
		workloadProfileType: 'Consumption'
	  }
    ]
    appLogsConfiguration: {
	  destination: 'log-analytics'
	  logAnalyticsConfiguration: {
		customerId: logAnalytics.properties.customerId
		sharedKey: logAnalytics.listKeys().primarySharedKey
	  }
	}
  }
}

resource asaInstance 'Microsoft.AppPlatform/Spring@2023-03-01-preview' = {
  name: asaInstanceName
  location: location
  tags: union(tags, { 'azd-service-name': appName })
  sku: {
    name: 'S0'
	tier: 'StandardGen2'
  }
  properties: {
	managedEnvironmentId: asaManagedEnvironment.id
  }
}

resource asaApp 'Microsoft.AppPlatform/Spring/apps@2023-03-01-preview' = {
  name: appName
  location: location
  parent: asaInstance
  properties: {
  }
}

resource asaDeployment 'Microsoft.AppPlatform/Spring/apps/deployments@2023-03-01-preview' = {
  name: 'default'
  parent: asaApp
  properties: {
    source: {
      type: 'Jar'
      relativePath: relativePath
      runtimeVersion: 'Java_17'
    }
    deploymentSettings: {
      resourceRequests: {
        cpu: '2'
        memory: '4Gi'
      }
      environmentVariables: environmentVariables
    }
  }
}

resource springAppsMonitoringSettings 'Microsoft.AppPlatform/Spring/monitoringSettings@2023-03-01-preview' = {
  name: 'default' // The only supported value is 'default'
  parent: asaInstance
  properties: {
    traceEnabled: true
    appInsightsInstrumentationKey: applicationInsights.properties.InstrumentationKey
  }
}

resource applicationInsights 'Microsoft.Insights/components@2020-02-02' existing = if (!(empty(appInsightName))) {
  name: appInsightName
}

resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2021-12-01-preview' existing = {
  name: logAnalyticsName
}

output name string = asaApp.name
output uri string = 'https://${asaApp.properties.url}'