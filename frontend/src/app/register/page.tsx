'use client'
import { useState } from 'react';
import axios from 'axios';

export default function Register() {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');

  const handleRegister = async (e: React.FormEvent) => {
    e.preventDefault();
    try {
      await axios.post('http://localhost:3000/api/auth/register', { email, password });
      alert('¡Usuario creado! Ahora podés loguearte.');
    } catch (error) {
      alert('Error al registrarse');
    }
  };

  return (
    <div className="p-10">
      <h1 className="text-2xl mb-4">Registro</h1>
      <form onSubmit={handleRegister} className="flex flex-col gap-4 w-64">
        <input type="email" placeholder="Email" onChange={e => setEmail(e.target.value)} className="border p-2 text-black"/>
        <input type="password" placeholder="Password" onChange={e => setPassword(e.target.value)} className="border p-2 text-black"/>
        <button type="submit" className="bg-blue-500 text-white p-2">Crear cuenta</button>
      </form>
    </div>
  );
}