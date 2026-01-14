<template>
  <div class="product-container">
    <el-card>
      <template #header>
        <div class="card-header">
          <span>商品管理</span>
          <el-button type="primary" @click="handleAdd">新增商品</el-button>
        </div>
      </template>

      <el-form :inline="true" :model="searchForm">
        <el-form-item label="商品名称">
          <el-input v-model="searchForm.name" placeholder="请输入商品名称" clearable />
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="loadData">查询</el-button>
          <el-button @click="handleReset">重置</el-button>
        </el-form-item>
      </el-form>

      <el-table :data="tableData" border stripe>
        <el-table-column prop="id" label="ID" width="80" />
        <el-table-column prop="name" label="商品名称" />
        <el-table-column prop="code" label="商品编码" />
        <el-table-column prop="spec" label="规格型号" />
        <el-table-column prop="unit" label="单位" width="80" />
        <el-table-column prop="price" label="单价" width="100" />
        <el-table-column prop="stock" label="库存" width="100" />
        <el-table-column label="操作" width="320" fixed="right">
          <template #default="{ row }">
            <el-button type="primary" size="small" @click="handleEdit(row)">编辑</el-button>
            <el-button type="success" size="small" @click="handleGenerateQrCode(row)">生成二维码</el-button>
            <el-button type="info" size="small" @click="handleViewQrCode(row)">查看二维码</el-button>
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
        <el-form-item label="商品名称">
          <el-input v-model="form.name" />
        </el-form-item>
        <el-form-item label="商品编码">
          <el-input v-model="form.code" />
        </el-form-item>
        <el-form-item label="规格型号">
          <el-input v-model="form.spec" />
        </el-form-item>
        <el-form-item label="单位">
          <el-input v-model="form.unit" />
        </el-form-item>
        <el-form-item label="单价">
          <el-input-number v-model="form.price" :precision="2" :min="0" />
        </el-form-item>
        <el-form-item label="库存">
          <el-input-number v-model="form.stock" :min="0" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" @click="handleSubmit">确定</el-button>
      </template>
    </el-dialog>

    <!-- 二维码对话框 -->
    <el-dialog v-model="qrCodeVisible" title="商品二维码" width="400px" center>
      <div class="qrcode-container">
        <div v-if="qrCodeLoading" class="loading">加载中...</div>
        <div v-else-if="qrCodeUrl" class="qrcode-content">
          <img :src="qrCodeUrl" alt="二维码" class="qrcode-image" />
          <div class="qrcode-info">
            <p><strong>{{ currentProduct?.name }}</strong></p>
            <p>编码: {{ currentProduct?.code }}</p>
          </div>
        </div>
        <div v-else class="no-qrcode">
          <p>该商品还没有生成二维码</p>
          <el-button type="primary" @click="handleGenerateQrCodeDirect">立即生成</el-button>
        </div>
      </div>
      <template #footer>
        <el-button @click="qrCodeVisible = false">关闭</el-button>
        <el-button v-if="qrCodeUrl" type="primary" @click="handleDownloadQrCode">下载二维码</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { productApi } from '@/api/index'
import axios from 'axios'

const searchForm = reactive({ name: '' })
const tableData = ref([])
const pagination = reactive({ current: 1, size: 10, total: 0 })
const dialogVisible = ref(false)
const dialogTitle = ref('新增商品')
const form = reactive({
  id: null,
  name: '',
  code: '',
  spec: '',
  unit: '瓶',
  price: 0,
  stock: 0
})

// 二维码相关
const qrCodeVisible = ref(false)
const qrCodeUrl = ref('')
const qrCodeLoading = ref(false)
const currentProduct = ref(null)

const loadData = async () => {
  const res = await productApi.getPage({
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
  dialogTitle.value = '新增商品'
  Object.assign(form, { id: null, name: '', code: '', spec: '', unit: '瓶', price: 0, stock: 0 })
  dialogVisible.value = true
}

const handleEdit = (row) => {
  dialogTitle.value = '编辑商品'
  Object.assign(form, row)
  dialogVisible.value = true
}

const handleSubmit = async () => {
  if (form.id) {
    await productApi.update(form)
  } else {
    await productApi.add(form)
  }
  ElMessage.success('操作成功')
  dialogVisible.value = false
  loadData()
}

const handleDelete = (row) => {
  ElMessageBox.confirm('确定删除该商品吗？', '提示', {
    confirmButtonText: '确定',
    cancelButtonText: '取消',
    type: 'warning'
  }).then(async () => {
    await productApi.delete(row.id)
    ElMessage.success('删除成功')
    loadData()
  })
}

// 生成二维码
const handleGenerateQrCode = async (row) => {
  try {
    const res = await axios.post(`http://localhost:8080/api/product/qrcode/${row.id}`)
    if (res.data.code === 200) {
      ElMessage.success('二维码生成成功！')
      loadData()
    }
  } catch (error) {
    ElMessage.error('二维码生成失败')
  }
}

// 查看二维码
const handleViewQrCode = async (row) => {
  currentProduct.value = row
  qrCodeVisible.value = true
  qrCodeLoading.value = true
  qrCodeUrl.value = ''

  try {
    const res = await axios.get(`http://localhost:8080/api/product/qrcode/${row.id}`)
    if (res.data.code === 200 && res.data.data) {
      // 二维码路径格式: qrcodes/产品编码.png
      qrCodeUrl.value = `http://localhost:8080/${res.data.data}`
    }
  } catch (error) {
    console.error('获取二维码失败', error)
  } finally {
    qrCodeLoading.value = false
  }
}

// 直接生成二维码（在对话框中）
const handleGenerateQrCodeDirect = async () => {
  if (!currentProduct.value) return

  qrCodeLoading.value = true
  try {
    const res = await axios.post(`http://localhost:8080/api/product/qrcode/${currentProduct.value.id}`)
    if (res.data.code === 200 && res.data.data) {
      qrCodeUrl.value = `http://localhost:8080/${res.data.data}`
      ElMessage.success('二维码生成成功！')
      loadData()
    }
  } catch (error) {
    ElMessage.error('二维码生成失败')
  } finally {
    qrCodeLoading.value = false
  }
}

// 下载二维码
const handleDownloadQrCode = () => {
  if (!qrCodeUrl.value || !currentProduct.value) return

  const link = document.createElement('a')
  link.href = qrCodeUrl.value
  link.download = `${currentProduct.value.name}-${currentProduct.value.code}.png`
  link.click()
}

onMounted(() => {
  loadData()
})
</script>

<style scoped>
.product-container {
  height: 100%;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.qrcode-container {
  min-height: 300px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.qrcode-content {
  text-align: center;
}

.qrcode-image {
  width: 250px;
  height: 250px;
  margin-bottom: 20px;
  border: 1px solid #ddd;
  border-radius: 8px;
}

.qrcode-info {
  margin-top: 10px;
}

.qrcode-info p {
  margin: 5px 0;
  font-size: 16px;
  color: #666;
}

.no-qrcode {
  text-align: center;
}

.no-qrcode p {
  font-size: 16px;
  color: #999;
  margin-bottom: 20px;
}

.loading {
  font-size: 16px;
  color: #409eff;
}
</style>
