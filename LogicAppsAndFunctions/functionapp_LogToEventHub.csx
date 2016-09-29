#r "Newtonsoft.Json"
#r "Microsoft.ServiceBus"

using System;
using System.Net;
using System.Text;
using Microsoft.ServiceBus;
using Microsoft.ServiceBus.Messaging;
using Newtonsoft.Json;
using System.Dynamic;

public static async Task<object> Run(HttpRequestMessage req, TraceWriter log)
{
    string jsonContent = await req.Content.ReadAsStringAsync();
    log.Info($"Request Payload: " + jsonContent);

    dynamic requestObj = JsonConvert.DeserializeObject(jsonContent);

    // do any data inspection here
    if (requestObj.customer == null) {
        log.Error("Missing 'customer' parameter");
        return req.CreateResponse(HttpStatusCode.BadRequest, new {
            error = "Please pass customer in the input object"
        });
    } 

    // create our log message
    dynamic logMsg = new ExpandoObject();
    logMsg.jobID = requestObj.JobID;
    logMsg.customer = requestObj.customer;
    logMsg.status = requestObj.status;
    logMsg.payload = requestObj.job_payload;

    // Create EventHubClient object
    EventHubClient client = EventHubClient.CreateFromConnectionString({your connection string}, {hubname});

    // create object to be sent to the even hub
    var serializedString = JsonConvert.SerializeObject(logMsg);
    EventData data = new EventData(Encoding.UTF8.GetBytes(serializedString));

    // Set user properties if needed
    data.Properties.Add("Type", "Logging");

    // Send the metric to Event Hub
    client.Send(data);

    log.Info($"Event Logged");

    return req.CreateResponse(HttpStatusCode.OK, "event logged");
}
