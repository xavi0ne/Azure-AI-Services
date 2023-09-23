param storageDetails object
param tag string 
param location string 
param logAnalyitcsID string
param eventHubID string
param eventHub string
param blobpvtDnsZoneID string

resource storageDeployment 'Microsoft.Storage/storageAccounts@2022-05-01' = {
  name: storageDetails.storageName
  location: location
  tags: {
    financial: tag
  }
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    accessTier: 'Hot'
    allowBlobPublicAccess: false
    allowCrossTenantReplication: false
    allowSharedKeyAccess: true
    encryption: {
      keySource: 'Microsoft.Storage'
      requireInfrastructureEncryption: true
      services: {
        blob: {
          enabled: true
          keyType: 'Account'
        }
        file: {
          enabled: true
          keyType: 'Account'
        }
        queue: {
          enabled: true
          keyType: 'Service'
        }
        table: {
          enabled: true
          keyType: 'Service'
        }
      }
    }
    isHnsEnabled: false
    isNfsV3Enabled: false
    keyPolicy: {
      keyExpirationPeriodInDays: 7
    }
    largeFileSharesState: 'Disabled'
    minimumTlsVersion: 'TLS1_2'
    publicNetworkAccess: 'Disabled'
    networkAcls: {
      bypass: 'AzureServices'
      defaultAction: 'Deny'
    }
    supportsHttpsTrafficOnly: true
  }
}

resource storageDiagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  scope: storageDeployment
  name: '${storageDetails.storageName}-ds'
  properties: {
    workspaceId: logAnalyitcsID
    eventHubAuthorizationRuleId: eventHubID
    eventHubName: eventHub
    metrics: [
      {
        category: 'Transaction'
        enabled: true
      }
    ]
  }
}

resource storageAccountBlob 'Microsoft.Storage/storageAccounts/blobServices@2022-05-01' = {
  name: 'default'
  parent: storageDeployment
  properties: {
    containerDeleteRetentionPolicy: {
      enabled: true
      days: 7
    }
    deleteRetentionPolicy: {
      enabled: true
      days: 7
    }
  }

}

resource storageAccountContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2022-05-01' = {
  name: storageDetails.containerName
  parent: storageAccountBlob
}

resource diagnosticsBlob 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  scope: storageAccountBlob
  name: '${storageDetails.storageName}-ds'
  properties: {
    workspaceId: logAnalyitcsID
    eventHubAuthorizationRuleId: eventHubID
    eventHubName: eventHub
    logs: [
      {
        category: 'storageRead'
        enabled: true
      }
    ]
  }
}

resource privateEndpoint 'Microsoft.Network/privateEndpoints@2021-05-01' = {
  name: '${storageDetails.storageName}-sv'
  location: location
  tags: {
    financial: tag
  }
  properties: {
    subnet: {
      id: storageDetails.subnetID
    }
    privateLinkServiceConnections: [
      {
        name: '${storageDetails.storageName}-sv'
        properties: {
          privateLinkServiceId: resourceId(resourceGroup().name, 'Microsoft.Storage/storageAccounts', '${storageDetails.storageName}')
          groupIds: [
            'blob'
          ]
        }
      }
    ]
    ipConfigurations: [
      {
        name: '${storageDetails.storageName}-sv'
        properties: {
        
          groupId: 'blob'
        
          memberName: 'blob'
          
          privateIPAddress: storageDetails.storagePrivateEndPointIP
        }
      }  
    ]
  }
  dependsOn: [
    storageDeployment
  ]
}

resource pvtEndpointDnsGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2022-05-01' = {
  name: '${storageDetails.storageName}-sv/default'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'config1'
        properties: {
          privateDnsZoneId: blobpvtDnsZoneID
        }
      }
    ]
  }
  dependsOn: [
    privateEndpoint
  ]
}
output storageID string = storageDeployment.id
