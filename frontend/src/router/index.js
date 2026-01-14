import { createRouter, createWebHistory } from 'vue-router'

const routes = [
  {
    path: '/',
    redirect: '/home'
  },
  {
    path: '/home',
    name: 'Home',
    component: () => import('@/views/Home.vue'),
    children: [
      {
        path: '/product',
        name: 'Product',
        component: () => import('@/views/Product.vue')
      },
      {
        path: '/customer',
        name: 'Customer',
        component: () => import('@/views/Customer.vue')
      },
      {
        path: '/order',
        name: 'Order',
        component: () => import('@/views/Order.vue')
      },
      {
        path: '/monthly-bill',
        name: 'MonthlyBill',
        component: () => import('@/views/MonthlyBill.vue')
      }
    ]
  },
  {
    path: '/scan',
    name: 'Scan',
    component: () => import('@/views/Scan.vue')
  }
]

const router = createRouter({
  history: createWebHistory(),
  routes
})

export default router
