using System;
using System.IO;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.Http;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json;
using ChatOps_Bootstrap.Models;

namespace ChatOps_Bootstrap.Function
{
    public static class OrderProcessor
    {
        [FunctionName("OrderProcessor")]
        public static async Task<IActionResult> Run(
            [HttpTrigger(AuthorizationLevel.Function, "post", Route = null)] HttpRequest req,
            [CosmosDB(
                databaseName: "OrdersDatabase",
                containerName: "OrdersContainer",
                Connection = "CosmosDBConnection")] IAsyncCollector<Order> ordersCollector,
            ILogger log)
        {
            log.LogInformation("Order processing request received");

            string requestBody = await new StreamReader(req.Body).ReadToEndAsync();
            
            try
            {
                var order = JsonConvert.DeserializeObject<Order>(requestBody);
                
                if (order == null || string.IsNullOrEmpty(order.OrderID) || string.IsNullOrEmpty(order.ProductID) || order.Quantity <= 0)
                {
                    return new BadRequestObjectResult("Invalid order data. Please provide orderID, productID, and quantity.");
                }

                // Generate a unique ID for the order if not provided
                if (string.IsNullOrEmpty(order.Id))
                {
                    order.Id = Guid.NewGuid().ToString();
                }

                // Set creation timestamp
                order.CreatedAt = DateTime.UtcNow;

                // Save to Cosmos DB
                await ordersCollector.AddAsync(order);

                log.LogInformation($"Order {order.OrderID} processed successfully");
                
                return new OkObjectResult(new { 
                    message = "Order processed successfully", 
                    orderId = order.OrderID,
                    id = order.Id
                });
            }
            catch (Exception ex)
            {
                log.LogError($"Error processing order: {ex.Message}");
                return new StatusCodeResult(StatusCodes.Status500InternalServerError);
            }
        }
    }
}