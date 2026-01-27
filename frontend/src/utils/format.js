/**
 * 格式化日期时间
 * @param {string} dateTimeStr - ISO格式的日期时间字符串
 * @returns {string} 格式化后的日期时间字符串
 */
export function formatDateTime(dateTimeStr) {
  if (!dateTimeStr) return ''
  // 将 ISO 格式的 T 替换为空格，并去掉毫秒部分
  return dateTimeStr.replace('T', ' ').split('.')[0]
}

/**
 * 格式化日期
 * @param {string} dateStr - ISO格式的日期字符串
 * @returns {string} 格式化后的日期字符串
 */
export function formatDate(dateStr) {
  if (!dateStr) return ''
  return dateStr.split('T')[0]
}
