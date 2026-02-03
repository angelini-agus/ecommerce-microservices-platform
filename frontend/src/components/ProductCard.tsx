'use client'

import { useCartStore } from '@/store/useCartStore'
import toast from 'react-hot-toast'

interface Product {
  id: string
  name: string
  description: string
  price: number
  imageUrl: string
  stock: number
}

export default function ProductCard({ product }: { product: Product }) {
  const addItem = useCartStore((state) => state.addItem)

  const handleAddToCart = () => {
    addItem({
      productId: product.id,
      name: product.name,
      price: product.price,
      quantity: 1,
      imageUrl: product.imageUrl,
    })
    toast.success('Added to cart!')
  }

  return (
    <div className="border rounded-lg p-4 hover:shadow-lg transition">
      <div className="aspect-square bg-gray-200 rounded mb-4"></div>
      <h3 className="font-semibold text-lg mb-2">{product.name}</h3>
      <p className="text-gray-600 text-sm mb-4 line-clamp-2">
        {product.description}
      </p>
      <div className="flex justify-between items-center">
        <span className="text-xl font-bold">${product.price}</span>
        <button
          onClick={handleAddToCart}
          className="bg-blue-600 text-white px-4 py-2 rounded hover:bg-blue-700"
          disabled={product.stock === 0}
        >
          {product.stock > 0 ? 'Add to Cart' : 'Out of Stock'}
        </button>
      </div>
    </div>
  )
}
