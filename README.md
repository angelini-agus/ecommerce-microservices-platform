# 🛒 E-Commerce Platform - Microservices Architecture

Plataforma de e-commerce escalable construida con arquitectura de microservicios.

## 🏗️ Arquitectura

### Microservicios Core
- **User Service** (Puerto 3001): Autenticación y gestión de usuarios
- **Product Service** (Puerto 3002): Catálogo de productos e inventario
- **Cart Service** (Puerto 3003): Carrito de compras
- **Order Service** (Puerto 3004): Procesamiento de órdenes
- **Payment Service** (Puerto 3005): Pagos con Stripe/MercadoPago
- **Notification Service** (Puerto 3006): Emails y notificaciones

### Componentes Adicionales
- **API Gateway** (Puerto 3000): Kong/NGINX
- **Frontend** (Puerto 3100): Next.js
- **PostgreSQL** (Puerto 5432): Base de datos
- **Redis** (Puerto 6379): Cache y sesiones

## 🚀 Stack Tecnológico

- **Frontend**: Next.js 14+ (App Router, SSR/SSG)
- **Backend**: NestJS con TypeScript
- **Database**: PostgreSQL + Prisma ORM
- **Cache**: Redis
- **Message Queue**: RabbitMQ
- **Containerización**: Docker + Docker Compose
- **Payments**: Stripe / MercadoPago
- **Email**: Brevo (SendInBlue)
- **Storage**: DigitalOcean Spaces
- **Monitoring**: Prometheus + Grafana
- **Logging**: ELK Stack

## 📋 Requisitos Previos

- Node.js 18+
- Docker & Docker Compose
- Git

## 🛠️ Instalación

Ver `INSTALL.md` para instrucciones detalladas.

