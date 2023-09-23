param keyVaultDetails array = [
 {
  keyVaultName: '<keyVaultName>'
  keyVaultResourceGroup: '<resourceGroupName>'
  keyVaultPrivateEndpointIP: '<PrivateIP>'
  tenantId: '<tenantId>'
  subnetID: '<subnetId>'
 }
]
param translatorDetails array = [
  {
    translatorName: '<translatorName>'
    translatorPrivateEndPointIP: '<PrivateIP>'
    translatorResourceGroup: '<resourceGroupName>'
    skuName: 'S1'
    kind: 'TextTranslation'
    subnetID: '<subnetId>'
  }

]
param storageDetails array = [
  {
    storageName: 'translatorsg'
    storagePrivateEndPointIP:'<PrivateIP>'
    storageResourceGroup: '<resourceGroupName>'
    containerName: 'sourcedocuments'
    subnetID: '<subnetId>'
  }
]
param location string = '<location>'
param tag string = '<tagName>'
param subscriptionId string = '<subscriptionId>'
param DNSZoneresourceGroup string ='<resourceGroupName>'

var logAnalyitcsID = <existingLogAnalyticsId>
var eventHubID = '<existingEventHubId>'
var eventHub = '<existingEventHubName>'
var kvPvDnsZoneID = '<existingKeyVaultPrivateDNSZoneId>'
var transPvDnsZoneID = <existingCognitiveServicesPrivateDNSZoneId>
var blobpvtDnsZoneID = '<existingBlobPrivateDNSZoneId>'

module kv 'module-keyVault.bicep' = [ for (kv, i) in keyVaultDetails: {
  name: 'deploycsKeyvault'
  scope: resourceGroup(kv.keyVaultResourceGroup)
  params: {
    keyVaultDetails: kv
    tag: tag
    kvPvDnsZoneID: kvPvDnsZoneID
    location: location
    logAnalyitcsID: logAnalyitcsID
    eventHub: eventHub
    eventHubID: eventHubID
  }
}]
module trans 'module-ai-translator.bicep' = [ for (trans, i) in translatorDetails: {
  name: 'deployTranslator${i}'
  scope: resourceGroup(trans.translatorResourceGroup)
  params: {
    location: location
    eventHub: eventHub
    eventHubID: eventHubID
    tag: tag
    logAnalyitcsID: logAnalyitcsID
    transPvDnsZoneID: transPvDnsZoneID
    translatorDetails: trans
  }
}]
module storageBlob 'module-storageBlob.bicep' = [ for (stg, i) in storageDetails: {
  name: 'deployStorage${i}'
  scope: resourceGroup(stg.storageResourceGroup)
  params: {
    tag: tag
    location: location
    storageDetails: stg
    logAnalyitcsID: logAnalyitcsID
    eventHub: eventHub
    eventHubID: eventHubID
    blobpvtDnsZoneID: blobpvtDnsZoneID
  }
}]
