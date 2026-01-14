<template>
  <div class="order-container">
    <el-card>
      <template #header>
        <div class="card-header">
          <span>订单管理</span>
          <el-button type="primary" @click="handleAdd">创建订单</el-button>
        </div>
      </template>

      <el-form :inline="true" :model="searchForm">
        <el-form-item label="订单编号">
          <el-input v-model="searchForm.orderNo" placeholder="请输入订单编号" clearable />
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="loadData">查询</el-button>
          <el-button @click="handleReset">重置</el-button>
        </el-form-item>
      </el-form>

      <el-table :data="tableData" border stripe>
        <el-table-column prop="orderNo" label="订单编号" width="180" />
        <el-table-column prop="customerName" label="客户姓名" />
        <el-table-column prop="totalAmount" label="订单金额" width="120" />
        <el-table-column prop="paymentType" label="支付方式" width="100" />
        <el-table-column prop="paymentStatus" label="支付状态" width="100" />
        <el-table-column prop="orderStatus" label="订单状态" width="100" />
        <el-table-column prop="createTime" label="创建时间" width="180" />
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

    <!-- 创建订单对话框 -->
    <el-dialog v-model="dialogVisible" title="创建订单" width="800px">
      <el-form :model="form" label-width="100px">
        <el-form-item label="客户">
          <el-input v-model="form.customerName" placeholder="请输入客户姓名" />
        </el-form-item>
        <el-form-item label="支付方式">
          <el-select v-model="form.paymentType" placeholder="请选择支付方式">
            <el-option label="现金" value="现金" />
            <el-option label="微信" value="微信" />
            <el-option label="支付宝" value="支付宝" />
            <el-option label="月结" value="月结" />
          </el-select>
        </el-form-item>
        <el-form-item label="备注">
          <el-input v-model="form.remark" type="textarea" />
        </el-form-item>
        <el-divider>商品明细</el-divider>
        <el-button type="primary" size="small" @click="handleAddItem" style="margin-bottom: 10px;">
          添加商品
        </el-button>
        <el-table :data="form.items" border>
          <el-table-column label="商品编码" width="150">
            <template #default="{ row }">
              <el-input v-model="row.productCode" placeholder="扫码或输入" />
            </template>
          </el-table-column>
          <el-table-column label="数量" width="120">
            <template #default="{ row }">
              <el-input-number v-model="row.quantity" :min="1" />
            </template>
          </el-table-column>
          <el-table-column label="操作" width="100">
            <template #default="{ $index }">
              <el-button type="danger" size="small" @click="handleRemoveItem($index)">
                删除
              </el-button>
            </template>
          </el-table-column>
        </el-table>
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
import { orderApi } from '@/api/order'

const searchForm = reactive({ orderNo: '' })
const tableData = ref([])
const pagination = reactive({ current: 1, size: 10, total: 0 })
const dialogVisible = ref(false)
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
    orderNo: searchForm.orderNo
  })
  tableData.value = res.data.records
  pagination.total = res.data.total
}

const handleReset = () => {
  searchForm.orderNo = ''
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
  await orderApi.create(form)
  ElMessage.success('创建成功')
  dialogVisible.value = false
  loadData()
}

onMounted(() => {
  loadData()
})
</script>

<style scoped>
.order-container {
  height: 100%;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}
</style>
