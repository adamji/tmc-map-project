import { createPinia } from 'pinia'
import { defineStore } from 'pinia'

const pinia = createPinia()

/**
 * 全局状态管理
 */
export const useAppStore = defineStore('app', {
  state: () => ({
    // 用户位置信息
    userLocation: {
      latitude: 32.0584,
      longitude: 118.7964,
      city: '南京'
    },
    
    // 筛选条件
    filterOptions: {
      weekday: null, // 1-7表示周一到周日
      city: '南京'
    },
    
    // 俱乐部列表
    clubList: [],
    
    // 当前选中的俱乐部
    selectedClub: null,
    
    // 加载状态
    loading: false
  }),
  
  getters: {
    // 获取筛选后的俱乐部列表
    filteredClubList: (state) => {
      // 确保 clubList 是数组
      const clubList = Array.isArray(state.clubList) ? state.clubList : []
      
      if (!state.filterOptions.weekday) {
        return clubList
      }
      
      return clubList.filter(club => {
        // 根据例会时间筛选
        const weekdayMap = {
          1: '周一', 2: '周二', 3: '周三', 4: '周四',
          5: '周五', 6: '周六', 7: '周日'
        }
        const targetDay = weekdayMap[state.filterOptions.weekday]
        return club.meetingTime && club.meetingTime.includes(targetDay)
      })
    }
  },
  
  actions: {
    // 设置用户位置
    setUserLocation(location) {
      this.userLocation = { ...this.userLocation, ...location }
    },
    
    // 设置筛选条件
    setFilterOptions(options) {
      this.filterOptions = { ...this.filterOptions, ...options }
    },
    
    // 设置俱乐部列表
    setClubList(list) {
      this.clubList = Array.isArray(list) ? list : []
    },
    
    // 设置选中的俱乐部
    setSelectedClub(club) {
      this.selectedClub = club
    },
    
    // 设置加载状态
    setLoading(loading) {
      this.loading = loading
    }
  }
})

export default pinia 