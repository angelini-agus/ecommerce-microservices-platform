#!/bin/bash

echo "🚀 Installing dependencies for all microservices..."

# Array of services
services=(
  "user-service"
  "product-service"
  "cart-service"
  "order-service"
  "payment-service"
  "notification-service"
)

# Install dependencies for each service
for service in "${services[@]}"; do
  echo "📦 Installing dependencies for $service..."
  cd "services/$service"
  npm install
  echo "✅ $service dependencies installed"
  cd ../..
done

# Install frontend dependencies
echo "📦 Installing frontend dependencies..."
cd frontend
npm install
echo "✅ Frontend dependencies installed"
cd ..

echo ""
echo "✨ All dependencies installed successfully!"
echo ""
echo "Next steps:"
echo "1. Configure your .env file"
echo "2. Run: docker compose up --build"
echo "3. Run migrations: ./run-migrations.sh"
echo "4. Visit http://localhost:3100"
