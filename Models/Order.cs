using System;
using Newtonsoft.Json;

namespace ChatOps_Bootstrap.Models
{
    public class Order
    {
        [JsonProperty("id")]
        public string Id { get; set; }

        [JsonProperty("orderID")]
        public string OrderID { get; set; }

        [JsonProperty("productID")]
        public string ProductID { get; set; }

        [JsonProperty("quantity")]
        public int Quantity { get; set; }

        [JsonProperty("createdAt")]
        public DateTime CreatedAt { get; set; }
    }
}