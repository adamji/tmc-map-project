<template>
  <view class="container">
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

// 计算属性
const selectedClub = computed(() => store.selectedClub)
const loading = computed(() => store.loading)

// 方法
const loadClubList = async () => {
  try {
    store.setLoading(true)
    
    const params = {
      city: store.userLocation.city,
      lat: store.userLocation.latitude,
      lng: store.userLocation.longitude
    }
    
    // 如果有筛选条件，添加到参数中
    if (store.filterOptions.weekday) {
      params.weekday = store.filterOptions.weekday
    }
    
    const clubList = await clubApi.getClubList(params)
    console.log('获取俱乐部列表:', clubList)
    
    store.setClubList(clubList)
    
  } catch (error) {
    console.error('加载俱乐部列表失败:', error)
    uni.showToast({
      title: '加载失败，请重试',
      icon: 'none'
    })
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
</style> 