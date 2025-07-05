import { createSSRApp } from 'vue'
import pinia from './store/index.js'
import App from './App.vue'

export function createApp() {
  const app = createSSRApp(App)
  
  // 使用pinia状态管理
  app.use(pinia)
  
  return {
    app
  }
} 