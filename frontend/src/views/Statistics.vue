<template>
  <div class="statistics-page">
    <!-- 筛选栏 -->
    <div class="search-card">
      <el-radio-group v-model="queryType" @change="onTypeChange" size="default">
        <el-radio-button value="day">按日</el-radio-button>
        <el-radio-button value="week">按周</el-radio-button>
        <el-radio-button value="month">按月</el-radio-button>
      </el-radio-group>
      <el-date-picker
        v-model="dateRange"
        type="daterange"
        range-separator="至"
        start-placeholder="开始日期"
        end-placeholder="结束日期"
        value-format="YYYY-MM-DD"
        :shortcuts="dateShortcuts"
        style="margin-left: 16px;"
        @change="loadData"
      />
    </div>

    <!-- 汇总卡片 -->
    <div class="summary-row">
      <div class="summary-card">
        <div class="summary-label">期间总销售额</div>
        <div class="summary-value primary">¥{{ totalAmount.toFixed(2) }}</div>
      </div>
      <div class="summary-card">
        <div class="summary-label">期间订单天数</div>
        <div class="summary-value">{{ trendData.length }} 天</div>
      </div>
      <div class="summary-card">
        <div class="summary-label">TOP 商品</div>
        <div class="summary-value accent">{{ topProduct }}</div>
      </div>
      <div class="summary-card">
        <div class="summary-label">TOP 客户</div>
        <div class="summary-value accent">{{ topCustomer }}</div>
      </div>
    </div>

    <!-- 趋势图 -->
    <div class="chart-card">
      <div class="card-title">销售额趋势</div>
      <div ref="trendChartEl" class="chart-box" v-loading="loading"></div>
    </div>

    <!-- 排行榜 -->
    <div class="rank-row">
      <div class="chart-card half">
        <div class="card-title">商品销量排行 TOP10</div>
        <div ref="productChartEl" class="chart-box" v-loading="loading"></div>
      </div>
      <div class="chart-card half">
        <div class="card-title">客户消费排行 TOP10</div>
        <div ref="customerChartEl" class="chart-box" v-loading="loading"></div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, onUnmounted, nextTick } from 'vue'
import * as echarts from 'echarts'
import { statisticsApi } from '@/api/index.js'

// ---------- 状态 ----------
const loading = ref(false)
const queryType = ref('day')

// 默认最近 30 天
const today = new Date()
const thirtyDaysAgo = new Date(today)
thirtyDaysAgo.setDate(today.getDate() - 29)
const fmt = (d) => d.toISOString().slice(0, 10)
const dateRange = ref([fmt(thirtyDaysAgo), fmt(today)])

const trendData = ref([])
const productRank = ref([])
const customerRank = ref([])

// ---------- 汇总计算 ----------
const totalAmount = computed(() =>
  trendData.value.reduce((s, i) => s + Number(i.amount || 0), 0)
)
const topProduct = computed(() => productRank.value[0]?.productName || '-')
const topCustomer = computed(() => customerRank.value[0]?.customerName || '-')

// ---------- 图表实例 ----------
const trendChartEl = ref(null)
const productChartEl = ref(null)
const customerChartEl = ref(null)
let trendChart = null
let productChart = null
let customerChart = null

// ---------- 日期快捷选项 ----------
const dateShortcuts = [
  { text: '最近7天',  value: () => { const e = new Date(); const s = new Date(); s.setDate(e.getDate()-6); return [fmt(s), fmt(e)] } },
  { text: '最近30天', value: () => { const e = new Date(); const s = new Date(); s.setDate(e.getDate()-29); return [fmt(s), fmt(e)] } },
  { text: '本月',     value: () => { const e = new Date(); const s = new Date(e.getFullYear(), e.getMonth(), 1); return [fmt(s), fmt(e)] } },
  { text: '本年',     value: () => { const e = new Date(); const s = new Date(e.getFullYear(), 0, 1); return [fmt(s), fmt(e)] } },
]

// ---------- 加载数据 ----------
async function loadData() {
  if (!dateRange.value) return
  loading.value = true
  try {
    const res = await statisticsApi.get({
      type: queryType.value,
      start: dateRange.value[0],
      end: dateRange.value[1],
    })
    trendData.value = res.data.trend || []
    productRank.value = res.data.productRank || []
    customerRank.value = res.data.customerRank || []
    await nextTick()
    renderCharts()
  } finally {
    loading.value = false
  }
}

function onTypeChange() {
  loadData()
}

// ---------- 渲染图表 ----------
function renderCharts() {
  renderTrend()
  renderProductRank()
  renderCustomerRank()
}

function renderTrend() {
  if (!trendChartEl.value) return
  if (!trendChart) trendChart = echarts.init(trendChartEl.value)
  trendChart.setOption({
    tooltip: { trigger: 'axis', valueFormatter: v => '¥' + Number(v).toFixed(2) },
    grid: { left: 60, right: 20, top: 20, bottom: 40 },
    xAxis: {
      type: 'category',
      data: trendData.value.map(i => i.date),
      axisLabel: { rotate: trendData.value.length > 20 ? 30 : 0, fontSize: 12 }
    },
    yAxis: { type: 'value', axisLabel: { formatter: v => '¥' + v } },
    series: [{
      type: 'line',
      data: trendData.value.map(i => Number(i.amount).toFixed(2)),
      smooth: true,
      symbol: 'circle',
      symbolSize: 6,
      lineStyle: { color: '#4f46e5', width: 2 },
      itemStyle: { color: '#4f46e5' },
      areaStyle: { color: { type: 'linear', x: 0, y: 0, x2: 0, y2: 1, colorStops: [{ offset: 0, color: 'rgba(79,70,229,0.25)' }, { offset: 1, color: 'rgba(79,70,229,0)' }] } }
    }]
  })
}

function renderProductRank() {
  if (!productChartEl.value) return
  if (!productChart) productChart = echarts.init(productChartEl.value)
  const items = [...productRank.value].reverse()
  productChart.setOption({
    tooltip: { trigger: 'axis', axisPointer: { type: 'shadow' } },
    grid: { left: 120, right: 20, top: 10, bottom: 30 },
    xAxis: { type: 'value' },
    yAxis: { type: 'category', data: items.map(i => i.productName), axisLabel: { fontSize: 12 } },
    series: [{
      type: 'bar',
      data: items.map(i => i.totalQuantity),
      itemStyle: { color: '#10b981', borderRadius: [0, 4, 4, 0] },
      label: { show: true, position: 'right', formatter: '{c} 件' }
    }]
  })
}

function renderCustomerRank() {
  if (!customerChartEl.value) return
  if (!customerChart) customerChart = echarts.init(customerChartEl.value)
  const items = [...customerRank.value].reverse()
  customerChart.setOption({
    tooltip: { trigger: 'axis', axisPointer: { type: 'shadow' }, valueFormatter: v => '¥' + Number(v).toFixed(2) },
    grid: { left: 100, right: 20, top: 10, bottom: 30 },
    xAxis: { type: 'value', axisLabel: { formatter: v => '¥' + v } },
    yAxis: { type: 'category', data: items.map(i => i.customerName), axisLabel: { fontSize: 12 } },
    series: [{
      type: 'bar',
      data: items.map(i => Number(i.totalAmount).toFixed(2)),
      itemStyle: { color: '#f59e0b', borderRadius: [0, 4, 4, 0] },
      label: { show: true, position: 'right', formatter: p => '¥' + Number(p.value).toFixed(0) }
    }]
  })
}

// ---------- 响应式 resize ----------
function handleResize() {
  trendChart?.resize()
  productChart?.resize()
  customerChart?.resize()
}

onMounted(() => {
  loadData()
  window.addEventListener('resize', handleResize)
})

onUnmounted(() => {
  window.removeEventListener('resize', handleResize)
  trendChart?.dispose()
  productChart?.dispose()
  customerChart?.dispose()
})
</script>

<style scoped>
.statistics-page {
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.search-card {
  background: white;
  border-radius: var(--radius-md);
  padding: 16px 24px;
  display: flex;
  align-items: center;
  box-shadow: var(--shadow-sm);
  flex-wrap: wrap;
  gap: 12px;
}

.summary-row {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 16px;
}

.summary-card {
  background: white;
  border-radius: var(--radius-md);
  padding: 20px 24px;
  box-shadow: var(--shadow-sm);
}

.summary-label {
  font-size: 13px;
  color: var(--text-secondary);
  margin-bottom: 8px;
}

.summary-value {
  font-size: 22px;
  font-weight: 700;
  color: var(--text-main);
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.summary-value.primary {
  color: var(--primary-color);
}

.summary-value.accent {
  font-size: 18px;
  color: #10b981;
}

.chart-card {
  background: white;
  border-radius: var(--radius-md);
  padding: 20px 24px;
  box-shadow: var(--shadow-sm);
}

.chart-card.half {
  flex: 1;
  min-width: 0;
}

.rank-row {
  display: flex;
  gap: 20px;
}

.card-title {
  font-size: 15px;
  font-weight: 600;
  color: var(--text-main);
  margin-bottom: 16px;
}

.chart-box {
  width: 100%;
  height: 320px;
}

@media (max-width: 768px) {
  .summary-row {
    grid-template-columns: repeat(2, 1fr);
  }
  .rank-row {
    flex-direction: column;
  }
}
</style>
