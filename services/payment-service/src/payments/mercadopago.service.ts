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
