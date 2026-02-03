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
