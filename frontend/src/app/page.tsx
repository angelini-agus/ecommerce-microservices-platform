'use client';

import { useEffect, useState } from 'react';
import axios from 'axios';

// Definimos cómo se ve un producto
interface Product {
  id: string;
  name: string;
  description: string;
  price: number;
  imageUrl: string;
  stock: number;
}

export default function Home() {
  const [products, setProducts] = useState<Product[]>([]);
  const [loading, setLoading] = useState(true);

  // Cargamos los productos al iniciar
  useEffect(() => {
    const fetchProducts = async () => {
      try {
        const response = await axios.get('http://localhost:3000/api/products');
        setProducts(response.data);
      } catch (error) {
        console.error('Error fetching products:', error);
      } finally {
        setLoading(false);
      }
    };

    fetchProducts();
  }, []);

  // --- ESTA ES LA MAGIA NUEVA ---
  const addToCart = async (product: Product) => {
    try {
      // Usamos un ID fijo temporalmente para probar sin Login
      const guestUserId = 'guest-user-123';

      await axios.post('http://localhost:3000/api/cart/items', {
        userId: guestUserId,
        productId: product.id,
        quantity: 1,
        price: product.price
      });

      alert(`✅ ${product.name} agregado al carrito!`);
    } catch (error) {
      console.error('Error adding to cart:', error);
      alert('❌ Error al agregar producto. Chequeá la consola.');
    }
  };
  // -----------------------------

  if (loading) return <div className="text-center p-10">Cargando productos...</div>;

  return (
    <div className="container mx-auto p-4">
      <h1 className="text-3xl font-bold mb-6 text-center">Nuestros Productos</h1>
      
      {products.length === 0 ? (
        <div className="text-center text-gray-500">
          <p>No hay productos disponibles.</p>
          <p className="text-sm mt-2">(Asegurate de crear productos en el product-service)</p>
        </div>
      ) : (
        <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
          {products.map((product) => (
            <div key={product.id} className="border rounded-lg p-4 shadow-lg flex flex-col items-center">
              {/* Si tenés imágenes reales, usá product.imageUrl */}
              <div className="w-full h-48 bg-gray-200 mb-4 rounded flex items-center justify-center text-gray-500">
                [Imagen de {product.name}]
              </div>
              
              <h2 className="text-xl font-bold">{product.name}</h2>
              <p className="text-gray-600 my-2">{product.description}</p>
              <p className="text-2xl font-bold text-green-600">${product.price}</p>
              
              <button
                onClick={() => addToCart(product)}
                className="mt-4 bg-blue-600 text-white px-4 py-2 rounded hover:bg-blue-700 transition w-full"
              >
                Añadir al Carrito
              </button>
            </div>
          ))}
        </div>
      )}
    </div>
  );
}