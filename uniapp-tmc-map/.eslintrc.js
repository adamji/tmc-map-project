module.exports = {
  env: {
    browser: true,
    es2021: true,
    node: true
  },
  extends: [
    'eslint:recommended',
    '@vue/typescript/recommended',
    '@vue/standard'
  ],
  parserOptions: {
    ecmaVersion: 'latest',
    sourceType: 'module'
  },
  rules: {
    // Vue 相关规则
    'vue/multi-word-component-names': 'off',
    'vue/max-attributes-per-line': 'off',
    'vue/singleline-html-element-content-newline': 'off',
    'vue/no-v-html': 'off',
    
    // 代码格式规则
    'indent': ['error', 2],
    'quotes': ['error', 'single'],
    'semi': ['error', 'never'],
    'comma-dangle': ['error', 'never'],
    'no-console': 'warn',
    'no-unused-vars': 'warn',
    
    // 现代化规则
    'prefer-const': 'error',
    'no-var': 'error',
    'arrow-spacing': 'error',
    'object-shorthand': 'error'
  },
  globals: {
    uni: 'readonly',
    plus: 'readonly',
    wx: 'readonly',
    getCurrentPages: 'readonly',
    getApp: 'readonly'
  }
} 