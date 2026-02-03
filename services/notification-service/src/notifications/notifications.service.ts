import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { EmailService } from './email.service';
import { EventPattern } from '@nestjs/microservices';

@Injectable()
export class NotificationsService {
  constructor(
    private prisma: PrismaService,
    private emailService: EmailService,
  ) {}

  @EventPattern('send_email')
  async handleEmailEvent(data: { to: string; subject: string; template: string; data: any }) {
    return this.sendEmail(data.to, data.subject, data.template, data.data);
  }

  async sendEmail(to: string, subject: string, template: string, data: any) {
    try {
      await this.emailService.sendEmail(to, subject, this.getEmailContent(template, data));
      
      await this.prisma.notification.create({
        data: {
          userId: to,
          type: 'email',
          channel: 'brevo',
          subject,
          message: JSON.stringify(data),
          status: 'sent',
        },
      });

      return { success: true };
    } catch (error) {
      console.error('Email sending failed:', error);
      return { success: false, error: error.message };
    }
  }

  private getEmailContent(template: string, data: any): string {
    switch (template) {
      case 'order_confirmation':
        return `
          <h1>Order Confirmation</h1>
          <p>Thank you for your order!</p>
          <p>Order ID: ${data.orderId}</p>
          <p>Total Amount: $${data.totalAmount}</p>
        `;
      case 'shipping_update':
        return `
          <h1>Shipping Update</h1>
          <p>Your order ${data.orderId} has been shipped!</p>
          <p>Tracking number: ${data.trackingNumber}</p>
        `;
      default:
        return '<p>Notification from our e-commerce platform</p>';
    }
  }

  async findAll(userId?: string) {
    return this.prisma.notification.findMany({
      where: userId ? { userId } : undefined,
      orderBy: { sentAt: 'desc' },
    });
  }
}
