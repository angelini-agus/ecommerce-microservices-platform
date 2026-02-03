#!/bin/bash

echo "🌱 Seeding database with sample data..."

# Wait for services to be ready
sleep 5

# Create sample products
echo "📦 Creating sample products..."

curl -X POST http://localhost:3000/api/products \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Laptop Gaming MSI",
    "description": "Laptop de alto rendimiento para gaming con RTX 4070",
    "price": 1599.99,
    "stock": 15,
    "imageUrl": "https://via.placeholder.com/300"
  }'

curl -X POST http://localhost:3000/api/products \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Mouse Logitech G502",
    "description": "Mouse gaming de alta precisión con sensor HERO",
    "price": 79.99,
    "stock": 50,
    "imageUrl": "https://via.placeholder.com/300"
  }'

curl -X POST http://localhost:3000/api/products \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Teclado Mecánico Corsair K70",
    "description": "Teclado mecánico RGB con switches Cherry MX",
    "price": 149.99,
    "stock": 30,
    "imageUrl": "https://via.placeholder.com/300"
  }'

curl -X POST http://localhost:3000/api/products \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Monitor Samsung 27\" 144Hz",
    "description": "Monitor gaming curvo de 27 pulgadas con 144Hz",
    "price": 299.99,
    "stock": 20,
    "imageUrl": "https://via.placeholder.com/300"
  }'

curl -X POST http://localhost:3000/api/products \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Auriculares HyperX Cloud II",
    "description": "Auriculares gaming con sonido surround 7.1",
    "price": 99.99,
    "stock": 40,
    "imageUrl": "https://via.placeholder.com/300"
  }'

curl -X POST http://localhost:3000/api/products \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Webcam Logitech C920",
    "description": "Webcam Full HD 1080p para streaming",
    "price": 69.99,
    "stock": 25,
    "imageUrl": "https://via.placeholder.com/300"
  }'

curl -X POST http://localhost:3000/api/products \
  -H "Content-Type: application/json" \
  -d '{
    "name": "SSD Samsung 1TB NVMe",
    "description": "Disco SSD de alto rendimiento 1TB",
    "price": 119.99,
    "stock": 35,
    "imageUrl": "https://via.placeholder.com/300"
  }'

curl -X POST http://localhost:3000/api/products \
  -H "Content-Type: application/json" \
  -d '{
    "name": "GPU NVIDIA RTX 4080",
    "description": "Tarjeta gráfica de última generación",
    "price": 1199.99,
    "stock": 8,
    "imageUrl": "https://via.placeholder.com/300"
  }'

echo ""
echo "✨ Database seeded successfully!"
echo "🌐 Visit http://localhost:3100 to see the products"
