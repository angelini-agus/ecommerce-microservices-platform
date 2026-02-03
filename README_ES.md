# 🛒 Plataforma E-Commerce - Arquitectura de Microservicios

![Node.js](https://img.shields.io/badge/Node.js-18+-green)
![TypeScript](https://img.shields.io/badge/TypeScript-5.3-blue)
![NestJS](https://img.shields.io/badge/NestJS-10-red)
![Next.js](https://img.shields.io/badge/Next.js-14-black)
![Docker](https://img.shields.io/badge/Docker-24+-blue)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-15-blue)

Plataforma de e-commerce completa y escalable construida con arquitectura de microservicios, desarrollada como proyecto educativo del roadmap.sh.

## 📋 Tabla de Contenidos

- [Características](#-características)
- [Arquitectura](#-arquitectura)
- [Stack Tecnológico](#-stack-tecnológico)
- [Estructura del Proyecto](#-estructura-del-proyecto)
- [Instalación](#-instalación-rápida)
- [Documentación](#-documentación)
- [Capturas de Pantalla](#-capturas-de-pantalla)
- [Roadmap](#-roadmap)
- [Contribuir](#-contribuir)
- [Licencia](#-licencia)

## ✨ Características

### Core Features
- ✅ **Autenticación JWT** - Registro, login y autorización
- ✅ **Gestión de Productos** - CRUD completo con categorías
- ✅ **Carrito de Compras** - Agregar, actualizar, eliminar productos
- ✅ **Procesamiento de Órdenes** - Creación y seguimiento de pedidos
- ✅ **Pagos Integrados** - Stripe y MercadoPago
- ✅ **Notificaciones Email** - Confirmaciones y actualizaciones
- ✅ **API Gateway** - NGINX como punto de entrada único

### Arquitectura
- 🏗️ **Microservicios** - 6 servicios independientes
- 🐳 **Docker Compose** - Orquestación completa
- 🔄 **RabbitMQ** - Comunicación asíncrona entre servicios
- 💾 **PostgreSQL** - Base de datos relacional
- ⚡ **Redis** - Cache y sesiones
- 🎯 **Prisma ORM** - Type-safe database queries

### Frontend
- ⚛️ **Next.js 14** - App Router, SSR/SSG
- 🎨 **Tailwind CSS** - Diseño responsive
- 🔥 **React Hot Toast** - Notificaciones
- 🗃️ **Zustand** - State management

## 🏗️ Arquitectura

```
┌─────────────────────────────────────────────────────────┐
│                     API Gateway (NGINX)                  │
│                     Port: 3000                           │
└────────────────────┬────────────────────────────────────┘
                     │
         ┌───────────┼──────────┐
         │           │          │
    ┌────▼────┐ ┌───▼────┐ ┌──▼─────┐
    │  User   │ │Product │ │  Cart  │
    │ Service │ │Service │ │Service │
    │  :3001  │ │ :3002  │ │ :3003  │
    └─────────┘ └────────┘ └────────┘
         │           │          │
    ┌────▼────┐ ┌───▼────┐ ┌──▼─────┐
    │  Order  │ │Payment │ │ Notif. │
    │ Service │ │Service │ │Service │
    │  :3004  │ │ :3005  │ │ :3006  │
    └─────────┘ └────────┘ └────────┘
         │           │          │
         └───────────┼──────────┘
                     │
         ┌───────────▼──────────┐
         │   RabbitMQ (Events)  │
         └───────────┬──────────┘
                     │
         ┌───────────▼──────────┐
         │   PostgreSQL + Redis │
         └──────────────────────┘
```

## 🚀 Stack Tecnológico

### Backend
- **Framework**: NestJS 10
- **Language**: TypeScript 5.3
- **ORM**: Prisma
- **Authentication**: JWT + Passport
- **Validation**: class-validator
- **Message Queue**: RabbitMQ

### Frontend
- **Framework**: Next.js 14 (App Router)
- **Language**: TypeScript
- **Styling**: Tailwind CSS
- **State Management**: Zustand
- **HTTP Client**: Axios
- **Notifications**: React Hot Toast

### Infraestructura
- **Containerización**: Docker + Docker Compose
- **API Gateway**: NGINX
- **Base de Datos**: PostgreSQL 15
- **Cache**: Redis 7
- **Message Broker**: RabbitMQ 3

### Servicios Externos
- **Payments**: Stripe, MercadoPago, Polar.sh
- **Email**: Brevo (SendInBlue)
- **Storage**: DigitalOcean Spaces
- **Scheduling**: Inngest

## 📁 Estructura del Proyecto

```
ecommerce-platform/
├── services/
│   ├── user-service/          # Autenticación y usuarios
│   │   ├── src/
│   │   ├── prisma/
│   │   ├── Dockerfile
│   │   └── package.json
│   ├── product-service/       # Catálogo de productos
│   ├── cart-service/          # Carrito de compras
│   ├── order-service/         # Gestión de órdenes
│   ├── payment-service/       # Procesamiento de pagos
│   └── notification-service/  # Notificaciones email/SMS
├── frontend/                  # Next.js frontend
│   ├── src/
│   │   ├── app/
│   │   ├── components/
│   │   ├── lib/
│   │   └── store/
│   ├── public/
│   └── package.json
├── api-gateway/               # NGINX configuration
│   └── nginx.conf
├── docker-compose.yml         # Orquestación de servicios
├── .env.example               # Variables de entorno
├── INSTALL.md                 # Guía de instalación
├── API.md                     # Documentación de API
└── README.md                  # Este archivo
```

## 🚀 Instalación Rápida

### Prerrequisitos
- Node.js 18+
- Docker & Docker Compose
- Git

### Pasos

1. **Clonar el repositorio**
```bash
git clone <tu-repositorio>
cd ecommerce-platform
```

2. **Configurar variables de entorno**
```bash
cp .env.example .env
# Edita .env con tus claves de API
```

3. **Instalar dependencias**
```bash
chmod +x install-deps.sh
./install-deps.sh
```

4. **Iniciar con Docker**
```bash
docker compose up --build -d
```

5. **Ejecutar migraciones**
```bash
chmod +x run-migrations.sh
./run-migrations.sh
```

6. **Poblar con datos de prueba**
```bash
chmod +x seed.sh
./seed.sh
```

7. **Acceder a la aplicación**
- Frontend: http://localhost:3100
- API Gateway: http://localhost:3000
- RabbitMQ Management: http://localhost:15672 (admin/admin)

## 📚 Documentación

- 📖 [Guía de Instalación Completa](INSTALL.md)
- 📘 [Documentación de API](API.md)
- 🏗️ [Arquitectura Detallada](docs/ARCHITECTURE.md) _(próximamente)_
- 🔐 [Seguridad](docs/SECURITY.md) _(próximamente)_

## 🎯 Microservicios

### User Service (Puerto 3001)
- Registro y autenticación
- Gestión de perfiles
- Direcciones de envío
- Roles y permisos

### Product Service (Puerto 3002)
- CRUD de productos
- Gestión de categorías
- Control de inventario
- Búsqueda y filtros

### Cart Service (Puerto 3003)
- Agregar/quitar productos
- Actualizar cantidades
- Persistencia de carrito
- Calcular totales

### Order Service (Puerto 3004)
- Crear órdenes
- Seguimiento de estado
- Historial de pedidos
- Integración con pagos

### Payment Service (Puerto 3005)
- Stripe integration
- MercadoPago integration
- Webhooks de pago
- Manejo de reembolsos

### Notification Service (Puerto 3006)
- Emails transaccionales
- Notificaciones de pedidos
- Actualizaciones de envío
- Templates personalizables

## 🖼️ Capturas de Pantalla

_Próximamente: Agregar screenshots del frontend_

## 🗺️ Roadmap

### Fase 1: MVP ✅
- [x] Arquitectura de microservicios
- [x] Autenticación JWT
- [x] CRUD de productos
- [x] Carrito de compras
- [x] Procesamiento de órdenes
- [x] Integración de pagos
- [x] Notificaciones email

### Fase 2: Mejoras (En Progreso)
- [ ] Service Discovery (Consul)
- [ ] API Documentation (Swagger)
- [ ] Logging centralizado (ELK Stack)
- [ ] Monitoring (Prometheus + Grafana)
- [ ] Rate Limiting
- [ ] Búsqueda avanzada (Elasticsearch)

### Fase 3: Escalabilidad
- [ ] Kubernetes deployment
- [ ] CI/CD pipeline (GitHub Actions)
- [ ] Load testing
- [ ] Caching strategies
- [ ] Database replication
- [ ] CDN integration

### Fase 4: Features Avanzadas
- [ ] Recommendations engine
- [ ] Reviews y ratings
- [ ] Wishlist
- [ ] Multiple currencies
- [ ] Multi-language support
- [ ] Admin dashboard

## 🧪 Testing

```bash
# Unit tests
npm test

# E2E tests
npm run test:e2e

# Coverage
npm run test:cov
```

## 🛠️ Comandos Útiles

```bash
# Ver logs de todos los servicios
docker compose logs -f

# Ver logs de un servicio específico
docker compose logs -f user-service

# Reiniciar un servicio
docker compose restart product-service

# Detener todos los servicios
docker compose down

# Reconstruir e iniciar
docker compose up --build -d

# Acceder a la base de datos
docker compose exec postgres psql -U postgres -d ecommerce

# Ver estado de los servicios
docker compose ps
```

## 🤝 Contribuir

¡Las contribuciones son bienvenidas! Por favor:

1. Fork el proyecto
2. Crea una rama para tu feature (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

## 📝 Convenciones de Código

- TypeScript strict mode
- ESLint + Prettier
- Conventional Commits
- Tests obligatorios para nuevas features

## 🐛 Reportar Bugs

Si encuentras un bug, por favor abre un [issue](../../issues) con:
- Descripción del problema
- Pasos para reproducirlo
- Comportamiento esperado vs actual
- Screenshots (si aplica)
- Logs relevantes

## 📄 Licencia

Este proyecto está bajo la licencia MIT. Ver [LICENSE](LICENSE) para más detalles.

## 👥 Autores

- Tu Nombre - [@tuusuario](https://twitter.com/tuusuario)

## 🙏 Agradecimientos

- [Roadmap.sh](https://roadmap.sh) por el proyecto base
- [NestJS](https://nestjs.com) por el increíble framework
- [Next.js](https://nextjs.org) por el mejor framework de React
- La comunidad open source

## 📞 Contacto

- Email: tu-email@example.com
- LinkedIn: [tu-perfil](https://linkedin.com/in/tu-perfil)
- Twitter: [@tuusuario](https://twitter.com/tuusuario)

---

⭐ Si este proyecto te ayudó, considera darle una estrella en GitHub!

**Hecho con ❤️ usando NestJS, Next.js y Docker**
