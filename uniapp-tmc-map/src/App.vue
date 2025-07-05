<template>
	<view>
		<!-- 此处可以放置全局弹窗、Toast等 -->
	</view>
</template>

<script>
	export default {
		onLaunch: function() {
			console.log('App Launch')
		},
		onShow: function() {
			console.log('App Show')
		},
		onHide: function() {
			console.log('App Hide')
		}
	}
</script>

<style>
	/* 全局样式 */
	@import url('./static/fonts/iconfont.css');
	
	page {
		background-color: #f7f8fa;
		font-family: 'PingFang SC', 'Helvetica Neue', Arial, sans-serif;
	}
	
	/* 通用样式 */
	.container {
		padding: 0;
		margin: 0;
	}
	
	.btn-primary {
		background: linear-gradient(90deg, #2d8cf0 60%, #5ad1e6 100%);
		color: #fff;
		border: none;
		border-radius: 10rpx;
		padding: 20rpx 0;
		font-size: 32rpx;
		font-weight: 500;
	}
	
	.btn-secondary {
		background: #fff;
		color: #2d8cf0;
		border: 3rpx solid #2d8cf0;
		border-radius: 10rpx;
		padding: 20rpx 0;
		font-size: 32rpx;
		font-weight: 500;
	}
	
	.card {
		background: #fff;
		border-radius: 32rpx;
		box-shadow: 0 8rpx 48rpx rgba(45,140,240,0.10);
		padding: 40rpx 48rpx;
		margin: 24rpx;
	}
	
	.text-primary {
		color: #2d8cf0;
	}
	
	.text-secondary {
		color: #666;
	}
	
	.text-muted {
		color: #888;
	}
</style> 