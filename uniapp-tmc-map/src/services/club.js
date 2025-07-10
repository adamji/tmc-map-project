import { request } from '@/utils/cloudRequest.js'

// 云托管配置
const CLOUD_CONFIG = {
  env: 'prod-4glzuzf324169217', // 从错误日志中提取的环境ID
  serviceName: 'springboot-gub6' // 主要服务名
}

// 提取URL路径的辅助函数（兼容小程序环境）
const extractPath = (url) => {
  if (!url) return '/'
  
  // 如果已经是路径格式，直接返回
  if (url.startsWith('/')) {
    return url
  }
  
  try {
    // 尝试手动解析URL
    if (url.includes('://')) {
      // 找到第三个斜杠后的内容作为路径
      const parts = url.split('/')
      if (parts.length > 3) {
        return '/' + parts.slice(3).join('/')
      }
    }
    return '/api/clubs' // 默认路径
  } catch (error) {
    console.error('URL解析失败:', error)
    return '/api/clubs' // 默认路径
  }
}

// 云托管请求封装 - 直接使用云托管
const cloudRequest = async (options) => {
  console.log('☁️ 直接使用云托管 callContainer')
  
  try {
    // 提取API路径（兼容小程序环境）



    const result = await wx.cloud.callContainer({
      "config": {
        "env": CLOUD_CONFIG.env
      },
      "path": options.url,
      "header": {
        "X-WX-SERVICE": CLOUD_CONFIG.serviceName
      },
      "method": options.method || 'GET',
      "data": options.data,
      // "data": {
      //   "action": "inc"
      // }
    })
  
    console.log('☁️ 云托管响应:', result)
    
    if (result.errCode !== undefined && result.errCode !== 0) {
      throw new Error(`云托管错误 ${result.errCode}: ${result.errMsg}`)
    }
    
    return result.data.data
    
  } catch (error) {
    console.error('☁️ 云托管调用失败:', error)
    throw error
  }
}

// 获取API基础URL
const getApiBaseUrl = () => {
  // 优先使用构建时注入的环境变量
  let apiUrl = null
  
  try {
    // 尝试从 import.meta.env 获取（Vite）
    if (import.meta && import.meta.env && import.meta.env.VUE_APP_API_BASE_URL) {
      apiUrl = import.meta.env.VUE_APP_API_BASE_URL
      console.log('✅ 使用构建时环境变量:', apiUrl)
      return apiUrl
    }
  } catch (e) {
    console.log('import.meta.env 不可用:', e)
  }
  
  try {
    // 尝试从 process.env 获取（备用方案）
    if (typeof process !== 'undefined' && process.env && process.env.VUE_APP_API_BASE_URL) {
      apiUrl = process.env.VUE_APP_API_BASE_URL
      console.log('✅ 使用 process.env 环境变量:', apiUrl)
      return apiUrl
    }
  } catch (e) {
    console.log('process.env 不可用:', e)
  }
  
  // 降级到自动判断（如果环境变量都不可用）
  console.log('⚠️ 未找到环境变量，降级到自动判断')
  const isDev = typeof uni !== 'undefined' && uni.getSystemInfoSync && 
               uni.getSystemInfoSync().platform === 'devtools'
  
  // if (isDev) {
  //   apiUrl = 'http://10.153.227.79:8080'
  //   console.log('🔧 开发环境检测，使用本地地址:', apiUrl)
  // } else {
  //   apiUrl = 'https://springboot-gub6-171302-5-1367566291.sh.run.tcloudbase.com'
  //   console.log('🔧 生产环境检测，使用云托管地址:', apiUrl)
  // }

  apiUrl = 'https://springboot-gub6-171302-5-1367566291.sh.run.tcloudbase.com'
    console.log('🔧 生产环境检测，使用云托管地址:', apiUrl)
  
  return apiUrl
}

// 拼接API路径
const getApiPath = (path) => {
  const baseUrl = getApiBaseUrl()
  console.log('当前API Base URL:', baseUrl)
  return `${baseUrl}${path}`
}

// 开发调试开关 - 临时启用模拟数据
const USE_MOCK_DATA = false // 由于云托管配置问题，暂时启用模拟数据

// 模拟数据
const mockClubs = [
  {
    "id": 3,
    "name": "南京江宁国际演讲俱乐部",
    "shortName": "江宁TMC",
    "address": "南京市江宁经济技术开发区双龙大道1539号21世纪太阳城",
    "lat": 31.9558,
    "lng": 118.8420,
    "city": "南京",
    "meetingTime": "周五 19:30-21:30 双语",
    "language": "双语",
    "contact": "Sarah CHEN",
    "phone": "15850123456",
    "features": "21世纪太阳城，购物便利",
    "description": "大学生和年轻职场人士首选"
  },
  {
    "id": 4,
    "name": "上海浦东国际演讲俱乐部",
    "shortName": "浦东TMC",
    "address": "上海市浦东新区世纪大道1000号",
    "lat": 31.2304,
    "lng": 121.4737,
    "city": "上海",
    "meetingTime": "周六 14:00-16:00 中文",
    "language": "中文",
    "contact": "王先生",
    "phone": "13812345678",
    "features": "地铁便利，商务区",
    "description": "职场精英聚集地"
  },
  {
    "id": 5,
    "name": "南京河西国际演讲俱乐部",
    "shortName": "河西TMC",
    "address": "南京市建邺区江东中路98号河西万达广场",
    "lat": 32.0041,
    "lng": 118.7329,
    "city": "南京",
    "meetingTime": "周日 14:00-16:00 中文",
    "language": "中文",
    "contact": "李女士",
    "phone": "13901234567",
    "features": "河西CBD，交通便利",
    "description": "商务人士首选"
  }
]

/**
 * 带错误处理的API请求包装器
 */
const safeApiCall = async (apiCall, fallbackData = null) => {
  try {
    console.log('开始API调用...')
    const result = await apiCall()
    console.log('API调用成功:', result)
    return result
  } catch (error) {
    console.error('API调用失败:', error)
    
    // 特殊处理云托管错误
    if (error.errCode === -501000) {
      console.error('云托管配置错误，使用模拟数据')
      uni.showToast({
        title: '云托管配置问题，使用离线数据',
        icon: 'none',
        duration: 3000
      })
      return fallbackData || mockClubs
    }
    
    // 如果有降级数据，使用降级数据
    if (fallbackData !== null) {
      console.log('使用降级数据:', fallbackData)
      uni.showToast({
        title: '网络异常，使用缓存数据',
        icon: 'none',
        duration: 2000
      })
      return fallbackData
    }
    
    // 抛出错误让上层处理
    throw error
  }
}

/**
 * 俱乐部相关API
 */
export const clubApi = {
  /**
   * 获取俱乐部列表
   * @param {Object} params - 查询参数
   * @param {string} params.city - 城市
   * @param {number} params.weekday - 星期几 (1-7)
   * @param {number} params.lat - 纬度
   * @param {number} params.lng - 经度
   */
  async getClubList(params = {}) {
    console.log('获取俱乐部列表，参数:', params)
    
    if (USE_MOCK_DATA) {
      console.log('使用模拟数据')
      // 根据城市筛选模拟数据
      let filteredClubs = mockClubs
      if (params.city) {
        filteredClubs = mockClubs.filter(club => club.city === params.city)
      }
      // 模拟异步延迟
      await new Promise(resolve => setTimeout(resolve, 500))
      return Promise.resolve(filteredClubs)
    }
    
    return safeApiCall(
      () => cloudRequest({
        url: '/api/clubs',
      method: 'GET',
      data: params
      }),
      mockClubs // 降级到模拟数据
    )
  },

  /**
   * 获取俱乐部详情
   * @param {number} id - 俱乐部ID
   */
  async getClubDetail(id) {
    console.log('获取俱乐部详情，ID:', id)
    
    if (USE_MOCK_DATA) {
      console.log('使用模拟数据')
      const mockClub = mockClubs.find(club => club.id === parseInt(id))
      await new Promise(resolve => setTimeout(resolve, 300))
      return Promise.resolve(mockClub || mockClubs[0])
    }
    
    return safeApiCall(
      () => cloudRequest({
        url: `/api/clubs/${id}`,
      method: 'GET'
      }),
      mockClubs.find(club => club.id === parseInt(id)) || mockClubs[0]
    )
  },

  /**
   * 计算导航路线
   * @param {Object} params - 导航参数
   * @param {number} params.fromLat - 起点纬度
   * @param {number} params.fromLng - 起点经度
   * @param {number} params.toLat - 终点纬度
   * @param {number} params.toLng - 终点经度
   * @param {string} params.mode - 出行方式 (driving|walking|transit)
   */
  async calculateNavigation(params) {
    console.log('计算导航路线，参数:', params)
    
    if (USE_MOCK_DATA) {
      console.log('使用模拟导航数据')
      await new Promise(resolve => setTimeout(resolve, 200))
      return Promise.resolve({
        distance: '约3.5公里',
        duration: '约12分钟',
        route: '建议路线：当前位置 → 江东中路 → 目的地'
      })
    }
    
    return safeApiCall(
      () => cloudRequest({
        url: '/api/navigation/calculate',
      method: 'POST',
      data: params
      }),
      {
        // 导航降级数据
        distance: '约5公里',
        duration: '约15分钟',
        route: '建议使用地图导航'
      }
    )
  },

  /**
   * 健康检查API
   */
  async healthCheck() {
    console.log('执行健康检查')
    
    if (USE_MOCK_DATA) {
      console.log('模拟健康检查')
      await new Promise(resolve => setTimeout(resolve, 100))
      return Promise.resolve({ status: 'ok', message: '模拟数据模式' })
    }
    
    return safeApiCall(
      () => cloudRequest({
        url: '/api/health',
        method: 'GET'
      }),
      { status: 'unknown', message: '健康检查失败' }
    )
  },

  /**
   * 测试连接
   */
  async testConnection() {
    console.log('测试API连接')
    
    if (USE_MOCK_DATA) {
      console.log('模拟连接测试')
      await new Promise(resolve => setTimeout(resolve, 200))
      return Promise.resolve({ 
        success: true, 
        endpoint: 'mock',
        message: '当前使用模拟数据' 
      })
    }
    
    try {
      // 尝试多个健康检查端点
      const endpoints = ['/api/health', '/api/actuator/health', '/api/']
      
      for (const endpoint of endpoints) {
        try {
          console.log(`测试端点: ${endpoint}`)
          await cloudRequest({
            url: getApiPath(endpoint),
            method: 'GET'
          })
          console.log(`端点 ${endpoint} 可用`)
          return { success: true, endpoint }
        } catch (error) {
          console.log(`端点 ${endpoint} 不可用:`, error)
          continue
        }
      }
      
      throw new Error('所有端点都不可用')
      
    } catch (error) {
      console.error('连接测试失败:', error)
      return { success: false, error: error.message }
    }
  },

  /**
   * 切换模拟数据模式
   */
  toggleMockData() {
    // 这里可以动态切换模拟数据模式
    console.log('当前模拟数据状态:', USE_MOCK_DATA)
    return USE_MOCK_DATA
  }
} 