# 🔧 Guía de Solución de Problemas

## Tabla de Contenidos
- [Problemas con Docker](#problemas-con-docker)
- [Problemas con la Base de Datos](#problemas-con-la-base-de-datos)
- [Problemas con los Servicios](#problemas-con-los-servicios)
- [Problemas con el Frontend](#problemas-con-el-frontend)
- [Problemas de Red](#problemas-de-red)
- [Comandos Útiles](#comandos-útiles)

---

## 🐳 Problemas con Docker

### Error: "Cannot connect to the Docker daemon"

**Síntomas:**
```
Cannot connect to the Docker daemon at unix:///var/run/docker.sock
```

**Soluciones:**

**En Linux:**
```bash
# Iniciar Docker
sudo systemctl start docker

# Verificar estado
sudo systemctl status docker

# Agregar tu usuario al grupo docker
sudo usermod -aG docker $USER

# Cerrar sesión y volver a iniciar para aplicar cambios
```

**En Windows/macOS:**
- Abre Docker Desktop
- Espera a que aparezca el ícono verde en la bandeja del sistema

### Error: "Port is already allocated"

**Síntomas:**
```
Error starting userland proxy: listen tcp 0.0.0.0:3000: bind: address already in use
```

**Soluciones:**

**Linux/macOS:**
```bash
# Encontrar qué proceso usa el puerto
sudo lsof -i :3000

# Matar el proceso (reemplaza PID con el número del proceso)
kill -9 PID
```

**Windows (PowerShell como Administrador):**
```powershell
# Encontrar proceso
netstat -ano | findstr :3000

# Matar proceso
taskkill /PID <PID> /F
```

**O cambiar el puerto:**
```bash
# Edita docker-compose.yml y cambia el puerto
ports:
  - "3100:3000"  # Usa 3100 en lugar de 3000
```

### Los contenedores no inician

**Diagnóstico:**
```bash
# Ver estado de contenedores
docker compose ps

# Ver logs de todos los contenedores
docker compose logs

# Ver logs de un contenedor específico
docker compose logs user-service
```

**Soluciones:**
```bash
# Reconstruir todo desde cero
docker compose down -v
docker compose up --build

# Si persiste, limpiar completamente Docker
docker system prune -a --volumes
# CUIDADO: esto elimina TODAS las imágenes y volúmenes
```

---

## 🗄️ Problemas con la Base de Datos

### Error: "Prisma Client not generated"

**Síntomas:**
```
Error: @prisma/client did not initialize yet
```

**Solución:**
```bash
# Generar cliente de Prisma para cada servicio
cd services/user-service && npx prisma generate
cd ../product-service && npx prisma generate
cd ../cart-service && npx prisma generate
cd ../order-service && npx prisma generate
cd ../payment-service && npx prisma generate
cd ../notification-service && npx prisma generate
```

### Error de conexión a PostgreSQL

**Síntomas:**
```
Can't reach database server at `postgres:5432`
```

**Solución:**
```bash
# Verificar que PostgreSQL está corriendo
docker compose ps postgres

# Ver logs de PostgreSQL
docker compose logs postgres

# Reiniciar PostgreSQL
docker compose restart postgres

# Si no funciona, recrear el contenedor
docker compose down postgres
docker compose up -d postgres

# Esperar a que esté listo
docker compose logs -f postgres
# Busca el mensaje: "database system is ready to accept connections"
```

### Error: "Database does not exist"

**Solución:**
```bash
# Conectarse a PostgreSQL
docker compose exec postgres psql -U postgres

# Crear base de datos
CREATE DATABASE ecommerce;
\q

# Ejecutar migraciones
./run-migrations.sh
```

### Error: "relation does not exist"

**Síntomas:**
```
ERROR: relation "users" does not exist
```

**Solución:**
```bash
# Las tablas no fueron creadas, ejecutar migraciones
./run-migrations.sh

# O manualmente para cada servicio
cd services/user-service && npx prisma db push
```

---

## 🔌 Problemas con los Servicios

### Servicio no responde

**Diagnóstico:**
```bash
# Verificar que el servicio está corriendo
docker compose ps

# Ver logs del servicio
docker compose logs -f user-service

# Probar endpoint directamente
curl http://localhost:3001/api/users
```

**Soluciones:**
```bash
# Reiniciar servicio
docker compose restart user-service

# Reconstruir servicio
docker compose up -d --build user-service

# Ver si hay errores en el código
docker compose logs user-service | grep -i error
```

### Error: "Cannot find module"

**Síntomas:**
```
Error: Cannot find module '@nestjs/common'
```

**Solución:**
```bash
# Reinstalar dependencias
cd services/user-service
rm -rf node_modules
npm install

# O reconstruir el contenedor
docker compose up -d --build user-service
```

### RabbitMQ connection failed

**Síntomas:**
```
Error: Failed to connect to RabbitMQ
```

**Solución:**
```bash
# Verificar RabbitMQ
docker compose ps rabbitmq
docker compose logs rabbitmq

# Reiniciar RabbitMQ
docker compose restart rabbitmq

# Esperar a que esté listo
docker compose exec rabbitmq rabbitmqctl status
```

---

## ⚛️ Problemas con el Frontend

### Error: "API request failed"

**Diagnóstico:**
```bash
# Verificar que API Gateway está corriendo
curl http://localhost:3000/health

# Verificar configuración
cat frontend/.env.local
```

**Solución:**
```bash
# Asegurar que NEXT_PUBLIC_API_URL está configurado
echo "NEXT_PUBLIC_API_URL=http://localhost:3000" >> frontend/.env.local

# Reiniciar frontend
docker compose restart frontend
```

### Página en blanco o error 500

**Solución:**
```bash
# Ver logs del frontend
docker compose logs -f frontend

# Limpiar cache de Next.js
rm -rf frontend/.next

# Reconstruir
docker compose up -d --build frontend
```

### Hot reload no funciona

**Solución:**
```bash
# Detener el contenedor
docker compose down frontend

# Correr localmente
cd frontend
npm run dev
```

---

## 🌐 Problemas de Red

### CORS errors

**Síntomas:**
```
Access to XMLHttpRequest blocked by CORS policy
```

**Solución:**

Edita el servicio backend que está dando el error:
```typescript
// En main.ts de cualquier servicio
app.enableCors({
  origin: ['http://localhost:3100', 'http://localhost:3000'],
  credentials: true,
});
```

### API Gateway no rutea correctamente

**Diagnóstico:**
```bash
# Probar cada servicio directamente
curl http://localhost:3001/api/users
curl http://localhost:3002/api/products

# Probar a través del gateway
curl http://localhost:3000/api/users
curl http://localhost:3000/api/products
```

**Solución:**
```bash
# Ver logs del gateway
docker compose logs api-gateway

# Reiniciar gateway
docker compose restart api-gateway

# Verificar configuración
cat api-gateway/nginx.conf
```

---

## 🛠️ Comandos Útiles

### Ver todos los logs
```bash
docker compose logs -f
```

### Ver logs de un servicio específico
```bash
docker compose logs -f user-service
```

### Reiniciar todos los servicios
```bash
docker compose restart
```

### Ver estado de todos los servicios
```bash
docker compose ps
```

### Acceder a un contenedor
```bash
docker compose exec user-service sh
```

### Ver uso de recursos
```bash
docker stats
```

### Limpiar logs
```bash
docker compose logs --tail=0 -f
```

### Reconstruir un servicio específico
```bash
docker compose up -d --build user-service
```

### Ver variables de entorno de un contenedor
```bash
docker compose exec user-service env
```

### Conectarse a PostgreSQL
```bash
docker compose exec postgres psql -U postgres -d ecommerce
```

### Conectarse a Redis
```bash
docker compose exec redis redis-cli
```

### Ver colas de RabbitMQ
```bash
docker compose exec rabbitmq rabbitmqctl list_queues
```

---

## 🐛 Debug Mode

Para habilitar logs de debug:

**En los servicios NestJS:**
```typescript
// main.ts
app.useLogger(['log', 'error', 'warn', 'debug', 'verbose']);
```

**En Docker Compose:**
```yaml
environment:
  - LOG_LEVEL=debug
```

---

## 📞 Obtener Ayuda

Si ninguna de estas soluciones funciona:

1. **Recopilar información:**
```bash
# Guardar logs en un archivo
docker compose logs > logs.txt

# Ver versiones
docker --version
docker compose version
node --version
```

2. **Buscar en Issues:** Revisa si alguien ya reportó el problema

3. **Crear un Issue:** Incluye:
   - Sistema operativo
   - Versiones de software
   - Comando que causó el error
   - Logs relevantes
   - Pasos para reproducir

---

## 🔄 Reset Completo

Si todo falla, empezar desde cero:

```bash
# 1. Detener y limpiar todo
docker compose down -v --rmi all

# 2. Limpiar sistema Docker
docker system prune -a --volumes

# 3. Eliminar node_modules
find . -name "node_modules" -type d -prune -exec rm -rf '{}' +

# 4. Reinstalar
./install-deps.sh

# 5. Reconstruir
docker compose up --build -d

# 6. Ejecutar migraciones
./run-migrations.sh

# 7. Poblar datos
./seed.sh
```

---

## ⚠️ Problemas Conocidos

### 1. En Windows con WSL2
- Asegúrate de que WSL2 está habilitado
- Los archivos deben estar en el sistema de archivos de WSL2, no en /mnt/c/

### 2. En macOS con chip M1/M2
- Algunos contenedores pueden necesitar `platform: linux/amd64` en docker-compose.yml

### 3. Memoria insuficiente
- Docker necesita al menos 4GB de RAM
- Aumenta memoria en Docker Desktop Settings > Resources

---

¿Encontraste un problema no listado aquí? ¡Abre un issue! 🐛
