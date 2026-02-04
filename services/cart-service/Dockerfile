FROM node:18-slim

# Instalar OpenSSL para que Prisma no explote
RUN apt-get update -y && apt-get install -y openssl procps

WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .

# Generar el cliente de Prisma
RUN npx prisma generate

EXPOSE 3003
CMD ["npm", "run", "start:dev"]