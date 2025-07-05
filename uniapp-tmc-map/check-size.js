const fs = require('fs')
const path = require('path')

function formatBytes(bytes) {
  if (bytes === 0) return '0 Bytes'
  const k = 1024
  const sizes = ['Bytes', 'KB', 'MB', 'GB']
  const i = Math.floor(Math.log(bytes) / Math.log(k))
  return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i]
}

function getDirSize(dir) {
  if (!fs.existsSync(dir)) {
    return 0
  }
  
  let size = 0
  const files = fs.readdirSync(dir)
  
  files.forEach(file => {
    const filePath = path.join(dir, file)
    const stat = fs.statSync(filePath)
    
    if (stat.isDirectory()) {
      size += getDirSize(filePath)
    } else {
      size += stat.size
    }
  })
  
  return size
}

function checkBundleSize() {
  const buildPath = path.join(__dirname, 'dist/build/mp-weixin')
  const devPath = path.join(__dirname, 'dist/dev/mp-weixin')
  
  console.log('📦 小程序包大小检查')
  console.log('========================')
  
  if (fs.existsSync(buildPath)) {
    const buildSize = getDirSize(buildPath)
    const buildSizeMB = buildSize / 1024 / 1024
    
    console.log(`🏗️  生产构建: ${formatBytes(buildSize)} (${buildSizeMB.toFixed(2)} MB)`)
    
    if (buildSizeMB < 1) {
      console.log('✅ 包大小优秀')
    } else if (buildSizeMB < 2) {
      console.log('⚠️  包大小正常，建议关注')
    } else {
      console.log('❌ 包大小过大，需要优化')
    }
  } else {
    console.log('❌ 生产构建不存在，请运行: npm run build:mp-weixin')
  }
  
  if (fs.existsSync(devPath)) {
    const devSize = getDirSize(devPath)
    const devSizeMB = devSize / 1024 / 1024
    
    console.log(`🔧 开发构建: ${formatBytes(devSize)} (${devSizeMB.toFixed(2)} MB)`)
  } else {
    console.log('❌ 开发构建不存在，请运行: npm run dev:mp-weixin')
  }
  
  console.log('========================')
  console.log('📊 微信小程序包大小限制:')
  console.log('   - 主包: < 2MB')
  console.log('   - 总包: < 20MB')
  console.log('   - 推荐: < 1MB (最佳体验)')
}

checkBundleSize() 