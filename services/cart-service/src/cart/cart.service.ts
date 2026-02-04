import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class CartService {
  constructor(private prisma: PrismaService) {}

  async getCart(userId: string) {
    // Si no llega un userId, devolvemos un carrito vacío ficticio
    if (!userId || userId === 'undefined' || userId === 'null') {
      return { id: 'guest-session', userId: 'guest', items: [] };
    }

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
    const activeUserId = userId || 'guest-user-123';
    const cart: any = await this.getCart(activeUserId);

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
    const activeUserId = userId || 'guest-user-123';
    const cart: any = await this.getCart(activeUserId);
    
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
    const activeUserId = userId || 'guest-user-123';
    const cart: any = await this.getCart(activeUserId);
    
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
    const activeUserId = userId || 'guest-user-123';
    const cart: any = await this.getCart(activeUserId);
    
    await this.prisma.cartItem.deleteMany({
      where: { cartId: cart.id },
    });

    return { message: 'Cart cleared' };
  }
} // <--- ¡ESTA LLAVE ES LA QUE TE FALTABA!