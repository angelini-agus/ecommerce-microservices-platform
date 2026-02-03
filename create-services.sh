#!/bin/bash

# This script creates all the remaining microservices
# Product, Cart, Order, Payment, and Notification services

BASE_DIR="/home/claude/ecommerce-platform/services"

# ============================================
# PRODUCT SERVICE
# ============================================
echo "Creating Product Service..."
mkdir -p $BASE_DIR/product-service/src/products
mkdir -p $BASE_DIR/product-service/prisma

cat > $BASE_DIR/product-service/package.json << 'EOF'
{
  "name": "product-service",
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
    "class-transformer": "^0.5.1",
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

cat > $BASE_DIR/product-service/Dockerfile << 'EOF'
FROM node:18-alpine
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
RUN npx prisma generate
EXPOSE 3002
CMD ["npm", "run", "start:dev"]
EOF

cat > $BASE_DIR/product-service/prisma/schema.prisma << 'EOF'
generator client {
  provider = "prisma-client-js"
}

datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}

model Product {
  id          String   @id @default(uuid())
  name        String
  description String?
  price       Float
  stock       Int      @default(0)
  categoryId  String?
  imageUrl    String?
  isActive    Boolean  @default(true)
  createdAt   DateTime @default(now())
  updatedAt   DateTime @updatedAt

  category Category? @relation(fields: [categoryId], references: [id])
  
  @@map("products")
}

model Category {
  id          String    @id @default(uuid())
  name        String    @unique
  description String?
  createdAt   DateTime  @default(now())
  
  products Product[]

  @@map("categories")
}
EOF

cat > $BASE_DIR/product-service/src/main.ts << 'EOF'
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
      queue: 'product_queue',
      queueOptions: { durable: true },
    },
  });

  await app.startAllMicroservices();
  await app.listen(process.env.PORT || 3002);
  console.log(`🚀 Product Service running on port ${process.env.PORT || 3002}`);
}
bootstrap();
EOF

cat > $BASE_DIR/product-service/src/app.module.ts << 'EOF'
import { Module } from '@nestjs/common';
import { PrismaModule } from './prisma/prisma.module';
import { ProductsModule } from './products/products.module';

@Module({
  imports: [PrismaModule, ProductsModule],
})
export class AppModule {}
EOF

mkdir -p $BASE_DIR/product-service/src/prisma
cat > $BASE_DIR/product-service/src/prisma/prisma.module.ts << 'EOF'
import { Module, Global } from '@nestjs/common';
import { PrismaService } from './prisma.service';

@Global()
@Module({
  providers: [PrismaService],
  exports: [PrismaService],
})
export class PrismaModule {}
EOF

cat > $BASE_DIR/product-service/src/prisma/prisma.service.ts << 'EOF'
import { Injectable, OnModuleInit } from '@nestjs/common';
import { PrismaClient } from '@prisma/client';

@Injectable()
export class PrismaService extends PrismaClient implements OnModuleInit {
  async onModuleInit() {
    await this.$connect();
    console.log('✅ Product DB connected');
  }
}
EOF

cat > $BASE_DIR/product-service/src/products/products.module.ts << 'EOF'
import { Module } from '@nestjs/common';
import { ProductsService } from './products.service';
import { ProductsController } from './products.controller';

@Module({
  providers: [ProductsService],
  controllers: [ProductsController],
})
export class ProductsModule {}
EOF

cat > $BASE_DIR/product-service/src/products/products.service.ts << 'EOF'
import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class ProductsService {
  constructor(private prisma: PrismaService) {}

  async findAll(categoryId?: string) {
    return this.prisma.product.findMany({
      where: categoryId ? { categoryId } : undefined,
      include: { category: true },
    });
  }

  async findOne(id: string) {
    return this.prisma.product.findUnique({
      where: { id },
      include: { category: true },
    });
  }

  async create(data: any) {
    return this.prisma.product.create({ data });
  }

  async update(id: string, data: any) {
    return this.prisma.product.update({ where: { id }, data });
  }

  async remove(id: string) {
    return this.prisma.product.delete({ where: { id } });
  }

  async updateStock(id: string, quantity: number) {
    return this.prisma.product.update({
      where: { id },
      data: { stock: { decrement: quantity } },
    });
  }
}
EOF

cat > $BASE_DIR/product-service/src/products/products.controller.ts << 'EOF'
import { Controller, Get, Post, Put, Delete, Body, Param, Query } from '@nestjs/common';
import { ProductsService } from './products.service';
import { MessagePattern } from '@nestjs/microservices';

@Controller('api/products')
export class ProductsController {
  constructor(private productsService: ProductsService) {}

  @Get()
  findAll(@Query('categoryId') categoryId?: string) {
    return this.productsService.findAll(categoryId);
  }

  @Get(':id')
  findOne(@Param('id') id: string) {
    return this.productsService.findOne(id);
  }

  @Post()
  create(@Body() body: any) {
    return this.productsService.create(body);
  }

  @Put(':id')
  update(@Param('id') id: string, @Body() body: any) {
    return this.productsService.update(id, body);
  }

  @Delete(':id')
  remove(@Param('id') id: string) {
    return this.productsService.remove(id);
  }

  @MessagePattern('update_stock')
  async updateStock(data: { productId: string; quantity: number }) {
    return this.productsService.updateStock(data.productId, data.quantity);
  }
}
EOF

cat > $BASE_DIR/product-service/tsconfig.json << 'EOF'
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

cat > $BASE_DIR/product-service/nest-cli.json << 'EOF'
{
  "collection": "@nestjs/schematics",
  "sourceRoot": "src"
}
EOF

# ============================================
# CART SERVICE
# ============================================
echo "Creating Cart Service..."
mkdir -p $BASE_DIR/cart-service/src/cart
mkdir -p $BASE_DIR/cart-service/prisma

cat > $BASE_DIR/cart-service/package.json << 'EOF'
{
  "name": "cart-service",
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

cat > $BASE_DIR/cart-service/Dockerfile << 'EOF'
FROM node:18-alpine
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
RUN npx prisma generate
EXPOSE 3003
CMD ["npm", "run", "start:dev"]
EOF

cat > $BASE_DIR/cart-service/prisma/schema.prisma << 'EOF'
generator client {
  provider = "prisma-client-js"
}

datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}

model Cart {
  id        String     @id @default(uuid())
  userId    String     @unique
  createdAt DateTime   @default(now())
  updatedAt DateTime   @updatedAt
  
  items CartItem[]

  @@map("carts")
}

model CartItem {
  id        String   @id @default(uuid())
  cartId    String
  productId String
  quantity  Int      @default(1)
  price     Float
  
  cart Cart @relation(fields: [cartId], references: [id], onDelete: Cascade)

  @@unique([cartId, productId])
  @@map("cart_items")
}
EOF

cat > $BASE_DIR/cart-service/src/main.ts << 'EOF'
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
      queue: 'cart_queue',
      queueOptions: { durable: true },
    },
  });

  await app.startAllMicroservices();
  await app.listen(process.env.PORT || 3003);
  console.log(`🚀 Cart Service running on port ${process.env.PORT || 3003}`);
}
bootstrap();
EOF

cat > $BASE_DIR/cart-service/src/app.module.ts << 'EOF'
import { Module } from '@nestjs/common';
import { PrismaModule } from './prisma/prisma.module';
import { CartModule } from './cart/cart.module';

@Module({
  imports: [PrismaModule, CartModule],
})
export class AppModule {}
EOF

mkdir -p $BASE_DIR/cart-service/src/prisma
cat > $BASE_DIR/cart-service/src/prisma/prisma.module.ts << 'EOF'
import { Module, Global } from '@nestjs/common';
import { PrismaService } from './prisma.service';

@Global()
@Module({
  providers: [PrismaService],
  exports: [PrismaService],
})
export class PrismaModule {}
EOF

cat > $BASE_DIR/cart-service/src/prisma/prisma.service.ts << 'EOF'
import { Injectable, OnModuleInit } from '@nestjs/common';
import { PrismaClient } from '@prisma/client';

@Injectable()
export class PrismaService extends PrismaClient implements OnModuleInit {
  async onModuleInit() {
    await this.$connect();
    console.log('✅ Cart DB connected');
  }
}
EOF

cat > $BASE_DIR/cart-service/src/cart/cart.module.ts << 'EOF'
import { Module } from '@nestjs/common';
import { CartService } from './cart.service';
import { CartController } from './cart.controller';

@Module({
  providers: [CartService],
  controllers: [CartController],
})
export class CartModule {}
EOF

cat > $BASE_DIR/cart-service/src/cart/cart.service.ts << 'EOF'
import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class CartService {
  constructor(private prisma: PrismaService) {}

  async getCart(userId: string) {
    let cart = await this.prisma.cart.findUnique({
      where: { userId },
      include: { items: true },
    });

    if (!cart) {
      cart = await this.prisma.cart.create({
        data: { userId },
        include: { items: true },
      });
    }

    return cart;
  }

  async addItem(userId: string, productId: string, quantity: number, price: number) {
    const cart = await this.getCart(userId);

    const existingItem = await this.prisma.cartItem.findUnique({
      where: {
        cartId_productId: {
          cartId: cart.id,
          productId,
        },
      },
    });

    if (existingItem) {
      return this.prisma.cartItem.update({
        where: { id: existingItem.id },
        data: { quantity: existingItem.quantity + quantity },
      });
    }

    return this.prisma.cartItem.create({
      data: {
        cartId: cart.id,
        productId,
        quantity,
        price,
      },
    });
  }

  async updateItem(userId: string, productId: string, quantity: number) {
    const cart = await this.getCart(userId);
    
    return this.prisma.cartItem.update({
      where: {
        cartId_productId: {
          cartId: cart.id,
          productId,
        },
      },
      data: { quantity },
    });
  }

  async removeItem(userId: string, productId: string) {
    const cart = await this.getCart(userId);
    
    return this.prisma.cartItem.delete({
      where: {
        cartId_productId: {
          cartId: cart.id,
          productId,
        },
      },
    });
  }

  async clearCart(userId: string) {
    const cart = await this.getCart(userId);
    
    await this.prisma.cartItem.deleteMany({
      where: { cartId: cart.id },
    });

    return { message: 'Cart cleared' };
  }
}
EOF

cat > $BASE_DIR/cart-service/src/cart/cart.controller.ts << 'EOF'
import { Controller, Get, Post, Put, Delete, Body, Param, Query } from '@nestjs/common';
import { CartService } from './cart.service';

@Controller('api/cart')
export class CartController {
  constructor(private cartService: CartService) {}

  @Get()
  getCart(@Query('userId') userId: string) {
    return this.cartService.getCart(userId);
  }

  @Post('items')
  addItem(@Body() body: { userId: string; productId: string; quantity: number; price: number }) {
    return this.cartService.addItem(body.userId, body.productId, body.quantity, body.price);
  }

  @Put('items/:productId')
  updateItem(@Query('userId') userId: string, @Param('productId') productId: string, @Body() body: { quantity: number }) {
    return this.cartService.updateItem(userId, productId, body.quantity);
  }

  @Delete('items/:productId')
  removeItem(@Query('userId') userId: string, @Param('productId') productId: string) {
    return this.cartService.removeItem(userId, productId);
  }

  @Delete()
  clearCart(@Query('userId') userId: string) {
    return this.cartService.clearCart(userId);
  }
}
EOF

cat > $BASE_DIR/cart-service/tsconfig.json << 'EOF'
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

cat > $BASE_DIR/cart-service/nest-cli.json << 'EOF'
{
  "collection": "@nestjs/schematics",
  "sourceRoot": "src"
}
EOF

echo "✅ Product and Cart services created successfully!"
