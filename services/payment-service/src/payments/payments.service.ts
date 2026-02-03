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
