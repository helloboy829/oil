<template>
  <div class="product-container">
    <!-- 搜索卡片 -->
    <el-card class="search-card" shadow="never">
      <el-form :inline="true" :model="searchForm" class="search-form">
        <el-form-item label="商品名称">
          <el-select
            v-model="searchForm.name"
            filterable
            remote
            reserve-keyword
            placeholder="请输入商品名称搜索"
            :remote-method="searchProductName"
            :loading="productNameLoading"
            clearable
            style="width: 200px;"
            @focus="loadAllProductNames"
          >
            <el-option
              v-for="name in productNameList"
              :key="name"
              :label="name"
              :value="name"
            />
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
            <el-icon class="title-icon"><Goods /></el-icon>
            <span>商品列表</span>
          </div>
          <el-button type="primary" @click="handleAdd" icon="Plus">新增商品</el-button>
        </div>
      </template>

      <!-- 移动端卡片视图 -->
      <div class="mobile-card-view">
        <div v-for="item in tableData" :key="item.id" class="product-card">
          <div class="product-card-header">
            <div class="product-name">{{ item.name }}</div>
            <el-tag :type="item.stock > 10 ? 'success' : item.stock > 0 ? 'warning' : 'danger'" size="small">
              库存: {{ item.stock }}
            </el-tag>
          </div>

          <div class="product-card-body">
            <div class="product-info-row">
              <span class="info-label">编码:</span>
              <span class="info-value">{{ item.code }}</span>
            </div>
            <div class="product-info-row">
              <span class="info-label">规格:</span>
              <span class="info-value">{{ item.spec }}</span>
            </div>
            <div class="product-info-row">
              <span class="info-label">单位:</span>
              <span class="info-value">{{ item.unit }}</span>
            </div>
            <div class="product-info-row price-row">
              <span class="info-label">单价:</span>
              <span class="price-text">¥{{ item.price?.toFixed(2) || '0.00' }}</span>
            </div>
          </div>

          <div class="product-card-actions">
            <el-button type="primary" size="small" @click="handleEdit(item)" icon="Edit">编辑</el-button>
            <el-button type="success" size="small" @click="handleGenerateQrCode(item)" icon="PictureFilled">生成码</el-button>
            <el-button type="info" size="small" @click="handleViewQrCode(item)" icon="View">查看码</el-button>
            <el-button type="danger" size="small" @click="handleDelete(item)" icon="Delete">删除</el-button>
          </div>
        </div>
      </div>

      <!-- PC端表格视图 -->
      <el-table :data="tableData" class="modern-table desktop-table-view" @row-click="handleRowClick">
        <el-table-column prop="id" label="ID" width="80" align="center" />
        <el-table-column prop="name" label="商品名称" min-width="180" show-overflow-tooltip />
        <el-table-column prop="code" label="商品编码" min-width="150" />
        <el-table-column prop="spec" label="规格型号" min-width="120" />
        <el-table-column prop="unit" label="单位" width="80" align="center" />
        <el-table-column prop="price" label="单价" width="120" align="right">
          <template #default="{ row }">
            <span class="price-text">¥{{ row.price?.toFixed(2) || '0.00' }}</span>
          </template>
        </el-table-column>
        <el-table-column prop="stock" label="库存" width="100" align="center">
          <template #default="{ row }">
            <el-tag :type="row.stock > 10 ? 'success' : row.stock > 0 ? 'warning' : 'danger'" size="small">
              {{ row.stock }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="320" fixed="right" align="center">
          <template #default="{ row }">
            <div class="action-buttons">
              <el-button type="primary" size="small" @click.stop="handleEdit(row)" icon="Edit">编辑</el-button>
              <el-button type="success" size="small" @click.stop="handleGenerateQrCode(row)" icon="PictureFilled">生成码</el-button>
              <el-button type="info" size="small" @click.stop="handleViewQrCode(row)" icon="View">查看码</el-button>
              <el-button type="danger" size="small" @click.stop="handleDelete(row)" icon="Delete">删除</el-button>
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
    <el-dialog v-model="dialogVisible" :title="dialogTitle" width="600px" class="modern-dialog">
      <el-form :model="form" label-width="100px" class="modern-form">
        <el-form-item label="商品名称">
          <el-input v-model="form.name" placeholder="请输入商品名称" />
        </el-form-item>
        <el-form-item label="商品编码">
          <el-input v-model="form.code" placeholder="请输入商品编码" />
        </el-form-item>
        <el-form-item label="规格型号">
          <el-input v-model="form.spec" placeholder="请输入规格型号" />
        </el-form-item>
        <el-form-item label="单位">
          <el-input v-model="form.unit" placeholder="请输入单位" />
        </el-form-item>
        <el-form-item label="单价">
          <el-input-number v-model="form.price" :precision="2" :min="0" :step="0.1" style="width: 100%;" />
        </el-form-item>
        <el-form-item label="库存">
          <el-input-number v-model="form.stock" :min="0" :step="1" style="width: 100%;" />
        </el-form-item>
      </el-form>
      <template #footer>
        <div class="dialog-footer">
          <el-button @click="dialogVisible = false" size="large">取消</el-button>
          <el-button type="primary" @click="handleSubmit" size="large" icon="Check">确定</el-button>
        </div>
      </template>
    </el-dialog>

    <!-- 二维码对话框 -->
    <el-dialog v-model="qrCodeVisible" title="商品二维码" width="450px" class="modern-dialog qrcode-dialog" center>
      <div class="qrcode-container">
        <div v-if="qrCodeLoading" class="loading">
          <el-icon class="is-loading"><Loading /></el-icon>
          <p>加载中...</p>
        </div>
        <div v-else-if="qrCodeUrl" class="qrcode-content">
          <div class="qrcode-wrapper">
            <img :src="qrCodeUrl" alt="二维码" class="qrcode-image" />
          </div>
          <div class="qrcode-info">
            <h3>{{ currentProduct?.name }}</h3>
            <p class="product-code">商品编码: {{ currentProduct?.code }}</p>
            <p class="product-spec" v-if="currentProduct?.spec">规格: {{ currentProduct?.spec }}</p>
          </div>
        </div>
        <div v-else class="no-qrcode">
          <el-icon class="empty-icon"><PictureFilled /></el-icon>
          <p>该商品还没有生成二维码</p>
          <el-button type="primary" @click="handleGenerateQrCodeDirect" size="large" icon="Plus">立即生成</el-button>
        </div>
      </div>
      <template #footer>
        <div class="dialog-footer">
          <el-button @click="qrCodeVisible = false" size="large">关闭</el-button>
          <el-button v-if="qrCodeUrl" type="primary" @click="handleDownloadQrCode" size="large" icon="Download">下载二维码</el-button>
        </div>
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

// 搜索下拉列表
const productNameList = ref([])
const productNameLoading = ref(false)
const allProductNames = ref([]) // 缓存所有商品名称

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

// 加载所有商品名称（点击搜索框时）
const loadAllProductNames = async () => {
  if (allProductNames.value.length > 0) {
    productNameList.value = allProductNames.value
    return
  }

  try {
    productNameLoading.value = true
    const res = await productApi.getPage({
      current: 1,
      size: 1000
    })
    allProductNames.value = res.data.records.map(item => item.name)
    productNameList.value = allProductNames.value
  } catch (err) {
    console.error('加载商品名称失败', err)
  } finally {
    productNameLoading.value = false
  }
}

// 搜索商品名称
const searchProductName = async (query) => {
  if (!query) {
    productNameList.value = allProductNames.value
    return
  }

  // 从缓存中模糊匹配
  productNameList.value = allProductNames.value.filter(name =>
    name.toLowerCase().includes(query.toLowerCase())
  )
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

// 行点击事件（可选）
const handleRowClick = (row) => {
  // 可以添加行点击逻辑，例如显示详情
}

// 生成二维码
const handleGenerateQrCode = async (row) => {
  try {
    const res = await axios.post(`/api/product/qrcode/${row.id}`)
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
    const res = await axios.get(`/api/product/qrcode/${row.id}`)
    if (res.data.code === 200 && res.data.data) {
      // 二维码路径格式: qrcodes/产品编码.png
      qrCodeUrl.value = `/${res.data.data}`
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
    const res = await axios.post(`/api/product/qrcode/${currentProduct.value.id}`)
    if (res.data.code === 200 && res.data.data) {
      qrCodeUrl.value = `/${res.data.data}`
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
  cursor: pointer;
}

.modern-table :deep(.el-table__row:hover) {
  background-color: var(--primary-light) !important;
  transform: translateY(-1px);
  box-shadow: 0 2px 8px rgba(79, 70, 229, 0.1);
}

.modern-table :deep(.el-table__body td) {
  border-bottom: 1px solid var(--border-color);
  padding: 16px 0;
}

/* 价格样式 */
.price-text {
  color: var(--primary-color);
  font-weight: 600;
  font-size: 15px;
}

/* 操作按钮 */
.action-buttons {
  display: flex;
  gap: 8px;
  justify-content: center;
  flex-wrap: wrap;
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

.pagination-container :deep(.el-pagination) {
  gap: 8px;
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

/* 二维码对话框 */
.qrcode-dialog {
  border-radius: var(--radius-lg);
}

.qrcode-container {
  min-height: 350px;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 20px;
}

.loading {
  text-align: center;
  color: var(--primary-color);
}

.loading .el-icon {
  font-size: 48px;
  margin-bottom: 12px;
}

.loading p {
  font-size: 16px;
  margin-top: 12px;
}

.qrcode-content {
  text-align: center;
  width: 100%;
}

.qrcode-wrapper {
  display: inline-block;
  padding: 20px;
  background: linear-gradient(135deg, #f5f7fa 0%, #ffffff 100%);
  border-radius: var(--radius-lg);
  box-shadow: var(--shadow-md);
  margin-bottom: 20px;
}

.qrcode-image {
  width: 280px;
  height: 280px;
  border-radius: var(--radius-md);
  display: block;
}

.qrcode-info h3 {
  margin: 0 0 12px 0;
  font-size: 20px;
  font-weight: 600;
  color: var(--text-main);
}

.qrcode-info p {
  margin: 8px 0;
  font-size: 14px;
  color: var(--text-secondary);
}

.product-code {
  color: var(--primary-color);
  font-weight: 500;
}

.no-qrcode {
  text-align: center;
}

.empty-icon {
  font-size: 80px;
  color: var(--text-placeholder);
  margin-bottom: 20px;
}

.no-qrcode p {
  font-size: 16px;
  color: var(--text-secondary);
  margin: 20px 0;
}

/* 移动端卡片视图 */
.mobile-card-view {
  display: none;
}

.product-card {
  background: white;
  border-radius: var(--radius-md);
  padding: 16px;
  margin-bottom: 12px;
  box-shadow: var(--shadow-sm);
  transition: var(--transition-base);
}

.product-card:hover {
  box-shadow: var(--shadow-md);
  transform: translateY(-2px);
}

.product-card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 12px;
  padding-bottom: 12px;
  border-bottom: 1px solid var(--border-color);
}

.product-card-header .product-name {
  font-size: 16px;
  font-weight: 600;
  color: var(--text-main);
  flex: 1;
  margin-right: 12px;
}

.product-card-body {
  margin-bottom: 12px;
}

.product-info-row {
  display: flex;
  justify-content: space-between;
  padding: 8px 0;
  font-size: 14px;
}

.info-label {
  color: var(--text-secondary);
  font-weight: 500;
}

.info-value {
  color: var(--text-main);
}

.price-row {
  border-top: 1px dashed var(--border-color);
  margin-top: 8px;
  padding-top: 12px;
}

.price-row .price-text {
  font-size: 18px;
  font-weight: 600;
  color: var(--primary-color);
}

.product-card-actions {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 8px;
}

.product-card-actions .el-button {
  width: 100%;
}

/* 响应式布局 */
@media (max-width: 768px) {
  /* 隐藏PC端表格，显示移动端卡片 */
  .desktop-table-view {
    display: none !important;
  }

  .mobile-card-view {
    display: block;
  }

  /* 优化搜索表单 */
  .search-form {
    display: flex;
    flex-direction: column;
  }

  .search-form :deep(.el-form-item) {
    width: 100%;
    margin-bottom: 12px;
  }

  .search-form :deep(.el-input) {
    width: 100%;
  }

  /* 优化卡片头部 */
  .card-header {
    flex-direction: column;
    gap: 12px;
    align-items: stretch;
  }

  .card-header .el-button {
    width: 100%;
  }

  /* 优化分页 */
  .pagination-container :deep(.el-pagination) {
    justify-content: center;
  }

  .pagination-container :deep(.el-pagination__sizes),
  .pagination-container :deep(.el-pagination__jump) {
    display: none;
  }

  /* 对话框移动端适配 */
  .modern-dialog :deep(.el-dialog) {
    width: 95% !important;
    margin: 5vh auto;
  }

  .modern-dialog :deep(.el-dialog__body) {
    padding: 16px;
  }

  .modern-form :deep(.el-form-item__label) {
    font-size: 14px;
  }

  .modern-form :deep(.el-input),
  .modern-form :deep(.el-input-number),
  .modern-form :deep(.el-select) {
    width: 100% !important;
  }

  /* 二维码对话框移动端适配 */
  .qrcode-dialog :deep(.el-dialog) {
    width: 90% !important;
  }

  .qrcode-container {
    padding: 16px;
  }

  .qrcode-container canvas {
    max-width: 100%;
    height: auto !important;
  }

  .product-info {
    font-size: 14px;
  }

  .qrcode-actions {
    flex-direction: column;
    gap: 8px;
  }

  .qrcode-actions .el-button {
    width: 100%;
  }
}
</style>
