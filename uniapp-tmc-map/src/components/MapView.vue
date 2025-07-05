<template>
  <view class="map-container">
    <map
      id="map"
      class="map"
      :key="mapKey"
      :longitude="mapCenter.longitude"
      :latitude="mapCenter.latitude"
      :scale="scale"
      :markers="markers"
      :show-location="true"
      enable-zoom
      enable-scroll
      enable-rotate
      @markertap="onMarkerTap"
      @tap="onMapTap"
    ></map>
    
    <!-- 我的位置按钮 - 暂时隐藏 -->
    <!-- <view class="location-btn" @tap="moveToLocation">
      <text class="iconfont icon-location"></text>
      <text class="location-text">我的位置</text>
    </view> -->
    
    <!-- 筛选按钮 -->
    <view class="filter-bar">
      <view class="filter-btn" @tap="showDatePicker">
        <text class="iconfont icon-calendar"></text>
        <text>{{ filterText }}</text>
      </view>
      <view class="city-btn" @tap="chooseCity">
        <text class="iconfont icon-location-o"></text>
        <text>{{ currentCity }}</text>
      </view>
    </view>
    
    <!-- 日期选择弹窗 -->
    <DatePicker 
      :show="showPicker" 
      @close="showPicker = false"
      @select="onDateSelect"
    />
  </view>
</template>

<script setup>
import { ref, computed, onMounted, watch } from 'vue'
import { useAppStore } from '@/store/index.js'
import { getCurrentLocation } from '@/utils/location.js'
import DatePicker from './DatePicker.vue'

const store = useAppStore()

// 地图相关数据
const mapCenter = ref({
  longitude: 118.7964,
  latitude: 32.0584
})
const scale = ref(12)
const showPicker = ref(false)
const mapKey = ref('map-' + Date.now()) // 用于强制重新渲染地图

// 计算属性
const markers = computed(() => {
  const clubList = store.filteredClubList
  
  // 确保是数组才进行map操作
  if (!Array.isArray(clubList)) {
    console.warn('filteredClubList is not an array:', clubList)
    return []
  }
  
  const markersData = clubList.map((club, index) => {
    // 简化俱乐部名字显示
    const shortName = club.name.replace('国际演讲俱乐部', 'TMC').replace('演讲俱乐部', 'TMC')
    
    return {
      id: club.id,
      longitude: club.lng,
      latitude: club.lat,
      width: 34,
      height: 34,
      iconPath: '', // 使用默认标记图标
      label: {
        content: shortName,
        color: '#ffffff',
        fontSize: 11,
        fontWeight: 'bold',
        anchorX: 0,
        anchorY: -45,
        borderWidth: 0,
        borderRadius: 12,
        bgColor: '#2d8cf0',
        padding: 8,
        textAlign: 'center'
      }
    }
  })
  
  console.log('生成的地图标记:', markersData)
  return markersData
})

const filterText = computed(() => {
  if (!store.filterOptions.weekday) {
    return '请选择日期'
  }
  const weekdayMap = {
    1: '周一', 2: '周二', 3: '周三', 4: '周四',
    5: '周五', 6: '周六', 7: '周日'
  }
  return weekdayMap[store.filterOptions.weekday]
})

const currentCity = computed(() => store.userLocation.city)

// 事件处理
const emit = defineEmits(['markerTap'])

// 防止标记点击和地图点击冲突的标记
const isMarkerTapped = ref(false)

const onMarkerTap = (e) => {
  const markerId = e.detail.markerId
  const club = store.clubList.find(c => c.id === markerId)
  if (club) {
    isMarkerTapped.value = true
    store.setSelectedClub(club)
    emit('markerTap', club)
    
    // 100ms后重置标记，防止地图点击事件误触发
    setTimeout(() => {
      isMarkerTapped.value = false
    }, 100)
  }
}

const onMapTap = () => {
  // 如果刚刚点击了标记，则不隐藏俱乐部信息卡片
  if (isMarkerTapped.value) {
    return
  }
  // 点击地图隐藏俱乐部信息卡片
  store.setSelectedClub(null)
}

const moveToLocation = async () => {
  try {
    // 显示加载提示
    uni.showLoading({
      title: '正在定位...',
      mask: true
    })
    
    console.log('🎯 开始获取位置（复用首页成功方案）...')
    
    // 直接使用简单的 uni.getLocation，不要复杂的权限检查
    uni.getLocation({
      type: 'gcj02',
      altitude: true,
      success: (res) => {
        console.log('✅ 获取位置成功:', res)
        uni.hideLoading()
        
        const location = {
          latitude: res.latitude,
          longitude: res.longitude,
          accuracy: res.accuracy
        }
        
        // 更新store中的用户位置（与首页逻辑一致）
        store.setUserLocation({
          latitude: location.latitude,
          longitude: location.longitude
        })
        
        // 更新地图显示
        updateMapToLocation(location)
        
      },
      fail: (error) => {
        console.error('❌ 获取位置失败:', error)
        uni.hideLoading()
        
        // 简化错误处理
        uni.showModal({
          title: '定位失败',
          content: '无法获取您的位置，请检查定位权限',
          confirmText: '重试',
          cancelText: '取消',
          success: (res) => {
            if (res.confirm) {
              setTimeout(() => {
                moveToLocation()
              }, 500)
            }
          }
        })
      }
    })
    
  } catch (error) {
    console.error('定位异常:', error)
    uni.hideLoading()
    uni.showToast({
      title: '定位功能异常',
      icon: 'none'
    })
  }
}

// 单独的地图更新函数
const updateMapToLocation = (location) => {
  console.log('🗺️ 更新地图到位置:', location)
  
  // 直接更新地图中心
  mapCenter.value = {
    longitude: location.longitude,
    latitude: location.latitude
  }
  
  // 设置合适的缩放级别
  scale.value = 17
  
  // 强制重新渲染地图
  mapKey.value = 'map-location-' + Date.now()
  
  console.log('📍 地图中心已更新:', mapCenter.value)
  
  // 使用地图API确保位置正确
  setTimeout(() => {
    const mapContext = uni.createMapContext('map')
    mapContext.includePoints({
      points: [{
        longitude: location.longitude,
        latitude: location.latitude
      }],
      padding: [80, 80, 80, 80],
      success: () => {
        console.log('✅ 地图已移动到正确位置')
      },
      fail: (error) => {
        console.warn('⚠️ 地图移动失败，但位置已更新:', error)
      }
    })
    
    uni.showToast({
      title: '已定位到您的位置',
      icon: 'success',
      duration: 2000
    })
  }, 300)
}

const showDatePicker = () => {
  // 临时用于测试地图移动功能
  if (filterText.value === '请选择日期') {
    testMoveToClub()
  } else {
    showPicker.value = true
  }
}

const onDateSelect = (weekday) => {
  store.setFilterOptions({ weekday })
  showPicker.value = false
}

const chooseCity = () => {
  // 可以实现城市选择功能
  uni.showToast({
    title: '城市选择功能待开发',
    icon: 'none'
  })
}

// 测试方法：直接设置到南京江宁俱乐部位置
const testMoveToClub = () => {
  console.log('测试移动到俱乐部位置')
  
  // 南京江宁俱乐部的坐标
  const clubLocation = {
    longitude: 118.8420,
    latitude: 31.9558
  }
  
  console.log('设置地图中心到俱乐部位置:', clubLocation)
  
  // 直接设置
  mapCenter.value = clubLocation
  scale.value = 18
  
  // 强制重新渲染
  mapKey.value = 'map-' + Date.now()
  
  uni.showToast({
    title: '已移动到俱乐部',
    icon: 'success'
  })
}

// 监听用户位置变化
watch(() => store.userLocation, (newLocation) => {
  mapCenter.value = {
    longitude: newLocation.longitude,
    latitude: newLocation.latitude
  }
}, { deep: true })

// 监听地图中心变化，添加调试信息
watch(() => mapCenter.value, (newCenter, oldCenter) => {
  console.log('地图中心变化:', {
    旧中心: oldCenter,
    新中心: newCenter
  })
}, { deep: true })

// 监听地图缩放变化
watch(() => scale.value, (newScale, oldScale) => {
  console.log('地图缩放变化:', {
    旧缩放: oldScale,
    新缩放: newScale
  })
})

onMounted(() => {
  // 初始化地图中心点
  mapCenter.value = {
    longitude: store.userLocation.longitude,
    latitude: store.userLocation.latitude
  }
  
  // 等待地图完全加载
  setTimeout(() => {
    console.log('地图组件已挂载，可以进行定位操作')
  }, 1000)
})
</script>

<style scoped>
.map-container {
  position: relative;
  height: 100%;
  width: 100%;
}

.map {
  width: 100%;
  height: 100%;
}

.location-btn {
  position: absolute;
  right: 40rpx;
  bottom: 40rpx;
  background: #fff;
  border: 4rpx solid #2d8cf0;
  border-radius: 50%;
  width: 120rpx;
  height: 120rpx;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  box-shadow: 0 4rpx 24rpx rgba(45,140,240,0.18);
  z-index: 10;
}

.location-btn .iconfont {
  font-size: 48rpx;
  color: #2d8cf0;
}

.location-text {
  font-size: 20rpx;
  color: #2d8cf0;
  margin-top: 4rpx;
  font-weight: 500;
}

.filter-bar {
  position: absolute;
  bottom: 40rpx;
  left: 40rpx;
  right: 200rpx;
  display: flex;
  justify-content: space-between;
  z-index: 10;
}

.filter-btn,
.city-btn {
  background: #fff;
  border: 3rpx solid #2d8cf0;
  border-radius: 20rpx;
  padding: 18rpx 36rpx;
  display: flex;
  align-items: center;
  box-shadow: 0 2rpx 8rpx rgba(45,140,240,0.08);
}

.filter-btn .iconfont,
.city-btn .iconfont {
  font-size: 28rpx;
  color: #2d8cf0;
  margin-right: 12rpx;
}

.filter-btn text:last-child,
.city-btn text:last-child {
  font-size: 28rpx;
  color: #2d8cf0;
  font-weight: 500;
}
</style> 