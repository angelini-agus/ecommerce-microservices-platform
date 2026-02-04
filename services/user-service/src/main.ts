import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { Transport, MicroserviceOptions } from '@nestjs/microservices';
import { Logger } from '@nestjs/common';

async function bootstrap() {
  const logger = new Logger('Main');
  
  // 1. Crear la aplicación base (Esto permite tráfico HTTP de Nginx)
  const app = await NestFactory.create(AppModule);

  // 2. Conectar el microservicio para RabbitMQ
  app.connectMicroservice<MicroserviceOptions>({
    transport: Transport.RMQ,
    options: {
      urls: [process.env.RABBITMQ_URL || 'amqp://guest:guest@rabbitmq:5672'],
      queue: 'user_queue',
      queueOptions: {
        durable: true,
      },
    },
  });

  // Habilitar CORS para que el Gateway no bloquee nada
  //app.enableCors();

  // 3. Iniciar ambos mundos
  await app.startAllMicroservices();
  logger.log('✅ User Microservice (RabbitMQ) is connected');

  // 🚀 IMPORTANTE: Abrir el puerto 3001 para que Nginx no tire 502
  await app.listen(3001, '0.0.0.0');
  logger.log('🚀 User API (HTTP) is listening on port 3001');
}
bootstrap();