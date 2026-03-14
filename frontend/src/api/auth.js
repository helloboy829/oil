import request from '../utils/request'

export const authApi = {
  // 登录
  login(data) {
    return request.post('/auth/login', data)
  },

  // 退出登录
  logout() {
    return request.post('/auth/logout')
  },

  // 验证 Token
  verify() {
    return request.get('/auth/verify')
  }
}
