<template>
  <div class="customer-container">
    <el-card>
      <template #header>
        <div class="card-header">
          <span>客户管理</span>
          <el-button type="primary" @click="handleAdd">新增客户</el-button>
        </div>
      </template>

      <el-form :inline="true" :model="searchForm">
        <el-form-item label="客户姓名">
          <el-input v-model="searchForm.name" placeholder="请输入客户姓名" clearable />
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="loadData">查询</el-button>
          <el-button @click="handleReset">重置</el-button>
        </el-form-item>
      </el-form>

      <el-table :data="tableData" border stripe>
        <el-table-column prop="id" label="ID" width="80" />
        <el-table-column prop="name" label="客户姓名" />
        <el-table-column prop="phone" label="联系电话" />
        <el-table-column prop="company" label="公司名称" />
        <el-table-column label="是否月结" width="100">
          <template #default="{ row }">
            <el-tag :type="row.isMonthly ? 'success' : 'info'">
              {{ row.isMonthly ? '是' : '否' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="creditLimit" label="信用额度" width="120" />
        <el-table-column prop="balance" label="当前欠款" width="120" />
        <el-table-column label="操作" width="180" fixed="right">
          <template #default="{ row }">
            <el-button type="primary" size="small" @click="handleEdit(row)">编辑</el-button>
            <el-button type="danger" size="small" @click="handleDelete(row)">删除</el-button>
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

    <!-- 新增/编辑对话框 -->
    <el-dialog v-model="dialogVisible" :title="dialogTitle" width="600px">
      <el-form :model="form" label-width="100px">
        <el-form-item label="客户姓名">
          <el-input v-model="form.name" />
        </el-form-item>
        <el-form-item label="联系电话">
          <el-input v-model="form.phone" />
        </el-form-item>
        <el-form-item label="公司名称">
          <el-input v-model="form.company" />
        </el-form-item>
        <el-form-item label="地址">
          <el-input v-model="form.address" type="textarea" />
        </el-form-item>
        <el-form-item label="是否月结">
          <el-switch v-model="form.isMonthly" :active-value="1" :inactive-value="0" />
        </el-form-item>
        <el-form-item label="信用额度" v-if="form.isMonthly">
          <el-input-number v-model="form.creditLimit" :precision="2" :min="0" />
        </el-form-item>
        <el-form-item label="备注">
          <el-input v-model="form.remark" type="textarea" />
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
import { ElMessage, ElMessageBox } from 'element-plus'
import { customerApi } from '@/api/index'

const searchForm = reactive({ name: '' })
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
    name: searchForm.name
  })
  tableData.value = res.data.records
  pagination.total = res.data.total
}

const handleReset = () => {
  searchForm.name = ''
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
  height: 100%;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}
</style>
