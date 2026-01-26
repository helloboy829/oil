<template>
  <div class="monthly-bill-container">
    <el-card>
      <template #header>
        <div class="card-header">
          <span>月结账单</span>
          <el-button type="primary" @click="handleGenerate">生成账单</el-button>
        </div>
      </template>

      <el-table :data="tableData" border stripe>
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
  // 获取当前月份的第一天
  const now = new Date()
  const currentMonth = new Date(now.getFullYear(), now.getMonth(), 1)
  // 禁用当前月份及之后的月份
  return time.getTime() >= currentMonth.getTime()
}

onMounted(() => {
  loadData()
  loadCustomers()
})
</script>

<style scoped>
.monthly-bill-container {
  height: 100%;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}
</style>
