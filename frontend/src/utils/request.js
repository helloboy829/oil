import axios from 'axios'
import { ElMessage } from 'element-plus'

const request = axios.create({
  baseURL: '/api',
  timeout: 10000,
  paramsSerializer: {
    // 配置数组参数序列化格式，使用 repeat 格式（a=1&a=2）以兼容 Spring Boot
    indexes: null  // 这会生成 a=1&a=2 而不是 a[0]=1&a[1]=2
  }
})

// 请求拦截器
request.interceptors.request.use(
  config => {
    // 添加 Token 到请求头
    const token = localStorage.getItem('admin_token')
    if (token) {
      config.headers.Authorization = `Bearer ${token}`
    }
    return config
  },
  error => {
    return Promise.reject(error)
  }
)

// 响应拦截器
request.interceptors.response.use(
  response => {
    const res = response.data
    if (res.code !== 200) {
      ElMessage.error(res.message || '请求失败')
      return Promise.reject(new Error(res.message || '请求失败'))
    }
    return res
  },
  error => {
    ElMessage.error(error.message || '网络错误')
    return Promise.reject(error)
  }
)

export default request
