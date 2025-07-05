<template>
  <view v-if="show" class="date-picker-overlay" @tap="closeModal">
    <view class="date-picker-content" @tap.stop>
      <view class="picker-header">
        <text class="picker-title">请选择日期</text>
        <text class="close-btn" @tap="closeModal">×</text>
      </view>
      
      <view class="date-list">
        <view 
          v-for="item in dateOptions" 
          :key="item.value"
          class="date-item"
          :class="{ active: selectedWeekday === item.value }"
          @tap="selectDate(item.value)"
        >
          <text class="day-text">{{ item.label }}</text>
          <text class="day-en">{{ item.en }}</text>
        </view>
        
        <!-- 清除筛选选项 -->
        <view class="date-item clear-item" @tap="clearFilter">
          <text class="day-text">全部</text>
          <text class="day-en">All</text>
        </view>
      </view>
    </view>
  </view>
</template>

<script setup>
import { ref, computed } from 'vue'
import { useAppStore } from '@/store/index.js'

const store = useAppStore()

const props = defineProps({
  show: {
    type: Boolean,
    default: false
  }
})

const emit = defineEmits(['close', 'select'])

const dateOptions = [
  { value: 1, label: '周一', en: 'Mon' },
  { value: 2, label: '周二', en: 'Tue' },
  { value: 3, label: '周三', en: 'Wed' },
  { value: 4, label: '周四', en: 'Thu' },
  { value: 5, label: '周五', en: 'Fri' },
  { value: 6, label: '周六', en: 'Sat' },
  { value: 7, label: '周日', en: 'Sun' }
]

const selectedWeekday = computed(() => store.filterOptions.weekday)

const selectDate = (weekday) => {
  emit('select', weekday)
}

const clearFilter = () => {
  emit('select', null)
}

const closeModal = () => {
  emit('close')
}
</script>

<style scoped>
.date-picker-overlay {
  position: fixed;
  top: 0;
  left: 0;
  width: 100vw;
  height: 100vh;
  background: rgba(0, 0, 0, 0.4);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
}

.date-picker-content {
  background: #fff;
  border-radius: 32rpx;
  padding: 56rpx 64rpx;
  margin: 0 48rpx;
  max-width: 520rpx;
  width: 100%;
  box-shadow: 0 4rpx 32rpx rgba(45,140,240,0.12);
}

.picker-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 44rpx;
}

.picker-title {
  font-size: 40rpx;
  font-weight: 700;
  color: #2d8cf0;
}

.close-btn {
  font-size: 48rpx;
  color: #aaa;
  font-weight: 300;
}

.date-list {
  display: flex;
  flex-direction: column;
  gap: 32rpx;
}

.date-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 26rpx 0;
  border-bottom: 1rpx solid #f0f0f0;
  transition: all 0.3s;
}

.date-item:last-child {
  border-bottom: none;
}

.date-item.active {
  background: #e6f0fa;
  border-radius: 16rpx;
  padding: 26rpx 20rpx;
}

.date-item.clear-item {
  border-top: 2rpx solid #f0f0f0;
  margin-top: 16rpx;
  padding-top: 32rpx;
}

.day-text {
  font-size: 34rpx;
  color: #2d8cf0;
  font-weight: 500;
}

.day-en {
  font-size: 28rpx;
  color: #aaa;
}

.date-item.active .day-text {
  color: #2d8cf0;
  font-weight: 600;
}

.date-item.active .day-en {
  color: #5ad1e6;
}
</style> 