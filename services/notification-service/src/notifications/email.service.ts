import { Injectable } from '@nestjs/common';

@Injectable()
export class EmailService {
  async sendEmail(to: string, subject: string, htmlContent: string) {
    // Simplified Brevo implementation
    // In production, use the Brevo SDK with actual API keys
    console.log(`📧 Email sent to ${to}: ${subject}`);
    
    // Simulated email sending
    return {
      messageId: 'msg_' + Math.random().toString(36).substr(2, 9),
      status: 'sent',
    };
  }
}
