param keyVaultDetails object
param location string 
param tag string 
param kvPvDnsZoneID string
param eventHub string
param eventHubID string
param logAnalyitcsID string


resource kv 'Microsoft.KeyVault/vaults@2022-07-01' = {
  name: keyVaultDetails.keyVaultName
  location: location
  tags: {
    financial: tag
  }
  properties: {
    sku: {
      family: 'A'
      name: 'premium'
    }
    enableRbacAuthorization: true
    tenantId: keyVaultDetails.tenantId 
    enabledForDeployment: true
    enabledForDiskEncryption: true
    enableSoftDelete: true
    softDeleteRetentionInDays: 90
    vaultUri: 'https://${keyVaultDetails.keyVaultName}.vault.usgovcloudapi.net'
    provisioningState: 'Succeeded'
    publicNetworkAccess: 'disabled'
    enabledForTemplateDeployment: true
    enablePurgeProtection: true
    networkAcls: {
      bypass: 'AzureServices'
      defaultAction: 'Deny'
    }
  }
}
resource diagnosticsKv 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  scope: kv
  name: '${keyVaultDetails.keyVaultName}-ds'
  properties: {
    workspaceId: logAnalyitcsID
    eventHubAuthorizationRuleId: eventHubID
    eventHubName: eventHub
    logs: [
      {
        category: 'AuditEvent'
        enabled: true
      }
      {
        category: 'AzurePolicyEvaluationDetails'
        enabled: true
      }
    ]
  }
}

resource privateEndpoint 'Microsoft.Network/privateEndpoints@2021-05-01' = {
  name: '${kv.name}-sv'
  tags: {
    financial: tag
  }
  location: location
  properties: {
    subnet: {
      id: keyVaultDetails.subnetID
    }
    privateLinkServiceConnections: [
      {
        name: '${kv.name}-sv'
        properties: {
          privateLinkServiceId: kv.id
          groupIds: [
            'vault'
          ]
        }
      }
    ]
    ipConfigurations: [
      {
        name: '${kv.name}-sv'
        properties: {
          groupId: 'vault'
          memberName: 'default'
          privateIPAddress: keyVaultDetails.keyVaultPrivateEndpointIP
        }
      }
    ]
  }
}

resource pvtEndpointDnsGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2022-05-01' = {
  name: '${kv.name}-sv/default'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'config1'
        properties: {
          privateDnsZoneId: kvPvDnsZoneID
        }
      }
    ]
  }
  dependsOn: [
    privateEndpoint
  ]
}
