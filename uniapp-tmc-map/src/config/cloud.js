/**
 * 微信云托管配置
 */

export const CLOUD_CONFIG = {
  // 微信云托管环境ID（必填）
  env: 'prod-4g2xqhcl04d0b0dc',
  
  // 微信云托管服务名称（必填）
  serviceName: 'springboot-gub6',
  
  // 如果是资源复用情况，需要配置以下参数
  // resourceAppid: 'YOUR_APPID', // 环境所属的账号appid
  // resourceEnv: 'YOUR_ENV_ID',  // 微信云托管的环境ID
  
  // 降级方案的HTTP请求地址
  fallbackBaseUrl: 'https://springboot-gub6-171302-5-1367566291.sh.run.tcloudbase.com',
  
  // 开发环境配置
  development: {
    computerIP: '10.153.227.79',
    useComputerIP: false, // 手机调试时设置为true
    port: 8080
  }
}

// 获取开发环境的API地址
export const getDevApiBase = () => {
  const { computerIP, useComputerIP, port } = CLOUD_CONFIG.development
  return useComputerIP ? `http://${computerIP}:${port}` : `http://localhost:${port}`
}

// 检查是否在微信小程序环境
export const isWeChatMiniProgram = () => {
  return typeof wx !== 'undefined' && wx.cloud
}

// 检查是否支持云托管
export const isCloudHostingSupported = () => {
  return isWeChatMiniProgram() && wx.cloud.callContainer
}

export default CLOUD_CONFIG 