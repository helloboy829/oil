<template>
  <div class="scan-container">
    <!-- 头部 -->
    <div class="header">
      <h1>扫码开单</h1>
    </div>

    <!-- 扫码区域 -->
    <div class="scan-section">
      <!-- 扫码时显示视频窗口 -->
      <video id="video" ref="video" v-show="scanning" autoplay></video>

      <el-button
        type="primary"
        size="large"
        @click="startScan"
        v-if="!scanning"
        class="scan-btn"
      >
        📷 开始扫码
      </el-button>

      <el-button
        type="danger"
        size="large"
        @click="stopScan"
        v-else
        class="scan-btn"
      >
        ⏸️ 停止扫码
      </el-button>

      <!-- 扫码状态提示 -->
      <div v-if="scanning" class="scan-tip-text">
        <p>📱 请将摄像头对准二维码</p>
      </div>

      <!-- 上传二维码图片（电脑端使用） -->
      <div class="upload-section">
        <el-upload
          :auto-upload="false"
          :show-file-list="false"
          accept="image/*"
          :on-change="handleFileUpload"
        >
          <el-button type="success" size="large" class="upload-btn">
            📷 上传二维码图片（电脑端）
          </el-button>
        </el-upload>
      </div>

      <!-- 手动搜索（备用） -->
      <div class="manual-search">
        <el-select
          v-model="selectedProduct"
          filterable
          remote
          reserve-keyword
          placeholder="扫不出来？输入商品名称搜索"
          :remote-method="searchProductRemote"
          :loading="productLoading"
          size="large"
          style="width: 100%;"
          clearable
          @change="handleProductSelect"
          @focus="loadAllProducts"
        >
          <el-option
            v-for="product in productList"
            :key="product.id"
            :label="product.name"
            :value="product.id"
          >
            <div style="display: flex; justify-content: space-between; align-items: center;">
              <span>{{ product.name }}</span>
              <div style="display: flex; gap: 8px; align-items: center;">
                <span style="color: #f56c6c; font-weight: bold;">¥{{ product.price }}</span>
                <el-tag size="small" :type="product.stock > 10 ? 'success' : 'warning'">
                  库存: {{ product.stock }}
                </el-tag>
              </div>
            </div>
          </el-option>
        </el-select>
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
          <el-select
            v-model="orderForm.customerName"
            filterable
            remote
            reserve-keyword
            placeholder="请输入客户姓名搜索"
            :remote-method="searchCustomers"
            :loading="customerLoading"
            size="large"
            style="width: 100%;"
            clearable
            @change="handleCustomerChange"
            @focus="loadAllCustomers"
          >
            <el-option
              v-for="customer in customerList"
              :key="customer.id"
              :label="customer.name"
              :value="customer.name"
            >
              <div style="display: flex; justify-content: space-between; align-items: center;">
                <span>{{ customer.name }}</span>
                <el-tag v-if="customer.isMonthly" type="success" size="small" style="margin-left: 8px;">月结</el-tag>
              </div>
            </el-option>
          </el-select>
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
import { BrowserMultiFormatReader } from '@zxing/library'
import { productApi, customerApi } from '@/api/index'
import { orderApi } from '@/api/order'

// 扫码相关
const scanning = ref(false)
let codeReader = null

// 搜索相关
const searchKeyword = ref('')
const searchResults = ref([])
const selectedProduct = ref(null)
const productList = ref([])
const productLoading = ref(false)
const allProducts = ref([]) // 缓存所有商品

// 购物车
const cart = ref([])

// 客户搜索相关
const customerList = ref([])
const customerLoading = ref(false)
const selectedCustomer = ref(null)
const allCustomers = ref([]) // 缓存所有客户

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
    ElMessage.info('正在启动摄像头...')

    codeReader = new BrowserMultiFormatReader()

    // 获取摄像头设备列表
    const videoDevices = await codeReader.getVideoInputDevices()
    console.log('摄像头设备列表:', videoDevices)

    if (videoDevices.length === 0) {
      ElMessage.error('未检测到摄像头设备')
      return
    }

    // 优先选择后置摄像头
    let selectedDeviceId = videoDevices[videoDevices.length - 1].deviceId

    if (videoDevices.length > 1) {
      // 查找包含 'back' 和 '0' 的后置摄像头
      const backCamera = videoDevices.find(device => {
        const label = device.label.toLowerCase()
        return label.includes('back') && label.includes('0')
      })

      if (backCamera) {
        selectedDeviceId = backCamera.deviceId
      }
    }

    console.log('选择的摄像头ID:', selectedDeviceId)

    // 开始扫码
    codeReader.decodeFromVideoDevice(selectedDeviceId, 'video', (result, err) => {
      if (result) {
        console.log('扫码成功:', result.text)
        onScanSuccess(result.text)
      }
      if (err && err.name !== 'NotFoundException') {
        console.error('扫码错误:', err)
      }
    })

    scanning.value = true
    ElMessage.success('摄像头已启动，请对准二维码')

  } catch (err) {
    console.error('启动摄像头失败:', err)
    ElMessage.error('无法启动摄像头：' + err.message)
  }
}

// 停止扫码
const stopScan = () => {
  if (codeReader) {
    codeReader.reset()
    scanning.value = false
    ElMessage.info('已停止扫码')
  }
}

// 扫码成功回调
const onScanSuccess = async (decodedText) => {
  // 停止扫码，避免重复识别
  stopScan()

  try {
    const res = await productApi.getByCode(decodedText)
    if (res.data) {
      const product = res.data

      // 弹出确认框
      ElMessageBox.confirm(
        `商品名称：${product.name}\n价格：¥${product.price}\n库存：${product.stock}\n\n是否添加到购物车？`,
        '扫码成功',
        {
          confirmButtonText: '添加',
          cancelButtonText: '取消',
          type: 'success',
          distinguishCancelAndClose: true
        }
      ).then(() => {
        // 用户点击"添加"
        addProduct(product)
        ElMessage.success(`已添加：${product.name}`)
        // 添加成功后重新开始扫码
        setTimeout(() => {
          startScan()
        }, 500)
      }).catch((action) => {
        // 用户点击"取消"或关闭
        if (action === 'cancel') {
          ElMessage.info('已取消添加')
        }
        // 重新开始扫码
        setTimeout(() => {
          startScan()
        }, 500)
      })
    } else {
      ElMessage.warning('未找到该商品')
      // 未找到商品也重新开始扫码
      setTimeout(() => {
        startScan()
      }, 1000)
    }
  } catch (err) {
    ElMessage.error('查询商品失败')
    console.error('查询商品错误:', err)
    // 查询失败也重新开始扫码
    setTimeout(() => {
      startScan()
    }, 1000)
  }
}

// 处理文件上传（扫描上传的二维码图片）
const handleFileUpload = async (file) => {
  const imageFile = file.raw
  if (!imageFile) return

  try {
    // 使用 @zxing/library 扫描上传的图片
    const reader = new BrowserMultiFormatReader()
    const imageUrl = URL.createObjectURL(imageFile)

    // 创建临时 img 元素
    const img = document.createElement('img')
    img.src = imageUrl

    img.onload = async () => {
      try {
        const result = await reader.decodeFromImageElement(img)
        console.log('图片扫码成功:', result.text)

        // 扫描成功，查询商品
        const res = await productApi.getByCode(result.text)
        if (res.data) {
          addProduct(res.data)
          ElMessage.success(`已添加：${res.data.name}`)
        } else {
          ElMessage.warning('未找到该商品')
        }

        // 清理
        URL.revokeObjectURL(imageUrl)
      } catch (err) {
        ElMessage.error('无法识别二维码，请确保图片清晰')
        console.error('图片扫码错误:', err)
        URL.revokeObjectURL(imageUrl)
      }
    }
  } catch (err) {
    ElMessage.error('图片加载失败')
    console.error('图片加载错误:', err)
  }
}

// 加载所有商品（点击搜索框时）
const loadAllProducts = async () => {
  if (allProducts.value.length > 0) {
    // 如果已经缓存了，直接使用
    productList.value = allProducts.value
    return
  }

  try {
    productLoading.value = true
    const res = await productApi.getPage({
      current: 1,
      size: 1000 // 获取所有商品
    })
    allProducts.value = res.data?.records || []
    productList.value = allProducts.value
  } catch (err) {
    ElMessage.error('加载商品列表失败')
  } finally {
    productLoading.value = false
  }
}

// 远程搜索商品（输入时模糊匹配）
const searchProductRemote = async (query) => {
  if (!query) {
    // 如果没有输入，显示所有商品
    productList.value = allProducts.value
    return
  }

  // 从缓存中模糊匹配
  productList.value = allProducts.value.filter(product =>
    product.name.toLowerCase().includes(query.toLowerCase())
  )
}

// 选择商品后添加到购物车
const handleProductSelect = async (productId) => {
  if (!productId) return

  const product = productList.value.find(p => p.id === productId)
  if (product) {
    addProduct(product)
    ElMessage.success(`已添加：${product.name}`)
    // 清空选择
    selectedProduct.value = null
  }
}

// 搜索商品（保留旧方法以防其他地方使用）
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
  // 打开对话框时加载所有客户
  loadAllCustomers()
}

// 加载所有客户（点击搜索框时）
const loadAllCustomers = async () => {
  if (allCustomers.value.length > 0) {
    // 如果已经缓存了，直接使用
    customerList.value = allCustomers.value
    return
  }

  try {
    customerLoading.value = true
    const res = await customerApi.getPage({
      current: 1,
      size: 1000 // 获取所有客户
    })
    allCustomers.value = res.data.records || []
    customerList.value = allCustomers.value
  } catch (err) {
    console.error('加载客户列表失败', err)
  } finally {
    customerLoading.value = false
  }
}

// 搜索客户（远程搜索）
const searchCustomers = async (query) => {
  if (!query) {
    loadAllCustomers()
    return
  }

  // 从缓存中模糊匹配
  if (allCustomers.value.length > 0) {
    customerList.value = allCustomers.value.filter(customer =>
      customer.name.toLowerCase().includes(query.toLowerCase())
    )
    return
  }

  // 如果缓存为空，从服务器搜索
  try {
    customerLoading.value = true
    const res = await customerApi.getPage({
      current: 1,
      size: 20,
      name: query
    })
    customerList.value = res.data.records || []
  } catch (err) {
    console.error('搜索客户失败', err)
  } finally {
    customerLoading.value = false
  }
}

// 客户选择变化
const handleCustomerChange = (customerName) => {
  // 查找选中的客户
  const customer = customerList.value.find(c => c.name === customerName)
  if (customer) {
    selectedCustomer.value = customer
    // 如果是月结客户，自动勾选月结并设置支付方式
    if (customer.isMonthly) {
      isMonthlyCustomer.value = true
      orderForm.value.paymentType = '月结'
    } else {
      isMonthlyCustomer.value = false
      if (orderForm.value.paymentType === '月结') {
        orderForm.value.paymentType = ''
      }
    }
  } else {
    selectedCustomer.value = null
    isMonthlyCustomer.value = false
  }
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

  // 验证客户是否存在
  if (!selectedCustomer.value || !selectedCustomer.value.id) {
    ElMessage.error('请从下拉列表中选择已存在的客户')
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
      customerId: selectedCustomer.value.id,
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
    selectedCustomer.value = null

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
  min-height: calc(100vh - 64px);
  padding: 0 0 120px 0;
}

/* 头部 - 现代简洁设计 */
.header {
  background: linear-gradient(135deg, var(--primary-color) 0%, #818cf8 100%);
  color: white;
  padding: 32px 24px;
  margin-bottom: 24px;
  box-shadow: var(--shadow-md);
}

.header h1 {
  margin: 0;
  font-size: 28px;
  font-weight: 700;
  text-align: center;
  letter-spacing: -0.5px;
}

/* 扫码区域 */
.scan-section {
  background: var(--bg-card);
  padding: 24px;
  border-radius: var(--radius-lg);
  margin: 0 24px 24px;
  box-shadow: var(--shadow-sm);
  transition: var(--transition-base);
}

.scan-section:hover {
  box-shadow: var(--shadow-md);
}

#video {
  width: 100% !important;
  min-height: 300px;
  border-radius: 8px;
  overflow: hidden;
  background-color: #000;
  display: block !important;
  object-fit: cover !important;
  margin-bottom: 16px;
}

/* 扫码提示文字 */
.scan-tip-text {
  text-align: center;
  padding: 20px;
}

.scan-tip-text p {
  font-size: 16px;
  color: var(--primary-color);
  margin: 0;
  font-weight: 500;
  animation: pulse 1.5s ease-in-out infinite;
}

@keyframes pulse {
  0%, 100% {
    opacity: 1;
  }
  50% {
    opacity: 0.6;
  }
}

.scan-btn {
  width: 100%;
  height: 60px;
  font-size: 20px;
  font-weight: bold;
  border-radius: 8px;
}

/* 上传区域 */
.upload-section {
  margin-top: 20px;
}

.upload-btn {
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

/* 移动端适配 */
@media (max-width: 768px) {
  /* 容器适配 */
  .scan-container {
    min-height: 100vh;
    padding: 0 0 100px 0;
  }

  /* 头部适配 */
  .header {
    padding: 24px 16px;
    margin-bottom: 16px;
  }

  .header h1 {
    font-size: 24px;
  }

  /* 扫码区域适配 */
  .scan-section {
    padding: 16px;
    margin: 0 12px 16px;
  }

  .scan-btn {
    height: 56px;
    font-size: 18px;
  }

  .upload-btn {
    height: 56px;
    font-size: 16px;
  }

  /* 购物车适配 */
  .cart-section {
    padding: 16px;
    margin: 0 12px 16px;
  }

  .cart-header h2 {
    font-size: 20px;
  }

  .cart-item {
    padding: 16px;
  }

  .item-name {
    font-size: 18px;
  }

  .item-price {
    font-size: 16px;
  }

  .item-actions .el-button {
    min-width: 44px;
    height: 44px;
    font-size: 16px;
  }

  /* 底部栏适配 */
  .bottom-bar {
    padding: 16px 12px;
  }

  .bottom-total .label {
    font-size: 16px;
  }

  .bottom-total .amount {
    font-size: 28px;
  }

  .checkout-btn {
    min-width: 120px;
    height: 56px;
    font-size: 20px;
  }

  /* 空购物车适配 */
  .empty-cart {
    padding: 40px 16px;
    margin: 0 12px;
  }

  .empty-cart p {
    font-size: 18px;
  }

  /* 对话框适配 */
  :deep(.el-dialog) {
    width: 95% !important;
    margin: 0 auto;
  }

  :deep(.el-dialog__title) {
    font-size: 20px;
  }

  :deep(.el-form-item__label) {
    font-size: 16px;
  }

  :deep(.el-input__inner) {
    font-size: 16px;
  }

  :deep(.el-radio-button__inner) {
    font-size: 16px;
    padding: 10px 16px;
  }

  :deep(.el-checkbox__label) {
    font-size: 16px;
  }

  .order-summary {
    padding: 16px;
  }

  .order-summary h3 {
    font-size: 18px;
  }

  .summary-item {
    font-size: 15px;
  }

  .summary-total {
    font-size: 18px;
  }

  .summary-total .total {
    font-size: 22px;
  }
}

/* 小屏手机适配 (iPhone SE 等) */
@media (max-width: 375px) {
  .header h1 {
    font-size: 20px;
  }

  .scan-btn,
  .upload-btn {
    height: 52px;
    font-size: 16px;
  }

  .bottom-total .amount {
    font-size: 24px;
  }

  .checkout-btn {
    min-width: 100px;
    height: 52px;
    font-size: 18px;
  }

  .item-actions .el-button {
    min-width: 40px;
    height: 40px;
    font-size: 14px;
  }
}
</style>
