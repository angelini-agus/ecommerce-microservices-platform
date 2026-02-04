# Usamos slim que es más estable para Prisma que Alpine
FROM node:18-slim

# Instalamos OpenSSL y procps (necesario para que NestJS se reinicie bien)
# Usamos apt-get porque estamos en Debian
RUN apt-get update -y && apt-get install -y openssl procps

WORKDIR /app

# Copiamos archivos de dependencias
COPY package*.json ./

# Instalamos todo
RUN npm install

# Copiamos el resto del código
COPY . .

# Generamos el cliente de Prisma
RUN npx prisma generate

EXPOSE 3003

# Iniciamos en modo desarrollo
CMD ["npm", "run", "start:dev"]