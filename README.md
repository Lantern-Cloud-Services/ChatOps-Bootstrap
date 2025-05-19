# ChatOps-Bootstrap

## Order Processor API

An HTTP-triggered Azure Function that processes orders and stores them in a Cosmos DB database.

### API Endpoint

`POST /api/OrderProcessor`

### Request Payload

```json
{
  "orderID": "ORD123",
  "productID": "PROD456",
  "quantity": 5
}
```

### Response (Success)

```json
{
  "message": "Order processed successfully",
  "orderId": "ORD123",
  "id": "generated-guid"
}
```

### Infrastructure

The solution includes Terraform configuration that provisions:
- Azure Function App
- Cosmos DB account, database, and container

### Local Development

1. Install Azure Functions Core Tools
2. Run `func start` from the project root
3. Use Cosmos DB Emulator for local development