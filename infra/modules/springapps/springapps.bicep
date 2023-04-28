param location string
param asaInstanceName string
param appName string
param tags object = {}
param relativePath string
param keyVaultName string

resource asaInstance 'Microsoft.AppPlatform/Spring@2022-12-01' = {
  name: asaInstanceName
  location: location
  tags: tags
  sku: {
    name: 'B0'
    tier: 'Basic'
  }
}

resource asaApp 'Microsoft.AppPlatform/Spring/apps@2022-12-01' = {
  name: appName
  location: location
  parent: asaInstance
  identity: {
	type: 'SystemAssigned'
  }
  properties: {
    public: true
    activeDeploymentName: 'default'
  }
}

resource asaDeployment 'Microsoft.AppPlatform/Spring/apps/deployments@2022-12-01' = {
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
        cpu: '1'
        memory: '2Gi'
      }
      environmentVariables: {
	    AZURE_KEY_VAULT_ENDPOINT: keyVault.properties.vaultUri
	  }
    }
  }
}

resource keyVault 'Microsoft.KeyVault/vaults@2022-07-01' existing = if (!(empty(keyVaultName))) {
  name: keyVaultName
}

output identityPrincipalId string = asaApp.identity.principalId
output name string = asaApp.name
output uri string = 'https://${asaApp.properties.url}'