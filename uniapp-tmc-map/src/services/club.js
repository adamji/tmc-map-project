import { request } from '@/utils/request.js'

// 根据运行环境自动选择API地址
const getApiBase = () => {
  // 如果有环境变量配置，优先使用
  if (import.meta.env.VUE_APP_API_BASE_URL) {
    return import.meta.env.VUE_APP_API_BASE_URL
  }
  
  // 开发环境：根据是否是远程调试选择不同的地址
  if (process.env.NODE_ENV === 'development') {
    // 如果需要手机调试，可以手动修改这个IP为你电脑的实际IP
    const COMPUTER_IP = '10.153.225.219' // 根据需要修改这个IP
    const USE_COMPUTER_IP = false // 手机调试时设置为true
    
    return USE_COMPUTER_IP ? `http://${COMPUTER_IP}:8080` : 'http://localhost:8080'
  }
  
  // 生产环境
  return 'https://api.tmcmap.com'
}

const API_BASE = getApiBase()

// 开发调试开关
const USE_MOCK_DATA = false // 如果API无法访问，可以设置为true使用模拟数据

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
  }
]

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
  getClubList(params = {}) {
    if (USE_MOCK_DATA) {
      console.log('使用模拟数据')
      // 模拟数据直接返回数组，与request.js的响应拦截器处理后的格式一致
      return Promise.resolve(mockClubs)
    }
    
    return request({
      url: `${API_BASE}/api/clubs`,
      method: 'GET',
      data: params
    })
  },

  /**
   * 获取俱乐部详情
   * @param {number} id - 俱乐部ID
   */
  getClubDetail(id) {
    return request({
      url: `${API_BASE}/api/clubs/${id}`,
      method: 'GET'
    })
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
  calculateNavigation(params) {
    return request({
      url: `${API_BASE}/api/navigation/calculate`,
      method: 'POST',
      data: params
    })
  }
} 