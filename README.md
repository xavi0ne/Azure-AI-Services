AZURE AI TRANSLATOR: Secure Text and Document Translation 

Azure AI Translators is a Cloud-based neural machine translation service part of the Azure AI Services umbrella. 
It's the muscle behind intelligent, multi-language operations for applications, with over 100 supported languages.

DETAILS

BICEP TEMPLATES

The ‘ai-translators-maindeploy.bicep’ template assumes that you are a US regulated entity with requirements for network isolation, access control, and least privilege security controls. For deployment to be successful, please ensure the following pre-requisites:

  •	The AI Translators, key vault, and Storage Account should be deployed in the same Azure US Government region.
  •	Template assumes the following resources exist in the subscription prior to deployment. Please provide the resource IDs for the following existing resources:
  
      o	Log Analytics Workspace
      o	Event Hub
      o	Key Vault Private DNS Zone
      o	Translator Private DNS Zone
      o	Storage Account Blob Private DNS Zone
      
  •	Template assumes a virtual network already exists and is linked to the private DNS zones. 
  •	Subnet ID parameter must pertain to the linked virtual network for each private DNS zone. 
  
MANAGED IDENTITIES
    
The AI Translator must have the following role assignment configured: 

  •	Storage Blob Data Contributor at resource scope
  
The Virtual Machine hosting the App must have the following role assignment configured:

  •	Key Vault Secret User

C# SAMPLES

The ‘translator-text-app.cs’ assumes you have an existing AI Translator resource, an existing Key Vault, and the secret created for the translator key. For a successful run, please ensure the following pre-requisites:

  •	Provide the FQDN (private endpoint) for the AI Translator.
  •	Provide AI Translator’s existing location or region. 
  •	Provide existing key vault URI.
  •	Provide the secret name for the translator key.

The ‘multiple-document-translator.cs’ assumes you have an existing AI Translator resource, a Storage Account with Blob services, an existing Key Vault, and the secret created for the translator key. The Storage Account must also have a source container, a French container, an Arabic container, and a Spanish container created. For a successful run, please ensure the following pre-requisites:

  •	Provide the FQDN (private endpoint) for the AI Translator.
  •	Provide AI Translator’s existing location or region. 
  •	Provide existing key vault URI.
  •	Provide the secret name for the translator key.
  •	Provide container URIs. 
