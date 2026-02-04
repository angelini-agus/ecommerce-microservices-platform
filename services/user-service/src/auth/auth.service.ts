import { Injectable, UnauthorizedException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { PrismaService } from '../prisma/prisma.service';
import * as bcrypt from 'bcrypt';

@Injectable()
export class AuthService {
  constructor(
    private prisma: PrismaService,
    private jwtService: JwtService,
  ) {}

  async validateUser(email: string, pass: string): Promise<any> {
    // Buscamos al usuario en la tabla que acabamos de mapear
    const user = await this.prisma.user.findUnique({
      where: { email },
    });

    if (!user) {
      console.log(`[Auth] El usuario con email ${email} no existe.`);
      return null;
    }

    // Comparamos la contraseña plana con el hash de la DB
    const isMatch = await bcrypt.compare(pass, user.password);
    
    if (!isMatch) {
      console.log(`[Auth] Contraseña incorrecta para: ${email}`);
      return null;
    }

    console.log(`[Auth] Usuario validado correctamente: ${email}`);
    
    // Quitamos el password del objeto antes de devolverlo por seguridad
    const { password, ...result } = user;
    return result;
  }

  async login(user: any) {
    const payload = { 
      email: user.email, 
      sub: user.id, 
      role: user.role 
    };
    
    return {
      access_token: this.jwtService.sign(payload),
      user: {
        id: user.id,
        email: user.email,
        firstName: user.firstName,
        lastName: user.lastName,
        role: user.role,
      },
    };
  }

  async register(data: any) {
    // Encriptamos la contraseña antes de guardarla
    const hashedPassword = await bcrypt.hash(data.password, 10);
    
    try {
      const newUser = await this.prisma.user.create({
        data: {
          ...data,
          password: hashedPassword,
        },
      });

      // Hacemos login automático al registrarse
      return this.login(newUser);
    } catch (error) {
      if (error.code === 'P2002') {
        throw new UnauthorizedException('El email ya está registrado');
      }
      throw error;
    }
  }
}