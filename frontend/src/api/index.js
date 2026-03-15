import request from '@/utils/request'

// 统计相关接口
export const statisticsApi = {
  get(params) {
    return request.get('/statistics', { params })
  },
  // 获取利润统计（需要管理员权限）
  getProfit(params) {
    return request.get('/statistics/profit', { params })
  },
  // 获取库存统计
  getStock() {
    return request.get('/statistics/stock')
  }
}

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
  },
  // 批量删除商品
  deleteBatch(ids) {
    return request.delete('/product/batch', { data: ids })
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
  // 删除客户（force=true 同时删订单；keep=true 保留订单只删客户）
  delete(id, { force = false, keep = false } = {}) {
    return request.delete(`/customer/${id}`, { params: { force, keep } })
  },
  // 批量删除客户
  deleteBatch(ids, force = false) {
    return request.delete('/customer/batch', { data: ids, params: { force } })
  }
}

// 商品分类相关接口
export const categoryApi = {
  // 获取所有分类列表
  getList() {
    return request.get('/category/list')
  },
  // 获取所有分类列表（含商品数量统计）
  getListWithCount() {
    return request.get('/category/listWithCount')
  },
  // 新增分类
  add(data) {
    return request.post('/category', data)
  },
  // 更新分类
  update(data) {
    return request.put('/category', data)
  },
  // 删除分类
  delete(id) {
    return request.delete(`/category/${id}`)
  }
}
