FROM node:18-slim
RUN apt-get update -y && apt-get install -y openssl procps
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
RUN npx prisma generate
EXPOSE 3004
CMD ["npm", "run", "start:dev"]
