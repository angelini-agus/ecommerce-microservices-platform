'use client'
import { useState } from 'react';
import axios from 'axios';
import { useRouter } from 'next/navigation';

export default function Login() {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState('');
  const router = useRouter();

  const handleLogin = async (e: React.FormEvent) => {
    e.preventDefault();
    setError('');
    
    try {
      // 1. Una SOLA petición al Gateway
      const response = await axios.post('http://localhost:3000/api/auth/login', { 
        email, 
        password 
      });

      console.log('Respuesta del server:', response.data);

      // 2. Verificamos que el token exista en el JSON (usando access_token con _)
      if (response.data.access_token) {
        // Guardamos el token
        localStorage.setItem('token', response.data.access_token);
        
        // Guardamos los datos del user si vienen
        if (response.data.user) {
          localStorage.setItem('user', JSON.stringify(response.data.user));
        }

        alert('¡Login exitoso!');
        
        // 3. Redirección limpia
        // Usamos window.location para forzar un refresh del layout de Next.js
        window.location.href = '/'; 
      } else {
        setError('El servidor no devolvió un token.');
      }

    } catch (err: any) {
      console.error('Error en login:', err);
      // Capturamos el mensaje de error que configuraste en NestJS
      const mensajeError = err.response?.data?.message || 'Email o contraseña incorrectos';
      setError(mensajeError);
    }
  };

  return (
    <div className="p-10 flex flex-col items-center">
      <h1 className="text-2xl font-bold mb-6">Iniciar Sesión</h1>
      
      <form onSubmit={handleLogin} className="flex flex-col gap-4 w-full max-w-xs">
        <input 
          type="email" 
          placeholder="Tu email" 
          value={email}
          onChange={e => setEmail(e.target.value)} 
          className="border p-2 rounded text-black"
          required
        />
        <input 
          type="password" 
          placeholder="Tu contraseña" 
          value={password}
          onChange={e => setPassword(e.target.value)} 
          className="border p-2 rounded text-black"
          required
        />
        
        {error && <p className="text-red-500 text-sm font-bold">{error}</p>}
        
        <button type="submit" className="bg-green-600 hover:bg-green-700 text-white p-2 rounded transition shadow font-bold">
          Entrar
        </button>
      </form>
      
      <p className="mt-4 text-sm text-gray-600">
        ¿No tenés cuenta? <a href="/register" className="text-blue-500 hover:underline">Registrate acá</a>
      </p>
    </div>
  );
}