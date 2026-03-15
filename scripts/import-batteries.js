/**
 * 批量导入蓄电池商品数据脚本
 */

const batteriesData = [
  // 能洋系列
  { name: "能洋36V反小头", price: 190, stock: 2 },
  { name: "能洋45L反大头", price: 200, stock: 2 },
  { name: "能洋45L反小头", price: 200, stock: 2 },
  { name: "能洋45R正粗", price: 200, stock: 2 },
  { name: "能洋54466R", price: 260, stock: 1 },
  { name: "能洋54466L", price: 260, stock: 1 },
  { name: "能洋58500R", price: 260, stock: 2 },
  { name: "能洋86550L反", price: 270, stock: 2 },
  { name: "能洋85750R正粗", price: 270, stock: 2 },
  { name: "能洋L2400R", price: 270, stock: 1 },
  { name: "能洋L2400L反头", price: 270, stock: 2 },
  { name: "能洋75D23L反头", price: 275, stock: 2 },
  { name: "能洋80D26L反头", price: 310, stock: 1 },
  { name: "能洋80D26R正粗", price: 310, stock: 1 },
  { name: "能洋70深头56318L反", price: 330, stock: 0 },
  { name: "能洋深头57069L反", price: 330, stock: 0 },
  { name: "能洋95D31R正头", price: 360, stock: 2 },
  { name: "能洋95D31L反头", price: 360, stock: 2 },
  { name: "能洋N125短头", price: 430, stock: 1 },
  { name: "能洋N120R", price: 520, stock: 2 },
  { name: "能洋N165R", price: 590, stock: 0 },

  // 银标瓦尔塔系列
  { name: "银标瓦尔塔65D23L反", price: 370, stock: 2 },
  { name: "银标瓦尔塔L2400L反", price: 370, stock: 1 },
  { name: "银标瓦尔塔80D26R正", price: 460, stock: 1 },
  { name: "银标瓦尔塔80D26L反", price: 460, stock: 2 },
  { name: "银标瓦尔塔45安反大", price: 280, stock: 2 },
  { name: "银标瓦尔塔45安反小", price: 280, stock: 2 },
  { name: "银标瓦尔塔45安正粗", price: 280, stock: 2 },

  // 星标系列
  { name: "星标S95L反", price: 0, stock: 0 },
  { name: "星标60VH5", price: 530, stock: 1 },
  { name: "星标70VH6", price: 580, stock: 1 },

  // 能洋起停系列
  { name: "能洋起停H5.60V", price: 420, stock: 2 },
  { name: "能洋起停H6.70V", price: 480, stock: 2 },
  { name: "能洋起停Q85.60V", price: 430, stock: 2 },
  { name: "能洋起停S95.70V", price: 480, stock: 2 }
];

// 生成SQL插入语句
function generateSQL(categoryId) {
  const timestamp = new Date().toISOString().slice(0, 19).replace('T', ' ');

  const values = batteriesData.map((item, index) => {
    const code = `BAT${String(index + 1).padStart(3, '0')}`;
    const name = item.name.replace(/'/g, "\\'");
    return `(${categoryId}, '${name}', '${code}', NULL, '只', ${item.price}, NULL, ${item.stock}, NULL, NULL, 0, '${timestamp}', '${timestamp}')`;
  }).join(',\n  ');

  const sql = `INSERT INTO product (category_id, name, code, spec, unit, price, cost, stock, qrcode_path, description, deleted, create_time, update_time) VALUES\n  ${values};`;

  return sql;
}

// 输出SQL（需要先确认类别ID）
console.log('-- 蓄电池商品批量导入SQL');
console.log('-- 使用前请先确认蓄电池类别ID，并替换下面的 <CATEGORY_ID>');
console.log('');
console.log(generateSQL('<CATEGORY_ID>'));
console.log('');
console.log(`-- 共 ${batteriesData.length} 条记录`);
