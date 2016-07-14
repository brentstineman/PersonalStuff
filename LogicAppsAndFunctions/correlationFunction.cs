#r "Newtonsoft.Json"
#r "System.Data"

using System;
using System.Net;
using Newtonsoft.Json;
using System.Data.SqlClient;

public static async Task<object> Run(HttpRequestMessage req, TraceWriter log)
{
    log.Info($"Webhook was triggered!");

    string jsonContent = await req.Content.ReadAsStringAsync();
    dynamic data = JsonConvert.DeserializeObject(jsonContent);

    if (data.customer == null || data.product == null) {
        return req.CreateResponse(HttpStatusCode.BadRequest, new {
            error = "Please pass customer/product properties in the input object"
        });
    }
    
    SqlConnection sqlConnection1 = new SqlConnection("{your connection string}");
    SqlCommand cmd = new SqlCommand();

    cmd.CommandText = "select count(Distinct Product) from Orders where Customer = '" + data.customer + "' AND complete = 0";
    cmd.CommandType = System.Data.CommandType.Text;
    cmd.Connection = sqlConnection1;

    sqlConnection1.Open();

    int productCnt;
    int.TryParse(cmd.ExecuteScalar().ToString(), out productCnt);

    log.Info("Product Count for Customer '" + data.customer + "' is " + productCnt.ToString());

    sqlConnection1.Close();

    if (productCnt > 1)
    {
        return req.CreateResponse(HttpStatusCode.OK, new {
            greeting = $"Customer Order is complete!"
        });
    } else {
        return req.CreateResponse(HttpStatusCode.BadRequest, new {
            greeting = $"Order Incomplete!"
        });
    }
}
