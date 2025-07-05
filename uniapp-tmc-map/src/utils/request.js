/**
 * HTTP请求工具
 */

// 请求拦截器
const requestInterceptor = (config) => {
  // 添加loading
  uni.showLoading({
    title: '加载中...'
  })
  
  // 添加请求头
  config.header = {
    'Content-Type': 'application/json',
    ...config.header
  }
  
  return config
}

// 响应拦截器
const responseInterceptor = (response) => {
  uni.hideLoading()
  
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
 * 封装请求方法
 * @param {Object} options - 请求参数
 */
export const request = (options) => {
  return new Promise((resolve, reject) => {
    // 请求拦截
    const config = requestInterceptor(options)
    
    uni.request({
      ...config,
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