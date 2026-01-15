<template>
  <div class="customer-container">
    <!-- 搜索卡片 -->
    <el-card class="search-card" shadow="never">
      <el-form :inline="true" :model="searchForm" class="search-form">
        <el-form-item label="客户姓名">
          <el-input
            v-model="searchForm.name"
            placeholder="请输入客户姓名"
            clearable
            prefix-icon="Search"
          />
        </el-form-item>
        <el-form-item label="月结客户">
          <el-select v-model="searchForm.isMonthly" placeholder="全部" clearable style="width: 120px;">
            <el-option label="是" :value="1" />
            <el-option label="否" :value="0" />
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
            <el-icon class="title-icon"><User /></el-icon>
            <span>客户列表</span>
          </div>
          <el-button type="primary" @click="handleAdd" icon="Plus">新增客户</el-button>
        </div>
      </template>

      <el-table :data="tableData" class="modern-table">
        <el-table-column prop="id" label="ID" width="80" align="center" />
        <el-table-column prop="name" label="客户姓名" min-width="120" show-overflow-tooltip />
        <el-table-column prop="phone" label="联系电话" min-width="130" />
        <el-table-column prop="company" label="公司名称" min-width="180" show-overflow-tooltip />
        <el-table-column label="是否月结" width="100" align="center">
          <template #default="{ row }">
            <el-tag :type="row.isMonthly ? 'success' : 'info'" size="small">
              {{ row.isMonthly ? '月结' : '普通' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="creditLimit" label="信用额度" width="120" align="right">
          <template #default="{ row }">
            <span v-if="row.isMonthly" class="credit-text">¥{{ row.creditLimit?.toFixed(2) || '0.00' }}</span>
            <span v-else class="na-text">-</span>
          </template>
        </el-table-column>
        <el-table-column prop="balance" label="当前欠款" width="120" align="right">
          <template #default="{ row }">
            <span v-if="row.isMonthly" class="balance-text" :class="{ 'has-balance': row.balance > 0 }">
              ¥{{ row.balance?.toFixed(2) || '0.00' }}
            </span>
            <span v-else class="na-text">-</span>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="180" fixed="right" align="center">
          <template #default="{ row }">
            <div class="action-buttons">
              <el-button type="primary" size="small" @click="handleEdit(row)" icon="Edit">编辑</el-button>
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

    <!-- 新增/编辑对话框 -->
    <el-dialog v-model="dialogVisible" :title="dialogTitle" width="650px" class="modern-dialog">
      <el-form :model="form" label-width="100px" class="modern-form">
        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="客户姓名">
              <el-input v-model="form.name" placeholder="请输入客户姓名" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="联系电话">
              <el-input v-model="form.phone" placeholder="请输入联系电话" />
            </el-form-item>
          </el-col>
        </el-row>

        <el-form-item label="公司名称">
          <el-input v-model="form.company" placeholder="请输入公司名称" />
        </el-form-item>

        <el-form-item label="地址">
          <el-input v-model="form.address" type="textarea" :rows="2" placeholder="请输入地址" />
        </el-form-item>

        <el-divider content-position="left">
          <span style="font-weight: 600; color: var(--text-main);">月结设置</span>
        </el-divider>

        <el-form-item label="是否月结">
          <el-switch
            v-model="form.isMonthly"
            :active-value="1"
            :inactive-value="0"
            active-text="是"
            inactive-text="否"
          />
        </el-form-item>

        <el-form-item label="信用额度" v-if="form.isMonthly">
          <el-input-number
            v-model="form.creditLimit"
            :precision="2"
            :min="0"
            :step="100"
            style="width: 100%;"
          />
          <div class="form-tip">月结客户可赊账的最大金额</div>
        </el-form-item>

        <el-form-item label="备注">
          <el-input v-model="form.remark" type="textarea" :rows="3" placeholder="请输入备注信息" />
        </el-form-item>
      </el-form>
      <template #footer>
        <div class="dialog-footer">
          <el-button @click="dialogVisible = false" size="large">取消</el-button>
          <el-button type="primary" @click="handleSubmit" size="large" icon="Check">确定</el-button>
        </div>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { customerApi } from '@/api/index'

const searchForm = reactive({
  name: '',
  isMonthly: undefined
})
const tableData = ref([])
const pagination = reactive({ current: 1, size: 10, total: 0 })
const dialogVisible = ref(false)
const dialogTitle = ref('新增客户')
const form = reactive({
  id: null,
  name: '',
  phone: '',
  company: '',
  address: '',
  isMonthly: 0,
  creditLimit: 0,
  balance: 0,
  remark: ''
})

const loadData = async () => {
  const res = await customerApi.getPage({
    current: pagination.current,
    size: pagination.size,
    name: searchForm.name,
    isMonthly: searchForm.isMonthly
  })
  tableData.value = res.data.records
  pagination.total = res.data.total
}

const handleReset = () => {
  searchForm.name = ''
  searchForm.isMonthly = undefined
  loadData()
}

const handleAdd = () => {
  dialogTitle.value = '新增客户'
  Object.assign(form, {
    id: null,
    name: '',
    phone: '',
    company: '',
    address: '',
    isMonthly: 0,
    creditLimit: 0,
    balance: 0,
    remark: ''
  })
  dialogVisible.value = true
}

const handleEdit = (row) => {
  dialogTitle.value = '编辑客户'
  Object.assign(form, row)
  dialogVisible.value = true
}

const handleSubmit = async () => {
  if (!form.name) {
    ElMessage.warning('请输入客户姓名')
    return
  }

  if (form.id) {
    await customerApi.update(form)
  } else {
    await customerApi.add(form)
  }
  ElMessage.success('操作成功')
  dialogVisible.value = false
  loadData()
}

const handleDelete = (row) => {
  ElMessageBox.confirm('确定删除该客户吗？', '提示', {
    confirmButtonText: '确定',
    cancelButtonText: '取消',
    type: 'warning'
  }).then(async () => {
    await customerApi.delete(row.id)
    ElMessage.success('删除成功')
    loadData()
  })
}

onMounted(() => {
  loadData()
})
</script>

<style scoped>
.customer-container {
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
.credit-text {
  color: var(--success-color);
  font-weight: 600;
  font-size: 14px;
}

.balance-text {
  color: var(--text-secondary);
  font-weight: 600;
  font-size: 14px;
}

.balance-text.has-balance {
  color: var(--danger-color);
}

.na-text {
  color: var(--text-placeholder);
  font-size: 14px;
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

/* 表单提示 */
.form-tip {
  margin-top: 4px;
  font-size: 12px;
  color: var(--text-placeholder);
}
</style>
