# 📦 Guía de Instalación - E-Commerce Platform

## 🛠️ Requisitos Previos

Antes de comenzar, asegúrate de tener instalado lo siguiente en tu PC:

### 1. Node.js (v18 o superior)

**Windows:**
```bash
# Descarga el instalador desde https://nodejs.org/
# Ejecuta el instalador y sigue las instrucciones
```

**Linux/macOS:**
```bash
# Usando nvm (recomendado)
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
source ~/.bashrc  # o ~/.zshrc para macOS
nvm install 18
nvm use 18
```

Verifica la instalación:
```bash
node --version  # Debería mostrar v18.x.x
npm --version   # Debería mostrar 9.x.x o superior
```

### 2. Docker y Docker Compose

**Windows:**
- Descarga [Docker Desktop](https://www.docker.com/products/docker-desktop/)
- Instala y reinicia tu PC
- Asegúrate de que WSL 2 esté habilitado

**Linux (Ubuntu/Debian):**
```bash
# Actualizar paquetes
sudo apt update

# Instalar Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Agregar tu usuario al grupo docker
sudo usermod -aG docker $USER

# Instalar Docker Compose
sudo apt install docker-compose-plugin

# Cerrar sesión y volver a iniciarla para aplicar cambios
```

**macOS:**
```bash
# Instalar con Homebrew
brew install --cask docker

# O descargar Docker Desktop desde https://www.docker.com/products/docker-desktop/
```

Verifica la instalación:
```bash
docker --version          # Debería mostrar Docker version 24.x.x o superior
docker compose version    # Debería mostrar Docker Compose version v2.x.x
```

### 3. Git

**Windows:**
```bash
# Descarga desde https://git-scm.com/download/win
# Instala siguiendo el asistente
```

**Linux:**
```bash
sudo apt install git
```

**macOS:**
```bash
brew install git
```

Verifica:
```bash
git --version
```

---

## 🚀 Instalación del Proyecto

### Paso 1: Clonar el Repositorio

```bash
# Si tienes el código en GitHub/GitLab
git clone <tu-repositorio-url>
cd ecommerce-platform

# Si tienes los archivos localmente, navega al directorio
cd /ruta/a/ecommerce-platform
```

### Paso 2: Configurar Variables de Entorno

Crea un archivo `.env` en la raíz del proyecto:

```bash
# Base de datos
DATABASE_URL=postgresql://postgres:postgres@postgres:5432/ecommerce

# JWT
JWT_SECRET=tu-super-secreto-jwt-clave-cambiar-en-produccion

# Redis
REDIS_URL=redis://redis:6379

# RabbitMQ
RABBITMQ_URL=amqp://admin:admin@rabbitmq:5672

# Stripe (obtén las claves en https://stripe.com/docs/keys)
STRIPE_SECRET_KEY=sk_test_tu_clave_de_stripe

# MercadoPago (obtén el token en https://www.mercadopago.com.ar/developers)
MERCADOPAGO_ACCESS_TOKEN=tu_token_de_mercadopago

# Brevo (ex-SendInBlue) (https://www.brevo.com/)
BREVO_API_KEY=tu_api_key_de_brevo
BREVO_SENDER_EMAIL=noreply@tudominio.com

# DigitalOcean Spaces (opcional)
SPACES_ENDPOINT=https://nyc3.digitaloceanspaces.com
SPACES_BUCKET=tu-bucket-name
SPACES_KEY=tu_spaces_key
SPACES_SECRET=tu_spaces_secret

# Frontend
NEXT_PUBLIC_API_URL=http://localhost:3000
```

### Paso 3: Instalar Dependencias de los Microservicios

Instala las dependencias de cada servicio:

```bash
# User Service
cd services/user-service
npm install
cd ../..

# Product Service
cd services/product-service
npm install
cd ../..

# Cart Service
cd services/cart-service
npm install
cd ../..

# Order Service
cd services/order-service
npm install
cd ../..

# Payment Service
cd services/payment-service
npm install
cd ../..

# Notification Service
cd services/notification-service
npm install
cd ../..

# Frontend
cd frontend
npm install
cd ..
```

**O usa este script para instalar todo de una vez:**

```bash
# En Linux/macOS
chmod +x install-deps.sh
./install-deps.sh

# En Windows (PowerShell)
.\install-deps.ps1
```

### Paso 4: Generar Prisma Clients

Genera los clientes de Prisma para cada servicio:

```bash
cd services/user-service && npx prisma generate && cd ../..
cd services/product-service && npx prisma generate && cd ../..
cd services/cart-service && npx prisma generate && cd ../..
cd services/order-service && npx prisma generate && cd ../..
cd services/payment-service && npx prisma generate && cd ../..
cd services/notification-service && npx prisma generate && cd ../..
```

### Paso 5: Iniciar con Docker Compose

**Opción A: Iniciar TODO (Recomendado para desarrollo)**

```bash
# Construir e iniciar todos los contenedores
docker compose up --build

# O en segundo plano
docker compose up -d --build
```

**Opción B: Iniciar solo infraestructura (Base de datos, Redis, RabbitMQ)**

```bash
docker compose up postgres redis rabbitmq -d
```

Luego, ejecuta cada servicio manualmente en terminales separadas:

```bash
# Terminal 1 - User Service
cd services/user-service
npm run start:dev

# Terminal 2 - Product Service
cd services/product-service
npm run start:dev

# Terminal 3 - Cart Service
cd services/cart-service
npm run start:dev

# Terminal 4 - Order Service
cd services/order-service
npm run start:dev

# Terminal 5 - Payment Service
cd services/payment-service
npm run start:dev

# Terminal 6 - Notification Service
cd services/notification-service
npm run start:dev

# Terminal 7 - Frontend
cd frontend
npm run dev
```

### Paso 6: Ejecutar Migraciones de Base de Datos

Una vez que PostgreSQL esté corriendo:

```bash
# User Service
cd services/user-service
npx prisma db push
cd ../..

# Product Service
cd services/product-service
npx prisma db push
cd ../..

# Cart Service
cd services/cart-service
npx prisma db push
cd ../..

# Order Service
cd services/order-service
npx prisma db push
cd ../..

# Payment Service
cd services/payment-service
npx prisma db push
cd ../..

# Notification Service
cd services/notification-service
npx prisma db push
cd ../..
```

---

## 🎯 Verificar la Instalación

### 1. Verificar que todos los contenedores estén corriendo:

```bash
docker compose ps
```

Deberías ver todos los servicios en estado "running".

### 2. Verificar los servicios individualmente:

```bash
# User Service
curl http://localhost:3001/api/users

# Product Service
curl http://localhost:3002/api/products

# Cart Service
curl http://localhost:3003/api/cart?userId=test

# Order Service
curl http://localhost:3004/api/orders

# Payment Service
curl http://localhost:3005/api/payments/order/test

# Notification Service
curl http://localhost:3006/api/notifications

# API Gateway
curl http://localhost:3000/health

# Frontend
curl http://localhost:3100
```

### 3. Acceder a las Interfaces Web:

- **Frontend**: http://localhost:3100
- **API Gateway**: http://localhost:3000
- **RabbitMQ Management**: http://localhost:15672 (admin/admin)

---

## 🧪 Poblar la Base de Datos con Datos de Prueba

Ejecuta el script de seeding:

```bash
npm run seed
```

O crea manualmente algunos productos:

```bash
curl -X POST http://localhost:3000/api/products \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Laptop Gaming",
    "description": "High performance gaming laptop",
    "price": 1299.99,
    "stock": 10,
    "imageUrl": "https://example.com/laptop.jpg"
  }'
```

---

## 🛑 Detener y Limpiar

### Detener los contenedores:

```bash
docker compose down
```

### Detener y eliminar volúmenes (CUIDADO: elimina los datos):

```bash
docker compose down -v
```

### Limpiar todo (contenedores, imágenes, volúmenes):

```bash
docker compose down -v --rmi all
```

---

## 🔧 Comandos Útiles

### Ver logs de un servicio específico:

```bash
docker compose logs -f user-service
docker compose logs -f product-service
docker compose logs -f frontend
```

### Reiniciar un servicio:

```bash
docker compose restart user-service
```

### Reconstruir un servicio:

```bash
docker compose up -d --build user-service
```

### Acceder a la base de datos:

```bash
docker compose exec postgres psql -U postgres -d ecommerce
```

### Ver la cola de RabbitMQ:

```bash
docker compose exec rabbitmq rabbitmqctl list_queues
```

---

## 🐛 Solución de Problemas Comunes

### Error: "Cannot connect to the Docker daemon"

```bash
# En Linux, asegúrate de que Docker esté corriendo
sudo systemctl start docker

# En Windows/macOS, inicia Docker Desktop
```

### Error: "Port already in use"

```bash
# Encuentra el proceso usando el puerto
sudo lsof -i :3000  # Linux/macOS
netstat -ano | findstr :3000  # Windows

# Mata el proceso o cambia el puerto en docker-compose.yml
```

### Error: "Prisma Client not generated"

```bash
cd services/<servicio-con-error>
npx prisma generate
```

### Error de conexión a PostgreSQL

```bash
# Asegúrate de que PostgreSQL esté corriendo
docker compose ps postgres

# Verifica los logs
docker compose logs postgres

# Reinicia PostgreSQL
docker compose restart postgres
```

---

## 📚 Próximos Pasos

1. **Configurar claves API reales** en el archivo `.env`
2. **Explorar la API** con Postman o cURL
3. **Personalizar el frontend** según tus necesidades
4. **Agregar más productos** a través de la API
5. **Implementar CI/CD** con Jenkins, GitHub Actions, o GitLab CI

---

## 🆘 Soporte

Si encuentras algún problema:

1. Revisa los logs: `docker compose logs`
2. Verifica que todos los requisitos estén instalados
3. Asegúrate de que los puertos no estén en uso
4. Consulta la documentación de cada tecnología

---

## 📝 Notas Adicionales

- **Desarrollo**: Los servicios se reinician automáticamente con los cambios
- **Producción**: Usa `docker compose -f docker-compose.prod.yml up` (si existe)
- **Base de datos**: Los datos persisten en volúmenes de Docker
- **Seguridad**: Cambia TODAS las contraseñas y secretos en producción

---

¡Feliz desarrollo! 🚀
