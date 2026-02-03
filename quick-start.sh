#!/bin/bash

echo "🚀 Quick Start - E-Commerce Platform"
echo "====================================="
echo ""

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker is not running. Please start Docker and try again."
    exit 1
fi

echo "✅ Docker is running"
echo ""

# Check if .env exists
if [ ! -f .env ]; then
    echo "⚠️  .env file not found. Creating from .env.example..."
    cp .env.example .env
    echo "✅ .env file created. Please edit it with your API keys."
    echo ""
fi

# Ask user what to do
echo "What would you like to do?"
echo ""
echo "1) Full setup (install deps + build + start + migrate + seed)"
echo "2) Just start services (assumes deps are installed)"
echo "3) Install dependencies only"
echo "4) Stop all services"
echo "5) View logs"
echo ""
read -p "Choose option (1-5): " choice

case $choice in
    1)
        echo ""
        echo "📦 Installing dependencies..."
        ./install-deps.sh
        
        echo ""
        echo "🐳 Building and starting Docker containers..."
        docker compose up --build -d
        
        echo ""
        echo "⏳ Waiting for services to be ready..."
        sleep 15
        
        echo ""
        echo "🗄️ Running database migrations..."
        ./run-migrations.sh
        
        echo ""
        echo "🌱 Seeding database..."
        ./seed.sh
        
        echo ""
        echo "✨ Setup complete!"
        echo ""
        echo "🌐 Access your application:"
        echo "   Frontend: http://localhost:3100"
        echo "   API Gateway: http://localhost:3000"
        echo "   RabbitMQ: http://localhost:15672 (admin/admin)"
        echo ""
        echo "📝 To view logs: docker compose logs -f"
        ;;
        
    2)
        echo ""
        echo "🐳 Starting Docker containers..."
        docker compose up -d
        
        echo ""
        echo "✨ Services started!"
        echo ""
        echo "🌐 Access your application:"
        echo "   Frontend: http://localhost:3100"
        echo "   API Gateway: http://localhost:3000"
        ;;
        
    3)
        echo ""
        echo "📦 Installing dependencies..."
        ./install-deps.sh
        echo "✅ Dependencies installed!"
        ;;
        
    4)
        echo ""
        echo "🛑 Stopping all services..."
        docker compose down
        echo "✅ Services stopped!"
        ;;
        
    5)
        echo ""
        echo "📋 Showing logs (Ctrl+C to exit)..."
        docker compose logs -f
        ;;
        
    *)
        echo "Invalid option"
        exit 1
        ;;
esac
