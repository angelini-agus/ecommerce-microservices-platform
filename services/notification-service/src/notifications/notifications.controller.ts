import { Controller, Get, Post, Body, Query } from '@nestjs/common';
import { NotificationsService } from './notifications.service';

@Controller('api/notifications')
export class NotificationsController {
  constructor(private notificationsService: NotificationsService) {}

  @Post('email')
  sendEmail(@Body() body: { to: string; subject: string; template: string; data: any }) {
    return this.notificationsService.sendEmail(body.to, body.subject, body.template, body.data);
  }

  @Get()
  findAll(@Query('userId') userId?: string) {
    return this.notificationsService.findAll(userId);
  }
}
