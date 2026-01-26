// 使用 Node.js Canvas 生成应用图标
const fs = require('fs');
const { createCanvas } = require('canvas');

function generateIcon(size, filename) {
  const canvas = createCanvas(size, size);
  const ctx = canvas.getContext('2d');
  const radius = size * 0.15;

  // 绘制圆角矩形背景
  ctx.fillStyle = '#4f46e5';
  ctx.beginPath();
  ctx.moveTo(radius, 0);
  ctx.lineTo(size - radius, 0);
  ctx.quadraticCurveTo(size, 0, size, radius);
  ctx.lineTo(size, size - radius);
  ctx.quadraticCurveTo(size, size, size - radius, size);
  ctx.lineTo(radius, size);
  ctx.quadraticCurveTo(0, size, 0, size - radius);
  ctx.lineTo(0, radius);
  ctx.quadraticCurveTo(0, 0, radius, 0);
  ctx.closePath();
  ctx.fill();

  // 绘制油滴形状
  ctx.fillStyle = 'rgba(255, 255, 255, 0.9)';
  ctx.beginPath();
  const centerX = size / 2;
  const startY = size * 0.25;
  const endY = size * 0.55;
  const width = size * 0.2;

  ctx.moveTo(centerX, startY);
  ctx.quadraticCurveTo(centerX - width, startY + width, centerX - width, endY);
  ctx.quadraticCurveTo(centerX - width, endY + width, centerX, endY + width);
  ctx.quadraticCurveTo(centerX + width, endY + width, centerX + width, endY);
  ctx.quadraticCurveTo(centerX + width, startY + width, centerX, startY);
  ctx.fill();

  // 绘制文字 "油"
  ctx.fillStyle = '#ffffff';
  ctx.font = `bold ${size * 0.25}px Arial, sans-serif`;
  ctx.textAlign = 'center';
  ctx.textBaseline = 'middle';
  ctx.fillText('油', centerX, size * 0.8);

  // 保存为 PNG
  const buffer = canvas.toBuffer('image/png');
  fs.writeFileSync(filename, buffer);
  console.log(`✅ 生成图标: ${filename}`);
}

// 生成两个尺寸的图标
try {
  generateIcon(192, 'public/icon-192.png');
  generateIcon(512, 'public/icon-512.png');
  console.log('🎉 图标生成完成!');
} catch (error) {
  console.error('❌ 生成图标失败:', error.message);
  console.log('提示: 请先安装 canvas 库: npm install canvas');
}
