<template>
  <el-container class="layout-container">
    <el-aside width="240px" class="main-aside">
      <div class="logo-container">
        <div class="logo-icon">Oil</div>
        <span class="logo-text">机油销售系统</span>
      </div>
      
      <el-menu
        :default-active="activeMenu"
        router
        class="main-menu"
        text-color="#4b5563"
        active-text-color="#4f46e5"
        background-color="#ffffff"
      >
        <el-menu-item index="/scan">
          <el-icon><Camera /></el-icon>
          <span>扫码开单</span>
        </el-menu-item>
        <el-menu-item index="/product">
          <el-icon><Goods /></el-icon>
          <span>商品管理</span>
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
      </el-menu>
    </el-aside>
    
    <el-container class="content-wrapper">
      <el-header class="main-header">
        <div class="header-left">
          <h2 class="page-title">{{ currentRouteName }}</h2>
        </div>
        <div class="header-right">
          <el-avatar class="user-avatar" :size="36" src="https://cube.elemecdn.com/0/88/03b0d39583f48206768a7534e55bcpng.png" />
          <span class="user-name">管理员</span>
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
  </el-container>
</template>

<script setup>
import { computed } from 'vue'
import { useRoute } from 'vue-router'

const route = useRoute()
const activeMenu = computed(() => route.path)

const currentRouteName = computed(() => {
  const nameMap = {
    '/scan': '扫码开单',
    '/product': '商品管理',
    '/customer': '客户管理',
    '/order': '订单管理',
    '/monthly-bill': '月结账单'
  }
  return nameMap[route.path] || '首页'
})
</script>

<style scoped>
.layout-container {
  height: 100vh;
  background-color: var(--bg-color);
}

.main-aside {
  background-color: white;
  border-right: 1px solid var(--border-color);
  display: flex;
  flex-direction: column;
  box-shadow: 2px 0 8px rgba(0,0,0,0.02);
  z-index: 10;
}

.logo-container {
  height: 64px;
  display: flex;
  align-items: center;
  padding: 0 24px;
  border-bottom: 1px solid var(--border-color);
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
</style>
