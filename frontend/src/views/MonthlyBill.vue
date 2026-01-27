<template>
  <div class="monthly-bill-container">
    <el-card>
      <template #header>
        <div class="card-header">
          <div class="header-title">
            <el-icon class="title-icon"><Document /></el-icon>
            <span>月结账单</span>
          </div>
          <el-button type="primary" @click="handleGenerate" icon="Plus">生成账单</el-button>
        </div>
      </template>

      <!-- 移动端卡片视图 -->
      <div class="mobile-card-view">
        <div v-for="item in tableData" :key="item.id" class="bill-card">
          <div class="bill-card-header">
            <div class="bill-no">{{ item.billNo }}</div>
            <el-tag :type="item.status === '已结清' ? 'success' : item.status === '部分支付' ? 'warning' : 'info'" size="small">
              {{ item.status }}
            </el-tag>
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
            <div class="bill-info-row amount-row">
              <span class="info-label">账单金额:</span>
              <span class="amount-text">¥{{ item.totalAmount?.toFixed(2) || '0.00' }}</span>
            </div>
            <div class="bill-info-row">
              <span class="info-label">已支付:</span>
              <span class="paid-text">¥{{ item.paidAmount?.toFixed(2) || '0.00' }}</span>
            </div>
          </div>

          <div class="bill-card-actions">
            <el-button type="success" size="small" @click="handleExport(item)" icon="Download">导出Excel</el-button>
          </div>
        </div>
      </div>

      <!-- PC端表格视图 -->
      <el-table :data="tableData" border stripe class="desktop-table-view">
        <el-table-column prop="billNo" label="账单编号" width="180" />
        <el-table-column prop="customerName" label="客户姓名" />
        <el-table-column prop="billMonth" label="账单月份" width="120" />
        <el-table-column prop="totalAmount" label="账单金额" width="120" />
        <el-table-column prop="paidAmount" label="已支付" width="120" />
        <el-table-column prop="status" label="状态" width="100" />
        <el-table-column label="操作" width="150" fixed="right">
          <template #default="{ row }">
            <el-button type="success" size="small" @click="handleExport(row)">
              导出Excel
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
    <el-dialog v-model="dialogVisible" title="生成月结账单" width="500px">
      <el-form :model="form" label-width="100px">
        <el-form-item label="客户">
          <el-select v-model="form.customerId" placeholder="请选择客户" style="width: 100%;">
            <el-option
              v-for="item in customers"
              :key="item.id"
              :label="item.name"
              :value="item.id"
            />
          </el-select>
        </el-form-item>
        <el-form-item label="账单月份">
          <el-date-picker
            v-model="form.billMonth"
            type="month"
            placeholder="选择月份"
            format="YYYY-MM"
            value-format="YYYY-MM"
            :disabled-date="disabledDate"
            style="width: 100%;"
          />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" @click="handleSubmit">确定</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import { monthlyBillApi } from '@/api/order'
import { customerApi } from '@/api/index'

const tableData = ref([])
const pagination = reactive({ current: 1, size: 10, total: 0 })
const dialogVisible = ref(false)
const customers = ref([])
const form = reactive({
  customerId: null,
  billMonth: ''
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
  const res = await customerApi.getMonthlyCustomers()
  customers.value = res.data
}

const handleGenerate = () => {
  Object.assign(form, { customerId: null, billMonth: '' })
  dialogVisible.value = true
}

const handleSubmit = async () => {
  await monthlyBillApi.generate({
    customerId: form.customerId,
    billMonth: form.billMonth
  })
  ElMessage.success('生成成功')
  dialogVisible.value = false
  loadData()
}

const handleExport = (row) => {
  window.open(monthlyBillApi.export(row.id))
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

  .card-header .el-button {
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
