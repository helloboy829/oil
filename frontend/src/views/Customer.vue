<template>
  <div class="customer-container">
    <!-- 搜索卡片 -->
    <el-card class="search-card" shadow="never">
      <el-form :inline="true" :model="searchForm" class="search-form">
        <el-form-item label="客户姓名">
          <el-select
            v-model="searchForm.name"
            filterable
            remote
            reserve-keyword
            placeholder="请输入客户姓名搜索"
            :remote-method="searchCustomerName"
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

      <!-- 移动端卡片视图 -->
      <div class="mobile-card-view">
        <div v-for="item in tableData" :key="item.id" class="customer-card">
          <div class="customer-card-header">
            <div class="customer-name">{{ item.name }}</div>
            <el-tag :type="item.isMonthly ? 'success' : 'info'" size="small">
              {{ item.isMonthly ? '月结' : '普通' }}
            </el-tag>
          </div>

          <div class="customer-card-body">
            <div class="customer-info-row">
              <span class="info-label">联系电话:</span>
              <span class="info-value">{{ item.phone || '-' }}</span>
            </div>
          </div>

          <div class="customer-card-actions">
            <el-button type="primary" size="small" @click="handleEdit(item)" icon="Edit">编辑</el-button>
            <el-button type="danger" size="small" @click="handleDelete(item)" icon="Delete">删除</el-button>
          </div>
        </div>
      </div>

      <!-- PC端表格视图 -->
      <el-table :data="tableData" class="modern-table desktop-table-view">
        <el-table-column prop="id" label="ID" width="70" align="center" />
        <el-table-column prop="name" label="客户姓名" width="140" show-overflow-tooltip />
        <el-table-column prop="phone" label="联系电话" width="140" />
        <el-table-column prop="address" label="地址" min-width="200" show-overflow-tooltip />
        <el-table-column label="是否月结" width="100" align="center">
          <template #default="{ row }">
            <el-tag :type="row.isMonthly ? 'success' : 'info'" size="small">
              {{ row.isMonthly ? '月结' : '普通' }}
            </el-tag>
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
    <el-dialog v-model="dialogVisible" :title="dialogTitle" width="650px" class="modern-dialog" lock-scroll>
      <el-form ref="formRef" :model="form" :rules="formRules" label-width="100px" class="modern-form">
        <el-form-item label="客户姓名" prop="name">
          <el-input v-model="form.name" placeholder="请输入客户姓名" />
        </el-form-item>

        <el-form-item label="联系电话">
          <el-input v-model="form.phone" placeholder="请输入联系电话" />
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

// 表单引用
const formRef = ref(null)

// 表单验证规则
const formRules = {
  name: [
    { required: true, message: '请输入客户姓名', trigger: 'blur' }
  ]
}

const searchForm = reactive({
  name: '',
  isMonthly: undefined
})

// 搜索下拉列表
const customerNameList = ref([])
const customerNameLoading = ref(false)
const allCustomerNames = ref([]) // 缓存所有客户姓名

const tableData = ref([])
const pagination = reactive({ current: 1, size: 10, total: 0 })
const dialogVisible = ref(false)
const dialogTitle = ref('新增客户')
const form = reactive({
  id: null,
  name: '',
  phone: '',
  address: '',
  isMonthly: 0,
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
    address: '',
    isMonthly: 0,
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
  // 验证表单
  if (!formRef.value) return

  try {
    await formRef.value.validate()
  } catch (error) {
    ElMessage.warning('请填写必填字段')
    return
  }

  try {
    if (form.id) {
      await customerApi.update(form)
    } else {
      await customerApi.add(form)
    }
    ElMessage.success('操作成功')
    dialogVisible.value = false
    // 等待数据加载完成
    await loadData()
  } catch (error) {
    ElMessage.error('操作失败：' + (error.response?.data?.message || error.message || '未知错误'))
  }
}

const handleDelete = (row) => {
  ElMessageBox.confirm('确定删除该客户吗？', '提示', {
    confirmButtonText: '确定',
    cancelButtonText: '取消',
    type: 'warning'
  }).then(async () => {
    try {
      await customerApi.delete(row.id)
      ElMessage.success('删除成功')
      // 等待数据加载完成
      await loadData()
    } catch (error) {
      ElMessage.error('删除失败：' + (error.response?.data?.message || error.message || '未知错误'))
    }
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

/* 移动端卡片视图 */
.mobile-card-view {
  display: none;
}

.customer-card {
  background: white;
  border: 1px solid var(--border-color);
  border-radius: var(--radius-md);
  padding: 16px;
  margin-bottom: 12px;
  transition: var(--transition-base);
}

.customer-card:hover {
  box-shadow: var(--shadow-md);
  border-color: var(--primary-color);
}

.customer-card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 12px;
  padding-bottom: 12px;
  border-bottom: 1px solid var(--border-color);
}

.customer-name {
  font-size: 16px;
  font-weight: 600;
  color: var(--text-main);
}

.customer-card-body {
  margin-bottom: 12px;
}

.customer-info-row {
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
  word-break: break-all;
}

.customer-card-actions {
  display: flex;
  gap: 8px;
}

.customer-card-actions .el-button {
  flex: 1;
}

/* 移动端响应式 */
@media (max-width: 768px) {
  .customer-container {
    padding: 12px;
  }

  /* 隐藏PC端表格，显示移动端卡片 */
  .desktop-table-view {
    display: none !important;
  }

  .mobile-card-view {
    display: block;
  }

  /* 搜索表单优化 */
  .search-form {
    display: flex;
    flex-direction: column;
  }

  .search-form :deep(.el-form-item) {
    margin-bottom: 12px;
    width: 100%;
  }

  .search-form :deep(.el-input),
  .search-form :deep(.el-select) {
    width: 100% !important;
  }

  .search-form :deep(.el-form-item:last-child) {
    margin-bottom: 0;
  }

  .search-form :deep(.el-button) {
    width: 100%;
    margin-bottom: 8px;
  }

  /* 卡片头部按钮 */
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
  .pagination-container {
    margin-top: 16px;
  }

  .pagination-container :deep(.el-pagination) {
    justify-content: center;
    flex-wrap: wrap;
  }

  .pagination-container :deep(.el-pagination__sizes),
  .pagination-container :deep(.el-pagination__jump) {
    display: none;
  }

  /* 对话框优化 */
  .modern-dialog :deep(.el-dialog) {
    width: 95% !important;
    margin: 0 auto;
  }

  .modern-form :deep(.el-col) {
    width: 100%;
  }
}
</style>
