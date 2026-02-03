'use client'

import Link from 'next/link'
import { useCartStore } from '@/store/useCartStore'
import { useAuthStore } from '@/store/useAuthStore'

export default function Navbar() {
  const items = useCartStore((state) => state.items)
  const user = useAuthStore((state) => state.user)
  const logout = useAuthStore((state) => state.logout)

  return (
    <nav className="bg-gray-800 text-white p-4">
      <div className="container mx-auto flex justify-between items-center">
        <Link href="/" className="text-2xl font-bold">
          E-Commerce
        </Link>
        
        <div className="flex items-center gap-6">
          <Link href="/products" className="hover:text-gray-300">
            Products
          </Link>
          
          {user ? (
            <>
              <Link href="/orders" className="hover:text-gray-300">
                Orders
              </Link>
              <button onClick={logout} className="hover:text-gray-300">
                Logout
              </button>
            </>
          ) : (
            <>
              <Link href="/login" className="hover:text-gray-300">
                Login
              </Link>
              <Link href="/register" className="hover:text-gray-300">
                Register
              </Link>
            </>
          )}
          
          <Link href="/cart" className="hover:text-gray-300 relative">
            Cart
            {items.length > 0 && (
              <span className="absolute -top-2 -right-2 bg-red-500 rounded-full w-5 h-5 flex items-center justify-center text-xs">
                {items.length}
              </span>
            )}
          </Link>
        </div>
      </div>
    </nav>
  )
}
