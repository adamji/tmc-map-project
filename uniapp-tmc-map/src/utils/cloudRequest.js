/**
 * 微信云托管请求工具
 * 优先使用云托管内网调用，降级到传统HTTP请求
 */

// 云托管配置
const CLOUD_CONFIG = {
  env: 'prod-4g2xqhcl04d0b0dc', // 你的微信云托管环境ID
  serviceName: 'springboot', // 你的服务名称
  // 如果是资源复用，需要配置以下参数
  // resourceAppid: 'YOUR_APPID',
  // resourceEnv: 'YOUR_ENV_ID',
}

// 传统HTTP请求的基础URL（降级方案）
const FALLBACK_BASE_URL = 'https://springboot-gub6-171302-5-1367566291.sh.run.tcloudbase.com'

/**
 * 请求拦截器
 */
const requestInterceptor = (config) => {
  // 添加loading
  uni.showLoading({
    title: '加载中...'
  })
  
  return config
}

/**
 * 响应拦截器
 */
const responseInterceptor = (response) => {
  uni.hideLoading()
  
  // 云托管响应格式
  if (response && response.data !== undefined) {
    const data = response.data
    
    // 如果是Spring Boot的标准响应格式
    if (typeof data === 'object' && data.hasOwnProperty('code')) {
      if (data.code === 0) {
        return Promise.resolve(data.data)
      } else {
        uni.showToast({
          title: data.msg || '请求失败',
          icon: 'none'
        })
        return Promise.reject(data)
      }
    }
    
    // 直接返回数据
    return Promise.resolve(data)
  }
  
  // 传统HTTP响应格式
  const { data, statusCode } = response
  
  if (statusCode === 200) {
    if (data.code === 0) {
      return Promise.resolve(data.data)
    } else {
      uni.showToast({
        title: data.msg || '请求失败',
        icon: 'none'
      })
      return Promise.reject(data)
    }
  } else {
    uni.showToast({
      title: '网络错误',
      icon: 'none'
    })
    return Promise.reject(response)
  }
}

/**
 * 云托管请求方法
 */
const cloudRequest = async (options) => {
  // 请求拦截
  const config = requestInterceptor(options)
  
  try {
    // 优先尝试云托管调用
    if (typeof wx !== 'undefined' && wx.cloud) {
      const app = getApp()
      if (app && app.call) {
        const result = await app.call({
          path: config.url,
          method: config.method || 'GET',
          data: config.data,
          header: config.header
        })
        
        return responseInterceptor({ data: result })
      }
    }
    
    // 降级到传统HTTP请求
    return fallbackRequest(config)
    
  } catch (error) {
    console.warn('云托管请求失败，降级到HTTP请求:', error)
    return fallbackRequest(config)
  }
}

/**
 * 传统HTTP请求（降级方案）
 */
const fallbackRequest = (config) => {
  return new Promise((resolve, reject) => {
    const url = config.url.startsWith('http') ? config.url : `${FALLBACK_BASE_URL}${config.url}`
    
    uni.request({
      url,
      method: config.method || 'GET',
      data: config.data,
      header: {
        'Content-Type': 'application/json',
        ...config.header
      },
      success: (response) => {
        responseInterceptor(response)
          .then(resolve)
          .catch(reject)
      },
      fail: (error) => {
        uni.hideLoading()
        uni.showToast({
          title: '网络连接失败',
          icon: 'none'
        })
        reject(error)
      }
    })
  })
}

/**
 * 直接使用微信云托管调用（仅在微信小程序环境中可用）
 */
const directCloudCall = async (options) => {
  if (typeof wx === 'undefined' || !wx.cloud) {
    throw new Error('微信云托管不可用')
  }
  
  const config = requestInterceptor(options)
  
  try {
    const result = await wx.cloud.callContainer({
      config: {
        env: CLOUD_CONFIG.env,
      },
      path: config.url,
      method: config.method || 'GET',
      data: config.data,
      header: {
        'X-WX-SERVICE': CLOUD_CONFIG.serviceName,
        'Content-Type': 'application/json',
        ...config.header
      }
    })
    
    console.log(`微信云托管调用结果${result.errMsg} | callid:${result.callID}`)
    return responseInterceptor({ data: result.data })
    
  } catch (error) {
    uni.hideLoading()
    throw error
  }
}

export {
  cloudRequest as request,
  directCloudCall,
  fallbackRequest,
  CLOUD_CONFIG
} 