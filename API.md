# 📘 API Documentation

## Base URL

```
http://localhost:3000/api
```

---

## 🔐 Authentication

### Register

```http
POST /api/auth/register
```

**Request Body:**
```json
{
  "email": "user@example.com",
  "password": "password123",
  "firstName": "John",
  "lastName": "Doe"
}
```

**Response:**
```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "id": "uuid",
    "email": "user@example.com",
    "firstName": "John",
    "lastName": "Doe",
    "role": "CUSTOMER"
  }
}
```

### Login

```http
POST /api/auth/login
```

**Request Body:**
```json
{
  "email": "user@example.com",
  "password": "password123"
}
```

**Response:** Same as Register

---

## 👤 Users

### Get All Users

```http
GET /api/users
```

**Headers:**
```
Authorization: Bearer {token}
```

**Response:**
```json
[
  {
    "id": "uuid",
    "email": "user@example.com",
    "firstName": "John",
    "lastName": "Doe",
    "role": "CUSTOMER",
    "isActive": true,
    "createdAt": "2024-01-01T00:00:00.000Z"
  }
]
```

### Get User by ID

```http
GET /api/users/:id
```

### Update User

```http
PUT /api/users/:id
```

**Request Body:**
```json
{
  "firstName": "Jane",
  "lastName": "Smith"
}
```

### Delete User

```http
DELETE /api/users/:id
```

---

## 📦 Products

### Get All Products

```http
GET /api/products
```

**Query Parameters:**
- `categoryId` (optional): Filter by category

**Response:**
```json
[
  {
    "id": "uuid",
    "name": "Laptop Gaming",
    "description": "High performance laptop",
    "price": 1299.99,
    "stock": 10,
    "imageUrl": "https://example.com/image.jpg",
    "categoryId": "uuid",
    "isActive": true,
    "createdAt": "2024-01-01T00:00:00.000Z",
    "category": {
      "id": "uuid",
      "name": "Electronics"
    }
  }
]
```

### Get Product by ID

```http
GET /api/products/:id
```

### Create Product

```http
POST /api/products
```

**Request Body:**
```json
{
  "name": "Laptop Gaming",
  "description": "High performance laptop",
  "price": 1299.99,
  "stock": 10,
  "categoryId": "uuid",
  "imageUrl": "https://example.com/image.jpg"
}
```

### Update Product

```http
PUT /api/products/:id
```

**Request Body:**
```json
{
  "name": "Updated Product Name",
  "price": 1199.99,
  "stock": 15
}
```

### Delete Product

```http
DELETE /api/products/:id
```

---

## 🛒 Shopping Cart

### Get Cart

```http
GET /api/cart?userId={userId}
```

**Response:**
```json
{
  "id": "uuid",
  "userId": "uuid",
  "items": [
    {
      "id": "uuid",
      "productId": "uuid",
      "quantity": 2,
      "price": 1299.99
    }
  ],
  "createdAt": "2024-01-01T00:00:00.000Z"
}
```

### Add Item to Cart

```http
POST /api/cart/items
```

**Request Body:**
```json
{
  "userId": "uuid",
  "productId": "uuid",
  "quantity": 1,
  "price": 1299.99
}
```

### Update Cart Item

```http
PUT /api/cart/items/:productId?userId={userId}
```

**Request Body:**
```json
{
  "quantity": 3
}
```

### Remove Item from Cart

```http
DELETE /api/cart/items/:productId?userId={userId}
```

### Clear Cart

```http
DELETE /api/cart?userId={userId}
```

---

## 📋 Orders

### Get All Orders

```http
GET /api/orders
```

**Query Parameters:**
- `userId` (optional): Filter by user

**Response:**
```json
[
  {
    "id": "uuid",
    "userId": "uuid",
    "status": "PENDING",
    "totalAmount": 1299.99,
    "shippingAddress": "123 Main St, City",
    "items": [
      {
        "id": "uuid",
        "productId": "uuid",
        "quantity": 1,
        "price": 1299.99
      }
    ],
    "createdAt": "2024-01-01T00:00:00.000Z"
  }
]
```

### Get Order by ID

```http
GET /api/orders/:id
```

### Create Order

```http
POST /api/orders
```

**Request Body:**
```json
{
  "userId": "uuid",
  "items": [
    {
      "productId": "uuid",
      "quantity": 1,
      "price": 1299.99
    }
  ],
  "shippingAddress": "123 Main St, City, Country"
}
```

### Update Order Status

```http
PUT /api/orders/:id/status
```

**Request Body:**
```json
{
  "status": "CONFIRMED"
}
```

**Available Statuses:**
- `PENDING`
- `CONFIRMED`
- `PROCESSING`
- `SHIPPED`
- `DELIVERED`
- `CANCELLED`

---

## 💳 Payments

### Create Payment

```http
POST /api/payments
```

**Request Body:**
```json
{
  "orderId": "uuid",
  "userId": "uuid",
  "amount": 1299.99,
  "paymentMethod": "stripe",
  "currency": "USD"
}
```

**Payment Methods:**
- `stripe`
- `mercadopago`

**Response:**
```json
{
  "payment": {
    "id": "uuid",
    "orderId": "uuid",
    "userId": "uuid",
    "amount": 1299.99,
    "status": "PENDING",
    "paymentMethod": "stripe",
    "stripePaymentId": "pi_xxxxx"
  },
  "clientSecret": "pi_xxxxx_secret_xxxxx"
}
```

### Get Payment by Order ID

```http
GET /api/payments/order/:orderId
```

### Update Payment Status

```http
PUT /api/payments/:id/status
```

**Request Body:**
```json
{
  "status": "COMPLETED"
}
```

**Available Statuses:**
- `PENDING`
- `PROCESSING`
- `COMPLETED`
- `FAILED`
- `REFUNDED`

---

## 📧 Notifications

### Send Email

```http
POST /api/notifications/email
```

**Request Body:**
```json
{
  "to": "user@example.com",
  "subject": "Order Confirmation",
  "template": "order_confirmation",
  "data": {
    "orderId": "uuid",
    "totalAmount": 1299.99
  }
}
```

**Available Templates:**
- `order_confirmation`
- `shipping_update`

### Get All Notifications

```http
GET /api/notifications?userId={userId}
```

**Response:**
```json
[
  {
    "id": "uuid",
    "userId": "uuid",
    "type": "email",
    "channel": "brevo",
    "subject": "Order Confirmation",
    "message": "{\"orderId\":\"uuid\"}",
    "status": "sent",
    "sentAt": "2024-01-01T00:00:00.000Z"
  }
]
```

---

## 🔄 Microservices Events (Internal)

These events are communicated between microservices via RabbitMQ:

### Update Stock
- **Queue**: `product_queue`
- **Pattern**: `update_stock`
- **Payload**: `{ productId: string, quantity: number }`

### Send Email
- **Queue**: `notification_queue`
- **Pattern**: `send_email`
- **Payload**: `{ to: string, subject: string, template: string, data: object }`

---

## ⚠️ Error Responses

All errors follow this format:

```json
{
  "statusCode": 400,
  "message": "Error message",
  "error": "Bad Request"
}
```

**Common Status Codes:**
- `400` - Bad Request
- `401` - Unauthorized
- `403` - Forbidden
- `404` - Not Found
- `500` - Internal Server Error

---

## 🧪 Testing with cURL

### Example: Register and Create Order

```bash
# 1. Register
TOKEN=$(curl -X POST http://localhost:3000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "password123",
    "firstName": "Test",
    "lastName": "User"
  }' | jq -r '.access_token')

# 2. Get Products
curl http://localhost:3000/api/products

# 3. Add to Cart
curl -X POST http://localhost:3000/api/cart/items \
  -H "Content-Type: application/json" \
  -d '{
    "userId": "your-user-id",
    "productId": "product-id",
    "quantity": 1,
    "price": 1299.99
  }'

# 4. Create Order
curl -X POST http://localhost:3000/api/orders \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "userId": "your-user-id",
    "items": [{
      "productId": "product-id",
      "quantity": 1,
      "price": 1299.99
    }],
    "shippingAddress": "123 Main St"
  }'
```

---

## 📊 Rate Limiting

- **Window**: 15 minutes
- **Max Requests**: 100 per window per IP

---

## 🔒 Security Headers

All responses include security headers:
- `X-Frame-Options: DENY`
- `X-Content-Type-Options: nosniff`
- `Strict-Transport-Security`

---

## 📝 Notes

- All timestamps are in ISO 8601 format
- All IDs are UUIDs
- Prices are in the specified currency (default: USD)
- Bearer token authentication required for protected routes
