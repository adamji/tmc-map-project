/**
 * 定位相关工具函数
 */

/**
 * 获取用户当前位置
 */
export const getCurrentLocation = () => {
  return new Promise((resolve, reject) => {
    // 首先检查位置权限
    uni.getSetting({
      success: (settingRes) => {
        console.log('权限设置:', settingRes)
        
        if (settingRes.authSetting['scope.userLocation'] === false) {
          // 用户拒绝了位置权限
          console.log('用户拒绝了位置权限')
          uni.showModal({
            title: '需要位置权限',
            content: '请在设置中开启位置权限，以便获取您的位置信息',
            confirmText: '去设置',
            cancelText: '取消',
            success: (res) => {
              if (res.confirm) {
                // 打开设置页面
                uni.openSetting({
                  success: (openRes) => {
                    console.log('打开设置结果:', openRes)
                    if (openRes.authSetting['scope.userLocation']) {
                      // 用户重新授权了，重新获取位置
                      getLocationInternal(resolve, reject)
                    } else {
                      reject(new Error('用户未授权位置权限'))
                    }
                  },
                  fail: (error) => {
                    console.error('打开设置失败:', error)
                    reject(error)
                  }
                })
              } else {
                reject(new Error('用户取消授权'))
              }
            }
          })
        } else {
          // 权限正常或未设置，直接获取位置
          getLocationInternal(resolve, reject)
        }
      },
      fail: (error) => {
        console.error('获取权限设置失败:', error)
        // 如果获取设置失败，直接尝试获取位置
        getLocationInternal(resolve, reject)
      }
    })
  })
}

/**
 * 内部获取位置方法
 */
function getLocationInternal(resolve, reject) {
  uni.getLocation({
    type: 'gcj02',
    altitude: true,
    success: (res) => {
      console.log('获取位置成功:', res)
      resolve({
        latitude: res.latitude,
        longitude: res.longitude,
        address: res.address || '',
        accuracy: res.accuracy,
        altitude: res.altitude,
        speed: res.speed
      })
    },
    fail: (error) => {
      console.error('获取位置失败:', error)
      
      // 分析错误原因
      let errorMessage = '获取位置失败'
      if (error.errMsg) {
        if (error.errMsg.includes('auth')) {
          errorMessage = '位置权限被拒绝'
        } else if (error.errMsg.includes('network')) {
          errorMessage = '网络连接异常'
        } else if (error.errMsg.includes('timeout')) {
          errorMessage = '定位超时'
        } else if (error.errMsg.includes('GPS')) {
          errorMessage = 'GPS信号弱，请到空旷地方重试'
        }
      }
      
      // 不在这里显示弹窗，让调用方处理
      reject(Object.assign(error, { message: errorMessage }))
    }
  })
}

/**
 * 选择位置
 */
export const chooseLocation = () => {
  return new Promise((resolve, reject) => {
    uni.chooseLocation({
      success: (res) => {
        console.log('选择位置成功:', res)
        resolve({
          name: res.name,
          address: res.address,
          latitude: res.latitude,
          longitude: res.longitude
        })
      },
      fail: (error) => {
        console.error('选择位置失败:', error)
        reject(error)
      }
    })
  })
}

/**
 * 打开地图导航
 * @param {Object} params - 导航参数
 * @param {number} params.latitude - 目标纬度
 * @param {number} params.longitude - 目标经度
 * @param {string} params.name - 目标名称
 * @param {string} params.address - 目标地址
 */
export const openMapNavigation = (params) => {
  // 验证参数
  if (!params || !params.latitude || !params.longitude) {
    console.error('导航参数无效:', params)
    uni.showToast({
      title: '导航信息不完整',
      icon: 'none'
    })
    return
  }

  // 确保坐标是数字类型并验证有效性
  const latitude = Number(params.latitude)
  const longitude = Number(params.longitude)
  
  if (isNaN(latitude) || isNaN(longitude)) {
    console.error('坐标格式错误:', params)
    uni.showToast({
      title: '坐标信息错误',
      icon: 'none'
    })
    return
  }

  // 验证坐标范围（中国境内）
  if (latitude < 3.86 || latitude > 53.55 || longitude < 73.66 || longitude > 135.05) {
    console.error('坐标超出有效范围:', { latitude, longitude })
    uni.showToast({
      title: '坐标超出有效范围',
      icon: 'none'
    })
    return
  }

  console.log('准备打开导航:', {
    latitude,
    longitude,
    name: params.name,
    address: params.address
  })

  // 检查环境，小程序中直接使用备用方案
  // #ifdef MP-WEIXIN
  console.log('小程序环境，直接使用备用导航方案')
  fallbackNavigation(params, latitude, longitude)
  // #endif
  
  // #ifndef MP-WEIXIN
  // 方案1: 尝试使用 uni.openLocation (推荐)
  uni.openLocation({
    latitude: latitude,
    longitude: longitude,
    name: params.name || '目标位置',
    address: params.address || '',
    scale: 18,
    success: () => {
      console.log('打开地图导航成功')
    },
    fail: (error) => {
      console.error('uni.openLocation 失败:', error)
      // 方案2: 备用导航方案
      fallbackNavigation(params, latitude, longitude)
    }
  })
  // #endif
}

/**
 * 备用导航方案
 */
function fallbackNavigation(params, latitude, longitude) {
  console.log('使用备用导航方案')
  
  // #ifdef MP-WEIXIN
  // 小程序环境下的导航选项
  uni.showActionSheet({
    itemList: ['复制地址信息', '复制坐标位置', '查看位置详情'],
    success: (res) => {
      const index = res.tapIndex
      
      switch (index) {
        case 0:
          // 复制完整地址信息
          copyAddressToClipboard(params)
          break
        case 1:
          // 复制坐标
          copyCoordinates(latitude, longitude, params.name)
          break
        case 2:
          // 显示位置详情
          showLocationDetails(params, latitude, longitude)
          break
      }
    },
    fail: (error) => {
      console.error('显示导航选项失败:', error)
      // 最后的备用方案：复制地址
      copyAddressToClipboard(params)
    }
  })
  // #endif
  
  // #ifndef MP-WEIXIN
  // 非小程序环境的导航选项
  uni.showActionSheet({
    itemList: ['复制地址', '使用腾讯地图', '使用百度地图'],
    success: (res) => {
      const index = res.tapIndex
      
      switch (index) {
        case 0:
          // 复制地址到剪贴板
          copyAddressToClipboard(params)
          break
        case 1:
          // 使用腾讯地图
          openWithTencentMap(latitude, longitude, params.name)
          break
        case 2:
          // 使用百度地图
          openWithBaiduMap(latitude, longitude, params.name)
          break
      }
    },
    fail: (error) => {
      console.error('显示导航选项失败:', error)
      // 最后的备用方案：复制地址
      copyAddressToClipboard(params)
    }
  })
  // #endif
}

/**
 * 复制地址到剪贴板
 */
function copyAddressToClipboard(params) {
  const addressText = `${params.name}\n地址: ${params.address}`
  
  uni.setClipboardData({
    data: addressText,
    success: () => {
      uni.showToast({
        title: '地址已复制到剪贴板',
        icon: 'success'
      })
    },
    fail: () => {
      uni.showModal({
        title: '导航信息',
        content: `目标位置:\n${params.name}\n地址: ${params.address}`,
        showCancel: false,
        confirmText: '知道了'
      })
    }
  })
}

/**
 * 复制坐标到剪贴板
 */
function copyCoordinates(latitude, longitude, name) {
  const coordText = `${name}\n坐标: ${latitude}, ${longitude}`
  
  uni.setClipboardData({
    data: coordText,
    success: () => {
      uni.showToast({
        title: '坐标已复制到剪贴板',
        icon: 'success'
      })
    },
    fail: () => {
      uni.showModal({
        title: '坐标信息',
        content: coordText,
        showCancel: false,
        confirmText: '知道了'
      })
    }
  })
}

/**
 * 显示位置详情
 */
function showLocationDetails(params, latitude, longitude) {
  const detailText = `位置详情:\n\n名称: ${params.name}\n地址: ${params.address}\n坐标: ${latitude}, ${longitude}\n\n使用说明:\n1. 复制地址后在地图应用中搜索\n2. 复制坐标后在导航应用中输入\n3. 坐标格式：纬度,经度`
  
  uni.showModal({
    title: '位置详情',
    content: detailText,
    showCancel: true,
    cancelText: '复制地址',
    confirmText: '复制坐标',
    success: (res) => {
      if (res.confirm) {
        // 复制坐标
        copyCoordinates(latitude, longitude, params.name)
      } else if (res.cancel) {
        // 复制地址
        copyAddressToClipboard(params)
      }
    }
  })
}

/**
 * 使用腾讯地图
 */
function openWithTencentMap(latitude, longitude, name) {
  // 使用更简单的腾讯地图URL格式，避免fromcoord参数问题
  
  const tencentUrl = `qqmap://map/geocoder?coord=${latitude},${longitude}&addr=${encodeURIComponent(name)}`
  
  // #ifdef APP-PLUS
  plus.runtime.openURL(tencentUrl, (error) => {
    if (error) {
      // 备用方案：使用简单的地图查看URL
      const fallbackUrl = `qqmap://map/marker?marker=coord:${latitude},${longitude};title:${encodeURIComponent(name)}`
      plus.runtime.openURL(fallbackUrl, (error2) => {
        if (error2) {
          copyAddressToClipboard({ name, address: `坐标: ${latitude}, ${longitude}` })
        }
      })
    }
  })
  // #endif
  
  // #ifdef MP-WEIXIN
  // 小程序中无法直接调用外部应用，显示信息
  uni.showModal({
    title: '腾讯地图导航',
    content: `目标: ${name}\n坐标: ${latitude}, ${longitude}\n\n请在腾讯地图中手动搜索`,
    showCancel: false,
    confirmText: '知道了'
  })
  // #endif
}

/**
 * 使用百度地图
 */
function openWithBaiduMap(latitude, longitude, name) {
  // 百度地图URL
  const baiduUrl = `baidumap://map/direction?destination=${latitude},${longitude}&destination_name=${encodeURIComponent(name)}&mode=driving`
  
  // #ifdef APP-PLUS
  plus.runtime.openURL(baiduUrl, (error) => {
    if (error) {
      copyAddressToClipboard({ name, address: `坐标: ${latitude}, ${longitude}` })
    }
  })
  // #endif
  
  // #ifdef MP-WEIXIN
  // 小程序中显示信息
  uni.showModal({
    title: '百度地图导航',
    content: `目标: ${name}\n坐标: ${latitude}, ${longitude}\n\n请在百度地图中手动搜索`,
    showCancel: false,
    confirmText: '知道了'
  })
  // #endif
}

/**
 * 计算两点间距离
 * @param {number} lat1 - 点1纬度
 * @param {number} lng1 - 点1经度
 * @param {number} lat2 - 点2纬度
 * @param {number} lng2 - 点2经度
 * @returns {number} 距离(km)
 */
export const calculateDistance = (lat1, lng1, lat2, lng2) => {
  const R = 6371 // 地球半径(km)
  const dLat = (lat2 - lat1) * Math.PI / 180
  const dLng = (lng2 - lng1) * Math.PI / 180
  const a = Math.sin(dLat / 2) * Math.sin(dLat / 2) +
            Math.cos(lat1 * Math.PI / 180) * Math.cos(lat2 * Math.PI / 180) *
            Math.sin(dLng / 2) * Math.sin(dLng / 2)
  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a))
  return R * c
} 