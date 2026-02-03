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
