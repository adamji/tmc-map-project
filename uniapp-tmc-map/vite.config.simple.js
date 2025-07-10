import { defineConfig } from 'vite'
import uni from '@dcloudio/vite-plugin-uni'

export default defineConfig({
  plugins: [uni()],
  server: {
    host: '0.0.0.0',
    port: 3000
  },
  // 最小化配置，避免编译错误
  define: {
    __UNI_PLATFORM__: '"mp-weixin"'
  }
}) 