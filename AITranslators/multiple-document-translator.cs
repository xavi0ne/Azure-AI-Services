using Azure;
using Azure.AI.Translation.Document;
using Azure.Identity;
using Azure.Security.KeyVault.Secrets;

string endpoint = "<AITranslatorFQDN>";

// Create a secret client to retrieve the Translator API access key from Key Vault.
SecretClient secretClient = new SecretClient(new Uri("<keyVaultURI>"), new DefaultAzureCredential());

// Retrieve the Translator API access key from Key Vault.
KeyVaultSecret translatorApiSecret = await secretClient.GetSecretAsync("<TranslatorKeySecretName>");

string apiKey = translatorApiSecret.Value;

var client = new DocumentTranslationClient(new Uri(endpoint), new AzureKeyCredential(apiKey));

Uri source1SasUri = new Uri("<sourceContainerURI>");
Uri source2SasUri = new Uri("<source2ContainerURI>");
Uri frenchTargetSasUri = new Uri("<frenchContainerURI>");
Uri arabicTargetSasUri = new Uri("<arabicContainerURI>");
Uri spanishTargetSasUri = new Uri("<spanishContainerURI>");



var input1 = new DocumentTranslationInput(source1SasUri, frenchTargetSasUri, "fr");
input1.AddTarget(spanishTargetSasUri, "es");

var input2 = new DocumentTranslationInput(source2SasUri, arabicTargetSasUri, "ar");

var inputs = new List<DocumentTranslationInput>()
    {
        input1,
        input2
    };

DocumentTranslationOperation operation = await client.StartTranslationAsync(inputs);

await operation.WaitForCompletionAsync();

await foreach (DocumentStatusResult document in operation.GetValuesAsync())
{
    Console.WriteLine($"Document with Id: {document.Id}");
    Console.WriteLine($"  Status:{document.Status}");
    if (document.Status == DocumentTranslationStatus.Succeeded)
    {
        Console.WriteLine($"  Translated Document Uri: {document.TranslatedDocumentUri}");
        Console.WriteLine($"  Translated to language code: {document.TranslatedToLanguageCode}.");
        Console.WriteLine($"  Document source Uri: {document.SourceDocumentUri}");
    }
    else
    {
        Console.WriteLine($"  Document source Uri: {document.SourceDocumentUri}");
        Console.WriteLine($"  Error Code: {document.Error.Code}");
        Console.WriteLine($"  Message: {document.Error.Message}");
    }
}
