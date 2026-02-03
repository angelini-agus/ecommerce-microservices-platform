#!/bin/bash

FRONTEND_DIR="/home/claude/ecommerce-platform/frontend"
mkdir -p $FRONTEND_DIR

# Package.json
cat > $FRONTEND_DIR/package.json << 'EOF'
{
  "name": "ecommerce-frontend",
  "version": "0.1.0",
  "private": true,
  "scripts": {
    "dev": "next dev",
    "build": "next build",
    "start": "next start",
    "lint": "next lint"
  },
  "dependencies": {
    "next": "14.2.0",
    "react": "^18.2.0",
    "react-dom": "^18.2.0",
    "axios": "^1.6.5",
    "@stripe/stripe-js": "^2.4.0",
    "@stripe/react-stripe-js": "^2.4.0",
    "zustand": "^4.5.0",
    "react-hot-toast": "^2.4.1"
  },
  "devDependencies": {
    "typescript": "^5.3.3",
    "@types/node": "^20.11.0",
    "@types/react": "^18.2.0",
    "@types/react-dom": "^18.2.0",
    "autoprefixer": "^10.4.17",
    "postcss": "^8.4.33",
    "tailwindcss": "^3.4.1",
    "eslint": "^8",
    "eslint-config-next": "14.2.0"
  }
}
EOF

# Dockerfile
cat > $FRONTEND_DIR/Dockerfile << 'EOF'
FROM node:18-alpine

WORKDIR /app

COPY package*.json ./

RUN npm install

COPY . .

EXPOSE 3000

CMD ["npm", "run", "dev"]
EOF

# Next.js config
cat > $FRONTEND_DIR/next.config.js << 'EOF'
/** @type {import('next').NextConfig} */
const nextConfig = {
  reactStrictMode: true,
  images: {
    domains: ['localhost'],
  },
}

module.exports = nextConfig
EOF

# Tailwind config
cat > $FRONTEND_DIR/tailwind.config.js << 'EOF'
/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    './src/pages/**/*.{js,ts,jsx,tsx,mdx}',
    './src/components/**/*.{js,ts,jsx,tsx,mdx}',
    './src/app/**/*.{js,ts,jsx,tsx,mdx}',
  ],
  theme: {
    extend: {},
  },
  plugins: [],
}
EOF

cat > $FRONTEND_DIR/postcss.config.js << 'EOF'
module.exports = {
  plugins: {
    tailwindcss: {},
    autoprefixer: {},
  },
}
EOF

# TypeScript config
cat > $FRONTEND_DIR/tsconfig.json << 'EOF'
{
  "compilerOptions": {
    "target": "ES2017",
    "lib": ["dom", "dom.iterable", "esnext"],
    "allowJs": true,
    "skipLibCheck": true,
    "strict": true,
    "noEmit": true,
    "esModuleInterop": true,
    "module": "esnext",
    "moduleResolution": "bundler",
    "resolveJsonModule": true,
    "isolatedModules": true,
    "jsx": "preserve",
    "incremental": true,
    "plugins": [
      {
        "name": "next"
      }
    ],
    "paths": {
      "@/*": ["./src/*"]
    }
  },
  "include": ["next-env.d.ts", "**/*.ts", "**/*.tsx", ".next/types/**/*.ts"],
  "exclude": ["node_modules"]
}
EOF

# Create app directory structure
mkdir -p $FRONTEND_DIR/src/app
mkdir -p $FRONTEND_DIR/src/components
mkdir -p $FRONTEND_DIR/src/lib
mkdir -p $FRONTEND_DIR/src/store
mkdir -p $FRONTEND_DIR/public

# Root layout
cat > $FRONTEND_DIR/src/app/layout.tsx << 'EOF'
import type { Metadata } from 'next'
import { Inter } from 'next/font/google'
import './globals.css'
import { Toaster } from 'react-hot-toast'

const inter = Inter({ subsets: ['latin'] })

export const metadata: Metadata = {
  title: 'E-Commerce Platform',
  description: 'Scalable microservices e-commerce platform',
}

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html lang="en">
      <body className={inter.className}>
        <Toaster position="top-right" />
        {children}
      </body>
    </html>
  )
}
EOF

# Global CSS
cat > $FRONTEND_DIR/src/app/globals.css << 'EOF'
@tailwind base;
@tailwind components;
@tailwind utilities;

:root {
  --foreground-rgb: 0, 0, 0;
  --background-start-rgb: 214, 219, 220;
  --background-end-rgb: 255, 255, 255;
}

@media (prefers-color-scheme: dark) {
  :root {
    --foreground-rgb: 255, 255, 255;
    --background-start-rgb: 0, 0, 0;
    --background-end-rgb: 0, 0, 0;
  }
}

body {
  color: rgb(var(--foreground-rgb));
  background: linear-gradient(
      to bottom,
      transparent,
      rgb(var(--background-end-rgb))
    )
    rgb(var(--background-start-rgb));
}
EOF

# Home page
cat > $FRONTEND_DIR/src/app/page.tsx << 'EOF'
'use client'

import { useEffect, useState } from 'react'
import { api } from '@/lib/api'
import ProductCard from '@/components/ProductCard'
import Navbar from '@/components/Navbar'

interface Product {
  id: string
  name: string
  description: string
  price: number
  imageUrl: string
  stock: number
}

export default function Home() {
  const [products, setProducts] = useState<Product[]>([])
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    fetchProducts()
  }, [])

  const fetchProducts = async () => {
    try {
      const { data } = await api.get('/products')
      setProducts(data)
    } catch (error) {
      console.error('Error fetching products:', error)
    } finally {
      setLoading(false)
    }
  }

  return (
    <div className="min-h-screen">
      <Navbar />
      <main className="container mx-auto px-4 py-8">
        <h1 className="text-4xl font-bold mb-8">Featured Products</h1>
        
        {loading ? (
          <div className="text-center py-12">Loading...</div>
        ) : (
          <div className="grid grid-cols-1 md:grid-cols-3 lg:grid-cols-4 gap-6">
            {products.map((product) => (
              <ProductCard key={product.id} product={product} />
            ))}
          </div>
        )}
      </main>
    </div>
  )
}
EOF

# API client
cat > $FRONTEND_DIR/src/lib/api.ts << 'EOF'
import axios from 'axios'

export const api = axios.create({
  baseURL: process.env.NEXT_PUBLIC_API_URL || 'http://localhost:3000/api',
  headers: {
    'Content-Type': 'application/json',
  },
})

// Add token to requests if available
api.interceptors.request.use((config) => {
  const token = localStorage.getItem('token')
  if (token) {
    config.headers.Authorization = `Bearer ${token}`
  }
  return config
})
EOF

# Zustand store
cat > $FRONTEND_DIR/src/store/useAuthStore.ts << 'EOF'
import { create } from 'zustand'

interface User {
  id: string
  email: string
  firstName?: string
  lastName?: string
}

interface AuthState {
  user: User | null
  token: string | null
  setAuth: (user: User, token: string) => void
  logout: () => void
}

export const useAuthStore = create<AuthState>((set) => ({
  user: null,
  token: null,
  setAuth: (user, token) => {
    localStorage.setItem('token', token)
    set({ user, token })
  },
  logout: () => {
    localStorage.removeItem('token')
    set({ user: null, token: null })
  },
}))
EOF

cat > $FRONTEND_DIR/src/store/useCartStore.ts << 'EOF'
import { create } from 'zustand'

interface CartItem {
  productId: string
  name: string
  price: number
  quantity: number
  imageUrl: string
}

interface CartState {
  items: CartItem[]
  addItem: (item: CartItem) => void
  removeItem: (productId: string) => void
  updateQuantity: (productId: string, quantity: number) => void
  clearCart: () => void
  total: () => number
}

export const useCartStore = create<CartState>((set, get) => ({
  items: [],
  addItem: (item) => {
    const items = get().items
    const existing = items.find((i) => i.productId === item.productId)
    
    if (existing) {
      set({
        items: items.map((i) =>
          i.productId === item.productId
            ? { ...i, quantity: i.quantity + item.quantity }
            : i
        ),
      })
    } else {
      set({ items: [...items, item] })
    }
  },
  removeItem: (productId) =>
    set({ items: get().items.filter((i) => i.productId !== productId) }),
  updateQuantity: (productId, quantity) =>
    set({
      items: get().items.map((i) =>
        i.productId === productId ? { ...i, quantity } : i
      ),
    }),
  clearCart: () => set({ items: [] }),
  total: () =>
    get().items.reduce((sum, item) => sum + item.price * item.quantity, 0),
}))
EOF

# Navbar component
cat > $FRONTEND_DIR/src/components/Navbar.tsx << 'EOF'
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
EOF

# Product Card component
cat > $FRONTEND_DIR/src/components/ProductCard.tsx << 'EOF'
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
EOF

echo "✅ Frontend created successfully!"
