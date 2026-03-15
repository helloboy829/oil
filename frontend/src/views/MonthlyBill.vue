<template>
  <div class="monthly-bill-container">
    <el-card>
      <template #header>
        <div class="card-header">
          <div class="header-title">
            <el-icon class="title-icon"><Document /></el-icon>
            <span>月结账单</span>
          </div>
          <div class="header-actions">
            <el-button
              v-if="selectedRows.length > 0"
              type="danger"
              @click="handleBatchDelete"
              icon="Delete"
            >
              批量删除 ({{ selectedRows.length }})
            </el-button>
            <el-button type="primary" @click="handleGenerate" icon="Plus">生成账单</el-button>
          </div>
        </div>
      </template>

      <!-- 移动端卡片视图 -->
      <div class="mobile-card-view">
        <div v-for="item in formattedTableData" :key="item.id" class="bill-card">
          <div class="bill-card-header">
            <div class="bill-no">{{ item.billNo }}</div>
          </div>

          <div class="bill-card-body">
            <div class="bill-info-row">
              <span class="info-label">客户姓名:</span>
              <span class="info-value">{{ item.customerName }}</span>
            </div>
            <div class="bill-info-row">
              <span class="info-label">账单月份:</span>
              <span class="info-value">{{ item.billMonth }}</span>
            </div>
            <div class="bill-info-row">
              <span class="info-label">生成时间:</span>
              <span class="info-value">{{ item.createTime }}</span>
            </div>
            <div class="bill-info-row amount-row">
              <span class="info-label">账单金额:</span>
              <span class="amount-text">¥{{ item.totalAmount?.toFixed(2) || '0.00' }}</span>
            </div>
            <div class="bill-info-row">
              <span class="info-label">已支付:</span>
              <span class="paid-text">¥{{ item.paidAmount?.toFixed(2) || '0.00' }}</span>
            </div>
            <div class="bill-info-row">
              <span class="info-label">结算状态:</span>
              <el-button
                v-if="item.status === '未结清'"
                type="warning"
                size="small"
                @click="handleSettle(item)"
                plain
              >
                未结算
              </el-button>
              <el-button
                v-else
                type="success"
                size="small"
                @click="handleSettle(item)"
                plain
              >
                已结算
              </el-button>
            </div>
          </div>

          <div class="bill-card-actions">
            <el-button type="primary" size="small" @click="handleView(item)" icon="View">预览</el-button>
            <el-button type="success" size="small" @click="handleExport(item)" icon="Download">导出Excel</el-button>
            <el-button type="danger" size="small" @click="handleDelete(item)" icon="Delete">删除</el-button>
          </div>
        </div>
      </div>

      <!-- PC端表格视图 -->
      <el-table :data="formattedTableData" border stripe class="desktop-table-view" @selection-change="handleSelectionChange">
        <el-table-column type="selection" width="55" align="center" />
        <el-table-column prop="billNo" label="账单编号" width="180" />
        <el-table-column prop="customerName" label="客户姓名" width="110" />
        <el-table-column prop="billMonth" label="账单月份" width="100" />
        <el-table-column prop="createTime" label="生成时间" width="150" />
        <el-table-column prop="totalAmount" label="账单金额" width="110">
          <template #default="{ row }">
            <span style="color: #409eff; font-weight: 600;">¥{{ row.totalAmount?.toFixed(2) || '0.00' }}</span>
          </template>
        </el-table-column>
        <el-table-column prop="paidAmount" label="已支付" width="110">
          <template #default="{ row }">
            <span style="color: #67c23a; font-weight: 600;">¥{{ row.paidAmount?.toFixed(2) || '0.00' }}</span>
          </template>
        </el-table-column>
        <el-table-column label="结算状态" width="110" align="center">
          <template #default="{ row }">
            <el-button
              v-if="row.status === '未结清'"
              type="warning"
              size="small"
              @click="handleSettle(row)"
              plain
            >
              未结算
            </el-button>
            <el-button
              v-else
              type="success"
              size="small"
              @click="handleSettle(row)"
              plain
            >
              已结算
            </el-button>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="260" align="center">
          <template #default="{ row }">
            <el-button type="primary" size="small" @click="handleView(row)" icon="View">
              预览
            </el-button>
            <el-button type="success" size="small" @click="handleExport(row)" icon="Download">
              导出
            </el-button>
            <el-button type="danger" size="small" @click="handleDelete(row)" icon="Delete">
              删除
            </el-button>
          </template>
        </el-table-column>
      </el-table>

      <el-pagination
        v-model:current-page="pagination.current"
        v-model:page-size="pagination.size"
        :total="pagination.total"
        layout="total, prev, pager, next"
        @current-change="loadData"
        style="margin-top: 20px; justify-content: center;"
      />
    </el-card>

    <!-- 生成账单对话框 -->
    <el-dialog v-model="dialogVisible" title="生成月结账单" width="500px" lock-scroll>
      <el-form ref="formRef" :model="form" :rules="formRules" label-width="100px">
        <el-form-item label="客户" prop="customerId">
          <el-select v-model="form.customerId" placeholder="请选择客户" style="width: 100%;">
            <el-option
              v-for="item in customers"
              :key="item.id"
              :label="item.name"
              :value="item.id"
            >
              <div style="display: flex; justify-content: space-between; align-items: center;">
                <span>{{ item.name }}</span>
                <el-tag v-if="item.isMonthly" type="success" size="small" style="margin-left: 8px;">月结</el-tag>
              </div>
            </el-option>
          </el-select>
        </el-form-item>
        <el-form-item label="账单月份" prop="billMonth">
          <el-date-picker
            v-model="form.billMonth"
            type="month"
            placeholder="选择月份"
            format="YYYY年MM月"
            value-format="YYYY-MM"
            :disabled-date="disabledDate"
            style="width: 100%;"
          />
        </el-form-item>
        <el-form-item label="商品类别">
          <el-checkbox-group v-model="form.categoryIds">
            <el-checkbox
              v-for="category in categoryList"
              :key="category.id"
              :label="category.id"
            >
              {{ category.name }}
            </el-checkbox>
          </el-checkbox-group>
          <div style="font-size: 12px; color: #999; margin-top: 4px;">
            不选择表示统计所有类别
          </div>
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" @click="handleSubmit">确定</el-button>
      </template>
    </el-dialog>

    <!-- 账单预览对话框 -->
    <el-dialog v-model="detailVisible" title="账单预览" width="900px" class="modern-dialog detail-dialog" lock-scroll>
      <div class="bill-detail" v-if="currentBill">
        <!-- 基本信息 -->
        <div class="detail-section">
          <h3 class="section-title">
            <el-icon><InfoFilled /></el-icon>
            <span>账单信息</span>
          </h3>
          <div class="info-grid">
            <div class="info-item">
              <span class="label">账单编号:</span>
              <span class="value bill-no">{{ currentBill.bill?.billNo }}</span>
            </div>
            <div class="info-item">
              <span class="label">客户姓名:</span>
              <span class="value">{{ currentBill.bill?.customerName }}</span>
            </div>
            <div class="info-item">
              <span class="label">账单月份:</span>
              <span class="value">{{ currentBill.bill?.billMonth }}</span>
            </div>
            <div class="info-item">
              <span class="label">账单金额:</span>
              <span class="value amount-highlight">¥{{ currentBill.bill?.totalAmount?.toFixed(2) }}</span>
            </div>
            <div class="info-item">
              <span class="label">已付金额:</span>
              <span class="value paid-text">¥{{ currentBill.bill?.paidAmount?.toFixed(2) }}</span>
            </div>
            <div class="info-item">
              <span class="label">账单状态:</span>
              <el-tag :type="currentBill.bill?.status === '已结清' ? 'success' : 'warning'" size="small">
                {{ currentBill.bill?.status }}
              </el-tag>
            </div>
            <div class="info-item">
              <span class="label">生成时间:</span>
              <span class="value">{{ currentBill.bill?.createTime }}</span>
            </div>
          </div>
        </div>

        <!-- 商品明细 -->
        <div class="detail-section">
          <h3 class="section-title">
            <el-icon><Goods /></el-icon>
            <span>商品明细</span>
          </h3>
          <el-table :data="currentBill.items" border class="detail-table">
            <el-table-column type="index" label="序号" width="60" align="center" />
            <el-table-column prop="orderDate" label="日期" width="110" align="center" />
            <el-table-column prop="productName" label="品名" min-width="150" show-overflow-tooltip />
            <el-table-column prop="productSpec" label="规格" width="100" align="center" />
            <el-table-column prop="unit" label="单位" width="80" align="center" />
            <el-table-column prop="quantity" label="数量" width="80" align="center" />
            <el-table-column prop="price" label="单价" width="100" align="right">
              <template #default="{ row }">
                <span class="price-text">¥{{ row.price?.toFixed(2) }}</span>
              </template>
            </el-table-column>
            <el-table-column prop="subtotal" label="金额" width="120" align="right">
              <template #default="{ row }">
                <span class="subtotal-text">¥{{ row.subtotal?.toFixed(2) }}</span>
              </template>
            </el-table-column>
          </el-table>

          <!-- 合计 -->
          <div class="bill-summary">
            <div class="summary-row">
              <span class="summary-label">商品总数:</span>
              <span class="summary-value">{{ getTotalQuantity() }} 件</span>
            </div>
            <div class="summary-row total-row">
              <span class="summary-label">账单总额:</span>
              <span class="summary-value total-amount">¥{{ currentBill.bill?.totalAmount?.toFixed(2) }}</span>
            </div>
          </div>
        </div>
      </div>
      <template #footer>
        <div class="dialog-footer">
          <el-button @click="detailVisible = false" size="large">关闭</el-button>
          <el-button type="success" @click="handleExport(currentBill.bill)" size="large" icon="Download">导出Excel</el-button>
        </div>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted, computed } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { monthlyBillApi } from '@/api/order'
import { customerApi, categoryApi } from '@/api/index'
import { formatDateTime } from '@/utils/format'

// 表单引用
const formRef = ref(null)

// 表单验证规则
const formRules = {
  customerId: [
    { required: true, message: '请选择客户', trigger: 'change' }
  ],
  billMonth: [
    { required: true, message: '请选择账单月份', trigger: 'change' }
  ]
}

const tableData = ref([])
const pagination = reactive({ current: 1, size: 10, total: 0 })
const dialogVisible = ref(false)
const detailVisible = ref(false)
const currentBill = ref(null)
const customers = ref([])
const selectedRows = ref([])
const categoryList = ref([])
const form = reactive({
  customerId: null,
  billMonth: '',
  categoryIds: []
})

// 格式化表格数据中的时间
const formattedTableData = computed(() => {
  return tableData.value.map(item => ({
    ...item,
    createTime: formatDateTime(item.createTime)
  }))
})

const loadData = async () => {
  const res = await monthlyBillApi.getPage({
    current: pagination.current,
    size: pagination.size
  })
  tableData.value = res.data.records
  pagination.total = res.data.total
}

const loadCustomers = async () => {
  // 加载所有客户（不仅限于月结客户）
  const res = await customerApi.getPage({
    current: 1,
    size: 1000  // 加载所有客户
  })
  customers.value = res.data.records
}

const loadCategories = async () => {
  try {
    const res = await categoryApi.getList()
    categoryList.value = res.data
  } catch (err) {
    console.error('加载分类列表失败', err)
  }
}

const handleGenerate = () => {
  Object.assign(form, { customerId: null, billMonth: '', categoryIds: [] })
  dialogVisible.value = true
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

  await monthlyBillApi.generate({
    customerId: form.customerId,
    billMonth: form.billMonth,
    categoryIds: form.categoryIds.length > 0 ? form.categoryIds : null
  })
  ElMessage.success('生成成功')
  dialogVisible.value = false
  await loadData()
}

const handleExport = (row) => {
  window.open(monthlyBillApi.export(row.id))
}

const handleView = async (row) => {
  try {
    const res = await monthlyBillApi.getById(row.id)
    // 格式化时间
    if (res.data.bill) {
      res.data.bill.createTime = formatDateTime(res.data.bill.createTime)
      res.data.bill.updateTime = formatDateTime(res.data.bill.updateTime)
    }
    currentBill.value = res.data
    detailVisible.value = true
  } catch (err) {
    ElMessage.error('获取账单详情失败')
  }
}

const getTotalQuantity = () => {
  if (!currentBill.value?.items) return 0
  return currentBill.value.items.reduce((sum, item) => sum + item.quantity, 0)
}

const handleSettle = async (row) => {
  const isSettled = row.status === '已结清'
  const confirmText = isSettled ? '确定取消结算此账单吗？' : '确定将此账单标记为已结清吗？'
  const actionText = isSettled ? '取消结算' : '结算'

  try {
    await ElMessageBox.confirm(confirmText, '提示', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    })

    await monthlyBillApi.settle(row.id)
    ElMessage.success(`${actionText}成功`)
    await loadData()
  } catch (error) {
    if (error !== 'cancel') {
      ElMessage.error(`${actionText}失败：` + (error.response?.data?.message || error.message || '未知错误'))
    }
  }
}

const handleSelectionChange = (selection) => {
  selectedRows.value = selection
}

const handleBatchDelete = () => {
  if (selectedRows.value.length === 0) {
    ElMessage.warning('请先选择要删除的账单')
    return
  }

  ElMessageBox.confirm(`确定删除选中的 ${selectedRows.value.length} 个账单吗？`, '提示', {
    confirmButtonText: '确定',
    cancelButtonText: '取消',
    type: 'warning'
  }).then(async () => {
    const ids = selectedRows.value.map(row => row.id)
    await monthlyBillApi.deleteBatch(ids)
    ElMessage.success('批量删除成功')
    selectedRows.value = []
    await loadData()
  }).catch(() => {
    // 用户取消删除
  })
}

const handleDelete = (row) => {
  ElMessageBox.confirm('确定删除该账单吗？', '提示', {
    confirmButtonText: '确定',
    cancelButtonText: '取消',
    type: 'warning'
  }).then(async () => {
    await monthlyBillApi.delete(row.id)
    ElMessage.success('删除成功')
    await loadData()
  }).catch(() => {
    // 用户取消删除
  })
}

// 禁用未来的日期
const disabledDate = (time) => {
  // 获取下个月的第一天
  const now = new Date()
  const nextMonth = new Date(now.getFullYear(), now.getMonth() + 1, 1)
  // 只禁用下个月及之后的月份（当前月份可以选择）
  return time.getTime() >= nextMonth.getTime()
}

onMounted(() => {
  loadData()
  loadCustomers()
  loadCategories()
})
</script>

<style scoped>
.monthly-bill-container {
  padding: 0;
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

.header-actions {
  display: flex;
  gap: 12px;
}

.title-icon {
  font-size: 20px;
  color: var(--primary-color);
}

/* 移动端卡片视图 */
.mobile-card-view {
  display: none;
}

.bill-card {
  background: white;
  border: 1px solid var(--border-color);
  border-radius: var(--radius-md);
  padding: 16px;
  margin-bottom: 12px;
  transition: var(--transition-base);
}

.bill-card:hover {
  box-shadow: var(--shadow-md);
  border-color: var(--primary-color);
}

.bill-card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 12px;
  padding-bottom: 12px;
  border-bottom: 1px solid var(--border-color);
}

.bill-no {
  font-size: 14px;
  font-weight: 600;
  color: var(--text-main);
  font-family: 'Courier New', monospace;
}

.bill-card-body {
  margin-bottom: 12px;
}

.bill-info-row {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 8px 0;
  font-size: 14px;
}

.info-label {
  color: var(--text-secondary);
  font-weight: 500;
}

.info-value {
  color: var(--text-main);
  text-align: right;
  flex: 1;
  margin-left: 12px;
}

.amount-text {
  color: var(--primary-color);
  font-weight: 600;
  font-size: 16px;
}

.paid-text {
  color: var(--success-color);
  font-weight: 600;
  font-size: 14px;
}

.bill-card-actions {
  display: flex;
  gap: 8px;
}

.bill-card-actions .el-button {
  flex: 1;
}

/* 账单预览样式 */
.bill-detail {
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

.amount-highlight {
  color: var(--primary-color);
  font-size: 18px;
  font-weight: 700;
}

.paid-text {
  color: var(--success-color);
  font-weight: 600;
}

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

.bill-summary {
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

.dialog-footer {
  display: flex;
  justify-content: flex-end;
  gap: 12px;
}

/* 结算状态按钮样式 */
.el-button.is-plain {
  font-weight: 500;
}

.el-button--success.is-plain {
  border-color: var(--el-color-success);
  color: var(--el-color-success);
}

.el-button--success.is-plain:hover {
  background-color: var(--el-color-success);
  border-color: var(--el-color-success);
  color: white;
}

.el-button--warning.is-plain {
  border-color: var(--el-color-warning);
  color: var(--el-color-warning);
}

.el-button--warning.is-plain:hover {
  background-color: var(--el-color-warning);
  border-color: var(--el-color-warning);
  color: white;
}

/* 移动端响应式 */
@media (max-width: 768px) {
  .monthly-bill-container {
    padding: 12px;
  }

  /* 隐藏PC端表格，显示移动端卡片 */
  .desktop-table-view {
    display: none !important;
  }

  .mobile-card-view {
    display: block;
  }

  /* 卡片头部优化 */
  .card-header {
    flex-direction: column;
    gap: 12px;
    align-items: stretch;
  }

  .header-title {
    justify-content: center;
  }

  .header-actions {
    flex-direction: column;
    width: 100%;
  }

  .header-actions .el-button {
    width: 100%;
  }

  /* 分页优化 */
  :deep(.el-pagination) {
    justify-content: center;
    flex-wrap: wrap;
    margin-top: 16px;
  }

  :deep(.el-pagination .el-pagination__sizes) {
    display: none;
  }

  :deep(.el-pagination .el-pagination__jump) {
    display: none;
  }
}
</style>
