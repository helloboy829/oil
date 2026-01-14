<template>
  <div class="scan-container">
    <div class="header">
      <h2>扫码开单</h2>
      <el-button type="primary" link @click="showHistory">历史订单</el-button>
    </div>

    <!-- 客户选择区域 -->
    <div class="customer-section">
      <el-card shadow="hover">
        <template #header>
          <div class="card-header">
            <span>客户信息</span>
          </div>
        </template>
        <el-radio-group v-model="customerMode" @change="handleCustomerModeChange">
          <el-radio-button label="temporary">临时客户</el-radio-button>
          <el-radio-button label="monthly">月结客户</el-radio-button>
        </el-radio-group>

        <div v-if="customerMode === 'temporary'" class="customer-input">
          <el-input
            v-model="orderForm.customerName"
            placeholder="请输入客户姓名"
            clearable
            size="large"
          />
        </div>

        <div v-else class="customer-select">
          <el-select
            v-model="selectedCustomerId"
            placeholder="选择月结客户"
            filterable
            clearable
            size="large"
            style="width: 100%;"
            @change="handleCustomerChange"
          >
            <el-option
              v-for="customer in monthlyCustomers"
              :key="customer.id"
              :label="`${customer.name} (余额: ¥${customer.balance || 0})`"
              :value="customer.id"
            >
              <div class="customer-option">
                <span>{{ customer.name }}</span>
                <span class="customer-balance">余额: ¥{{ customer.balance || 0 }}</span>
              </div>
            </el-option>
          </el-select>
          <div v-if="selectedCustomer" class="customer-info">
            <el-tag type="info">信用额度: ¥{{ selectedCustomer.creditLimit || 0 }}</el-tag>
            <el-tag :type="getBalanceType(selectedCustomer.balance)">
              当前欠款: ¥{{ selectedCustomer.balance || 0 }}
            </el-tag>
            <el-tag :type="canUseCredit ? 'success' : 'danger'">
              可用额度: ¥{{ availableCredit }}
            </el-tag>
          </div>
        </div>
      </el-card>
    </div>

    <!-- 扫码和商品搜索区域 -->
    <div class="scan-section">
      <el-tabs v-model="scanMode">
        <el-tab-pane label="扫码添加" name="scan">
          <div class="scan-area">
            <div id="reader" style="width: 100%;"></div>
            <el-button type="primary" @click="startScan" v-if="!scanning" size="large">
              开始扫码
            </el-button>
            <el-button type="danger" @click="stopScan" v-else size="large">
              停止扫码
            </el-button>
          </div>
        </el-tab-pane>

        <el-tab-pane label="手动添加" name="manual">
          <div class="manual-add">
            <el-input
              v-model="searchKeyword"
              placeholder="输入商品编码或名称搜索"
              clearable
              size="large"
              @keyup.enter="searchProduct"
            >
              <template #append>
                <el-button @click="searchProduct" :icon="Search">搜索</el-button>
              </template>
            </el-input>

            <div v-if="searchResults.length > 0" class="search-results">
              <el-table :data="searchResults" border @row-click="addProductFromSearch">
                <el-table-column prop="name" label="商品名称" />
                <el-table-column prop="code" label="编码" width="120" />
                <el-table-column prop="spec" label="规格" width="100" />
                <el-table-column prop="price" label="单价" width="100" />
                <el-table-column prop="stock" label="库存" width="80" />
                <el-table-column label="操作" width="100">
                  <template #default="{ row }">
                    <el-button type="primary" size="small" @click.stop="addProductFromSearch(row)">
                      添加
                    </el-button>
                  </template>
                </el-table-column>
              </el-table>
            </div>
          </div>
        </el-tab-pane>
      </el-tabs>
    </div>

    <!-- 购物车商品列表 -->
    <div class="product-list">
      <el-card shadow="hover">
        <template #header>
          <div class="card-header">
            <span>购物车 ({{ scannedProducts.length }}件)</span>
            <el-button type="danger" link @click="clearCart" v-if="scannedProducts.length > 0">
              清空
            </el-button>
          </div>
        </template>

        <el-empty v-if="scannedProducts.length === 0" description="暂无商品，请扫码或搜索添加" />

        <el-table v-else :data="scannedProducts" border>
          <el-table-column prop="name" label="商品名称" />
          <el-table-column prop="code" label="编码" width="100" />
          <el-table-column prop="price" label="单价" width="80">
            <template #default="{ row }">
              ¥{{ row.price }}
            </template>
          </el-table-column>
          <el-table-column label="数量" width="140">
            <template #default="{ row }">
              <el-input-number
                v-model="row.quantity"
                :min="1"
                :max="row.stock"
                size="small"
              />
            </template>
          </el-table-column>
          <el-table-column label="小计" width="100">
            <template #default="{ row }">
              <span class="subtotal">¥{{ (row.price * row.quantity).toFixed(2) }}</span>
            </template>
          </el-table-column>
          <el-table-column label="操作" width="80" fixed="right">
            <template #default="{ $index }">
              <el-button type="danger" size="small" link @click="removeProduct($index)">
                删除
              </el-button>
            </template>
          </el-table-column>
        </el-table>

        <div class="cart-summary">
          <div class="summary-item">
            <span>商品数量：</span>
            <span class="value">{{ totalQuantity }} 件</span>
          </div>
          <div class="summary-item total">
            <span>总金额：</span>
            <span class="amount">¥{{ totalAmount }}</span>
          </div>
        </div>
      </el-card>
    </div>

    <!-- 底部操作栏 -->
    <div class="bottom-bar">
      <div class="total-info">
        <span class="label">合计：</span>
        <span class="total">¥{{ totalAmount }}</span>
      </div>
      <el-button
        type="success"
        size="large"
        @click="handleSubmit"
        :disabled="scannedProducts.length === 0"
      >
        提交订单
      </el-button>
    </div>

    <!-- 订单确认对话框 -->
    <el-dialog v-model="dialogVisible" title="确认订单" width="90%">
      <el-form :model="orderForm" :rules="orderRules" ref="orderFormRef" label-width="100px">
        <el-form-item label="客户信息" prop="customerName">
          <el-input
            v-model="orderForm.customerName"
            :disabled="customerMode === 'monthly'"
            placeholder="请输入客户姓名"
          />
        </el-form-item>

        <el-form-item label="支付方式" prop="paymentType">
          <el-select
            v-model="orderForm.paymentType"
            placeholder="请选择支付方式"
            style="width: 100%;"
          >
            <el-option label="现金" value="现金" />
            <el-option label="微信" value="微信" />
            <el-option label="支付宝" value="支付宝" />
            <el-option label="月结" value="月结" :disabled="customerMode !== 'monthly'" />
          </el-select>
        </el-form-item>

        <el-alert
          v-if="orderForm.paymentType === '月结' && !canUseCredit"
          title="警告：客户可用额度不足！"
          type="error"
          :closable="false"
          show-icon
        >
          <template #default>
            订单金额: ¥{{ totalAmount }}<br>
            可用额度: ¥{{ availableCredit }}<br>
            超出金额: ¥{{ (parseFloat(totalAmount) - parseFloat(availableCredit)).toFixed(2) }}
          </template>
        </el-alert>

        <el-form-item label="备注">
          <el-input
            v-model="orderForm.remark"
            type="textarea"
            :rows="3"
            placeholder="选填，如有特殊要求请备注"
          />
        </el-form-item>

        <el-divider />

        <div class="order-summary">
          <h4>订单明细</h4>
          <el-table :data="scannedProducts" border max-height="300">
            <el-table-column prop="name" label="商品" />
            <el-table-column prop="quantity" label="数量" width="80" />
            <el-table-column label="小计" width="100">
              <template #default="{ row }">
                ¥{{ (row.price * row.quantity).toFixed(2) }}
              </template>
            </el-table-column>
          </el-table>
          <div class="summary-total">
            <span>订单总额：</span>
            <span class="amount">¥{{ totalAmount }}</span>
          </div>
        </div>
      </el-form>

      <template #footer>
        <el-button @click="dialogVisible = false" size="large">取消</el-button>
        <el-button
          type="primary"
          @click="submitOrder"
          :loading="submitting"
          :disabled="orderForm.paymentType === '月结' && !canUseCredit"
          size="large"
        >
          确认提交
        </el-button>
      </template>
    </el-dialog>

    <!-- 历史订单对话框 -->
    <el-dialog v-model="historyVisible" title="历史订单" width="95%">
      <el-table :data="historyOrders" border v-loading="loadingHistory">
        <el-table-column prop="orderNo" label="订单号" width="180" />
        <el-table-column prop="customerName" label="客户" width="120" />
        <el-table-column prop="totalAmount" label="金额" width="100">
          <template #default="{ row }">
            ¥{{ row.totalAmount }}
          </template>
        </el-table-column>
        <el-table-column prop="paymentType" label="支付方式" width="100" />
        <el-table-column prop="createTime" label="时间" width="160" />
        <el-table-column label="操作" width="120" fixed="right">
          <template #default="{ row }">
            <el-button type="primary" link size="small" @click="viewOrderDetail(row)">
              查看详情
            </el-button>
          </template>
        </el-table-column>
      </el-table>

      <el-pagination
        v-model:current-page="historyPage.current"
        v-model:page-size="historyPage.size"
        :total="historyPage.total"
        @current-change="loadHistory"
        layout="total, prev, pager, next"
        style="margin-top: 20px; justify-content: center;"
      />
    </el-dialog>

    <!-- 订单详情对话框 -->
    <el-dialog v-model="detailVisible" title="订单详情" width="90%">
      <div v-if="currentOrder" class="order-detail">
        <el-descriptions :column="2" border>
          <el-descriptions-item label="订单号">{{ currentOrder.orderNo }}</el-descriptions-item>
          <el-descriptions-item label="客户">{{ currentOrder.customerName }}</el-descriptions-item>
          <el-descriptions-item label="支付方式">{{ currentOrder.paymentType }}</el-descriptions-item>
          <el-descriptions-item label="订单金额">¥{{ currentOrder.totalAmount }}</el-descriptions-item>
          <el-descriptions-item label="创建时间" :span="2">{{ currentOrder.createTime }}</el-descriptions-item>
          <el-descriptions-item label="备注" :span="2">{{ currentOrder.remark || '无' }}</el-descriptions-item>
        </el-descriptions>

        <h4 style="margin-top: 20px;">商品明细</h4>
        <el-table :data="currentOrder.items" border>
          <el-table-column prop="productName" label="商品名称" />
          <el-table-column prop="productCode" label="编码" width="120" />
          <el-table-column prop="price" label="单价" width="100">
            <template #default="{ row }">
              ¥{{ row.price }}
            </template>
          </el-table-column>
          <el-table-column prop="quantity" label="数量" width="80" />
          <el-table-column prop="subtotal" label="小计" width="100">
            <template #default="{ row }">
              ¥{{ row.subtotal }}
            </template>
          </el-table-column>
        </el-table>
      </div>

      <template #footer>
        <el-button @click="detailVisible = false">关闭</el-button>
        <el-button type="primary" @click="shareOrder">分享订单</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, onUnmounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Search } from '@element-plus/icons-vue'
import { Html5Qrcode } from 'html5-qrcode'
import { productApi, customerApi } from '@/api/index'
import { orderApi } from '@/api/order'

// 扫码相关
const scanning = ref(false)
const scanMode = ref('scan')
let html5QrCode = null

// 商品相关
const scannedProducts = ref([])
const searchKeyword = ref('')
const searchResults = ref([])

// 客户相关
const customerMode = ref('temporary')
const monthlyCustomers = ref([])
const selectedCustomerId = ref(null)
const selectedCustomer = ref(null)

// 订单相关
const dialogVisible = ref(false)
const submitting = ref(false)
const orderFormRef = ref(null)
const orderForm = ref({
  customerName: '',
  customerId: null,
  paymentType: '',
  remark: ''
})

const orderRules = {
  customerName: [{ required: true, message: '请输入客户姓名', trigger: 'blur' }],
  paymentType: [{ required: true, message: '请选择支付方式', trigger: 'change' }]
}

// 历史订单相关
const historyVisible = ref(false)
const loadingHistory = ref(false)
const historyOrders = ref([])
const historyPage = ref({
  current: 1,
  size: 10,
  total: 0
})

// 订单详情相关
const detailVisible = ref(false)
const currentOrder = ref(null)

// 计算属性
const totalAmount = computed(() => {
  return scannedProducts.value.reduce((sum, item) => {
    return sum + (item.price * item.quantity)
  }, 0).toFixed(2)
})

const totalQuantity = computed(() => {
  return scannedProducts.value.reduce((sum, item) => {
    return sum + item.quantity
  }, 0)
})

const availableCredit = computed(() => {
  if (!selectedCustomer.value) return 0
  const credit = parseFloat(selectedCustomer.value.creditLimit || 0)
  const balance = parseFloat(selectedCustomer.value.balance || 0)
  return (credit - balance).toFixed(2)
})

const canUseCredit = computed(() => {
  if (!selectedCustomer.value) return false
  return parseFloat(totalAmount.value) <= parseFloat(availableCredit.value)
})

// 生命周期
onMounted(() => {
  loadMonthlyCustomers()
})

onUnmounted(() => {
  stopScan()
})

// 客户相关方法
const loadMonthlyCustomers = async () => {
  try {
    const res = await customerApi.getMonthlyCustomers()
    monthlyCustomers.value = res.data || []
  } catch (err) {
    console.error('加载月结客户失败:', err)
  }
}

const handleCustomerModeChange = (mode) => {
  selectedCustomerId.value = null
  selectedCustomer.value = null
  orderForm.value.customerName = ''
  orderForm.value.customerId = null

  if (mode === 'monthly') {
    orderForm.value.paymentType = '月结'
  } else {
    orderForm.value.paymentType = ''
  }
}

const handleCustomerChange = (customerId) => {
  const customer = monthlyCustomers.value.find(c => c.id === customerId)
  selectedCustomer.value = customer
  if (customer) {
    orderForm.value.customerName = customer.name
    orderForm.value.customerId = customer.id
    orderForm.value.paymentType = '月结'
  }
}

const getBalanceType = (balance) => {
  const bal = parseFloat(balance || 0)
  if (bal === 0) return 'success'
  if (bal < 5000) return 'warning'
  return 'danger'
}

// 扫码相关方法
const startScan = async () => {
  try {
    html5QrCode = new Html5Qrcode("reader")
    await html5QrCode.start(
      { facingMode: "environment" },
      { fps: 10, qrbox: 250 },
      onScanSuccess
    )
    scanning.value = true
  } catch (err) {
    ElMessage.error('启动摄像头失败：' + err)
  }
}

const stopScan = () => {
  if (html5QrCode) {
    html5QrCode.stop()
    scanning.value = false
  }
}

const onScanSuccess = async (decodedText) => {
  try {
    const res = await productApi.getByCode(decodedText)
    if (res.data) {
      addProduct(res.data)
      ElMessage.success('扫码成功: ' + res.data.name)
    } else {
      ElMessage.warning('未找到该商品')
    }
  } catch (err) {
    ElMessage.error('查询商品失败')
  }
}

// 商品相关方法
const searchProduct = async () => {
  if (!searchKeyword.value.trim()) {
    ElMessage.warning('请输入搜索关键词')
    return
  }

  try {
    const res = await productApi.getPage({
      current: 1,
      size: 20,
      name: searchKeyword.value
    })
    searchResults.value = res.data?.records || []

    if (searchResults.value.length === 0) {
      ElMessage.info('未找到相关商品')
    }
  } catch (err) {
    ElMessage.error('搜索商品失败')
  }
}

const addProduct = (product) => {
  const existingProduct = scannedProducts.value.find(p => p.id === product.id)
  if (existingProduct) {
    if (existingProduct.quantity < product.stock) {
      existingProduct.quantity++
    } else {
      ElMessage.warning('库存不足')
    }
  } else {
    scannedProducts.value.push({
      ...product,
      quantity: 1
    })
  }
}

const addProductFromSearch = (product) => {
  addProduct(product)
  searchKeyword.value = ''
  searchResults.value = []
}

const removeProduct = (index) => {
  scannedProducts.value.splice(index, 1)
}

const clearCart = () => {
  ElMessageBox.confirm('确定要清空购物车吗？', '提示', {
    confirmButtonText: '确定',
    cancelButtonText: '取消',
    type: 'warning'
  }).then(() => {
    scannedProducts.value = []
    ElMessage.success('已清空')
  }).catch(() => {})
}

// 订单相关方法
const handleSubmit = () => {
  if (scannedProducts.value.length === 0) {
    ElMessage.warning('请先添加商品')
    return
  }

  // 检查客户信息
  if (customerMode.value === 'temporary' && !orderForm.value.customerName.trim()) {
    ElMessage.warning('请输入客户姓名')
    return
  }

  if (customerMode.value === 'monthly' && !selectedCustomerId.value) {
    ElMessage.warning('请选择月结客户')
    return
  }

  dialogVisible.value = true
}

const submitOrder = async () => {
  if (!orderFormRef.value) return

  try {
    await orderFormRef.value.validate()
  } catch (err) {
    return
  }

  // 月结客户额度检查
  if (orderForm.value.paymentType === '月结' && !canUseCredit.value) {
    ElMessage.error('客户可用额度不足，无法使用月结支付')
    return
  }

  submitting.value = true

  try {
    const items = scannedProducts.value.map(p => ({
      productId: p.id,
      productCode: p.code,
      quantity: p.quantity
    }))

    await orderApi.create({
      customerId: orderForm.value.customerId,
      customerName: orderForm.value.customerName,
      paymentType: orderForm.value.paymentType,
      remark: orderForm.value.remark,
      items
    })

    ElMessage.success('订单创建成功！')

    // 重置表单
    dialogVisible.value = false
    scannedProducts.value = []
    searchResults.value = []

    // 如果是临时客户，清空客户姓名
    if (customerMode.value === 'temporary') {
      orderForm.value.customerName = ''
    }
    orderForm.value.paymentType = customerMode.value === 'monthly' ? '月结' : ''
    orderForm.value.remark = ''

    // 重新加载月结客户数据（更新余额）
    if (customerMode.value === 'monthly') {
      await loadMonthlyCustomers()
      handleCustomerChange(selectedCustomerId.value)
    }
  } catch (err) {
    ElMessage.error('订单创建失败: ' + (err.message || '未知错误'))
  } finally {
    submitting.value = false
  }
}

// 历史订单相关方法
const showHistory = async () => {
  historyVisible.value = true
  await loadHistory()
}

const loadHistory = async () => {
  loadingHistory.value = true
  try {
    const res = await orderApi.getPage({
      current: historyPage.value.current,
      size: historyPage.value.size
    })

    historyOrders.value = res.data?.records || []
    historyPage.value.total = res.data?.total || 0
  } catch (err) {
    ElMessage.error('加载历史订单失败')
  } finally {
    loadingHistory.value = false
  }
}

const viewOrderDetail = async (order) => {
  try {
    const res = await orderApi.getById(order.id)
    currentOrder.value = res.data
    detailVisible.value = true
  } catch (err) {
    ElMessage.error('加载订单详情失败')
  }
}

const shareOrder = () => {
  if (!currentOrder.value) return

  const orderText = `
订单号: ${currentOrder.value.orderNo}
客户: ${currentOrder.value.customerName}
支付方式: ${currentOrder.value.paymentType}
订单金额: ¥${currentOrder.value.totalAmount}
创建时间: ${currentOrder.value.createTime}

商品明细:
${currentOrder.value.items.map(item =>
  `${item.productName} x${item.quantity} = ¥${item.subtotal}`
).join('\n')}

总计: ¥${currentOrder.value.totalAmount}
  `.trim()

  // 复制到剪贴板
  if (navigator.clipboard) {
    navigator.clipboard.writeText(orderText).then(() => {
      ElMessage.success('订单信息已复制到剪贴板')
    }).catch(() => {
      ElMessage.error('复制失败')
    })
  } else {
    // 降级方案
    const textarea = document.createElement('textarea')
    textarea.value = orderText
    document.body.appendChild(textarea)
    textarea.select()
    try {
      document.execCommand('copy')
      ElMessage.success('订单信息已复制到剪贴板')
    } catch (err) {
      ElMessage.error('复制失败')
    }
    document.body.removeChild(textarea)
  }
}
</script>

<style scoped>
.scan-container {
  padding: 10px;
  max-width: 1200px;
  margin: 0 auto;
  padding-bottom: 100px;
}

.header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
  padding: 10px;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  border-radius: 10px;
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
}

.header h2 {
  margin: 0;
  font-size: 24px;
}

.customer-section {
  margin-bottom: 20px;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  font-weight: bold;
}

.customer-input,
.customer-select {
  margin-top: 15px;
}

.customer-option {
  display: flex;
  justify-content: space-between;
  width: 100%;
}

.customer-balance {
  color: #909399;
  font-size: 12px;
}

.customer-info {
  margin-top: 15px;
  display: flex;
  gap: 10px;
  flex-wrap: wrap;
}

.scan-section {
  margin-bottom: 20px;
}

.scan-area {
  text-align: center;
  padding: 20px;
}

.scan-area #reader {
  margin-bottom: 20px;
  border-radius: 10px;
  overflow: hidden;
}

.scan-area button {
  width: 100%;
  max-width: 300px;
  height: 50px;
  font-size: 16px;
}

.manual-add {
  padding: 20px;
}

.search-results {
  margin-top: 20px;
}

.product-list {
  margin-bottom: 20px;
}

.cart-summary {
  margin-top: 20px;
  padding: 15px;
  background: #f5f7fa;
  border-radius: 8px;
}

.summary-item {
  display: flex;
  justify-content: space-between;
  margin-bottom: 10px;
  font-size: 16px;
}

.summary-item.total {
  margin-bottom: 0;
  padding-top: 10px;
  border-top: 2px solid #dcdfe6;
}

.summary-item .value {
  font-weight: bold;
  color: #409eff;
}

.summary-item .amount {
  font-size: 24px;
  font-weight: bold;
  color: #f56c6c;
}

.subtotal {
  color: #f56c6c;
  font-weight: bold;
}

.bottom-bar {
  position: fixed;
  bottom: 0;
  left: 0;
  right: 0;
  background: white;
  padding: 15px 20px;
  box-shadow: 0 -2px 10px rgba(0, 0, 0, 0.1);
  display: flex;
  justify-content: space-between;
  align-items: center;
  z-index: 1000;
}

.total-info {
  display: flex;
  align-items: baseline;
  gap: 10px;
}

.total-info .label {
  font-size: 16px;
  color: #606266;
}

.total-info .total {
  font-size: 28px;
  font-weight: bold;
  color: #f56c6c;
}

.bottom-bar button {
  min-width: 140px;
  height: 50px;
  font-size: 18px;
}

.order-summary h4 {
  margin-bottom: 15px;
  color: #303133;
}

.summary-total {
  margin-top: 15px;
  padding-top: 15px;
  border-top: 2px solid #dcdfe6;
  text-align: right;
  font-size: 18px;
}

.summary-total .amount {
  font-size: 24px;
  font-weight: bold;
  color: #f56c6c;
  margin-left: 10px;
}

.order-detail {
  padding: 10px 0;
}

/* 移动端适配 */
@media (max-width: 768px) {
  .scan-container {
    padding: 5px;
  }

  .header h2 {
    font-size: 20px;
  }

  .customer-info {
    font-size: 12px;
  }

  .cart-summary {
    padding: 10px;
  }

  .summary-item {
    font-size: 14px;
  }

  .summary-item .amount {
    font-size: 20px;
  }

  .total-info .total {
    font-size: 24px;
  }

  .bottom-bar {
    padding: 10px;
  }

  .bottom-bar button {
    min-width: 120px;
    height: 45px;
    font-size: 16px;
  }
}

/* 表格优化 */
:deep(.el-table) {
  font-size: 14px;
}

:deep(.el-table th) {
  background-color: #f5f7fa;
  font-weight: bold;
}

/* 卡片样式优化 */
:deep(.el-card) {
  border-radius: 10px;
  box-shadow: 0 2px 12px 0 rgba(0, 0, 0, 0.1);
}

:deep(.el-card__header) {
  background-color: #f5f7fa;
  border-bottom: 2px solid #e4e7ed;
}

/* 对话框优化 */
:deep(.el-dialog) {
  border-radius: 10px;
}

:deep(.el-dialog__header) {
  background-color: #f5f7fa;
  padding: 20px;
  border-radius: 10px 10px 0 0;
}

:deep(.el-dialog__title) {
  font-weight: bold;
  font-size: 18px;
}

/* 标签页优化 */
:deep(.el-tabs__item) {
  font-size: 16px;
  font-weight: bold;
}

/* 按钮组优化 */
:deep(.el-radio-group) {
  width: 100%;
}

:deep(.el-radio-button) {
  flex: 1;
}

:deep(.el-radio-button__inner) {
  width: 100%;
}
</style>
