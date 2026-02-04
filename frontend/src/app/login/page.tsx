'use client'
import { useState } from 'react';
import axios from 'axios';

export default function Login() {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [loading, setLoading] = useState(false);

  const handleLogin = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    
    console.log("Intentando conectar con:", email);

    try {
      const response = await axios.post('http://localhost:3000/api/auth/login', { 
        email, 
        password 
      });

      console.log("Respuesta bruta del servidor:", response.data);

      // VALIDACIÓN CLAVE: NestJS devuelve 'access_token' (con guion bajo)
      if (response.data && response.data.access_token) {
        
        // Guardamos los datos
        localStorage.setItem('token', response.data.access_token);
        localStorage.setItem('user', JSON.stringify(response.data.user));
        
        alert('¡LOGIN EXITOSO! Guardado en LocalStorage.');
        
        // Redirección forzada para asegurar que limpie todo
        window.location.href = '/'; 
      } else {
        alert('El servidor respondió pero NO envió el access_token. Revisá la consola.');
        console.log("Keys recibidas:", Object.keys(response.data));
      }

    } catch (err: any) {
      console.error('Error capturado:', err);
      const mensaje = err.response?.data?.message || 'Error de conexión con el servidor';
      alert('FALLÓ EL LOGIN: ' + mensaje);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="flex flex-col items-center justify-center min-h-screen bg-gray-100 text-black">
      <form onSubmit={handleLogin} className="p-10 bg-white shadow-xl rounded-xl w-full max-w-sm border border-gray-200">
        <h1 className="text-3xl font-bold mb-8 text-center text-blue-600">Bienvenido</h1>
        
        <input 
          type="email" 
          placeholder="Email" 
          value={email}
          onChange={e => setEmail(e.target.value)} 
          className="border p-3 mb-4 rounded w-full focus:ring-2 focus:ring-blue-400 outline-none"
          required
        />
        
        <input 
          type="password" 
          placeholder="Contraseña" 
          value={password}
          onChange={e => setPassword(e.target.value)} 
          className="border p-3 mb-6 rounded w-full focus:ring-2 focus:ring-blue-400 outline-none"
          required
        />
        
        <button 
          type="submit" 
          disabled={loading}
          className={`w-full p-3 rounded font-bold text-white transition ${loading ? 'bg-gray-400' : 'bg-blue-600 hover:bg-blue-700'}`}
        >
          {loading ? 'Cargando...' : 'INGRESAR'}
        </button>

        <p className="mt-6 text-center text-sm">
          ¿No tenés cuenta? <a href="/register" className="text-blue-500 hover:underline">Registrate</a>
        </p>
      </form>
    </div>
  );
}