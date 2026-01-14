<template>
  <div class="scan-container">
    <!-- 头部 -->
    <div class="header">
      <h1>扫码开单</h1>
    </div>

    <!-- 扫码区域 -->
    <div class="scan-section">
      <div id="reader" v-show="scanning"></div>

      <el-button
        type="primary"
        size="large"
        @click="startScan"
        v-if="!scanning"
        class="scan-btn"
      >
        开始扫码
      </el-button>

      <el-button
        type="danger"
        size="large"
        @click="stopScan"
        v-else
        class="scan-btn"
      >
        停止扫码
      </el-button>

      <!-- 手动搜索（备用） -->
      <div class="manual-search">
        <el-input
          v-model="searchKeyword"
          placeholder="扫不出来？输入商品名称搜索"
          size="large"
          clearable
          @keyup.enter="searchProduct"
        >
          <template #append>
            <el-button @click="searchProduct">搜索</el-button>
          </template>
        </el-input>

        <!-- 搜索结果 -->
        <div v-if="searchResults.length > 0" class="search-results">
          <div
            v-for="product in searchResults"
            :key="product.id"
            class="product-item"
            @click="addProduct(product)"
          >
            <div class="product-name">{{ product.name }}</div>
            <div class="product-info">
              <span class="product-price">¥{{ product.price }}</span>
              <span class="product-stock">库存: {{ product.stock }}</span>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- 购物车 -->
    <div class="cart-section" v-if="cart.length > 0">
      <div class="cart-header">
        <h2>已添加商品</h2>
        <el-button type="danger" text @click="clearCart">清空</el-button>
      </div>

      <div class="cart-list">
        <div v-for="(item, index) in cart" :key="index" class="cart-item">
          <div class="item-info">
            <div class="item-name">{{ item.name }}</div>
            <div class="item-price">¥{{ item.price }} × {{ item.quantity }}</div>
          </div>

          <div class="item-actions">
            <el-button-group>
              <el-button size="large" @click="decreaseQuantity(index)">-</el-button>
              <el-button size="large" disabled>{{ item.quantity }}</el-button>
              <el-button size="large" @click="increaseQuantity(index)">+</el-button>
            </el-button-group>
            <el-button
              type="danger"
              size="large"
              @click="removeItem(index)"
              style="margin-left: 10px;"
            >
              删除
            </el-button>
          </div>
        </div>
      </div>

      <!-- 总计 -->
      <div class="cart-total">
        <span class="total-label">总计：</span>
        <span class="total-amount">¥{{ totalAmount }}</span>
      </div>
    </div>

    <!-- 空购物车提示 -->
    <div v-else class="empty-cart">
      <p>请扫描商品二维码添加商品</p>
    </div>

    <!-- 底部结算按钮 -->
    <div class="bottom-bar" v-if="cart.length > 0">
      <div class="bottom-total">
        <span class="label">合计：</span>
        <span class="amount">¥{{ totalAmount }}</span>
      </div>
      <el-button
        type="success"
        size="large"
        @click="showCheckout"
        class="checkout-btn"
      >
        结算
      </el-button>
    </div>

    <!-- 结算对话框 -->
    <el-dialog
      v-model="checkoutVisible"
      title="结算"
      width="90%"
      :close-on-click-modal="false"
    >
      <el-form :model="orderForm" :rules="orderRules" ref="orderFormRef" label-position="top">
        <!-- 客户姓名 -->
        <el-form-item label="客户姓名" prop="customerName">
          <el-input
            v-model="orderForm.customerName"
            placeholder="请输入客户姓名"
            size="large"
            clearable
          />
        </el-form-item>

        <!-- 是否月结 -->
        <el-form-item>
          <el-checkbox
            v-model="isMonthlyCustomer"
            size="large"
            @change="handleMonthlyChange"
          >
            <span style="font-size: 18px;">月结客户（月底统一结算）</span>
          </el-checkbox>
        </el-form-item>

        <!-- 支付方式 -->
        <el-form-item label="支付方式" prop="paymentType">
          <el-radio-group v-model="orderForm.paymentType" size="large">
            <el-radio-button value="现金">现金</el-radio-button>
            <el-radio-button value="微信">微信</el-radio-button>
            <el-radio-button value="支付宝">支付宝</el-radio-button>
            <el-radio-button value="月结" :disabled="!isMonthlyCustomer">月结</el-radio-button>
          </el-radio-group>
        </el-form-item>

        <!-- 备注 -->
        <el-form-item label="备注（选填）">
          <el-input
            v-model="orderForm.remark"
            type="textarea"
            :rows="3"
            placeholder="有特殊要求可以在这里备注"
          />
        </el-form-item>

        <!-- 订单明细 -->
        <div class="order-summary">
          <h3>订单明细</h3>
          <div class="summary-list">
            <div v-for="(item, index) in cart" :key="index" class="summary-item">
              <span>{{ item.name }} × {{ item.quantity }}</span>
              <span>¥{{ (item.price * item.quantity).toFixed(2) }}</span>
            </div>
          </div>
          <div class="summary-total">
            <span>总计</span>
            <span class="total">¥{{ totalAmount }}</span>
          </div>
        </div>
      </el-form>

      <template #footer>
        <el-button @click="checkoutVisible = false" size="large">取消</el-button>
        <el-button
          type="primary"
          @click="submitOrder"
          :loading="submitting"
          size="large"
        >
          确认提交
        </el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, computed, onUnmounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Html5Qrcode } from 'html5-qrcode'
import { productApi } from '@/api/index'
import { orderApi } from '@/api/order'

// 扫码相关
const scanning = ref(false)
let html5QrCode = null

// 搜索相关
const searchKeyword = ref('')
const searchResults = ref([])

// 购物车
const cart = ref([])

// 结算相关
const checkoutVisible = ref(false)
const submitting = ref(false)
const isMonthlyCustomer = ref(false)
const orderFormRef = ref(null)
const orderForm = ref({
  customerName: '',
  paymentType: '',
  remark: ''
})

const orderRules = {
  customerName: [
    { required: true, message: '请输入客户姓名', trigger: 'blur' }
  ],
  paymentType: [
    { required: true, message: '请选择支付方式', trigger: 'change' }
  ]
}

// 计算总金额
const totalAmount = computed(() => {
  return cart.value.reduce((sum, item) => {
    return sum + (item.price * item.quantity)
  }, 0).toFixed(2)
})

// 开始扫码
const startScan = async () => {
  try {
    html5QrCode = new Html5Qrcode("reader")
    await html5QrCode.start(
      { facingMode: "environment" },
      { fps: 10, qrbox: { width: 250, height: 250 } },
      onScanSuccess
    )
    scanning.value = true
  } catch (err) {
    ElMessage.error('无法启动摄像头，请检查权限')
    console.error(err)
  }
}

// 停止扫码
const stopScan = () => {
  if (html5QrCode) {
    html5QrCode.stop()
    scanning.value = false
  }
}

// 扫码成功
const onScanSuccess = async (decodedText) => {
  try {
    const res = await productApi.getByCode(decodedText)
    if (res.data) {
      addProduct(res.data)
      ElMessage.success(`已添加：${res.data.name}`)
    } else {
      ElMessage.warning('未找到该商品')
    }
  } catch (err) {
    ElMessage.error('查询商品失败')
  }
}

// 搜索商品
const searchProduct = async () => {
  if (!searchKeyword.value.trim()) {
    ElMessage.warning('请输入商品名称')
    return
  }

  try {
    const res = await productApi.getPage({
      current: 1,
      size: 10,
      name: searchKeyword.value
    })
    searchResults.value = res.data?.records || []

    if (searchResults.value.length === 0) {
      ElMessage.info('未找到相关商品')
    }
  } catch (err) {
    ElMessage.error('搜索失败')
  }
}

// 添加商品到购物车
const addProduct = (product) => {
  // 检查是否已存在
  const existingItem = cart.value.find(item => item.id === product.id)

  if (existingItem) {
    if (existingItem.quantity < product.stock) {
      existingItem.quantity++
    } else {
      ElMessage.warning('库存不足')
    }
  } else {
    cart.value.push({
      id: product.id,
      name: product.name,
      code: product.code,
      price: product.price,
      stock: product.stock,
      quantity: 1
    })
  }

  // 清空搜索
  searchKeyword.value = ''
  searchResults.value = []
}

// 增加数量
const increaseQuantity = (index) => {
  const item = cart.value[index]
  if (item.quantity < item.stock) {
    item.quantity++
  } else {
    ElMessage.warning('库存不足')
  }
}

// 减少数量
const decreaseQuantity = (index) => {
  const item = cart.value[index]
  if (item.quantity > 1) {
    item.quantity--
  }
}

// 删除商品
const removeItem = (index) => {
  cart.value.splice(index, 1)
}

// 清空购物车
const clearCart = () => {
  ElMessageBox.confirm('确定要清空购物车吗？', '提示', {
    confirmButtonText: '确定',
    cancelButtonText: '取消',
    type: 'warning'
  }).then(() => {
    cart.value = []
    ElMessage.success('已清空')
  }).catch(() => {})
}

// 显示结算对话框
const showCheckout = () => {
  checkoutVisible.value = true
}

// 月结客户变化
const handleMonthlyChange = (checked) => {
  if (checked) {
    orderForm.value.paymentType = '月结'
  } else {
    if (orderForm.value.paymentType === '月结') {
      orderForm.value.paymentType = ''
    }
  }
}

// 提交订单
const submitOrder = async () => {
  if (!orderFormRef.value) return

  try {
    await orderFormRef.value.validate()
  } catch (err) {
    return
  }

  submitting.value = true

  try {
    const items = cart.value.map(item => ({
      productId: item.id,
      productCode: item.code,
      quantity: item.quantity
    }))

    await orderApi.create({
      customerName: orderForm.value.customerName,
      paymentType: orderForm.value.paymentType,
      remark: orderForm.value.remark,
      items
    })

    ElMessage.success('订单创建成功！')

    // 重置
    checkoutVisible.value = false
    cart.value = []
    orderForm.value = {
      customerName: '',
      paymentType: '',
      remark: ''
    }
    isMonthlyCustomer.value = false

  } catch (err) {
    ElMessage.error('订单创建失败：' + (err.response?.data?.message || err.message || '未知错误'))
  } finally {
    submitting.value = false
  }
}

// 组件卸载时停止扫码
onUnmounted(() => {
  stopScan()
})
</script>

<style scoped>
/* 全局容器 */
.scan-container {
  min-height: 100vh;
  padding: 20px 15px 120px;
  background: #f5f5f5;
}

/* 头部 */
.header {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  padding: 25px 20px;
  border-radius: 12px;
  margin-bottom: 20px;
  box-shadow: 0 4px 12px rgba(102, 126, 234, 0.3);
}

.header h1 {
  margin: 0;
  font-size: 32px;
  font-weight: bold;
  text-align: center;
}

/* 扫码区域 */
.scan-section {
  background: white;
  padding: 25px;
  border-radius: 12px;
  margin-bottom: 20px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
}

#reader {
  margin-bottom: 20px;
  border-radius: 8px;
  overflow: hidden;
}

.scan-btn {
  width: 100%;
  height: 60px;
  font-size: 20px;
  font-weight: bold;
  border-radius: 8px;
}

/* 手动搜索 */
.manual-search {
  margin-top: 20px;
}

.search-results {
  margin-top: 15px;
  max-height: 300px;
  overflow-y: auto;
}

.product-item {
  background: #f8f9fa;
  padding: 15px;
  border-radius: 8px;
  margin-bottom: 10px;
  cursor: pointer;
  transition: all 0.2s;
}

.product-item:hover {
  background: #e9ecef;
  transform: translateX(5px);
}

.product-name {
  font-size: 18px;
  font-weight: bold;
  margin-bottom: 5px;
}

.product-info {
  display: flex;
  justify-content: space-between;
  font-size: 16px;
  color: #666;
}

.product-price {
  color: #f56c6c;
  font-weight: bold;
}

/* 购物车 */
.cart-section {
  background: white;
  padding: 20px;
  border-radius: 12px;
  margin-bottom: 20px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
}

.cart-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
  padding-bottom: 15px;
  border-bottom: 2px solid #e9ecef;
}

.cart-header h2 {
  margin: 0;
  font-size: 24px;
  font-weight: bold;
}

.cart-list {
  margin-bottom: 20px;
}

.cart-item {
  background: #f8f9fa;
  padding: 20px;
  border-radius: 8px;
  margin-bottom: 15px;
}

.item-info {
  margin-bottom: 15px;
}

.item-name {
  font-size: 20px;
  font-weight: bold;
  margin-bottom: 5px;
}

.item-price {
  font-size: 18px;
  color: #f56c6c;
  font-weight: bold;
}

.item-actions {
  display: flex;
  align-items: center;
}

.item-actions .el-button {
  min-width: 50px;
  height: 45px;
  font-size: 18px;
}

.cart-total {
  padding: 20px;
  background: #f8f9fa;
  border-radius: 8px;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.total-label {
  font-size: 22px;
  font-weight: bold;
}

.total-amount {
  font-size: 32px;
  font-weight: bold;
  color: #f56c6c;
}

/* 空购物车 */
.empty-cart {
  background: white;
  padding: 60px 20px;
  border-radius: 12px;
  text-align: center;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
}

.empty-cart p {
  font-size: 20px;
  color: #999;
  margin: 0;
}

/* 底部操作栏 */
.bottom-bar {
  position: fixed;
  bottom: 0;
  left: 0;
  right: 0;
  background: white;
  padding: 20px 15px;
  box-shadow: 0 -4px 12px rgba(0, 0, 0, 0.1);
  display: flex;
  justify-content: space-between;
  align-items: center;
  z-index: 1000;
}

.bottom-total {
  flex: 1;
}

.bottom-total .label {
  font-size: 18px;
  color: #666;
}

.bottom-total .amount {
  font-size: 32px;
  font-weight: bold;
  color: #f56c6c;
  margin-left: 10px;
}

.checkout-btn {
  min-width: 140px;
  height: 60px;
  font-size: 22px;
  font-weight: bold;
  border-radius: 8px;
}

/* 订单明细 */
.order-summary {
  margin-top: 20px;
  padding: 20px;
  background: #f8f9fa;
  border-radius: 8px;
}

.order-summary h3 {
  margin: 0 0 15px 0;
  font-size: 20px;
}

.summary-list {
  margin-bottom: 15px;
}

.summary-item {
  display: flex;
  justify-content: space-between;
  padding: 12px 0;
  font-size: 16px;
  border-bottom: 1px solid #dee2e6;
}

.summary-total {
  display: flex;
  justify-content: space-between;
  padding-top: 15px;
  border-top: 2px solid #dee2e6;
  font-size: 20px;
  font-weight: bold;
}

.summary-total .total {
  color: #f56c6c;
  font-size: 24px;
}

/* 表单优化 */
:deep(.el-form-item__label) {
  font-size: 18px;
  font-weight: bold;
}

:deep(.el-input__inner) {
  font-size: 18px;
}

:deep(.el-radio-button__inner) {
  font-size: 18px;
  padding: 12px 20px;
}

:deep(.el-checkbox__label) {
  font-size: 18px;
}

:deep(.el-dialog__title) {
  font-size: 24px;
  font-weight: bold;
}

:deep(.el-button--large) {
  font-size: 18px;
  padding: 12px 20px;
}
</style>
