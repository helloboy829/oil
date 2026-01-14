import request from '@/utils/request'

// 商品相关接口
export const productApi = {
  // 分页查询商品
  getPage(params) {
    return request.get('/product/page', { params })
  },
  // 根据编码查询商品
  getByCode(code) {
    return request.get(`/product/code/${code}`)
  },
  // 新增商品
  add(data) {
    return request.post('/product', data)
  },
  // 更新商品
  update(data) {
    return request.put('/product', data)
  },
  // 删除商品
  delete(id) {
    return request.delete(`/product/${id}`)
  }
}

// 客户相关接口
export const customerApi = {
  // 分页查询客户
  getPage(params) {
    return request.get('/customer/page', { params })
  },
  // 查询月结客户
  getMonthlyCustomers() {
    return request.get('/customer/monthly')
  },
  // 新增客户
  add(data) {
    return request.post('/customer', data)
  },
  // 更新客户
  update(data) {
    return request.put('/customer', data)
  },
  // 删除客户
  delete(id) {
    return request.delete(`/customer/${id}`)
  }
}
