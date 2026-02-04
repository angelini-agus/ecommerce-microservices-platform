# Usamos slim (Debian) igual que en el backend para evitar errores de librerías
FROM node:18-slim

# Instalamos dependencias necesarias (openssl y procps para procesos)
RUN apt-get update -y && apt-get install -y openssl procps

WORKDIR /app

# Copiamos los archivos de dependencias
COPY package*.json ./

# Instalamos las dependencias
RUN npm install

# Copiamos el resto del código
COPY . .

# Exponemos el puerto de Next.js
EXPOSE 3000

# Iniciamos en modo desarrollo
CMD ["npm", "run", "dev"]