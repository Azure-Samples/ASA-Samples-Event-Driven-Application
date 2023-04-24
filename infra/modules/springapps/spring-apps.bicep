param location string
param springAppsName string
param applicationName string
param environmentVariables object = {}
param resourceTags object = {}

resource springAppsService 'Microsoft.AppPlatform/Spring@2022-12-01' = {
  name: springAppsName
  location: location
  tags: resourceTags
  sku: {
    name: 'B0'
    tier: 'Basic'
  }
}

resource springApp 'Microsoft.AppPlatform/Spring/apps@2022-12-01' = {
  name: '${springAppsService.name}/${applicationName}'
  location: location
  properties: {
    public: true
    activeDeploymentName: 'default'
    httpsOnly: false
    temporaryDisk: {
      sizeInGB: 5
      mountPath: '/tmp'
    }
    persistentDisk: {
      sizeInGB: 0
      mountPath: '/persistent'
    }
    enableEndToEndTLS: false
  }
}

resource springAppsDeployment 'Microsoft.AppPlatform/Spring/apps/deployments@2022-12-01' = {
  name: '${springApp.name}/default'
  properties: {
    source: {
      type: 'Jar'
      relativePath: '<default>'
      jvmOptions: '-Xms2048m -Xmx2048m'
      runtimeVersion: 'Java_17'
    }
    deploymentSettings: {
      cpu: 1
      memoryInGB: 2
      resourceRequests: {
        cpu: '1'
        memory: '2Gi'
      }
      environmentVariables: environmentVariables
    }
  }
}