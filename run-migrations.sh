#!/bin/bash

echo "🗄️ Running database migrations..."

services=(
  "user-service"
  "product-service"
  "cart-service"
  "order-service"
  "payment-service"
  "notification-service"
)

for service in "${services[@]}"; do
  echo "📊 Running migrations for $service..."
  cd "services/$service"
  npx prisma db push
  echo "✅ $service migrations completed"
  cd ../..
done

echo ""
echo "✨ All migrations completed successfully!"
