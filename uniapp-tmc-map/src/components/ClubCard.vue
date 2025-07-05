<template>
  <view v-if="club" class="club-card" @tap.stop>
    <view class="club-header">
      <text class="club-title">{{ club.name }}</text>
    </view>
    
    <view class="club-info">
      <view class="info-item">
        <text class="iconfont icon-location"></text>
        <text class="info-text">{{ club.address }}</text>
      </view>
      
      <view class="info-item">
        <text class="iconfont icon-clock"></text>
        <text class="info-text">{{ club.meetingTime }}</text>
      </view>
    </view>
    
    <view class="club-actions">
      <button class="action-btn primary" @tap="handleNavigation">
        <text class="iconfont icon-navigation"></text>
        <text>导航</text>
      </button>
      
      <button class="action-btn secondary" @tap="handleDetail">
        <text class="iconfont icon-info"></text>
        <text>详情</text>
      </button>
    </view>
  </view>
</template>

<script setup>
import { openMapNavigation } from '@/utils/location.js'

const props = defineProps({
  club: {
    type: Object,
    default: null
  }
})

const emit = defineEmits(['detail', 'navigation'])

const handleNavigation = () => {
  if (props.club) {
    openMapNavigation({
      latitude: props.club.lat,
      longitude: props.club.lng,
      name: props.club.name,
      address: props.club.address
    })
    emit('navigation', props.club)
  }
}

const handleDetail = () => {
  if (props.club) {
    emit('detail', props.club)
  }
}
</script>

<style scoped>
.club-card {
  position: absolute;
  left: 50%;
  bottom: 64rpx;
  transform: translateX(-50%);
  background: #fff;
  border-radius: 32rpx;
  box-shadow: 0 4rpx 32rpx rgba(45,140,240,0.15);
  padding: 44rpx 52rpx;
  min-width: 680rpx;
  max-width: 90vw;
  z-index: 20;
  border: 3rpx solid #e6f0fa;
}

.club-header {
  margin-bottom: 16rpx;
}

.club-title {
  font-size: 40rpx;
  font-weight: 700;
  color: #2d8cf0;
  line-height: 1.3;
}

.club-info {
  margin-bottom: 28rpx;
}

.info-item {
  display: flex;
  align-items: center;
  margin-bottom: 12rpx;
}

.info-item .iconfont {
  font-size: 28rpx;
  color: #2d8cf0;
  margin-right: 16rpx;
  width: 28rpx;
}

.info-text {
  font-size: 30rpx;
  color: #666;
  flex: 1;
  line-height: 1.4;
}

.club-actions {
  display: flex;
  gap: 36rpx;
}

.action-btn {
  flex: 1;
  border-radius: 20rpx;
  padding: 20rpx 0;
  font-size: 32rpx;
  font-weight: 500;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 12rpx;
  border: none;
  transition: all 0.3s;
}

.action-btn.primary {
  background: linear-gradient(90deg, #2d8cf0 60%, #5ad1e6 100%);
  color: #fff;
  box-shadow: 0 2rpx 8rpx rgba(45,140,240,0.12);
}

.action-btn.secondary {
  background: #fff;
  color: #2d8cf0;
  border: 3rpx solid #2d8cf0;
}

.action-btn.secondary:active {
  background: #e6f0fa;
}

.action-btn .iconfont {
  font-size: 28rpx;
}
</style> 