<template>
  <div class="order-container">
    <!-- 搜索卡片 -->
    <el-card class="search-card" shadow="never">
      <el-form :inline="true" :model="searchForm" class="search-form">
        <el-form-item label="订单编号">
          <el-select
            v-model="searchForm.orderNo"
            filterable
            placeholder="请选择或输入订单编号"
            :loading="orderNoLoading"
            clearable
            style="width: 200px;"
            @focus="loadAllOrderNos"
          >
            <el-option
              v-for="orderNo in orderNoList"
              :key="orderNo"
              :label="orderNo"
              :value="orderNo"
            />
          </el-select>
        </el-form-item>
        <el-form-item label="客户姓名">
          <el-select
            v-model="searchForm.customerName"
            filterable
            placeholder="请选择或输入客户姓名"
            :loading="customerNameLoading"
            clearable
            style="width: 200px;"
            @focus="loadAllCustomerNames"
          >
            <el-option
              v-for="name in customerNameList"
              :key="name"
              :label="name"
              :value="name"
            />
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="loadData" icon="Search">查询</el-button>
          <el-button @click="handleReset" icon="Refresh">重置</el-button>
        </el-form-item>
      </el-form>
    </el-card>

    <!-- 数据卡片 -->
    <el-card class="table-card" shadow="never">
      <template #header>
        <div class="card-header">
          <div class="header-title">
            <el-icon class="title-icon"><Document /></el-icon>
            <span>订单列表</span>
          </div>
          <el-button type="primary" @click="handleAdd" icon="Plus">创建订单</el-button>
        </div>
      </template>

      <!-- 移动端卡片视图 -->
      <div class="mobile-card-view">
        <div v-for="item in formattedTableData" :key="item.id" class="order-card">
          <div class="order-card-header">
            <div class="order-no">{{ item.orderNo }}</div>
          </div>

          <div class="order-card-body">
            <div class="order-info-row">
              <span class="info-label">客户:</span>
              <span class="info-value">{{ item.customerName }}</span>
            </div>
            <div class="order-info-row">
              <span class="info-label">支付方式:</span>
              <el-tag :type="getPaymentTypeTag(item.paymentType)" size="small">
                {{ item.paymentType }}
              </el-tag>
            </div>
            <div class="order-info-row">
              <span class="info-label">创建时间:</span>
              <span class="info-value">{{ item.createTime }}</span>
            </div>
            <div class="order-info-row amount-row">
              <span class="info-label">订单金额:</span>
              <span class="amount-text">¥{{ item.totalAmount?.toFixed(2) || '0.00' }}</span>
            </div>
          </div>

          <div class="order-card-actions">
            <el-button type="primary" size="small" @click="handleView(item)" icon="View">查看详情</el-button>
            <el-button type="danger" size="small" @click="handleDelete(item)" icon="Delete">删除</el-button>
          </div>
        </div>
      </div>

      <!-- PC端表格视图 -->
      <el-table :data="formattedTableData" class="modern-table desktop-table-view">
        <el-table-column prop="orderNo" label="订单编号" width="200" show-overflow-tooltip />
        <el-table-column prop="customerName" label="客户姓名" width="150" />
        <el-table-column prop="totalAmount" label="订单金额" width="150" align="right">
          <template #default="{ row }">
            <span class="amount-text">¥{{ row.totalAmount?.toFixed(2) || '0.00' }}</span>
          </template>
        </el-table-column>
        <el-table-column prop="paymentType" label="支付方式" width="120" align="center">
          <template #default="{ row }">
            <el-tag :type="getPaymentTypeTag(row.paymentType)" size="small">
              {{ row.paymentType }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="createTime" label="创建时间" width="180" align="center" />
        <el-table-column label="操作" width="200" fixed="right" align="center">
          <template #default="{ row }">
            <div class="action-buttons">
              <el-button type="primary" size="small" @click="handleView(row)" icon="View">详情</el-button>
              <el-button type="danger" size="small" @click="handleDelete(row)" icon="Delete">删除</el-button>
            </div>
          </template>
        </el-table-column>
      </el-table>

      <div class="pagination-container">
        <el-pagination
          v-model:current-page="pagination.current"
          v-model:page-size="pagination.size"
          :total="pagination.total"
          :page-sizes="[10, 20, 50, 100]"
          layout="total, sizes, prev, pager, next, jumper"
          @current-change="loadData"
          @size-change="loadData"
          background
        />
      </div>
    </el-card>

    <!-- 创建订单对话框 -->
    <el-dialog v-model="dialogVisible" title="创建订单" width="800px" class="modern-dialog" lock-scroll>
      <el-form ref="formRef" :model="form" :rules="formRules" label-width="100px" class="modern-form">
        <el-form-item label="客户姓名" prop="customerName">
          <el-input v-model="form.customerName" placeholder="请输入客户姓名" />
        </el-form-item>
        <el-form-item label="支付方式">
          <el-select v-model="form.paymentType" placeholder="请选择支付方式" style="width: 100%;">
            <el-option label="现金" value="现金" />
            <el-option label="微信" value="微信" />
            <el-option label="支付宝" value="支付宝" />
            <el-option label="月结" value="月结" />
          </el-select>
        </el-form-item>
        <el-form-item label="备注">
          <el-input v-model="form.remark" type="textarea" :rows="3" placeholder="请输入备注信息" />
        </el-form-item>

        <el-divider content-position="left">
          <span style="font-weight: 600; color: var(--text-main);">商品明细</span>
        </el-divider>

        <el-button type="primary" size="small" @click="handleAddItem" icon="Plus" style="margin-bottom: 16px;">
          添加商品
        </el-button>

        <el-table :data="form.items" border class="items-table">
          <el-table-column type="index" label="序号" width="60" align="center" />
          <el-table-column label="商品编码" min-width="180">
            <template #default="{ row }">
              <el-input v-model="row.productCode" placeholder="扫码或输入商品编码" />
            </template>
          </el-table-column>
          <el-table-column label="数量" width="150">
            <template #default="{ row }">
              <el-input-number v-model="row.quantity" :min="1" :step="1" style="width: 100%;" />
            </template>
          </el-table-column>
          <el-table-column label="操作" width="100" align="center">
            <template #default="{ $index }">
              <el-button type="danger" size="small" @click="handleRemoveItem($index)" icon="Delete">
                删除
              </el-button>
            </template>
          </el-table-column>
        </el-table>
      </el-form>
      <template #footer>
        <div class="dialog-footer">
          <el-button @click="dialogVisible = false" size="large">取消</el-button>
          <el-button type="primary" @click="handleSubmit" size="large" icon="Check">确定</el-button>
        </div>
      </template>
    </el-dialog>

    <!-- 订单详情对话框 -->
    <el-dialog v-model="detailVisible" title="订单详情" width="900px" class="modern-dialog detail-dialog" lock-scroll>
      <div class="order-detail" v-if="currentOrder">
        <!-- 基本信息 -->
        <div class="detail-section">
          <h3 class="section-title">
            <el-icon><InfoFilled /></el-icon>
            <span>基本信息</span>
          </h3>
          <div class="info-grid">
            <div class="info-item">
              <span class="label">订单编号:</span>
              <span class="value order-no">{{ currentOrder.order?.orderNo }}</span>
            </div>
            <div class="info-item">
              <span class="label">客户姓名:</span>
              <span class="value">{{ currentOrder.order?.customerName }}</span>
            </div>
            <div class="info-item">
              <span class="label">订单金额:</span>
              <span class="value amount-highlight">¥{{ currentOrder.order?.totalAmount?.toFixed(2) }}</span>
            </div>
            <div class="info-item">
              <span class="label">支付方式:</span>
              <el-tag :type="getPaymentTypeTag(currentOrder.order?.paymentType)" size="small">
                {{ currentOrder.order?.paymentType }}
              </el-tag>
            </div>
            <div class="info-item">
              <span class="label">创建时间:</span>
              <span class="value">{{ currentOrder.order?.createTime }}</span>
            </div>
            <div class="info-item" v-if="currentOrder.order?.updateTime">
              <span class="label">更新时间:</span>
              <span class="value">{{ currentOrder.order?.updateTime }}</span>
            </div>
          </div>
          <div class="info-item full-width" v-if="currentOrder.order?.remark">
            <span class="label">备注:</span>
            <span class="value remark-text">{{ currentOrder.order?.remark }}</span>
          </div>
        </div>

        <!-- 商品明细 -->
        <div class="detail-section">
          <h3 class="section-title">
            <el-icon><Goods /></el-icon>
            <span>商品明细</span>
          </h3>
          <el-table :data="currentOrder.items" border class="detail-table">
            <el-table-column type="index" label="序号" width="60" align="center" />
            <el-table-column prop="productName" label="商品名称" min-width="150" show-overflow-tooltip />
            <el-table-column prop="productCode" label="商品编码" width="140" align="center" />
            <el-table-column prop="productSpec" label="规格" width="100" align="center" />
            <el-table-column prop="unit" label="单位" width="80" align="center" />
            <el-table-column prop="price" label="单价" width="100" align="right">
              <template #default="{ row }">
                <span class="price-text">¥{{ row.price?.toFixed(2) }}</span>
              </template>
            </el-table-column>
            <el-table-column prop="quantity" label="数量" width="80" align="center" />
            <el-table-column prop="subtotal" label="小计" width="120" align="right">
              <template #default="{ row }">
                <span class="subtotal-text">¥{{ row.subtotal?.toFixed(2) }}</span>
              </template>
            </el-table-column>
          </el-table>

          <!-- 合计 -->
          <div class="order-summary">
            <div class="summary-row">
              <span class="summary-label">商品总数:</span>
              <span class="summary-value">{{ getTotalQuantity() }} 件</span>
            </div>
            <div class="summary-row total-row">
              <span class="summary-label">订单总额:</span>
              <span class="summary-value total-amount">¥{{ currentOrder.order?.totalAmount?.toFixed(2) }}</span>
            </div>
          </div>
        </div>
      </div>
      <template #footer>
        <div class="dialog-footer">
          <el-button @click="detailVisible = false" size="large">关闭</el-button>
        </div>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted, computed } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { orderApi } from '@/api/order'
import { customerApi } from '@/api/index'
import { formatDateTime } from '@/utils/format'

// 表单引用
const formRef = ref(null)

// 表单验证规则
const formRules = {
  customerName: [
    { required: true, message: '请输入客户姓名', trigger: 'blur' }
  ]
}

const searchForm = reactive({
  orderNo: '',
  customerName: ''
})

// 搜索下拉列表
const orderNoList = ref([])
const customerNameList = ref([])
const orderNoLoading = ref(false)
const customerNameLoading = ref(false)
const allOrderNos = ref([]) // 缓存所有订单编号
const allCustomerNames = ref([]) // 缓存所有客户姓名

const tableData = ref([])
const pagination = reactive({ current: 1, size: 10, total: 0 })
const dialogVisible = ref(false)
const detailVisible = ref(false)
const currentOrder = ref(null)
const form = reactive({
  customerName: '',
  paymentType: '',
  remark: '',
  items: []
})

// 格式化表格数据中的时间
const formattedTableData = computed(() => {
  return tableData.value.map(item => ({
    ...item,
    createTime: formatDateTime(item.createTime),
    updateTime: formatDateTime(item.updateTime)
  }))
})

const loadData = async () => {
  // 去除空格，确保参数正确传递
  const params = {
    current: pagination.current,
    size: pagination.size
  }

  // 只有非空值才添加到参数中
  if (searchForm.orderNo && searchForm.orderNo.trim()) {
    params.orderNo = searchForm.orderNo.trim()
  }
  if (searchForm.customerName && searchForm.customerName.trim()) {
    params.customerName = searchForm.customerName.trim()
  }

  const res = await orderApi.getPage(params)
  tableData.value = res.data.records
  pagination.total = res.data.total
}

// 加载所有订单编号（点击搜索框时）
const loadAllOrderNos = async () => {
  if (allOrderNos.value.length > 0) {
    orderNoList.value = allOrderNos.value
    return
  }

  try {
    orderNoLoading.value = true
    const res = await orderApi.getPage({
      current: 1,
      size: 1000
    })
    allOrderNos.value = res.data.records.map(item => item.orderNo)
    orderNoList.value = allOrderNos.value
  } catch (err) {
    console.error('加载订单编号失败', err)
  } finally {
    orderNoLoading.value = false
  }
}

// 搜索订单编号
const searchOrderNo = async (query) => {
  if (!query) {
    orderNoList.value = allOrderNos.value
    return
  }

  // 从缓存中模糊匹配
  orderNoList.value = allOrderNos.value.filter(orderNo =>
    orderNo.toLowerCase().includes(query.toLowerCase())
  )
}

// 加载所有客户姓名（点击搜索框时）
const loadAllCustomerNames = async () => {
  if (allCustomerNames.value.length > 0) {
    customerNameList.value = allCustomerNames.value
    return
  }

  try {
    customerNameLoading.value = true
    const res = await customerApi.getPage({
      current: 1,
      size: 1000
    })
    allCustomerNames.value = res.data.records.map(item => item.name)
    customerNameList.value = allCustomerNames.value
  } catch (err) {
    console.error('加载客户姓名失败', err)
  } finally {
    customerNameLoading.value = false
  }
}

// 搜索客户姓名
const searchCustomerName = async (query) => {
  if (!query) {
    customerNameList.value = allCustomerNames.value
    return
  }

  // 从缓存中模糊匹配
  customerNameList.value = allCustomerNames.value.filter(name =>
    name.toLowerCase().includes(query.toLowerCase())
  )
}

const handleReset = () => {
  searchForm.orderNo = ''
  searchForm.customerName = ''
  loadData()
}

const handleAdd = () => {
  Object.assign(form, {
    customerName: '',
    paymentType: '',
    remark: '',
    items: []
  })
  dialogVisible.value = true
}

const handleAddItem = () => {
  form.items.push({
    productCode: '',
    quantity: 1
  })
}

const handleRemoveItem = (index) => {
  form.items.splice(index, 1)
}

const handleSubmit = async () => {
  // 验证表单
  if (!formRef.value) return

  try {
    await formRef.value.validate()
  } catch (error) {
    ElMessage.warning('请填写必填字段')
    return
  }

  if (!form.paymentType) {
    ElMessage.warning('请选择支付方式')
    return
  }
  if (form.items.length === 0) {
    ElMessage.warning('请至少添加一个商品')
    return
  }

  // 验证商品明细
  for (let i = 0; i < form.items.length; i++) {
    const item = form.items[i]
    if (!item.productCode) {
      ElMessage.warning(`第 ${i + 1} 行商品编码不能为空`)
      return
    }
    if (!item.quantity || item.quantity <= 0) {
      ElMessage.warning(`第 ${i + 1} 行商品数量必须大于0`)
      return
    }
  }

  await orderApi.create(form)
  ElMessage.success('创建成功')
  dialogVisible.value = false
  await loadData()
}

const handleView = async (row) => {
  try {
    const res = await orderApi.getById(row.id)
    // 格式化时间
    if (res.data.order) {
      res.data.order.createTime = formatDateTime(res.data.order.createTime)
      res.data.order.updateTime = formatDateTime(res.data.order.updateTime)
    }
    currentOrder.value = res.data
    detailVisible.value = true
  } catch (err) {
    ElMessage.error('获取订单详情失败')
  }
}

const getTotalQuantity = () => {
  if (!currentOrder.value?.items) return 0
  return currentOrder.value.items.reduce((sum, item) => sum + item.quantity, 0)
}

const handleDelete = (row) => {
  ElMessageBox.confirm('确定删除该订单吗？', '提示', {
    confirmButtonText: '确定',
    cancelButtonText: '取消',
    type: 'warning'
  }).then(async () => {
    await orderApi.delete(row.id)
    ElMessage.success('删除成功')
    await loadData()
  })
}

const getPaymentTypeTag = (type) => {
  const map = {
    '现金': 'success',
    '微信': 'success',
    '支付宝': 'primary',
    '月结': 'warning'
  }
  return map[type] || 'info'
}

onMounted(() => {
  loadData()
})
</script>

<style scoped>
.order-container {
  padding: 0;
}

/* 搜索卡片 */
.search-card {
  margin-bottom: 16px;
  border: 1px solid var(--border-color);
  transition: var(--transition-base);
}

.search-card:hover {
  box-shadow: var(--shadow-md);
}

.search-form {
  margin: 0;
}

.search-form :deep(.el-form-item) {
  margin-bottom: 0;
}

/* 表格卡片 */
.table-card {
  border: 1px solid var(--border-color);
  transition: var(--transition-base);
}

.table-card:hover {
  box-shadow: var(--shadow-md);
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.header-title {
  display: flex;
  align-items: center;
  gap: 12px;
  font-size: 18px;
  font-weight: 600;
  color: var(--text-main);
}

.title-icon {
  font-size: 20px;
  color: var(--primary-color);
}

/* 现代化表格样式 */
.modern-table {
  border-radius: var(--radius-md);
  overflow: hidden;
}

.modern-table :deep(.el-table__header-wrapper) {
  background-color: var(--bg-color);
}

.modern-table :deep(.el-table__header th) {
  background-color: var(--bg-color);
  color: var(--text-secondary);
  font-weight: 600;
  font-size: 14px;
  border-bottom: 2px solid var(--border-color);
}

.modern-table :deep(.el-table__row) {
  transition: var(--transition-base);
}

.modern-table :deep(.el-table__row:hover) {
  background-color: var(--primary-light) !important;
  box-shadow: 0 2px 8px rgba(79, 70, 229, 0.1);
}

.modern-table :deep(.el-table__body td) {
  border-bottom: 1px solid var(--border-color);
  padding: 16px 0;
}

/* 金额样式 */
.amount-text {
  color: var(--primary-color);
  font-weight: 600;
  font-size: 15px;
}

/* 操作按钮 */
.action-buttons {
  display: flex;
  gap: 8px;
  justify-content: center;
}

.action-buttons .el-button {
  margin: 0;
}

/* 分页容器 */
.pagination-container {
  margin-top: 24px;
  display: flex;
  justify-content: center;
}

/* 对话框样式 */
.modern-dialog :deep(.el-dialog__header) {
  border-bottom: 1px solid var(--border-color);
  padding: 20px 24px;
  background-color: var(--bg-color);
}

.modern-dialog :deep(.el-dialog__title) {
  font-size: 18px;
  font-weight: 600;
  color: var(--text-main);
}

.modern-dialog :deep(.el-dialog__body) {
  padding: 24px;
}

.modern-form :deep(.el-form-item__label) {
  font-weight: 500;
  color: var(--text-secondary);
}

.dialog-footer {
  display: flex;
  justify-content: flex-end;
  gap: 12px;
}

/* 商品明细表格 */
.items-table {
  border-radius: var(--radius-md);
  overflow: hidden;
}

.items-table :deep(.el-table__header th) {
  background-color: var(--bg-color);
  font-weight: 600;
}

/* 订单详情样式 */
.order-detail {
  padding: 8px;
}

.detail-section {
  margin-bottom: 32px;
}

.detail-section:last-child {
  margin-bottom: 0;
}

.section-title {
  margin: 0 0 20px 0;
  padding: 12px 16px;
  font-size: 16px;
  font-weight: 600;
  color: var(--text-main);
  background: linear-gradient(135deg, var(--primary-light), #f0f0ff);
  border-left: 4px solid var(--primary-color);
  border-radius: 4px;
  display: flex;
  align-items: center;
  gap: 8px;
}

.section-title .el-icon {
  font-size: 18px;
  color: var(--primary-color);
}

.info-grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 16px 24px;
  padding: 16px;
  background: var(--bg-color);
  border-radius: var(--radius-md);
}

.info-item {
  display: flex;
  align-items: center;
  gap: 8px;
}

.info-item.full-width {
  grid-column: 1 / -1;
  padding-top: 12px;
  border-top: 1px dashed var(--border-color);
}

.info-item .label {
  color: var(--text-secondary);
  font-size: 14px;
  min-width: 80px;
  font-weight: 500;
}

.info-item .value {
  color: var(--text-main);
  font-size: 14px;
  font-weight: 500;
}

.info-item .order-no {
  font-family: 'Courier New', monospace;
  color: var(--primary-color);
  font-weight: 600;
}

.info-item .remark-text {
  color: var(--text-secondary);
  font-style: italic;
}

.amount-highlight {
  color: var(--primary-color);
  font-size: 18px;
  font-weight: 700;
}

/* 商品明细表格 */
.detail-table {
  border-radius: var(--radius-md);
  overflow: hidden;
}

.detail-table :deep(.el-table__header th) {
  background-color: var(--bg-color);
  font-weight: 600;
  color: var(--text-secondary);
}

.detail-table :deep(.el-table__body td) {
  padding: 12px 0;
}

.price-text {
  color: var(--text-main);
  font-weight: 500;
}

.subtotal-text {
  color: var(--primary-color);
  font-weight: 600;
  font-size: 15px;
}

/* 订单汇总 */
.order-summary {
  margin-top: 16px;
  padding: 16px 20px;
  background: linear-gradient(135deg, #f8f9ff, #f0f0ff);
  border-radius: var(--radius-md);
  border: 1px solid var(--primary-color);
}

.summary-row {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 8px 0;
}

.summary-row.total-row {
  margin-top: 8px;
  padding-top: 12px;
  border-top: 2px solid var(--primary-color);
}

.summary-label {
  font-size: 15px;
  color: var(--text-secondary);
  font-weight: 500;
}

.summary-value {
  font-size: 15px;
  color: var(--text-main);
  font-weight: 600;
}

.total-row .summary-label {
  font-size: 16px;
  color: var(--text-main);
  font-weight: 600;
}

.total-row .total-amount {
  font-size: 22px;
  color: var(--primary-color);
  font-weight: 700;
}

/* 移动端卡片视图 */
.mobile-card-view {
  display: none;
}

.order-card {
  background: white;
  border-radius: var(--radius-md);
  padding: 16px;
  margin-bottom: 12px;
  box-shadow: var(--shadow-sm);
  transition: var(--transition-base);
}

.order-card:hover {
  box-shadow: var(--shadow-md);
  transform: translateY(-2px);
}

.order-card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 12px;
  padding-bottom: 12px;
  border-bottom: 1px solid var(--border-color);
}

.order-card-header .order-no {
  font-size: 15px;
  font-weight: 600;
  color: var(--text-main);
  flex: 1;
  margin-right: 12px;
}

.order-card-body {
  margin-bottom: 12px;
}

.order-info-row {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 8px 0;
  font-size: 14px;
}

.order-info-row .info-label {
  color: var(--text-secondary);
  font-weight: 500;
}

.order-info-row .info-value {
  color: var(--text-main);
}

.amount-row {
  border-top: 1px dashed var(--border-color);
  margin-top: 8px;
  padding-top: 12px;
}

.amount-row .amount-text {
  font-size: 18px;
  font-weight: 600;
  color: var(--primary-color);
}

.order-card-actions {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 8px;
}

.order-card-actions .el-button {
  width: 100%;
}

/* 响应式布局 */
@media (max-width: 768px) {
  .desktop-table-view {
    display: none !important;
  }

  .mobile-card-view {
    display: block;
  }

  .search-form {
    display: flex;
    flex-direction: column;
  }

  .search-form :deep(.el-form-item) {
    width: 100%;
    margin-bottom: 12px;
  }

  .card-header {
    flex-direction: column;
    gap: 12px;
    align-items: stretch;
  }

  .card-header .el-button {
    width: 100%;
  }

  .pagination-container :deep(.el-pagination) {
    justify-content: center;
  }

  .pagination-container :deep(.el-pagination__sizes),
  .pagination-container :deep(.el-pagination__jump) {
    display: none;
  }

  /* 订单详情对话框移动端适配 */
  .detail-dialog :deep(.el-dialog) {
    width: 95% !important;
    margin: 5vh auto;
  }

  .detail-dialog :deep(.el-dialog__body) {
    padding: 16px;
    max-height: 70vh;
    overflow-y: auto;
  }

  .order-detail {
    padding: 0;
  }

  .detail-section {
    margin-bottom: 24px;
  }

  .section-title {
    font-size: 15px;
    padding: 10px 12px;
    margin-bottom: 16px;
  }

  .section-title .el-icon {
    font-size: 16px;
  }

  .info-grid {
    grid-template-columns: 1fr;
    gap: 12px;
    padding: 12px;
  }

  .info-item {
    flex-direction: column;
    align-items: flex-start;
    gap: 4px;
  }

  .info-item .label {
    font-size: 13px;
    min-width: auto;
  }

  .info-item .value {
    font-size: 14px;
    font-weight: 600;
  }

  .info-item.full-width {
    padding-top: 8px;
  }

  .amount-highlight {
    font-size: 20px;
  }

  /* 商品明细表格移动端优化 */
  .detail-table {
    font-size: 13px;
  }

  .detail-table :deep(.el-table__header th) {
    padding: 8px 0;
    font-size: 13px;
  }

  .detail-table :deep(.el-table__body td) {
    padding: 8px 0;
    font-size: 13px;
  }

  /* 隐藏部分列以适应小屏幕 */
  .detail-table :deep(.el-table__body-wrapper) {
    overflow-x: auto;
  }

  .price-text,
  .subtotal-text {
    font-size: 13px;
  }

  /* 订单汇总移动端优化 */
  .order-summary {
    padding: 12px 16px;
    margin-top: 12px;
  }

  .summary-row {
    padding: 6px 0;
  }

  .summary-label {
    font-size: 14px;
  }

  .summary-value {
    font-size: 14px;
  }

  .total-row .summary-label {
    font-size: 15px;
  }

  .total-row .total-amount {
    font-size: 20px;
  }
}
</style>
