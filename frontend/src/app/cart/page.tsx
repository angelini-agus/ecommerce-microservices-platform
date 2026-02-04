'use client';

import { useEffect, useState } from 'react';
import axios from 'axios';

interface CartItem {
  id: string;
  productId: string;
  quantity: number;
  price: number;
}

export default function CartPage() {
  const [cartItems, setCartItems] = useState<CartItem[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');

  const fetchCart = async () => {
    try {
      // 🔑 LA CLAVE: Le enviamos el userId 'guest-user-123' como parámetro
      const response = await axios.get('http://localhost:3000/api/cart', {
        params: { userId: 'guest-user-123' } 
      });
      
      // El backend nos devuelve el objeto cart, y dentro tiene 'items'
      setCartItems(response.data.items || []); 
    } catch (err) {
      console.error('Error cargando el carrito:', err);
      setError('No se pudo cargar el carrito');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchCart();
  }, []);

  if (loading) return <div className="text-center p-10">Cargando carrito...</div>;
  if (error) return <div className="text-center p-10 text-red-500">{error}</div>;

  return (
    <div className="container mx-auto p-4">
      <h1 className="text-3xl font-bold mb-6">Tu Carrito</h1>

      {cartItems.length === 0 ? (
        <div className="bg-white p-10 rounded-lg shadow text-center">
          <h2 className="text-xl text-gray-600 mb-4">Tu carrito está vacío</h2>
          <a href="/" className="bg-blue-600 text-white px-6 py-2 rounded hover:bg-blue-700">
            Ir a comprar
          </a>
        </div>
      ) : (
        <div className="bg-white rounded-lg shadow overflow-hidden">
          <table className="w-full">
            <thead className="bg-gray-100">
              <tr>
                <th className="p-4 text-left">Producto ID</th>
                <th className="p-4 text-left">Precio</th>
                <th className="p-4 text-left">Cantidad</th>
                <th className="p-4 text-left">Total</th>
              </tr>
            </thead>
            <tbody>
              {cartItems.map((item) => (
                <tr key={item.id} className="border-t">
                  <td className="p-4 text-gray-700">{item.productId}</td>
                  <td className="p-4">${item.price}</td>
                  <td className="p-4">{item.quantity}</td>
                  <td className="p-4 font-bold">${item.price * item.quantity}</td>
                </tr>
              ))}
            </tbody>
          </table>
          <div className="p-4 bg-gray-50 text-right">
            <span className="text-xl font-bold mr-4">
              Total Final: ${cartItems.reduce((acc, item) => acc + (item.price * item.quantity), 0)}
            </span>
            <button className="bg-green-600 text-white px-6 py-2 rounded hover:bg-green-700">
              Finalizar Compra
            </button>
          </div>
        </div>
      )}
    </div>
  );
}