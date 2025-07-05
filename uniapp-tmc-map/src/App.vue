<template>
	<view>
		<!-- 此处可以放置全局弹窗、Toast等 -->
	</view>
</template>

<script>
	export default {
		async onLaunch() {
			console.log('App Launch')
			
			// 初始化微信云托管
			if (typeof wx !== 'undefined' && wx.cloud) {
				try {
					await wx.cloud.init()
					console.log('微信云托管初始化成功')
				} catch (error) {
					console.error('微信云托管初始化失败:', error)
				}
			}
		},
		onShow: function() {
			console.log('App Show')
		},
		onHide: function() {
			console.log('App Hide')
		},
		
		/**
		 * 封装的微信云托管调用方法
		 * @param {Object} obj 业务请求信息
		 * @param {number} number 请求等待，默认不用传，用于初始化等待
		 */
		async call(obj, number = 0) {
			const that = this
			if (that.cloud == null) {
				// 如果是在微信小程序环境
				if (typeof wx !== 'undefined' && wx.cloud) {
					const cloud = new wx.cloud.Cloud({
						// 这里需要填入你的实际环境信息
						// resourceAppid: 'YOUR_APPID', // 如果是资源复用，需要填入
						// resourceEnv: 'YOUR_ENV_ID', // 如果是资源复用，需要填入
					})
					that.cloud = cloud
					await that.cloud.init()
				} else {
					// 非微信环境，使用传统的uni.request
					return this.traditionalRequest(obj)
				}
			}
			
			try {
				const result = await that.cloud.callContainer({
					config: {
						env: 'prod-4g2xqhcl04d0b0dc', // 你的微信云托管环境ID
					},
					path: obj.path,
					method: obj.method || 'GET',
					data: obj.data,
					header: {
						'X-WX-SERVICE': 'springboot', // 你的服务名称
						'Content-Type': 'application/json',
						...obj.header
					}
				})
				console.log(`微信云托管调用结果${result.errMsg} | callid:${result.callID}`)
				return result.data
			} catch (e) {
				const error = e.toString()
				// 如果错误信息为未初始化，则等待300ms再次尝试
				if (error.indexOf("Cloud API isn't enabled") != -1 && number < 3) {
					return new Promise((resolve) => {
						setTimeout(function() {
							resolve(that.call(obj, number + 1))
						}, 300)
					})
				} else {
					console.error('微信云托管调用失败:', error)
					// 降级到传统请求方式
					return this.traditionalRequest(obj)
				}
			}
		},
		
		/**
		 * 传统请求方式（降级方案）
		 */
		async traditionalRequest(obj) {
			const { request } = require('./utils/request.js')
			return request({
				url: obj.path,
				method: obj.method || 'GET',
				data: obj.data,
				header: obj.header
			})
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