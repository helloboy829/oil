import request from '@/utils/request'

// 订单相关接口
export const orderApi = {
  // 分页查询订单
  getPage(params) {
    return request.get('/order/page', { params })
  },
  // 创建订单
  create(data) {
    return request.post('/order', data)
  },
  // 更新订单
  update(id, data) {
    return request.put(`/order/${id}`, data)
  },
  // 查询订单详情
  getById(id) {
    return request.get(`/order/${id}`)
  },
  // 删除订单
  delete(id) {
    return request.delete(`/order/${id}`)
  },
  // 批量删除订单
  deleteBatch(ids) {
    return request.delete('/order/batch', { data: ids })
  }
}

// 月结账单相关接口
export const monthlyBillApi = {
  // 分页查询月结账单
  getPage(params) {
    return request.get('/monthly-bill/page', { params })
  },
  // 生成月结账单
  generate(params) {
    return request.post('/monthly-bill/generate', null, { params })
  },
  // 结算月结账单
  settle(id) {
    return request.put(`/monthly-bill/settle/${id}`)
  },
  // 获取账单详情
  getById(id) {
    return request.get(`/monthly-bill/${id}`)
  },
  // 导出月结账单
  export(id) {
    return `/api/monthly-bill/export/${id}`
  },
  // 删除月结账单
  delete(id) {
    return request.delete(`/monthly-bill/${id}`)
  },
  // 批量删除月结账单
  deleteBatch(ids) {
    return request.delete('/monthly-bill/batch', { data: ids })
  }
}
