import type { Metadata } from 'next';
import { Inter } from 'next/font/google';
import './globals.css';
// 👇 1. Importá tu Navbar (Ajustá la ruta si está en otra carpeta)
import Navbar from '../components/Navbar'; 

const inter = Inter({ subsets: ['latin'] });

export const metadata: Metadata = {
  title: 'Mi E-Commerce',
  description: 'E-Commerce con Microservicios',
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="es">
      <body className={inter.className}>
        {/* 👇 2. Agregalo acá, arriba de todo */}
        <Navbar />
        
        <main className="min-h-screen bg-gray-50">
          {children}
        </main>
      </body>
    </html>
  );
}