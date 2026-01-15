<template>
  <div class="order-container">
    <!-- 搜索卡片 -->
    <el-card class="search-card" shadow="never">
      <el-form :inline="true" :model="searchForm" class="search-form">
        <el-form-item label="订单编号">
          <el-input
            v-model="searchForm.orderNo"
            placeholder="请输入订单编号"
            clearable
            prefix-icon="Search"
          />
        </el-form-item>
        <el-form-item label="客户姓名">
          <el-input
            v-model="searchForm.customerName"
            placeholder="请输入客户姓名"
            clearable
          />
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

      <el-table :data="tableData" class="modern-table">
        <el-table-column prop="orderNo" label="订单编号" min-width="180" show-overflow-tooltip />
        <el-table-column prop="customerName" label="客户姓名" min-width="120" />
        <el-table-column prop="totalAmount" label="订单金额" width="140" align="right">
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
        <el-table-column prop="paymentStatus" label="结算状态" width="120" align="center">
          <template #default="{ row }">
            <el-tag :type="row.paymentStatus === '已结算' ? 'success' : 'warning'" size="small">
              {{ row.paymentStatus }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="orderStatus" label="订单状态" width="120" align="center">
          <template #default="{ row }">
            <el-tag type="success" size="small">
              {{ row.orderStatus }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="createTime" label="创建时间" width="180" align="center" />
        <el-table-column label="操作" width="150" fixed="right" align="center">
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
    <el-dialog v-model="dialogVisible" title="创建订单" width="800px" class="modern-dialog">
      <el-form :model="form" label-width="100px" class="modern-form">
        <el-form-item label="客户姓名">
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
    <el-dialog v-model="detailVisible" title="订单详情" width="700px" class="modern-dialog">
      <div class="order-detail" v-if="currentOrder">
        <div class="detail-section">
          <h3 class="section-title">基本信息</h3>
          <div class="info-grid">
            <div class="info-item">
              <span class="label">订单编号:</span>
              <span class="value">{{ currentOrder.orderNo }}</span>
            </div>
            <div class="info-item">
              <span class="label">客户姓名:</span>
              <span class="value">{{ currentOrder.customerName }}</span>
            </div>
            <div class="info-item">
              <span class="label">订单金额:</span>
              <span class="value amount-highlight">¥{{ currentOrder.totalAmount?.toFixed(2) }}</span>
            </div>
            <div class="info-item">
              <span class="label">支付方式:</span>
              <el-tag :type="getPaymentTypeTag(currentOrder.paymentType)" size="small">
                {{ currentOrder.paymentType }}
              </el-tag>
            </div>
            <div class="info-item">
              <span class="label">结算状态:</span>
              <el-tag :type="currentOrder.paymentStatus === '已结算' ? 'success' : 'warning'" size="small">
                {{ currentOrder.paymentStatus }}
              </el-tag>
            </div>
            <div class="info-item">
              <span class="label">创建时间:</span>
              <span class="value">{{ currentOrder.createTime }}</span>
            </div>
          </div>
          <div class="info-item full-width" v-if="currentOrder.remark">
            <span class="label">备注:</span>
            <span class="value">{{ currentOrder.remark }}</span>
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
import { ref, reactive, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { orderApi } from '@/api/order'

const searchForm = reactive({
  orderNo: '',
  customerName: ''
})
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

const loadData = async () => {
  const res = await orderApi.getPage({
    current: pagination.current,
    size: pagination.size,
    orderNo: searchForm.orderNo,
    customerName: searchForm.customerName
  })
  tableData.value = res.data.records
  pagination.total = res.data.total
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
  if (!form.customerName) {
    ElMessage.warning('请输入客户姓名')
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

  await orderApi.create(form)
  ElMessage.success('创建成功')
  dialogVisible.value = false
  loadData()
}

const handleView = (row) => {
  currentOrder.value = row
  detailVisible.value = true
}

const handleDelete = (row) => {
  ElMessageBox.confirm('确定删除该订单吗？', '提示', {
    confirmButtonText: '确定',
    cancelButtonText: '取消',
    type: 'warning'
  }).then(async () => {
    await orderApi.delete(row.id)
    ElMessage.success('删除成功')
    loadData()
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
  margin-bottom: 24px;
}

.section-title {
  margin: 0 0 16px 0;
  padding-bottom: 12px;
  font-size: 16px;
  font-weight: 600;
  color: var(--text-main);
  border-bottom: 2px solid var(--primary-color);
}

.info-grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 16px 24px;
}

.info-item {
  display: flex;
  align-items: center;
  gap: 8px;
}

.info-item.full-width {
  grid-column: 1 / -1;
}

.info-item .label {
  color: var(--text-secondary);
  font-size: 14px;
  min-width: 80px;
}

.info-item .value {
  color: var(--text-main);
  font-size: 14px;
  font-weight: 500;
}

.amount-highlight {
  color: var(--primary-color);
  font-size: 18px;
  font-weight: 600;
}
</style>
