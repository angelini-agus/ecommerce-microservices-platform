FROM node:18-alpine

# --- CORRECCION: Usamos solo libssl1.1 que sí existe en v3.15 ---
RUN echo "https://dl-cdn.alpinelinux.org/alpine/v3.15/main" >> /etc/apk/repositories && \
    apk update && \
    apk add --no-cache libssl1.1

WORKDIR /app
COPY package*.json ./
# ... el resto sigue igual
RUN npm install
COPY . .
RUN npx prisma generate
EXPOSE 3002
CMD ["npm", "run", "start:dev"]
