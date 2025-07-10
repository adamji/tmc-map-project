/**
 * 微信云托管请求工具
 * 优先使用云托管内网调用，降级到传统HTTP请求
 */

// 云托管配置
const CLOUD_CONFIG = {
  env: 'prod-4g2xqhcl04d0b0dc', // 你的微信云托管环境ID
  // 可能的服务名称列表（按优先级排序）
  serviceNames: [
    'springboot',           // 主要服务名
    'tmc-map-backend',      // 备用服务名
    'backend',              // 通用服务名
    'api',                  // API服务名
    'app'                   // 应用服务名
  ],
  // 如果是资源复用，需要配置以下参数
  // resourceAppid: 'YOUR_APPID',
  // resourceEnv: 'YOUR_ENV_ID',
}

// 传统HTTP请求的基础URL（降级方案）
const FALLBACK_BASE_URL = 'https://springboot-gub6-171302-5-1367566291.sh.run.tcloudbase.com'

// 请求配置
const REQUEST_CONFIG = {
  timeout: 15000, // 请求超时时间（毫秒）
  retryCount: 2, // 重试次数
  retryDelay: 1000, // 重试延迟（毫秒）
}

/**
 * 延迟函数
 */
const delay = (ms) => new Promise(resolve => setTimeout(resolve, ms))

/**
 * 请求拦截器
 */
const requestInterceptor = (config) => {
  // 添加loading
  uni.showLoading({
    title: '加载中...'
  })
  
  console.log('发起请求:', config.url, config.method || 'GET', config.data)
  
  return config
}

/**
 * 响应拦截器
 */
const responseInterceptor = (response) => {
  uni.hideLoading()
  
  console.log('响应数据:', response)
  
  // 云托管响应格式
  if (response && response.data !== undefined) {
    const data = response.data
    
    // 如果是Spring Boot的标准响应格式
    if (typeof data === 'object' && data.hasOwnProperty('code')) {
      if (data.code === 0) {
        console.log('请求成功，返回数据:', data.data)
        return Promise.resolve(data.data)
      } else {
        console.error('业务错误:', data.msg || '请求失败')
        uni.showToast({
          title: data.msg || '请求失败',
          icon: 'none'
        })
        return Promise.reject(data)
      }
    }
    
    // 直接返回数据
    console.log('直接返回数据:', data)
    return Promise.resolve(data)
  }
  
  // 传统HTTP响应格式
  const { data, statusCode } = response
  
  if (statusCode === 200) {
    if (data && data.code === 0) {
      console.log('HTTP请求成功，返回数据:', data.data)
      return Promise.resolve(data.data)
    } else if (data && data.code !== undefined) {
      console.error('HTTP业务错误:', data.msg || '请求失败')
      uni.showToast({
        title: data.msg || '请求失败',
        icon: 'none'
      })
      return Promise.reject(data)
    } else {
      // 直接返回数据（可能是数组或其他格式）
      console.log('HTTP请求成功，直接返回:', data)
      return Promise.resolve(data)
    }
  } else {
    console.error('HTTP状态码错误:', statusCode)
    uni.showToast({
      title: '网络错误',
      icon: 'none'
    })
    return Promise.reject(response)
  }
}

/**
 * 带重试的请求方法
 */
const requestWithRetry = async (requestFn, config, retryCount = REQUEST_CONFIG.retryCount) => {
  try {
    return await requestFn(config)
  } catch (error) {
    console.error(`请求失败 (剩余重试次数: ${retryCount}):`, error)
    
    if (retryCount > 0) {
      console.log(`等待 ${REQUEST_CONFIG.retryDelay}ms 后重试...`)
      await delay(REQUEST_CONFIG.retryDelay)
      return requestWithRetry(requestFn, config, retryCount - 1)
    }
    
    throw error
  }
}

/**
 * 云托管请求方法
 */
const cloudRequest = async (options) => {
  // 请求拦截
  const config = requestInterceptor(options)
  
  try {
    // 检查是否在微信小程序环境中
    if (typeof wx !== 'undefined' && wx.cloud) {
      console.log('检测到微信小程序环境，尝试云托管调用')
      
      // 直接降级到HTTP请求，避免云托管配置问题
      console.log('由于云托管配置问题，直接使用HTTP请求')
      return await requestWithRetry(fallbackRequest, config)
    }
    
    // 降级到传统HTTP请求
    console.log('非微信小程序环境，使用HTTP请求')
    return await requestWithRetry(fallbackRequest, config)
    
  } catch (error) {
    console.error('请求失败，使用HTTP降级:', error)
    return await requestWithRetry(fallbackRequest, config)
  }
}

/**
 * 传统HTTP请求（降级方案）
 */
const fallbackRequest = (config) => {
  return new Promise((resolve, reject) => {
    const url = config.url.startsWith('http') ? config.url : `${FALLBACK_BASE_URL}${config.url}`
    
    console.log('发起HTTP请求:', url)
    
    uni.request({
      url,
      method: config.method || 'GET',
      data: config.data,
      header: {
        'Content-Type': 'application/json',
        ...config.header
      },
      timeout: REQUEST_CONFIG.timeout,
      success: (response) => {
        console.log('HTTP请求成功:', response)
        responseInterceptor(response)
          .then(resolve)
          .catch(reject)
      },
      fail: (error) => {
        console.error('HTTP请求失败:', error)
        uni.hideLoading()
        
        // 根据错误类型提供不同的提示
        let errorMessage = '网络连接失败'
        if (error.errMsg) {
          if (error.errMsg.includes('timeout')) {
            errorMessage = '请求超时，请检查网络'
          } else if (error.errMsg.includes('fail')) {
            errorMessage = '网络请求失败'
          }
        }
        
        uni.showToast({
          title: errorMessage,
          icon: 'none',
          duration: 3000
        })
        reject(error)
      }
    })
  })
}

/**
 * 直接使用微信云托管调用（仅在微信小程序环境中可用）
 * 支持自动检测服务名称
 */
const directCloudCall = async (options) => {
  if (typeof wx === 'undefined' || !wx.cloud) {
    throw new Error('微信云托管不可用')
  }
  
  const config = requestInterceptor(options)
  
  // 尝试多个服务名称
  for (const serviceName of CLOUD_CONFIG.serviceNames) {
    try {
      console.log(`尝试使用服务名: ${serviceName}`)
      
      const result = await wx.cloud.callContainer({
        config: {
          env: CLOUD_CONFIG.env,
        },
        path: config.url,
        method: config.method || 'GET',
        data: config.data,
        header: {
          'X-WX-SERVICE': serviceName,
          'Content-Type': 'application/json',
          ...config.header
        }
      })
      
      console.log(`服务名 ${serviceName} 调用成功: ${result.errMsg} | callid: ${result.callID}`)
      
      // 检查云托管错误
      if (result.errCode !== 0) {
        console.error(`服务名 ${serviceName} 调用失败:`, result)
        // 如果是服务名错误，尝试下一个服务名
        if (result.errCode === -501000) {
          console.log(`服务名 ${serviceName} 无效，尝试下一个...`)
          continue
        }
        throw new Error(`云托管错误: ${result.errMsg}`)
      }
      
      // 成功时，将这个服务名移到列表前面（优化下次调用）
      const index = CLOUD_CONFIG.serviceNames.indexOf(serviceName)
      if (index > 0) {
        CLOUD_CONFIG.serviceNames.splice(index, 1)
        CLOUD_CONFIG.serviceNames.unshift(serviceName)
        console.log(`服务名 ${serviceName} 验证成功，已优化调用顺序`)
      }
      
      return responseInterceptor({ data: result.data })
      
    } catch (error) {
      console.error(`服务名 ${serviceName} 调用失败:`, error)
      
      // 如果是最后一个服务名，抛出错误
      if (serviceName === CLOUD_CONFIG.serviceNames[CLOUD_CONFIG.serviceNames.length - 1]) {
        uni.hideLoading()
        
        // 特殊处理云托管错误
        if (error.errCode === -501000) {
          console.error('所有服务名都无效 (Invalid host)')
          uni.showToast({
            title: '云托管服务名配置错误',
            icon: 'none'
          })
        }
        
        throw error
      }
      
      // 继续尝试下一个服务名
      continue
    }
  }
}

/**
 * 修复云托管配置的请求方法
 */
const fixedCloudRequest = async (options) => {
  // 暂时直接使用HTTP请求，避免云托管配置问题
  console.log('使用修复后的请求方法，直接HTTP调用')
  
  const config = requestInterceptor(options)
  
  try {
    return await requestWithRetry(fallbackRequest, config)
  } catch (error) {
    console.error('修复后的请求也失败:', error)
    throw error
  }
}

export {
  fixedCloudRequest as request,
  directCloudCall,
  fallbackRequest,
  CLOUD_CONFIG,
  REQUEST_CONFIG
} 