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
