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
