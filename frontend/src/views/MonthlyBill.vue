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
                type="success"
                size="small"
                @click="handleSettle(item)"
                plain
              >
                点击结算
              </el-button>
              <el-button
                v-else
                type="warning"
                size="small"
                @click="handleSettle(item)"
                plain
              >
                取消结算
              </el-button>
            </div>
          </div>

          <div class="bill-card-actions">
            <el-button type="success" size="small" @click="handleExport(item)" icon="Download">导出Excel</el-button>
            <el-button type="danger" size="small" @click="handleDelete(item)" icon="Delete">删除</el-button>
          </div>
        </div>
      </div>

      <!-- PC端表格视图 -->
      <el-table :data="formattedTableData" border stripe class="desktop-table-view">
        <el-table-column prop="billNo" label="账单编号" width="180" />
        <el-table-column prop="customerName" label="客户姓名" />
        <el-table-column prop="billMonth" label="账单月份" width="120" />
        <el-table-column prop="createTime" label="生成时间" width="160" />
        <el-table-column prop="totalAmount" label="账单金额" width="120">
          <template #default="{ row }">
            <span>¥{{ row.totalAmount?.toFixed(2) || '0.00' }}</span>
          </template>
        </el-table-column>
        <el-table-column prop="paidAmount" label="已支付" width="120">
          <template #default="{ row }">
            <span>¥{{ row.paidAmount?.toFixed(2) || '0.00' }}</span>
          </template>
        </el-table-column>
        <el-table-column label="结算状态" width="140" align="center">
          <template #default="{ row }">
            <el-button
              v-if="row.status === '未结清'"
              type="success"
              size="small"
              @click="handleSettle(row)"
              plain
            >
              点击结算
            </el-button>
            <el-button
              v-else
              type="warning"
              size="small"
              @click="handleSettle(row)"
              plain
            >
              取消结算
            </el-button>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="200" fixed="right">
          <template #default="{ row }">
            <el-button type="success" size="small" @click="handleExport(row)">
              导出Excel
            </el-button>
            <el-button type="danger" size="small" @click="handleDelete(row)">
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
      </el-form>
      <template #footer>
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" @click="handleSubmit">确定</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted, computed } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { monthlyBillApi } from '@/api/order'
import { customerApi } from '@/api/index'
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
const customers = ref([])
const form = reactive({
  customerId: null,
  billMonth: ''
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

const handleGenerate = () => {
  Object.assign(form, { customerId: null, billMonth: '' })
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
    billMonth: form.billMonth
  })
  ElMessage.success('生成成功')
  dialogVisible.value = false
  await loadData()
}

const handleExport = (row) => {
  window.open(monthlyBillApi.export(row.id))
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
