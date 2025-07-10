<template>
  <view class="container">
    <!-- 调试信息面板 -->
    <view v-if="showDebugInfo" class="debug-panel">
      <view class="debug-header">
        <text class="debug-title">调试信息</text>
        <button class="debug-close" @click="showDebugInfo = false">×</button>
      </view>
      <view class="debug-content">
        <text class="debug-item">环境: {{ debugInfo.env }}</text>
        <text class="debug-item">云托管: {{ debugInfo.cloudAvailable ? '可用' : '不可用' }}</text>
        <text class="debug-item">API状态: {{ debugInfo.apiStatus }}</text>
        <text class="debug-item">最后错误: {{ debugInfo.lastError }}</text>
        <button class="debug-button" @click="testConnection">测试连接</button>
        <button class="debug-button" @click="toggleMockData">{{ useMockData ? '关闭' : '开启' }}模拟数据</button>
      </view>
    </view>

    <!-- 地图组件 -->
    <MapView 
      class="map-view"
      @markerTap="onMarkerTap"
    />
    
    <!-- 俱乐部信息卡片 -->
    <ClubCard 
      v-if="selectedClub"
      :club="selectedClub"
      @detail="goToDetail"
      @navigation="onNavigation"
    />
    
    <!-- 加载状态 -->
    <view v-if="loading" class="loading-overlay">
      <text class="loading-text">加载中...</text>
    </view>

    <!-- 错误提示 -->
    <view v-if="errorMessage" class="error-overlay">
      <view class="error-content">
        <text class="error-title">网络错误</text>
        <text class="error-message">{{ errorMessage }}</text>
        <view class="error-actions">
          <button class="error-button" @click="retryLoad">重试</button>
          <button class="error-button secondary" @click="useMockDataTemporary">使用离线数据</button>
        </view>
      </view>
    </view>

    <!-- 调试按钮 -->
    <!-- <view class="debug-toggle"  @click="showDebugInfo = !showDebugInfo">
      <text class="debug-toggle-text">调试</text>
    </view> -->
  </view>
</template>

<script setup>
import { ref, computed, onMounted, onUnmounted, watch } from 'vue'
import { useAppStore } from '@/store/index.js'
import { clubApi } from '@/services/club.js'
import { getCurrentLocation } from '@/utils/location.js'
import MapView from '@/components/MapView.vue'
import ClubCard from '@/components/ClubCard.vue'

const store = useAppStore()

// 响应式数据
const showDebugInfo = ref(false)
const errorMessage = ref('')
const useMockData = ref(false)
const debugInfo = ref({
  env: process.env.NODE_ENV || 'unknown',
  cloudAvailable: typeof wx !== 'undefined' && wx.cloud,
  apiStatus: '未知',
  lastError: '无'
})

// 计算属性
const selectedClub = computed(() => store.selectedClub)
const loading = computed(() => store.loading)

// 方法
const loadClubList = async () => {
  try {
    store.setLoading(true)
    errorMessage.value = ''
    
    const params = {
      city: store.userLocation.city,
      lat: store.userLocation.latitude,
      lng: store.userLocation.longitude
    }
    
    // 如果有筛选条件，添加到参数中
    if (store.filterOptions.weekday) {
      params.weekday = store.filterOptions.weekday
    }
    
    console.log('开始加载俱乐部列表...')
    const clubList = await clubApi.getClubList(params)
    console.log('获取俱乐部列表成功:', clubList)
    
    store.setClubList(clubList)
    debugInfo.value.apiStatus = '正常'
    debugInfo.value.lastError = '无'
    
  } catch (error) {
    console.error('加载俱乐部列表失败:', error)
    debugInfo.value.apiStatus = '错误'
    debugInfo.value.lastError = error.message || error.errMsg || '未知错误'
    
    // 显示用户友好的错误信息
    if (error.errMsg && error.errMsg.includes('timeout')) {
      errorMessage.value = '请求超时，请检查网络连接'
    } else if (error.errMsg && error.errMsg.includes('fail')) {
      errorMessage.value = '网络连接失败，请检查网络设置'
    } else {
      errorMessage.value = '加载失败，请重试或使用离线数据'
    }
    
  } finally {
    store.setLoading(false)
  }
}

const initLocation = async () => {
  try {
    const location = await getCurrentLocation()
    store.setUserLocation({
      latitude: location.latitude,
      longitude: location.longitude
    })
    
    // 获取位置后加载俱乐部列表
    await loadClubList()
    
  } catch (error) {
    console.error('初始化位置失败:', error)
    // 使用默认位置加载俱乐部列表
    await loadClubList()
  }
}

const onMarkerTap = (club) => {
  console.log('点击俱乐部:', club)
}

const goToDetail = (club) => {
  uni.navigateTo({
    url: `/pages/club-detail/club-detail?id=${club.id}`
  })
}

const onNavigation = (club) => {
  console.log('导航到:', club.name)
}

const retryLoad = () => {
  errorMessage.value = ''
  loadClubList()
}

const useMockDataTemporary = () => {
  errorMessage.value = ''
  useMockData.value = true
  // 这里可以设置一个临时的模拟数据标志
  uni.showToast({
    title: '已切换到离线数据',
    icon: 'none'
  })
  loadClubList()
}

const testConnection = async () => {
  try {
    uni.showLoading({ title: '测试连接...' })
    const result = await clubApi.testConnection()
    uni.hideLoading()
    
    if (result.success) {
      debugInfo.value.apiStatus = '正常'
      debugInfo.value.lastError = '无'
      uni.showToast({
        title: '连接测试成功',
        icon: 'success'
      })
    } else {
      debugInfo.value.apiStatus = '错误'
      debugInfo.value.lastError = result.error
      uni.showToast({
        title: '连接测试失败',
        icon: 'none'
      })
    }
  } catch (error) {
    uni.hideLoading()
    debugInfo.value.apiStatus = '错误'
    debugInfo.value.lastError = error.message
    uni.showToast({
      title: '连接测试异常',
      icon: 'none'
    })
  }
}

const toggleMockData = () => {
  useMockData.value = !useMockData.value
  uni.showToast({
    title: useMockData.value ? '已开启模拟数据' : '已关闭模拟数据',
    icon: 'none'
  })
}

// 监听筛选条件变化，重新加载数据
watch(() => store.filterOptions, () => {
  loadClubList()
}, { deep: true })

onMounted(() => {
  initLocation()
})

// 页面卸载时清理监听
onUnmounted(() => {
  // 不需要手动清理 watch，Vue 3 会自动清理
})
</script>

<style scoped>
.container {
  height: 100vh;
  position: relative;
  overflow: hidden;
}

.map-view {
  height: 100%;
  width: 100%;
}

.loading-overlay {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background: rgba(255, 255, 255, 0.8);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 100;
}

.loading-text {
  font-size: 32rpx;
  color: #2d8cf0;
}

.error-overlay {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background: rgba(0, 0, 0, 0.5);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 101;
}

.error-content {
  background: white;
  padding: 40rpx;
  border-radius: 20rpx;
  margin: 40rpx;
  text-align: center;
}

.error-title {
  font-size: 36rpx;
  font-weight: bold;
  color: #333;
  margin-bottom: 20rpx;
}

.error-message {
  font-size: 28rpx;
  color: #666;
  margin-bottom: 30rpx;
  line-height: 1.5;
}

.error-actions {
  display: flex;
  gap: 20rpx;
  justify-content: center;
}

.error-button {
  padding: 20rpx 40rpx;
  background: #2d8cf0;
  color: white;
  border: none;
  border-radius: 10rpx;
  font-size: 28rpx;
}

.error-button.secondary {
  background: #f0f0f0;
  color: #333;
}

.debug-toggle {
  position: absolute;
  top: 100rpx;
  right: 20rpx;
  background: rgba(0, 0, 0, 0.7);
  color: white;
  padding: 10rpx 20rpx;
  border-radius: 20rpx;
  z-index: 99;
}

.debug-toggle-text {
  font-size: 24rpx;
}

.debug-panel {
  position: absolute;
  top: 160rpx;
  right: 20rpx;
  left: 20rpx;
  background: white;
  border-radius: 20rpx;
  box-shadow: 0 4rpx 20rpx rgba(0, 0, 0, 0.1);
  z-index: 98;
}

.debug-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 20rpx;
  border-bottom: 1rpx solid #f0f0f0;
}

.debug-title {
  font-size: 32rpx;
  font-weight: bold;
  color: #333;
}

.debug-close {
  background: none;
  border: none;
  font-size: 40rpx;
  color: #999;
  padding: 0;
  width: 40rpx;
  height: 40rpx;
  display: flex;
  align-items: center;
  justify-content: center;
}

.debug-content {
  padding: 20rpx;
}

.debug-item {
  display: block;
  font-size: 26rpx;
  color: #666;
  margin-bottom: 10rpx;
  line-height: 1.4;
}

.debug-button {
  background: #2d8cf0;
  color: white;
  border: none;
  padding: 15rpx 30rpx;
  border-radius: 10rpx;
  font-size: 24rpx;
  margin-right: 20rpx;
  margin-top: 20rpx;
}
</style> 