import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

export default defineConfig({
  base: '/customer-search-poc/',
  plugins: [react()],
  server: {
    port: 5173
  }
})