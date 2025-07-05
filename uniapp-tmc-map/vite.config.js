import { defineConfig } from 'vite'
import uni from '@dcloudio/vite-plugin-uni'

export default defineConfig({
  plugins: [uni()],
  server: {
    host: '0.0.0.0',
    port: 3000,
    open: true,
    hmr: {
      overlay: true
    }
  },
  // 简化配置，避免与 UniApp 冲突
  define: {
    __UNI_FEATURE_WX__: true,
    __UNI_FEATURE_PROMISE__: false,
    __UNI_PLATFORM__: JSON.stringify(process.env.UNI_PLATFORM || 'h5'),
    'import.meta.env.VUE_APP_API_BASE_URL': JSON.stringify(process.env.VUE_APP_API_BASE_URL)
  }
}) 