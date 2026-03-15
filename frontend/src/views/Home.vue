<template>
  <el-container class="layout-container">
    <!-- 移动端菜单按钮 -->
    <div class="mobile-menu-btn" @click="toggleMobileMenu" v-if="isMobile">
      <el-icon><Menu /></el-icon>
    </div>

    <!-- 侧边栏 -->
    <el-aside
      :width="isMobile ? '280px' : '240px'"
      class="main-aside"
      :class="{ 'mobile-menu-open': mobileMenuOpen, 'mobile-hidden': isMobile && !mobileMenuOpen }"
    >
      <div class="logo-container">
        <div class="logo-icon">Oil</div>
        <span class="logo-text">机油销售系统</span>
        <!-- 移动端关闭按钮 -->
        <el-icon class="mobile-close-btn" @click="closeMobileMenu" v-if="isMobile">
          <Close />
        </el-icon>
      </div>

      <el-menu
        :default-active="activeMenu"
        router
        class="main-menu"
        text-color="#4b5563"
        active-text-color="#4f46e5"
        background-color="#ffffff"
        @select="handleMenuSelect"
      >
        <el-menu-item index="/scan">
          <el-icon><Camera /></el-icon>
          <span>扫码开单</span>
        </el-menu-item>
        <el-menu-item index="/product">
          <el-icon><Goods /></el-icon>
          <span>商品管理</span>
        </el-menu-item>
        <el-menu-item index="/category" v-if="authStore.isAdmin">
          <el-icon><FolderOpened /></el-icon>
          <span>分类管理</span>
        </el-menu-item>
        <el-menu-item index="/customer">
          <el-icon><User /></el-icon>
          <span>客户管理</span>
        </el-menu-item>
        <el-menu-item index="/order">
          <el-icon><Document /></el-icon>
          <span>订单管理</span>
        </el-menu-item>
        <el-menu-item index="/monthly-bill">
          <el-icon><Tickets /></el-icon>
          <span>月结账单</span>
        </el-menu-item>
        <el-menu-item index="/statistics">
          <el-icon><TrendCharts /></el-icon>
          <span>数据统计</span>
        </el-menu-item>
      </el-menu>
    </el-aside>

    <!-- 移动端遮罩层 -->
    <div
      class="mobile-overlay"
      v-if="isMobile && mobileMenuOpen"
      @click="closeMobileMenu"
    ></div>

    <el-container class="content-wrapper">
      <el-header class="main-header">
        <div class="header-left">
          <h2 class="page-title">{{ currentRouteName }}</h2>
        </div>
        <div class="header-right">
          <el-button
            v-if="!authStore.isAdmin"
            type="primary"
            size="small"
            @click="showLoginDialog"
          >
            管理员登录
          </el-button>
          <el-button
            v-else
            type="warning"
            size="small"
            plain
            @click="handleLogout"
          >
            退出管理
          </el-button>
          <el-avatar class="user-avatar" :size="36" src="https://cube.elemecdn.com/0/88/03b0d39583f48206768a7534e55bcpng.png" />
          <span class="user-name" v-if="!isMobile">{{ authStore.isAdmin ? (authStore.userInfo?.nickname || '管理员') : '访客' }}</span>
        </div>
      </el-header>

      <el-main class="main-content">
        <router-view v-slot="{ Component }">
          <transition name="fade" mode="out-in">
            <component :is="Component" />
          </transition>
        </router-view>
      </el-main>
    </el-container>

    <!-- 登录对话框 -->
    <el-dialog
      v-model="loginDialogVisible"
      title="管理员登录"
      width="400px"
      :close-on-click-modal="false"
    >
      <el-form :model="loginForm" :rules="loginRules" ref="loginFormRef" label-width="80px">
        <el-form-item label="用户名" prop="username">
          <el-input
            v-model="loginForm.username"
            placeholder="请输入用户名"
            clearable
            @keyup.enter="handleLogin"
          />
        </el-form-item>
        <el-form-item label="密码" prop="password">
          <el-input
            v-model="loginForm.password"
            type="password"
            placeholder="请输入密码"
            show-password
            clearable
            @keyup.enter="handleLogin"
          />
        </el-form-item>
        <el-form-item style="margin-bottom: 0;">
          <div style="color: #909399; font-size: 12px;">
            提示：登录后可查看商品成本和利润数据
          </div>
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="loginDialogVisible = false">取消</el-button>
        <el-button type="primary" @click="handleLogin" :loading="loginLoading">
          登录
        </el-button>
      </template>
    </el-dialog>
  </el-container>
</template>

<script setup>
import { computed, ref, onMounted, onUnmounted } from 'vue'
import { useRoute } from 'vue-router'
import { TrendCharts, FolderOpened } from '@element-plus/icons-vue'
import { useAuthStore } from '@/stores/auth'
import { authApi } from '@/api/auth'
import { ElMessage } from 'element-plus'

const route = useRoute()
const activeMenu = computed(() => route.path)
const authStore = useAuthStore()

// 登录对话框相关
const loginDialogVisible = ref(false)
const loginLoading = ref(false)
const loginFormRef = ref(null)
const loginForm = ref({
  username: '',
  password: ''
})

const loginRules = {
  username: [
    { required: true, message: '请输入用户名', trigger: 'blur' }
  ],
  password: [
    { required: true, message: '请输入密码', trigger: 'blur' },
    { min: 6, message: '密码长度至少6位', trigger: 'blur' }
  ]
}

// 显示登录对话框
const showLoginDialog = () => {
  loginDialogVisible.value = true
  loginForm.value = { username: '', password: '' }
}

// 登录
const handleLogin = async () => {
  if (!loginFormRef.value) return

  await loginFormRef.value.validate(async (valid) => {
    if (!valid) return

    loginLoading.value = true
    try {
      const res = await authApi.login(loginForm.value)
      authStore.login(res.data.token, res.data)
      ElMessage.success('登录成功')
      loginDialogVisible.value = false
      loginForm.value = { username: '', password: '' }
    } catch (error) {
      ElMessage.error(error.message || '登录失败')
    } finally {
      loginLoading.value = false
    }
  })
}

// 退出登录
const handleLogout = () => {
  authStore.logout()
  ElMessage.success('已退出管理员模式')
}

// 移动端菜单状态
const isMobile = ref(false)
const mobileMenuOpen = ref(false)

// 检测屏幕尺寸
const checkMobile = () => {
  isMobile.value = window.innerWidth < 768
  if (!isMobile.value) {
    mobileMenuOpen.value = false
  }
}

// 切换移动端菜单
const toggleMobileMenu = () => {
  mobileMenuOpen.value = !mobileMenuOpen.value
}

// 关闭移动端菜单
const closeMobileMenu = () => {
  mobileMenuOpen.value = false
}

// 菜单选择时关闭移动端菜单
const handleMenuSelect = () => {
  if (isMobile.value) {
    closeMobileMenu()
  }
}

const currentRouteName = computed(() => {
  const nameMap = {
    '/scan': '扫码开单',
    '/product': '商品管理',
    '/category': '分类管理',
    '/customer': '客户管理',
    '/order': '订单管理',
    '/monthly-bill': '月结账单',
    '/statistics': '数据统计'
  }
  return nameMap[route.path] || '首页'
})

onMounted(() => {
  checkMobile()
  window.addEventListener('resize', checkMobile)
})

onUnmounted(() => {
  window.removeEventListener('resize', checkMobile)
})
</script>

<style scoped>
.layout-container {
  height: 100vh;
  background-color: var(--bg-color);
  position: relative;
}

/* 移动端菜单按钮 */
.mobile-menu-btn {
  position: fixed;
  top: 16px;
  left: 16px;
  width: 44px;
  height: 44px;
  background: var(--primary-color);
  color: white;
  border-radius: 8px;
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  z-index: 1001;
  box-shadow: 0 4px 12px rgba(79, 70, 229, 0.3);
  transition: all 0.3s;
}

.mobile-menu-btn:hover {
  transform: scale(1.05);
  box-shadow: 0 6px 16px rgba(79, 70, 229, 0.4);
}

.mobile-menu-btn .el-icon {
  font-size: 24px;
}

/* 侧边栏 */
.main-aside {
  background-color: white;
  border-right: 1px solid var(--border-color);
  display: flex;
  flex-direction: column;
  box-shadow: 2px 0 8px rgba(0,0,0,0.02);
  transition: transform 0.3s ease;
}

/* 移动端侧边栏隐藏 */
.main-aside.mobile-hidden {
  position: fixed;
  top: 0;
  left: 0;
  height: 100vh;
  transform: translateX(-100%);
  pointer-events: none; /* 隐藏时不接收点击事件 */
  z-index: -1; /* 隐藏时降低层级 */
}

/* 移动端侧边栏显示 */
.main-aside.mobile-menu-open {
  transform: translateX(0);
  pointer-events: auto; /* 显示时恢复点击事件 */
  z-index: 1000; /* 显示时提升层级 */
}

/* 移动端遮罩层 */
.mobile-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.5);
  z-index: 999;
  animation: fadeIn 0.3s;
}

@keyframes fadeIn {
  from {
    opacity: 0;
  }
  to {
    opacity: 1;
  }
}

.logo-container {
  height: 64px;
  display: flex;
  align-items: center;
  padding: 0 24px;
  border-bottom: 1px solid var(--border-color);
  position: relative;
}

.mobile-close-btn {
  position: absolute;
  right: 16px;
  font-size: 24px;
  cursor: pointer;
  color: var(--text-secondary);
  transition: color 0.3s;
}

.mobile-close-btn:hover {
  color: var(--primary-color);
}

.logo-icon {
  width: 32px;
  height: 32px;
  background: linear-gradient(135deg, var(--primary-color), #818cf8);
  border-radius: 8px;
  color: white;
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: bold;
  font-size: 12px;
  margin-right: 12px;
  box-shadow: 0 4px 6px -1px rgba(79, 70, 229, 0.2);
}

.logo-text {
  font-size: 18px;
  font-weight: 700;
  color: var(--text-main);
  letter-spacing: -0.5px;
}

.main-menu {
  border-right: none;
  padding: 16px 0;
  flex: 1;
}

:deep(.el-menu-item) {
  margin: 4px 12px;
  border-radius: 8px;
  height: 48px;
  line-height: 48px;
  border: 1px solid transparent;
}

:deep(.el-menu-item.is-active) {
  background-color: var(--primary-light);
  font-weight: 600;
  border-color: rgba(79, 70, 229, 0.1);
}

:deep(.el-menu-item:hover:not(.is-active)) {
  background-color: #f9fafb;
}

:deep(.el-menu-item .el-icon) {
  font-size: 18px;
  margin-right: 12px;
}

.content-wrapper {
  background-color: var(--bg-color);
  display: flex;
  flex-direction: column;
}

.main-header {
  height: 64px;
  background-color: white;
  border-bottom: 1px solid var(--border-color);
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 0 32px;
  box-shadow: 0 1px 2px 0 rgba(0, 0, 0, 0.02);
}

.page-title {
  font-size: 20px;
  font-weight: 600;
  color: var(--text-main);
}

.header-right {
  display: flex;
  align-items: center;
  gap: 12px;
}

.user-name {
  font-size: 14px;
  font-weight: 500;
  color: var(--text-secondary);
}

.main-content {
  padding: 24px;
  overflow-y: auto;
}

/* 移动端适配 */
@media (max-width: 768px) {
  .main-aside {
    position: fixed;
    top: 0;
    left: 0;
    height: 100vh;
  }

  .main-header {
    padding: 0 16px 0 70px;
  }

  .page-title {
    font-size: 18px;
  }

  .user-avatar {
    width: 32px;
    height: 32px;
  }

  .main-content {
    padding: 16px;
  }

  .content-wrapper {
    width: 100%;
  }
}
</style>
