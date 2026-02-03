import { Module } from '@nestjs/common';
import { PrismaModule } from './prisma/prisma.module';
import { CartModule } from './cart/cart.module';

@Module({
  imports: [PrismaModule, CartModule],
})
export class AppModule {}
