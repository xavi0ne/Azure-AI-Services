param translatorDetails object
param location string
param tag string
param transPvDnsZoneID string
param logAnalyitcsID string
param eventHubID string
param eventHub string

resource tazTranslator 'Microsoft.CognitiveServices/accounts@2022-12-01' = {
  name: translatorDetails.translatorName
  location: location
  tags: {
    financial: tag
  }
  sku: {
    name: 'S1'
  }
  kind: 'TextTranslation'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    customSubDomainName: translatorDetails.translatorName
    networkAcls: {
      defaultAction: 'Allow'
    }
    publicNetworkAccess: 'Disabled'
  }
}
resource diagnosticsTrans 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  scope: tazTranslator
  name: '${translatorDetails.translatorName}-ds'
  properties: {
    workspaceId: logAnalyitcsID
    eventHubAuthorizationRuleId: eventHubID
    eventHubName: eventHub
    logs: [
      {
        category: 'Audit'
        enabled: true
      }
      {
        category: 'RequestResponse'
        enabled: true
      }
      {
        category: 'Trace'
        enabled: true
      }
    ]
  }
}
resource privateEndpoint 'Microsoft.Network/privateEndpoints@2021-05-01' = {
  name: '${translatorDetails.translatorName}-sv'
  location: location
  tags: {
    financial: tag
  }
  properties: {
    subnet: {
      id: translatorDetails.subnetID
    }
    privateLinkServiceConnections: [
      {
        name: '${translatorDetails.translatorName}-sv'
        properties: {
          privateLinkServiceId: tazTranslator.id
          groupIds: [
            'account'
          ]
        }
      }
    ]
    ipConfigurations: [
      {
        name: '${translatorDetails.translatorName}-sv'
        properties: {
          
          groupId: 'account'
          
          memberName: 'default'
            
          privateIPAddress: translatorDetails.translatorPrivateEndPointIP
        }
      }  
    ]
  }
}
resource pvtDnsGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2022-05-01' = {
  name: '${translatorDetails.translatorName}-sv/default'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'config1'
        properties: {
          privateDnsZoneId: transPvDnsZoneID
        }
      }
    ]
  }
  dependsOn: [
    privateEndpoint
  ]
}
