<template>
  <view class="container">
    <view v-if="club" class="detail-content">
      <!-- 头部信息 -->
      <view class="detail-header">
        <text class="iconfont icon-users"></text>
        <text class="club-name">{{ club.name }}</text>
      </view>
      
      <!-- 详细信息 -->
      <view class="detail-sections">
        <view class="detail-section">
          <text class="section-label">简称</text>
          <text class="section-value">{{ club.shortName }}</text>
        </view>
        
        <view class="detail-section">
          <text class="section-label">地址</text>
          <text class="section-value">{{ club.address }}</text>
        </view>
        
        <view class="detail-section">
          <text class="section-label">例会时间</text>
          <text class="section-value">{{ club.meetingTime }}</text>
        </view>
        
        <view class="detail-section">
          <text class="section-label">会议形式</text>
          <text class="section-value">{{ club.meetingFormat || club.shortName }}</text>
        </view>
        
        <view class="detail-section">
          <text class="section-label">联系人</text>
          <view class="contact-info">
            <view class="contact-item">
              <text class="iconfont icon-user"></text>
              <text class="contact-text">{{ club.contact }}</text>
            </view>
            <view class="contact-item">
              <text class="iconfont icon-phone"></text>
              <text class="contact-text">{{ club.contactPhone }}</text>
            </view>
          </view>
        </view>
        
        <view v-if="club.features" class="detail-section">
          <text class="section-label">特色</text>
          <text class="section-value">{{ club.features }}</text>
        </view>
        
        <view v-if="club.remarks" class="detail-section">
          <text class="section-label">备注</text>
          <text class="section-value">{{ club.remarks }}</text>
        </view>
      </view>
    </view>
    
    <!-- 加载状态 -->
    <view v-else-if="loading" class="loading-container">
      <text class="loading-text">加载中...</text>
    </view>
    
    <!-- 错误状态 -->
    <view v-else class="error-container">
      <text class="error-text">加载失败</text>
      <button class="retry-btn" @tap="loadClubDetail">重试</button>
    </view>
  </view>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { clubApi } from '@/services/club.js'

const club = ref(null)
const loading = ref(false)
const clubId = ref('')

const loadClubDetail = async () => {
  if (!clubId.value) {
    uni.showToast({
      title: '参数错误',
      icon: 'none'
    })
    return
  }
  
  try {
    loading.value = true
    const detail = await clubApi.getClubDetail(clubId.value)
    club.value = detail
  } catch (error) {
    console.error('加载俱乐部详情失败:', error)
    uni.showToast({
      title: '加载失败',
      icon: 'none'
    })
  } finally {
    loading.value = false
  }
}

onMounted(() => {
  // 获取页面参数
  const pages = getCurrentPages()
  const currentPage = pages[pages.length - 1]
  const options = currentPage.options
  
  if (options.id) {
    clubId.value = options.id
    loadClubDetail()
  } else {
    uni.showToast({
      title: '参数错误',
      icon: 'none'
    })
    setTimeout(() => {
      uni.navigateBack()
    }, 1500)
  }
})
</script>

<style scoped>
.container {
  min-height: 100vh;
  background: #f7f8fa;
}

.detail-content {
  padding: 0 56rpx;
}

.detail-header {
  display: flex;
  align-items: center;
  gap: 24rpx;
  margin: 64rpx 0 32rpx 0;
}

.detail-header .iconfont {
  font-size: 48rpx;
  color: #2d8cf0;
}

.club-name {
  font-size: 44rpx;
  font-weight: 700;
  color: #2d8cf0;
  flex: 1;
  line-height: 1.3;
}

.detail-sections {
  background: #fff;
  border-radius: 32rpx;
  padding: 48rpx 40rpx;
  box-shadow: 0 4rpx 24rpx rgba(45,140,240,0.08);
}

.detail-section {
  margin-bottom: 40rpx;
}

.detail-section:last-child {
  margin-bottom: 0;
}

.section-label {
  font-size: 30rpx;
  color: #888;
  margin-bottom: 8rpx;
  display: block;
}

.section-value {
  font-size: 34rpx;
  color: #333;
  font-weight: 500;
  line-height: 1.5;
  display: block;
}

.contact-info {
  display: flex;
  flex-direction: column;
  gap: 16rpx;
}

.contact-item {
  display: flex;
  align-items: center;
  gap: 16rpx;
}

.contact-item .iconfont {
  font-size: 32rpx;
  color: #2d8cf0;
  width: 32rpx;
}

.contact-text {
  font-size: 34rpx;
  color: #333;
  font-weight: 500;
}

.loading-container,
.error-container {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  height: 60vh;
  gap: 32rpx;
}

.loading-text,
.error-text {
  font-size: 32rpx;
  color: #666;
}

.retry-btn {
  background: linear-gradient(90deg, #2d8cf0 60%, #5ad1e6 100%);
  color: #fff;
  border: none;
  border-radius: 20rpx;
  padding: 24rpx 48rpx;
  font-size: 32rpx;
  font-weight: 500;
}
</style> 