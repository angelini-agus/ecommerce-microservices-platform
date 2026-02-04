# Usamos slim que es mucho más compatible con Prisma que Alpine
FROM node:18-slim

# Instalamos OpenSSL que es lo que te está dando error
RUN apt-get update -y && apt-get install -y openssl

WORKDIR /app

# Copiamos archivos de dependencias
COPY package*.json ./

# Instalamos todo
RUN npm install

# Copiamos el resto del código
COPY . .

# Generamos Prisma (Debian lo hará sin problemas ahora)
RUN npx prisma generate

EXPOSE 3003

# Iniciamos en modo desarrollo
CMD ["npm", "run", "start:dev"]