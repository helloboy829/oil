<template>
  <div class="category-page">
    <el-card class="search-card" shadow="never">
      <div class="card-header">
        <div class="header-left">
          <el-button type="primary" @click="handleAdd" icon="Plus">新增分类</el-button>
        </div>
        <div class="header-right">
          <el-button @click="loadData" icon="Refresh">刷新</el-button>
        </div>
      </div>

      <el-table
        :data="tableData"
        class="modern-table"
        v-loading="loading"
        row-key="id"
        :tree-props="{ children: 'children', hasChildren: 'hasChildren' }"
        default-expand-all
      >
        <el-table-column prop="id" label="ID" width="80" align="center" />
        <el-table-column prop="name" label="分类名称" min-width="200" />
        <el-table-column label="商品数量" width="120" align="center">
          <template #default="{ row }">
            <el-tag type="info" size="small">{{ row.productCount }} 种</el-tag>
          </template>
        </el-table-column>
        <el-table-column label="库存总量" width="120" align="center">
          <template #default="{ row }">
            <el-tag type="success" size="small">{{ row.productCount }} 件</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="sort" label="排序" width="100" align="center" />
        <el-table-column label="操作" width="200" align="center" fixed="right">
          <template #default="{ row }">
            <el-button type="primary" size="small" @click="handleEdit(row)" icon="Edit">编辑</el-button>
            <el-button type="danger" size="small" @click="handleDelete(row)" icon="Delete">删除</el-button>
          </template>
        </el-table-column>
      </el-table>
    </el-card>

    <!-- 新增/编辑对话框 -->
    <el-dialog v-model="dialogVisible" :title="dialogTitle" width="500px" class="modern-dialog">
      <el-form ref="formRef" :model="form" :rules="formRules" label-width="100px">
        <el-form-item label="父分类" prop="parentId">
          <el-tree-select
            v-model="form.parentId"
            :data="categoryTreeOptions"
            placeholder="请选择父分类（不选则为顶级分类）"
            clearable
            check-strictly
            :render-after-expand="false"
            style="width: 100%;"
            node-key="id"
            :props="{ label: 'name', children: 'children' }"
          />
          <div class="form-tip">不选择父分类则创建为顶级分类</div>
        </el-form-item>
        <el-form-item label="分类名称" prop="name">
          <el-input v-model="form.name" placeholder="请输入分类名称" maxlength="20" show-word-limit />
        </el-form-item>
        <el-form-item label="排序" prop="sort">
          <el-input-number v-model="form.sort" :min="0" :max="999" style="width: 100%;" />
          <div class="form-tip">数字越小排序越靠前</div>
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
import { ref, reactive, onMounted, computed } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { categoryApi, productApi } from '@/api/index.js'

const loading = ref(false)
const tableData = ref([])
const dialogVisible = ref(false)
const dialogTitle = ref('')
const formRef = ref(null)

const form = reactive({
  id: null,
  name: '',
  parentId: null,
  sort: 0
})

const formRules = {
  name: [
    { required: true, message: '请输入分类名称', trigger: 'blur' },
    { min: 1, max: 20, message: '长度在 1 到 20 个字符', trigger: 'blur' }
  ],
  sort: [
    { required: true, message: '请输入排序号', trigger: 'blur' }
  ]
}

// 计算父分类选择器的数据（编辑时需要排除当前分类及其子分类）
const categoryTreeOptions = computed(() => {
  if (form.id) {
    // 编辑模式：排除当前分类及其子分类
    return filterSelfAndChildren(tableData.value, form.id)
  }
  // 新增模式：显示所有分类
  return tableData.value
})

// 递归过滤掉指定ID及其所有子分类
const filterSelfAndChildren = (categories, excludeId) => {
  return categories.filter(cat => cat.id !== excludeId).map(cat => {
    if (cat.children && cat.children.length > 0) {
      return {
        ...cat,
        children: filterSelfAndChildren(cat.children, excludeId)
      }
    }
    return cat
  })
}

// 加载数据
const loadData = async () => {
  loading.value = true
  try {
    const res = await categoryApi.getListWithCount()
    tableData.value = res.data || []
  } catch (error) {
    ElMessage.error('加载数据失败：' + (error.message || '未知错误'))
  } finally {
    loading.value = false
  }
}

// 新增
const handleAdd = () => {
  dialogTitle.value = '新增分类'
  Object.assign(form, {
    id: null,
    name: '',
    parentId: null,
    sort: 0
  })
  dialogVisible.value = true
}

// 编辑
const handleEdit = (row) => {
  dialogTitle.value = '编辑分类'
  Object.assign(form, {
    id: row.id,
    name: row.name,
    parentId: row.parentId,
    sort: row.sort
  })
  dialogVisible.value = true
}

// 提交
const handleSubmit = async () => {
  if (!formRef.value) return

  try {
    await formRef.value.validate()
  } catch (error) {
    ElMessage.warning('请填写必填字段')
    return
  }

  // 检查是否选择了自己作为父分类
  if (form.id && form.parentId === form.id) {
    ElMessage.error('不能选择自己作为父分类')
    return
  }

  try {
    if (form.id) {
      await categoryApi.update(form)
      ElMessage.success('编辑成功')
    } else {
      await categoryApi.add(form)
      ElMessage.success('新增成功')
    }
    dialogVisible.value = false
    await loadData()
  } catch (error) {
    ElMessage.error('操作失败：' + (error.response?.data?.message || error.message || '未知错误'))
  }
}

// 删除
const handleDelete = async (row) => {
  // 先检查是否有子分类
  if (row.children && row.children.length > 0) {
    ElMessage.warning('该分类下有子分类，请先删除子分类')
    return
  }

  // 检查是否有关联商品
  if (row.productCount > 0) {
    ElMessageBox.confirm(
      `该分类下有 ${row.productCount} 件商品库存，删除后这些商品将变为"未分类"，确定删除吗？`,
      '警告',
      {
        confirmButtonText: '确定删除',
        cancelButtonText: '取消',
        type: 'warning',
        dangerouslyUseHTMLString: true
      }
    ).then(async () => {
      await deleteCategory(row.id)
    })
  } else {
    ElMessageBox.confirm('确定删除该分类吗？', '提示', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    }).then(async () => {
      await deleteCategory(row.id)
    })
  }
}

const deleteCategory = async (id) => {
  try {
    await categoryApi.delete(id)
    ElMessage.success('删除成功')
    await loadData()
  } catch (error) {
    ElMessage.error('删除失败：' + (error.response?.data?.message || error.message || '未知错误'))
  }
}

onMounted(() => {
  loadData()
})
</script>

<style scoped>
.category-page {
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.search-card {
  background: white;
  border-radius: var(--radius-md);
  box-shadow: var(--shadow-sm);
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
}

.header-left {
  display: flex;
  gap: 12px;
}

.header-right {
  display: flex;
  gap: 12px;
}

.modern-table {
  width: 100%;
}

.modern-dialog .form-tip {
  font-size: 12px;
  color: var(--text-secondary);
  margin-top: 4px;
}

.dialog-footer {
  display: flex;
  justify-content: flex-end;
  gap: 12px;
}

@media (max-width: 768px) {
  .card-header {
    flex-direction: column;
    gap: 12px;
    align-items: stretch;
  }

  .header-left,
  .header-right {
    flex-direction: column;
  }

  .header-left .el-button,
  .header-right .el-button {
    width: 100%;
  }
}
</style>
