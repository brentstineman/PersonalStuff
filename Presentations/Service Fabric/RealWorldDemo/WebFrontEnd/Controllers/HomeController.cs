using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;

//using Microsoft.ServiceFabric.Services.Client;
using System.Fabric;
using Microsoft.ServiceFabric.Services.Communication.Client;
using Microsoft.ServiceFabric.Services.Client;
using System.Threading;
using Newtonsoft.Json.Linq;
using System.Net.Http;

namespace WebFrontEnd.Controllers
{

    public class HomeController : Controller
    {
        private static readonly Uri serviceUri;

        private static readonly ServicePartitionResolver resolver;
 
        //private static readonly HttpCommunicationClientFactory communicationFactory;

        static HomeController()
        {
            serviceUri = new Uri(FabricRuntime.GetActivationContext().ApplicationName + "/APIBackEnd");

            resolver  = ServicePartitionResolver.GetDefault();
        }

        public IActionResult Index()
        {
            Task<string> myTask = GetAPIResult();
            myTask.Wait();

            ViewData["Message"] = myTask.Result;

            return View();
        }

        public async Task<string> GetAPIResult()
        {
            String responseString = string.Empty;

            ResolvedServicePartition mypartition = await resolver.ResolveAsync(serviceUri, new ServicePartitionKey(), new CancellationToken());

            ResolvedServiceEndpoint endpoint = mypartition.GetEndpoint();

            JObject addresses = JObject.Parse(endpoint.Address);
            string address = (string)addresses["Endpoints"].First();

            HttpClient client = new HttpClient();
            HttpRequestMessage request = new HttpRequestMessage(HttpMethod.Get, address + "/api/values");
            HttpResponseMessage response = await client.SendAsync(request);

            if (response.IsSuccessStatusCode)
            {
                responseString = await response.Content.ReadAsStringAsync();
            }

            return responseString;
        }

        public IActionResult About()
        {
            ViewData["Message"] = "Your application description page.";

            return View();
        }

        public IActionResult Contact()
        {
            ViewData["Message"] = "Your contact page.";

            return View();
        }

        public IActionResult Error()
        {
            return View();
        }
    }
}
