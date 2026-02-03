import { NestFactory } from '@nestjs/core';
import { ValidationPipe } from '@nestjs/common';
import { AppModule } from './app.module';
import { MicroserviceOptions, Transport } from '@nestjs/microservices';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);

  // --- CAMBIO IMPORTANTE ---
  // Comentamos esta línea porque el API Gateway ya habilita CORS.
  // Si lo dejamos, el navegador recibe dos permisos y bloquea la conexión por seguridad.
  // app.enableCors(); 
  // -------------------------

  app.useGlobalPipes(new ValidationPipe({ whitelist: true, transform: true }));

  app.connectMicroservice<MicroserviceOptions>({
    transport: Transport.RMQ,
    options: {
      urls: [process.env.RABBITMQ_URL || 'amqp://admin:admin@rabbitmq:5672'],
      queue: 'product_queue',
      queueOptions: { durable: true },
    },
  });

  await app.startAllMicroservices();
  await app.listen(process.env.PORT || 3002);
  console.log(`🚀 Product Service running on port ${process.env.PORT || 3002}`);
}
bootstrap();