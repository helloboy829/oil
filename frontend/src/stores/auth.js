import { defineStore } from 'pinia'
import { ref } from 'vue'

export const useAuthStore = defineStore('auth', () => {
  // 是否为管理员模式
  const isAdmin = ref(false)

  // Token
  const token = ref(localStorage.getItem('admin_token') || '')

  // 用户信息
  const userInfo = ref(null)

  // 登录
  function login(tokenValue, user) {
    token.value = tokenValue
    isAdmin.value = true
    userInfo.value = user
    localStorage.setItem('admin_token', tokenValue)
  }

  // 退出
  function logout() {
    token.value = ''
    isAdmin.value = false
    userInfo.value = null
    localStorage.removeItem('admin_token')
  }

  // 初始化：检查是否有保存的 token
  function initAuth() {
    const savedToken = localStorage.getItem('admin_token')
    if (savedToken) {
      token.value = savedToken
      isAdmin.value = true
      // 可以在这里验证 token 是否有效
    }
  }

  return {
    isAdmin,
    token,
    userInfo,
    login,
    logout,
    initAuth
  }
})
