using System;
using System.Net.Http;
using System.Text;
using System.Threading.Tasks;
using Azure.Identity;
using Azure.Security.KeyVault.Secrets;
using Newtonsoft.Json;

class Program
{
    //for private endpoint configuration, add the private endpoint URI//
    private static readonly string endpoint = "<AITranslatorFQDN>";
    private static readonly string location = "<USGovRegion>";

    static async Task Main(string[] args)
    {
        try
        {
            // Create a secret client to retrieve the Translator API access key from Key Vault.
            SecretClient secretClient = new SecretClient(new Uri("<keyVaultURI>"), new DefaultAzureCredential());

            // Retrieve the Translator API access key from Key Vault.
            KeyVaultSecret translatorApiSecret = await secretClient.GetSecretAsync("<TranslatorApiAccessKeySecretName>");

            string key = translatorApiSecret.Value;

            Console.WriteLine($"Retrieved secret: {translatorApiSecret.Name} - {translatorApiSecret.Value}");

            //ensure full route is added /translator/test/v3.0
            string route = "/translator/text/v3.0/translate?api-version=3.0&from=en&to=sw&to=it";
            string textToTranslate = "Hello, friend! What did you do today?";
            object[] body = new object[] { new { Text = textToTranslate } };
            var requestBody = JsonConvert.SerializeObject(body);

            using (var client = new HttpClient())
            using (var request = new HttpRequestMessage())
            {
                // Build the request.
                request.Method = HttpMethod.Post;
                request.RequestUri = new Uri(endpoint + route);
                request.Content = new StringContent(requestBody, Encoding.UTF8, "application/json");
                request.Headers.Add("Ocp-Apim-Subscription-Key", key);
                request.Headers.Add("Ocp-Apim-Subscription-Region", location);

                // Send the request and get response.
                HttpResponseMessage response = await client.SendAsync(request).ConfigureAwait(false);
                // Read response as a string.
                string result = await response.Content.ReadAsStringAsync();
                Console.WriteLine(result);
            }
        }
        catch (Exception ex)
        {
            Console.WriteLine($"Error: {ex}");
        }
    }
}
