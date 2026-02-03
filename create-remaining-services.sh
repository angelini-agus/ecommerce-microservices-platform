#!/bin/bash

BASE_DIR="/home/claude/ecommerce-platform/services"

# ============================================
# ORDER SERVICE
# ============================================
echo "Creating Order Service..."
mkdir -p $BASE_DIR/order-service/src/orders
mkdir -p $BASE_DIR/order-service/prisma

cat > $BASE_DIR/order-service/package.json << 'EOF'
{
  "name": "order-service",
  "version": "1.0.0",
  "scripts": {
    "build": "nest build",
    "start:dev": "nest start --watch",
    "prisma:generate": "prisma generate"
  },
  "dependencies": {
    "@nestjs/common": "^10.3.0",
    "@nestjs/core": "^10.3.0",
    "@nestjs/platform-express": "^10.3.0",
    "@nestjs/microservices": "^10.3.0",
    "@prisma/client": "^5.8.0",
    "class-validator": "^0.14.1",
    "redis": "^4.6.12",
    "amqplib": "^0.10.3",
    "reflect-metadata": "^0.2.1",
    "rxjs": "^7.8.1"
  },
  "devDependencies": {
    "@nestjs/cli": "^10.3.0",
    "prisma": "^5.8.0",
    "typescript": "^5.3.3"
  }
}
EOF

cat > $BASE_DIR/order-service/Dockerfile << 'EOF'
FROM node:18-alpine
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
RUN npx prisma generate
EXPOSE 3004
CMD ["npm", "run", "start:dev"]
EOF

cat > $BASE_DIR/order-service/prisma/schema.prisma << 'EOF'
generator client {
  provider = "prisma-client-js"
}

datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}

model Order {
  id            String      @id @default(uuid())
  userId        String
  status        OrderStatus @default(PENDING)
  totalAmount   Float
  shippingAddress String
  createdAt     DateTime    @default(now())
  updatedAt     DateTime    @updatedAt

  items OrderItem[]

  @@map("orders")
}

model OrderItem {
  id        String @id @default(uuid())
  orderId   String
  productId String
  quantity  Int
  price     Float

  order Order @relation(fields: [orderId], references: [id], onDelete: Cascade)

  @@map("order_items")
}

enum OrderStatus {
  PENDING
  CONFIRMED
  PROCESSING
  SHIPPED
  DELIVERED
  CANCELLED
}
EOF

cat > $BASE_DIR/order-service/src/main.ts << 'EOF'
import { NestFactory } from '@nestjs/core';
import { ValidationPipe } from '@nestjs/common';
import { AppModule } from './app.module';
import { MicroserviceOptions, Transport } from '@nestjs/microservices';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  app.enableCors();
  app.useGlobalPipes(new ValidationPipe({ whitelist: true, transform: true }));

  app.connectMicroservice<MicroserviceOptions>({
    transport: Transport.RMQ,
    options: {
      urls: [process.env.RABBITMQ_URL || 'amqp://admin:admin@rabbitmq:5672'],
      queue: 'order_queue',
      queueOptions: { durable: true },
    },
  });

  await app.startAllMicroservices();
  await app.listen(process.env.PORT || 3004);
  console.log(`🚀 Order Service running on port ${process.env.PORT || 3004}`);
}
bootstrap();
EOF

cat > $BASE_DIR/order-service/src/app.module.ts << 'EOF'
import { Module } from '@nestjs/common';
import { ClientsModule, Transport } from '@nestjs/microservices';
import { PrismaModule } from './prisma/prisma.module';
import { OrdersModule } from './orders/orders.module';

@Module({
  imports: [
    PrismaModule,
    OrdersModule,
    ClientsModule.register([
      {
        name: 'PRODUCT_SERVICE',
        transport: Transport.RMQ,
        options: {
          urls: [process.env.RABBITMQ_URL || 'amqp://admin:admin@rabbitmq:5672'],
          queue: 'product_queue',
          queueOptions: { durable: true },
        },
      },
      {
        name: 'NOTIFICATION_SERVICE',
        transport: Transport.RMQ,
        options: {
          urls: [process.env.RABBITMQ_URL || 'amqp://admin:admin@rabbitmq:5672'],
          queue: 'notification_queue',
          queueOptions: { durable: true },
        },
      },
    ]),
  ],
})
export class AppModule {}
EOF

mkdir -p $BASE_DIR/order-service/src/prisma
cat > $BASE_DIR/order-service/src/prisma/prisma.module.ts << 'EOF'
import { Module, Global } from '@nestjs/common';
import { PrismaService } from './prisma.service';

@Global()
@Module({
  providers: [PrismaService],
  exports: [PrismaService],
})
export class PrismaModule {}
EOF

cat > $BASE_DIR/order-service/src/prisma/prisma.service.ts << 'EOF'
import { Injectable, OnModuleInit } from '@nestjs/common';
import { PrismaClient } from '@prisma/client';

@Injectable()
export class PrismaService extends PrismaClient implements OnModuleInit {
  async onModuleInit() {
    await this.$connect();
    console.log('✅ Order DB connected');
  }
}
EOF

cat > $BASE_DIR/order-service/src/orders/orders.module.ts << 'EOF'
import { Module } from '@nestjs/common';
import { ClientsModule, Transport } from '@nestjs/microservices';
import { OrdersService } from './orders.service';
import { OrdersController } from './orders.controller';

@Module({
  imports: [
    ClientsModule.register([
      {
        name: 'PRODUCT_SERVICE',
        transport: Transport.RMQ,
        options: {
          urls: [process.env.RABBITMQ_URL || 'amqp://admin:admin@rabbitmq:5672'],
          queue: 'product_queue',
          queueOptions: { durable: true },
        },
      },
      {
        name: 'NOTIFICATION_SERVICE',
        transport: Transport.RMQ,
        options: {
          urls: [process.env.RABBITMQ_URL || 'amqp://admin:admin@rabbitmq:5672'],
          queue: 'notification_queue',
          queueOptions: { durable: true },
        },
      },
    ]),
  ],
  providers: [OrdersService],
  controllers: [OrdersController],
})
export class OrdersModule {}
EOF

cat > $BASE_DIR/order-service/src/orders/orders.service.ts << 'EOF'
import { Injectable, Inject } from '@nestjs/common';
import { ClientProxy } from '@nestjs/microservices';
import { PrismaService } from '../prisma/prisma.service';
import { firstValueFrom } from 'rxjs';

@Injectable()
export class OrdersService {
  constructor(
    private prisma: PrismaService,
    @Inject('PRODUCT_SERVICE') private productClient: ClientProxy,
    @Inject('NOTIFICATION_SERVICE') private notificationClient: ClientProxy,
  ) {}

  async create(userId: string, items: any[], shippingAddress: string) {
    const totalAmount = items.reduce((sum, item) => sum + (item.price * item.quantity), 0);

    const order = await this.prisma.order.create({
      data: {
        userId,
        totalAmount,
        shippingAddress,
        items: {
          create: items.map(item => ({
            productId: item.productId,
            quantity: item.quantity,
            price: item.price,
          })),
        },
      },
      include: { items: true },
    });

    // Update product stock
    for (const item of items) {
      this.productClient.emit('update_stock', {
        productId: item.productId,
        quantity: item.quantity,
      });
    }

    // Send notification
    this.notificationClient.emit('send_email', {
      to: userId,
      subject: 'Order Confirmation',
      template: 'order_confirmation',
      data: { orderId: order.id, totalAmount },
    });

    return order;
  }

  async findAll(userId?: string) {
    return this.prisma.order.findMany({
      where: userId ? { userId } : undefined,
      include: { items: true },
      orderBy: { createdAt: 'desc' },
    });
  }

  async findOne(id: string) {
    return this.prisma.order.findUnique({
      where: { id },
      include: { items: true },
    });
  }

  async updateStatus(id: string, status: string) {
    return this.prisma.order.update({
      where: { id },
      data: { status: status as any },
    });
  }
}
EOF

cat > $BASE_DIR/order-service/src/orders/orders.controller.ts << 'EOF'
import { Controller, Get, Post, Put, Body, Param, Query } from '@nestjs/common';
import { OrdersService } from './orders.service';

@Controller('api/orders')
export class OrdersController {
  constructor(private ordersService: OrdersService) {}

  @Post()
  create(@Body() body: { userId: string; items: any[]; shippingAddress: string }) {
    return this.ordersService.create(body.userId, body.items, body.shippingAddress);
  }

  @Get()
  findAll(@Query('userId') userId?: string) {
    return this.ordersService.findAll(userId);
  }

  @Get(':id')
  findOne(@Param('id') id: string) {
    return this.ordersService.findOne(id);
  }

  @Put(':id/status')
  updateStatus(@Param('id') id: string, @Body() body: { status: string }) {
    return this.ordersService.updateStatus(id, body.status);
  }
}
EOF

cat > $BASE_DIR/order-service/tsconfig.json << 'EOF'
{
  "compilerOptions": {
    "module": "commonjs",
    "declaration": true,
    "removeComments": true,
    "emitDecoratorMetadata": true,
    "experimentalDecorators": true,
    "allowSyntheticDefaultImports": true,
    "target": "ES2021",
    "sourceMap": true,
    "outDir": "./dist",
    "baseUrl": "./",
    "incremental": true,
    "skipLibCheck": true
  }
}
EOF

cat > $BASE_DIR/order-service/nest-cli.json << 'EOF'
{
  "collection": "@nestjs/schematics",
  "sourceRoot": "src"
}
EOF

# ============================================
# PAYMENT SERVICE
# ============================================
echo "Creating Payment Service..."
mkdir -p $BASE_DIR/payment-service/src/payments
mkdir -p $BASE_DIR/payment-service/prisma

cat > $BASE_DIR/payment-service/package.json << 'EOF'
{
  "name": "payment-service",
  "version": "1.0.0",
  "scripts": {
    "build": "nest build",
    "start:dev": "nest start --watch",
    "prisma:generate": "prisma generate"
  },
  "dependencies": {
    "@nestjs/common": "^10.3.0",
    "@nestjs/core": "^10.3.0",
    "@nestjs/platform-express": "^10.3.0",
    "@nestjs/microservices": "^10.3.0",
    "@prisma/client": "^5.8.0",
    "class-validator": "^0.14.1",
    "stripe": "^14.11.0",
    "mercadopago": "^2.0.6",
    "redis": "^4.6.12",
    "amqplib": "^0.10.3",
    "reflect-metadata": "^0.2.1",
    "rxjs": "^7.8.1"
  },
  "devDependencies": {
    "@nestjs/cli": "^10.3.0",
    "prisma": "^5.8.0",
    "typescript": "^5.3.3"
  }
}
EOF

cat > $BASE_DIR/payment-service/Dockerfile << 'EOF'
FROM node:18-alpine
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
RUN npx prisma generate
EXPOSE 3005
CMD ["npm", "run", "start:dev"]
EOF

cat > $BASE_DIR/payment-service/prisma/schema.prisma << 'EOF'
generator client {
  provider = "prisma-client-js"
}

datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}

model Payment {
  id              String        @id @default(uuid())
  orderId         String        @unique
  userId          String
  amount          Float
  currency        String        @default("USD")
  status          PaymentStatus @default(PENDING)
  paymentMethod   String
  transactionId   String?
  stripePaymentId String?
  mpPaymentId     String?
  createdAt       DateTime      @default(now())
  updatedAt       DateTime      @updatedAt

  @@map("payments")
}

enum PaymentStatus {
  PENDING
  PROCESSING
  COMPLETED
  FAILED
  REFUNDED
}
EOF

cat > $BASE_DIR/payment-service/src/main.ts << 'EOF'
import { NestFactory } from '@nestjs/core';
import { ValidationPipe } from '@nestjs/common';
import { AppModule } from './app.module';
import { MicroserviceOptions, Transport } from '@nestjs/microservices';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  app.enableCors();
  app.useGlobalPipes(new ValidationPipe({ whitelist: true, transform: true }));

  app.connectMicroservice<MicroserviceOptions>({
    transport: Transport.RMQ,
    options: {
      urls: [process.env.RABBITMQ_URL || 'amqp://admin:admin@rabbitmq:5672'],
      queue: 'payment_queue',
      queueOptions: { durable: true },
    },
  });

  await app.startAllMicroservices();
  await app.listen(process.env.PORT || 3005);
  console.log(`🚀 Payment Service running on port ${process.env.PORT || 3005}`);
}
bootstrap();
EOF

cat > $BASE_DIR/payment-service/src/app.module.ts << 'EOF'
import { Module } from '@nestjs/common';
import { PrismaModule } from './prisma/prisma.module';
import { PaymentsModule } from './payments/payments.module';

@Module({
  imports: [PrismaModule, PaymentsModule],
})
export class AppModule {}
EOF

mkdir -p $BASE_DIR/payment-service/src/prisma
cat > $BASE_DIR/payment-service/src/prisma/prisma.module.ts << 'EOF'
import { Module, Global } from '@nestjs/common';
import { PrismaService } from './prisma.service';

@Global()
@Module({
  providers: [PrismaService],
  exports: [PrismaService],
})
export class PrismaModule {}
EOF

cat > $BASE_DIR/payment-service/src/prisma/prisma.service.ts << 'EOF'
import { Injectable, OnModuleInit } from '@nestjs/common';
import { PrismaClient } from '@prisma/client';

@Injectable()
export class PrismaService extends PrismaClient implements OnModuleInit {
  async onModuleInit() {
    await this.$connect();
    console.log('✅ Payment DB connected');
  }
}
EOF

cat > $BASE_DIR/payment-service/src/payments/payments.module.ts << 'EOF'
import { Module } from '@nestjs/common';
import { PaymentsService } from './payments.service';
import { PaymentsController } from './payments.controller';
import { StripeService } from './stripe.service';
import { MercadoPagoService } from './mercadopago.service';

@Module({
  providers: [PaymentsService, StripeService, MercadoPagoService],
  controllers: [PaymentsController],
})
export class PaymentsModule {}
EOF

cat > $BASE_DIR/payment-service/src/payments/payments.service.ts << 'EOF'
import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { StripeService } from './stripe.service';
import { MercadoPagoService } from './mercadopago.service';

@Injectable()
export class PaymentsService {
  constructor(
    private prisma: PrismaService,
    private stripeService: StripeService,
    private mercadoPagoService: MercadoPagoService,
  ) {}

  async createPayment(
    orderId: string,
    userId: string,
    amount: number,
    paymentMethod: 'stripe' | 'mercadopago',
    currency: string = 'USD',
  ) {
    let paymentIntent;
    let payment;

    if (paymentMethod === 'stripe') {
      paymentIntent = await this.stripeService.createPaymentIntent(amount, currency);
      payment = await this.prisma.payment.create({
        data: {
          orderId,
          userId,
          amount,
          currency,
          paymentMethod: 'stripe',
          stripePaymentId: paymentIntent.id,
          status: 'PENDING',
        },
      });
    } else if (paymentMethod === 'mercadopago') {
      paymentIntent = await this.mercadoPagoService.createPreference(orderId, amount);
      payment = await this.prisma.payment.create({
        data: {
          orderId,
          userId,
          amount,
          currency,
          paymentMethod: 'mercadopago',
          mpPaymentId: paymentIntent.id,
          status: 'PENDING',
        },
      });
    }

    return { payment, clientSecret: paymentIntent.client_secret || paymentIntent.init_point };
  }

  async updatePaymentStatus(paymentId: string, status: string) {
    return this.prisma.payment.update({
      where: { id: paymentId },
      data: { status: status as any },
    });
  }

  async findByOrderId(orderId: string) {
    return this.prisma.payment.findUnique({ where: { orderId } });
  }
}
EOF

cat > $BASE_DIR/payment-service/src/payments/stripe.service.ts << 'EOF'
import { Injectable } from '@nestjs/common';
import Stripe from 'stripe';

@Injectable()
export class StripeService {
  private stripe: Stripe;

  constructor() {
    this.stripe = new Stripe(process.env.STRIPE_SECRET_KEY || 'sk_test_placeholder', {
      apiVersion: '2024-12-18.acacia',
    });
  }

  async createPaymentIntent(amount: number, currency: string) {
    return this.stripe.paymentIntents.create({
      amount: Math.round(amount * 100),
      currency: currency.toLowerCase(),
      automatic_payment_methods: {
        enabled: true,
      },
    });
  }

  async confirmPayment(paymentIntentId: string) {
    return this.stripe.paymentIntents.confirm(paymentIntentId);
  }
}
EOF

cat > $BASE_DIR/payment-service/src/payments/mercadopago.service.ts << 'EOF'
import { Injectable } from '@nestjs/common';

@Injectable()
export class MercadoPagoService {
  async createPreference(orderId: string, amount: number) {
    // Simplified MercadoPago implementation
    // In production, use the MercadoPago SDK
    return {
      id: 'mp_' + Math.random().toString(36).substr(2, 9),
      init_point: 'https://www.mercadopago.com/checkout/preference',
    };
  }
}
EOF

cat > $BASE_DIR/payment-service/src/payments/payments.controller.ts << 'EOF'
import { Controller, Post, Get, Put, Body, Param } from '@nestjs/common';
import { PaymentsService } from './payments.service';

@Controller('api/payments')
export class PaymentsController {
  constructor(private paymentsService: PaymentsService) {}

  @Post()
  createPayment(@Body() body: {
    orderId: string;
    userId: string;
    amount: number;
    paymentMethod: 'stripe' | 'mercadopago';
    currency?: string;
  }) {
    return this.paymentsService.createPayment(
      body.orderId,
      body.userId,
      body.amount,
      body.paymentMethod,
      body.currency,
    );
  }

  @Get('order/:orderId')
  findByOrderId(@Param('orderId') orderId: string) {
    return this.paymentsService.findByOrderId(orderId);
  }

  @Put(':id/status')
  updateStatus(@Param('id') id: string, @Body() body: { status: string }) {
    return this.paymentsService.updatePaymentStatus(id, body.status);
  }
}
EOF

cat > $BASE_DIR/payment-service/tsconfig.json << 'EOF'
{
  "compilerOptions": {
    "module": "commonjs",
    "declaration": true,
    "removeComments": true,
    "emitDecoratorMetadata": true,
    "experimentalDecorators": true,
    "allowSyntheticDefaultImports": true,
    "target": "ES2021",
    "sourceMap": true,
    "outDir": "./dist",
    "baseUrl": "./",
    "incremental": true,
    "skipLibCheck": true
  }
}
EOF

cat > $BASE_DIR/payment-service/nest-cli.json << 'EOF'
{
  "collection": "@nestjs/schematics",
  "sourceRoot": "src"
}
EOF

# ============================================
# NOTIFICATION SERVICE
# ============================================
echo "Creating Notification Service..."
mkdir -p $BASE_DIR/notification-service/src/notifications
mkdir -p $BASE_DIR/notification-service/prisma

cat > $BASE_DIR/notification-service/package.json << 'EOF'
{
  "name": "notification-service",
  "version": "1.0.0",
  "scripts": {
    "build": "nest build",
    "start:dev": "nest start --watch",
    "prisma:generate": "prisma generate"
  },
  "dependencies": {
    "@nestjs/common": "^10.3.0",
    "@nestjs/core": "^10.3.0",
    "@nestjs/platform-express": "^10.3.0",
    "@nestjs/microservices": "^10.3.0",
    "@prisma/client": "^5.8.0",
    "class-validator": "^0.14.1",
    "@getbrevo/brevo": "^2.2.0",
    "redis": "^4.6.12",
    "amqplib": "^0.10.3",
    "reflect-metadata": "^0.2.1",
    "rxjs": "^7.8.1"
  },
  "devDependencies": {
    "@nestjs/cli": "^10.3.0",
    "prisma": "^5.8.0",
    "typescript": "^5.3.3"
  }
}
EOF

cat > $BASE_DIR/notification-service/Dockerfile << 'EOF'
FROM node:18-alpine
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
RUN npx prisma generate
EXPOSE 3006
CMD ["npm", "run", "start:dev"]
EOF

cat > $BASE_DIR/notification-service/prisma/schema.prisma << 'EOF'
generator client {
  provider = "prisma-client-js"
}

datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}

model Notification {
  id        String   @id @default(uuid())
  userId    String
  type      String
  channel   String
  subject   String?
  message   String
  status    String   @default("sent")
  sentAt    DateTime @default(now())

  @@map("notifications")
}
EOF

cat > $BASE_DIR/notification-service/src/main.ts << 'EOF'
import { NestFactory } from '@nestjs/core';
import { ValidationPipe } from '@nestjs/common';
import { AppModule } from './app.module';
import { MicroserviceOptions, Transport } from '@nestjs/microservices';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  app.enableCors();
  app.useGlobalPipes(new ValidationPipe({ whitelist: true, transform: true }));

  app.connectMicroservice<MicroserviceOptions>({
    transport: Transport.RMQ,
    options: {
      urls: [process.env.RABBITMQ_URL || 'amqp://admin:admin@rabbitmq:5672'],
      queue: 'notification_queue',
      queueOptions: { durable: true },
    },
  });

  await app.startAllMicroservices();
  await app.listen(process.env.PORT || 3006);
  console.log(`🚀 Notification Service running on port ${process.env.PORT || 3006}`);
}
bootstrap();
EOF

cat > $BASE_DIR/notification-service/src/app.module.ts << 'EOF'
import { Module } from '@nestjs/common';
import { PrismaModule } from './prisma/prisma.module';
import { NotificationsModule } from './notifications/notifications.module';

@Module({
  imports: [PrismaModule, NotificationsModule],
})
export class AppModule {}
EOF

mkdir -p $BASE_DIR/notification-service/src/prisma
cat > $BASE_DIR/notification-service/src/prisma/prisma.module.ts << 'EOF'
import { Module, Global } from '@nestjs/common';
import { PrismaService } from './prisma.service';

@Global()
@Module({
  providers: [PrismaService],
  exports: [PrismaService],
})
export class PrismaModule {}
EOF

cat > $BASE_DIR/notification-service/src/prisma/prisma.service.ts << 'EOF'
import { Injectable, OnModuleInit } from '@nestjs/common';
import { PrismaClient } from '@prisma/client';

@Injectable()
export class PrismaService extends PrismaClient implements OnModuleInit {
  async onModuleInit() {
    await this.$connect();
    console.log('✅ Notification DB connected');
  }
}
EOF

cat > $BASE_DIR/notification-service/src/notifications/notifications.module.ts << 'EOF'
import { Module } from '@nestjs/common';
import { NotificationsService } from './notifications.service';
import { NotificationsController } from './notifications.controller';
import { EmailService } from './email.service';

@Module({
  providers: [NotificationsService, EmailService],
  controllers: [NotificationsController],
})
export class NotificationsModule {}
EOF

cat > $BASE_DIR/notification-service/src/notifications/notifications.service.ts << 'EOF'
import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { EmailService } from './email.service';
import { EventPattern } from '@nestjs/microservices';

@Injectable()
export class NotificationsService {
  constructor(
    private prisma: PrismaService,
    private emailService: EmailService,
  ) {}

  @EventPattern('send_email')
  async handleEmailEvent(data: { to: string; subject: string; template: string; data: any }) {
    return this.sendEmail(data.to, data.subject, data.template, data.data);
  }

  async sendEmail(to: string, subject: string, template: string, data: any) {
    try {
      await this.emailService.sendEmail(to, subject, this.getEmailContent(template, data));
      
      await this.prisma.notification.create({
        data: {
          userId: to,
          type: 'email',
          channel: 'brevo',
          subject,
          message: JSON.stringify(data),
          status: 'sent',
        },
      });

      return { success: true };
    } catch (error) {
      console.error('Email sending failed:', error);
      return { success: false, error: error.message };
    }
  }

  private getEmailContent(template: string, data: any): string {
    switch (template) {
      case 'order_confirmation':
        return `
          <h1>Order Confirmation</h1>
          <p>Thank you for your order!</p>
          <p>Order ID: ${data.orderId}</p>
          <p>Total Amount: $${data.totalAmount}</p>
        `;
      case 'shipping_update':
        return `
          <h1>Shipping Update</h1>
          <p>Your order ${data.orderId} has been shipped!</p>
          <p>Tracking number: ${data.trackingNumber}</p>
        `;
      default:
        return '<p>Notification from our e-commerce platform</p>';
    }
  }

  async findAll(userId?: string) {
    return this.prisma.notification.findMany({
      where: userId ? { userId } : undefined,
      orderBy: { sentAt: 'desc' },
    });
  }
}
EOF

cat > $BASE_DIR/notification-service/src/notifications/email.service.ts << 'EOF'
import { Injectable } from '@nestjs/common';

@Injectable()
export class EmailService {
  async sendEmail(to: string, subject: string, htmlContent: string) {
    // Simplified Brevo implementation
    // In production, use the Brevo SDK with actual API keys
    console.log(`📧 Email sent to ${to}: ${subject}`);
    
    // Simulated email sending
    return {
      messageId: 'msg_' + Math.random().toString(36).substr(2, 9),
      status: 'sent',
    };
  }
}
EOF

cat > $BASE_DIR/notification-service/src/notifications/notifications.controller.ts << 'EOF'
import { Controller, Get, Post, Body, Query } from '@nestjs/common';
import { NotificationsService } from './notifications.service';

@Controller('api/notifications')
export class NotificationsController {
  constructor(private notificationsService: NotificationsService) {}

  @Post('email')
  sendEmail(@Body() body: { to: string; subject: string; template: string; data: any }) {
    return this.notificationsService.sendEmail(body.to, body.subject, body.template, body.data);
  }

  @Get()
  findAll(@Query('userId') userId?: string) {
    return this.notificationsService.findAll(userId);
  }
}
EOF

cat > $BASE_DIR/notification-service/tsconfig.json << 'EOF'
{
  "compilerOptions": {
    "module": "commonjs",
    "declaration": true,
    "removeComments": true,
    "emitDecoratorMetadata": true,
    "experimentalDecorators": true,
    "allowSyntheticDefaultImports": true,
    "target": "ES2021",
    "sourceMap": true,
    "outDir": "./dist",
    "baseUrl": "./",
    "incremental": true,
    "skipLibCheck": true
  }
}
EOF

cat > $BASE_DIR/notification-service/nest-cli.json << 'EOF'
{
  "collection": "@nestjs/schematics",
  "sourceRoot": "src"
}
EOF

echo "✅ Order, Payment, and Notification services created successfully!"
