<template>
  <div class="operation-log-container">
    <!-- 筛选卡片 -->
    <el-card class="search-card" shadow="never">
      <el-form :inline="true" :model="searchForm" class="search-form">
        <el-form-item label="操作模块">
          <el-select v-model="searchForm.module" placeholder="全部模块" clearable style="width: 140px">
            <el-option label="商品管理" value="商品管理" />
            <el-option label="客户管理" value="客户管理" />
            <el-option label="订单管理" value="订单管理" />
            <el-option label="月结账单" value="月结账单" />
            <el-option label="分类管理" value="分类管理" />
            <el-option label="用户管理" value="用户管理" />
          </el-select>
        </el-form-item>
        <el-form-item label="操作类型">
          <el-select v-model="searchForm.action" placeholder="全部类型" clearable style="width: 140px">
            <el-option label="新增" value="新增" />
            <el-option label="修改" value="修改" />
            <el-option label="删除" value="删除" />
            <el-option label="批量删除" value="批量删除" />
            <el-option label="登录" value="登录" />
            <el-option label="生成账单" value="生成账单" />
            <el-option label="结算" value="结算" />
            <el-option label="导出" value="导出" />
            <el-option label="生成二维码" value="生成二维码" />
          </el-select>
        </el-form-item>
        <el-form-item label="操作人">
          <el-input v-model="searchForm.operatorName" placeholder="操作人姓名" clearable style="width: 150px" />
        </el-form-item>
        <el-form-item label="操作时间">
          <el-date-picker
            v-model="searchForm.dateRange"
            type="daterange"
            range-separator="至"
            start-placeholder="开始日期"
            end-placeholder="结束日期"
            format="YYYY-MM-DD"
            value-format="YYYY-MM-DD"
            style="width: 260px"
          />
        </el-form-item>
        <el-form-item>
          <el-button type="primary" icon="Search" @click="handleSearch">查询</el-button>
          <el-button icon="Refresh" @click="handleReset">重置</el-button>
        </el-form-item>
      </el-form>
    </el-card>

    <!-- 表格卡片 -->
    <el-card class="table-card" shadow="never">
      <template #header>
        <div class="card-header">
          <div class="header-title">
            <el-icon><Notebook /></el-icon>
            <span>操作日志</span>
          </div>
        </div>
      </template>

      <!-- 桌面端表格 -->
      <div class="desktop-table-view">
        <el-table :data="tableData" class="modern-table" v-loading="loading" stripe>
          <el-table-column prop="id" label="ID" width="70" align="center" />
          <el-table-column prop="module" label="操作模块" width="110">
            <template #default="{ row }">
              <el-tag :type="moduleTagType(row.module)" size="small">{{ row.module }}</el-tag>
            </template>
          </el-table-column>
          <el-table-column prop="action" label="操作类型" width="110">
            <template #default="{ row }">
              <el-tag :type="actionTagType(row.action)" size="small" effect="plain">{{ row.action }}</el-tag>
            </template>
          </el-table-column>
          <el-table-column prop="operatorName" label="操作人" width="120" />
          <el-table-column prop="requestIp" label="IP地址" width="140" show-overflow-tooltip />
          <el-table-column prop="requestUrl" label="请求URL" min-width="200" show-overflow-tooltip />
          <el-table-column prop="status" label="状态" width="80" align="center">
            <template #default="{ row }">
              <el-tag :type="row.status === '成功' ? 'success' : 'danger'" size="small">
                {{ row.status }}
              </el-tag>
            </template>
          </el-table-column>
          <el-table-column prop="createTime" label="操作时间" width="170">
            <template #default="{ row }">
              {{ formatDateTime(row.createTime) }}
            </template>
          </el-table-column>
          <el-table-column label="操作" width="80" align="center" fixed="right">
            <template #default="{ row }">
              <el-button type="primary" link size="small" @click="showDetail(row)">详情</el-button>
            </template>
          </el-table-column>
        </el-table>
      </div>

      <!-- 移动端卡片视图 -->
      <div class="mobile-card-view">
        <div v-for="row in tableData" :key="row.id" class="log-card" @click="showDetail(row)">
          <div class="log-card-header">
            <el-tag :type="moduleTagType(row.module)" size="small">{{ row.module }}</el-tag>
            <el-tag :type="actionTagType(row.action)" size="small" effect="plain">{{ row.action }}</el-tag>
            <el-tag :type="row.status === '成功' ? 'success' : 'danger'" size="small">
              {{ row.status }}
            </el-tag>
          </div>
          <div class="log-card-body">
            <div class="log-card-row">
              <span class="label">操作人：</span>
              <span>{{ row.operatorName || '未知' }}</span>
            </div>
            <div class="log-card-row">
              <span class="label">IP：</span>
              <span>{{ row.requestIp }}</span>
            </div>
            <div class="log-card-row">
              <span class="label">时间：</span>
              <span>{{ formatDateTime(row.createTime) }}</span>
            </div>
          </div>
        </div>
      </div>

      <!-- 分页 -->
      <div class="pagination-container">
        <el-pagination
          v-model:current-page="pagination.current"
          v-model:page-size="pagination.size"
          :total="pagination.total"
          :page-sizes="[10, 20, 50, 100]"
          layout="total, sizes, prev, pager, next, jumper"
          @current-change="loadData"
          @size-change="handleSizeChange"
          background
        />
      </div>
    </el-card>

    <!-- 详情对话框 -->
    <el-dialog v-model="detailVisible" title="操作详情" width="600px" class="modern-dialog">
      <el-descriptions :column="1" border size="large">
        <el-descriptions-item label="操作模块">{{ detailRow.module }}</el-descriptions-item>
        <el-descriptions-item label="操作类型">{{ detailRow.action }}</el-descriptions-item>
        <el-descriptions-item label="操作人">{{ detailRow.operatorName || '未知' }}</el-descriptions-item>
        <el-descriptions-item label="IP地址">{{ detailRow.requestIp }}</el-descriptions-item>
        <el-descriptions-item label="请求方法">{{ detailRow.requestMethod }}</el-descriptions-item>
        <el-descriptions-item label="请求URL">{{ detailRow.requestUrl }}</el-descriptions-item>
        <el-descriptions-item label="操作状态">
          <el-tag :type="detailRow.status === '成功' ? 'success' : 'danger'" size="small">
            {{ detailRow.status }}
          </el-tag>
        </el-descriptions-item>
        <el-descriptions-item label="操作时间">{{ formatDateTime(detailRow.createTime) }}</el-descriptions-item>
        <el-descriptions-item v-if="detailRow.beforeData" label="操作前数据">
          <div class="params-content before-data">{{ formatJson(detailRow.beforeData) }}</div>
        </el-descriptions-item>
        <el-descriptions-item v-if="detailRow.afterData" label="操作后数据">
          <div class="params-content after-data">{{ formatJson(detailRow.afterData) }}</div>
        </el-descriptions-item>
        <el-descriptions-item v-if="detailRow.requestParams && !detailRow.beforeData && !detailRow.afterData" label="请求参数">
          <div class="params-content">{{ formatJson(detailRow.requestParams) }}</div>
        </el-descriptions-item>
        <el-descriptions-item v-if="detailRow.errorMsg" label="错误信息">
          <span style="color: var(--danger-color)">{{ detailRow.errorMsg }}</span>
        </el-descriptions-item>
      </el-descriptions>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import { operationLogApi } from '@/api/index'
import { formatDateTime } from '@/utils/format'

const loading = ref(false)
const tableData = ref([])
const pagination = reactive({ current: 1, size: 10, total: 0 })

const searchForm = reactive({
  module: '',
  action: '',
  operatorName: '',
  dateRange: null
})

// 详情弹窗
const detailVisible = ref(false)
const detailRow = ref({})

const moduleTagType = (module) => {
  const map = {
    '商品管理': 'primary',
    '客户管理': 'success',
    '订单管理': 'warning',
    '月结账单': 'info',
    '分类管理': 'info',
    '用户管理': 'danger'
  }
  return map[module] || ''
}

const actionTagType = (action) => {
  if (action === '删除' || action === '批量删除') return 'danger'
  if (action === '新增' || action === '生成账单' || action === '生成二维码') return 'success'
  if (action === '修改' || action === '结算') return 'warning'
  if (action === '登录') return 'primary'
  if (action === '导出') return 'info'
  return ''
}

const loadData = async () => {
  loading.value = true
  try {
    const params = {
      current: pagination.current,
      size: pagination.size
    }
    if (searchForm.module) params.module = searchForm.module
    if (searchForm.action) params.action = searchForm.action
    if (searchForm.operatorName) params.operatorName = searchForm.operatorName
    if (searchForm.dateRange && searchForm.dateRange.length === 2) {
      params.startDate = searchForm.dateRange[0]
      params.endDate = searchForm.dateRange[1]
    }
    const res = await operationLogApi.getPage(params)
    tableData.value = res.data.records
    pagination.total = res.data.total
  } catch (error) {
    ElMessage.error(error.message || '加载失败')
  } finally {
    loading.value = false
  }
}

const handleSearch = () => {
  pagination.current = 1
  loadData()
}

const handleSizeChange = () => {
  pagination.current = 1
  loadData()
}

const handleReset = () => {
  searchForm.module = ''
  searchForm.action = ''
  searchForm.operatorName = ''
  searchForm.dateRange = null
  handleSearch()
}

const showDetail = (row) => {
  detailRow.value = { ...row }
  detailVisible.value = true
}

const formatJson = (str) => {
  if (str === null || str === undefined) return ''
  if (typeof str === 'object') return JSON.stringify(str, null, 2)
  try {
    const obj = JSON.parse(str)
    return JSON.stringify(obj, null, 2)
  } catch {
    return String(str)
  }
}

onMounted(() => {
  loadData()
})
</script>

<style scoped>
.operation-log-container {
  max-width: 1400px;
}

.search-card {
  margin-bottom: 16px;
  border-radius: var(--radius-lg);
}

.search-form {
  display: flex;
  flex-wrap: wrap;
  gap: 4px;
}

.table-card {
  border-radius: var(--radius-lg);
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.header-title {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 16px;
  font-weight: 600;
  color: var(--text-main);
}

.header-title .el-icon {
  font-size: 18px;
  color: var(--primary-color);
}

.params-content {
  background: var(--bg-color);
  border: 1px solid var(--border-color);
  border-radius: var(--radius-md);
  padding: 12px;
  font-size: 13px;
  font-family: 'Courier New', monospace;
  white-space: pre-wrap;
  word-break: break-all;
  max-height: 400px;
  overflow-y: auto;
  line-height: 1.6;
  color: var(--text-main);
}

.params-content.before-data {
  border-left: 4px solid var(--danger-color);
  background: #fef2f2;
}

.params-content.after-data {
  border-left: 4px solid var(--success-color);
  background: #f0fdf4;
}

.pagination-container {
  display: flex;
  justify-content: center;
  margin-top: 20px;
}

/* 移动端卡片视图 */
.mobile-card-view {
  display: none;
}

/* 移动端适配 */
@media (max-width: 768px) {
  .desktop-table-view {
    display: none !important;
  }

  .mobile-card-view {
    display: flex;
    flex-direction: column;
    gap: 12px;
  }

  .log-card {
    background: white;
    border: 1px solid var(--border-color);
    border-radius: var(--radius-md);
    padding: 16px;
    cursor: pointer;
    transition: all 0.3s;
  }

  .log-card:active {
    background: var(--bg-color);
  }

  .log-card-header {
    display: flex;
    gap: 8px;
    margin-bottom: 10px;
    flex-wrap: wrap;
  }

  .log-card-body {
    display: flex;
    flex-direction: column;
    gap: 6px;
  }

  .log-card-row {
    display: flex;
    font-size: 13px;
    color: var(--text-secondary);
  }

  .log-card-row .label {
    flex-shrink: 0;
    color: var(--text-placeholder);
  }

  .search-form {
    flex-direction: column;
  }

  .search-form .el-form-item {
    margin-right: 0;
    width: 100%;
  }

  .search-form .el-select,
  .search-form .el-input,
  .search-form .el-date-picker {
    width: 100% !important;
  }
}
</style>
