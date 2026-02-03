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
