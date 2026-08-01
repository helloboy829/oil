package com.oil.system.util;

import com.fasterxml.jackson.databind.ObjectMapper;

import java.math.BigDecimal;
import java.util.*;

/**
 * 操作日志变更描述生成器 — 将 beforeData/afterData JSON 转换为自然语言
 */
public class ChangeDescGenerator {

    private static final ObjectMapper MAPPER = new ObjectMapper();

    // ====== 字段名 → 中文对照 ======
    private static final Map<String, String> PRODUCT_FIELDS = new LinkedHashMap<>();
    private static final Map<String, String> CUSTOMER_FIELDS = new LinkedHashMap<>();
    private static final Map<String, String> ORDER_FIELDS = new LinkedHashMap<>();
    private static final Map<String, String> CATEGORY_FIELDS = new LinkedHashMap<>();
    private static final Map<String, String> BILL_FIELDS = new LinkedHashMap<>();
    private static final Map<String, String> UNIT_MAP = new HashMap<>();

    static {
        PRODUCT_FIELDS.put("name", "商品名称");
        PRODUCT_FIELDS.put("code", "编码");
        PRODUCT_FIELDS.put("spec", "规格");
        PRODUCT_FIELDS.put("unit", "单位");
        PRODUCT_FIELDS.put("price", "单价");
        PRODUCT_FIELDS.put("actualPrice", "实际售价");
        PRODUCT_FIELDS.put("cost", "成本");
        PRODUCT_FIELDS.put("stock", "库存");
        PRODUCT_FIELDS.put("description", "描述");
        PRODUCT_FIELDS.put("categoryId", "分类");

        CUSTOMER_FIELDS.put("name", "客户姓名");
        CUSTOMER_FIELDS.put("phone", "电话");
        CUSTOMER_FIELDS.put("address", "地址");
        CUSTOMER_FIELDS.put("isMonthly", "月结客户");
        CUSTOMER_FIELDS.put("remark", "备注");

        ORDER_FIELDS.put("orderNo", "订单编号");
        ORDER_FIELDS.put("customerName", "客户");
        ORDER_FIELDS.put("totalAmount", "总金额");
        ORDER_FIELDS.put("paymentType", "支付方式");
        ORDER_FIELDS.put("remark", "备注");

        CATEGORY_FIELDS.put("name", "分类名称");
        CATEGORY_FIELDS.put("sort", "排序");
        CATEGORY_FIELDS.put("parentId", "父分类");

        BILL_FIELDS.put("billNo", "账单编号");
        BILL_FIELDS.put("customerName", "客户");
        BILL_FIELDS.put("billMonth", "账单月份");
        BILL_FIELDS.put("totalAmount", "总金额");
        BILL_FIELDS.put("paidAmount", "已付金额");
        BILL_FIELDS.put("status", "状态");
        BILL_FIELDS.put("settlementDate", "结算日期");
        BILL_FIELDS.put("remark", "备注");

        // 单位映射
        UNIT_MAP.put("瓶", "瓶");
        UNIT_MAP.put("桶", "桶");
        UNIT_MAP.put("升", "升");
        UNIT_MAP.put("个", "个");
    }

    /**
     * 生成变更描述
     * @param module      操作模块
     * @param action      操作类型
     * @param beforeJson  操作前数据 JSON
     * @param afterJson   操作后数据 JSON
     * @return 自然语言变更描述
     */
    public static String generate(String module, String action, String beforeJson, String afterJson) {
        Map<String, String> fieldMap = getFieldMap(module);
        try {
            if ("删除".equals(action)) {
                return genDeleteDesc(module, beforeJson, fieldMap);
            }
            if ("批量删除".equals(action)) {
                return genBatchDeleteDesc(module, beforeJson, fieldMap);
            }
            if ("新增".equals(action)) {
                return genCreateDesc(module, afterJson, fieldMap);
            }
            if ("修改".equals(action)) {
                return genUpdateDesc(beforeJson, afterJson, fieldMap);
            }
        } catch (Exception e) {
            return null;
        }
        return null;
    }

    /**
     * 修改：逐字段对比，只列出变化的
     */
    @SuppressWarnings("unchecked")
    private static String genUpdateDesc(String beforeJson, String afterJson,
                                         Map<String, String> fieldMap) throws Exception {
        if (beforeJson == null || afterJson == null) return null;

        Map<String, Object> before = MAPPER.readValue(beforeJson, LinkedHashMap.class);
        Map<String, Object> after = MAPPER.readValue(afterJson, LinkedHashMap.class);

        List<String> changes = new ArrayList<>();
        for (String field : fieldMap.keySet()) {
            Object oldVal = before.get(field);
            Object newVal = after.get(field);
            if (oldVal == null && newVal == null) continue;
            if (oldVal != null && oldVal.equals(newVal)) continue;

            String fieldName = fieldMap.get(field);
            String oldStr = formatValue(field, oldVal);
            String newStr = formatValue(field, newVal);
            String diff = buildDiff(field, oldVal, newVal);

            if (oldVal == null) {
                changes.add(fieldName + "：" + newStr);
            } else if (newVal == null) {
                changes.add(fieldName + "：" + oldStr + " → 清空");
            } else {
                changes.add(fieldName + "：" + oldStr + " → " + newStr + (diff != null ? "（" + diff + "）" : ""));
            }
        }

        if (changes.isEmpty()) return "无实际变更";
        return String.join("；", changes);
    }

    /**
     * 新增：列出关键字段
     */
    @SuppressWarnings("unchecked")
    private static String genCreateDesc(String module, String afterJson,
                                         Map<String, String> fieldMap) throws Exception {
        if (afterJson == null) return "新增记录";
        Map<String, Object> data = MAPPER.readValue(afterJson, LinkedHashMap.class);

        String name = getEntityName(data, module);
        List<String> details = new ArrayList<>();
        for (String field : fieldMap.keySet()) {
            Object val = data.get(field);
            if (val == null) continue;
            // 只展示关键信息字段
            if ("price".equals(field) || "cost".equals(field) || "stock".equals(field)
                    || "totalAmount".equals(field) || "paidAmount".equals(field)
                    || "unit".equals(field) || "spec".equals(field) || "paymentType".equals(field)) {
                details.add(fieldMap.get(field) + "：" + formatValue(field, val));
            }
        }
        return name + (details.isEmpty() ? "" : "（" + String.join("，", details) + "）");
    }

    /**
     * 删除：记录被删数据全貌
     */
    @SuppressWarnings("unchecked")
    private static String genDeleteDesc(String module, String beforeJson,
                                         Map<String, String> fieldMap) throws Exception {
        if (beforeJson == null) return "删除记录";
        Map<String, Object> data = MAPPER.readValue(beforeJson, LinkedHashMap.class);

        String name = getEntityName(data, module);
        List<String> details = new ArrayList<>();
        for (String field : fieldMap.keySet()) {
            Object val = data.get(field);
            if (val == null) continue;
            if ("price".equals(field) || "cost".equals(field) || "stock".equals(field)
                    || "totalAmount".equals(field) || "paidAmount".equals(field)
                    || "unit".equals(field) || "paymentType".equals(field)) {
                details.add(fieldMap.get(field) + "：" + formatValue(field, val));
            }
        }
        return "删除" + name + (details.isEmpty() ? "" : "（" + String.join("，", details) + "）");
    }

    /**
     * 批量删除：列出被删项名称
     */
    @SuppressWarnings("unchecked")
    private static String genBatchDeleteDesc(String module, String beforeJson,
                                              Map<String, String> fieldMap) throws Exception {
        if (beforeJson == null) return "批量删除";
        List<Map<String, Object>> list = MAPPER.readValue(beforeJson, List.class);
        if (list == null || list.isEmpty()) return "批量删除";

        List<String> names = new ArrayList<>();
        for (Map<String, Object> item : list) {
            String n = getEntityName(item, module);
            if (n != null && !n.isEmpty()) names.add(n);
        }
        String prefix = "批量删除" + list.size() + "条";
        return names.isEmpty() ? prefix : prefix + "：" + String.join("、", names);
    }

    // ====== 辅助方法 ======

    private static String buildDiff(String field, Object oldVal, Object newVal) {
        if (oldVal == null || newVal == null) return null;
        if (!(oldVal instanceof Number) || !(newVal instanceof Number)) return null;

        BigDecimal oldNum = new BigDecimal(oldVal.toString());
        BigDecimal newNum = new BigDecimal(newVal.toString());
        BigDecimal diff = newNum.subtract(oldNum);

        if (diff.compareTo(BigDecimal.ZERO) == 0) return null;

        String sign = diff.compareTo(BigDecimal.ZERO) > 0 ? "+" : "";
        // 金额类字段保留2位小数
        if ("price".equals(field) || "cost".equals(field) || "actualPrice".equals(field)
                || "totalAmount".equals(field) || "paidAmount".equals(field)) {
            return sign + diff.setScale(2, BigDecimal.ROUND_HALF_UP) + "元";
        }
        // 库存/排序等整数
        return sign + diff.stripTrailingZeros().toPlainString();
    }

    private static String formatValue(String field, Object val) {
        if (val == null) return "无";
        if ("isMonthly".equals(field)) {
            return "1".equals(String.valueOf(val)) ? "是" : "否";
        }
        // 金额加"元"
        if ("price".equals(field) || "cost".equals(field) || "actualPrice".equals(field)
                || "totalAmount".equals(field) || "paidAmount".equals(field)) {
            return val + "元";
        }
        return String.valueOf(val);
    }

    /**
     * 从数据中提取实体名称（字段为"name"或"customerName"或"productName"等）
     */
    private static String getEntityName(Map<String, Object> data, String module) {
        if (module.contains("商品")) return String.valueOf(data.getOrDefault("name", "未知商品"));
        if (module.contains("客户")) return String.valueOf(data.getOrDefault("name", "未知客户"));
        if (module.contains("订单")) return String.valueOf(data.getOrDefault("orderNo",
                data.getOrDefault("customerName", "未知订单")));
        if (module.contains("分类")) return String.valueOf(data.getOrDefault("name", "未知分类"));
        if (module.contains("账单")) return String.valueOf(data.getOrDefault("billNo",
                data.getOrDefault("customerName", "未知账单")));
        return "";
    }

    private static Map<String, String> getFieldMap(String module) {
        if (module.contains("商品")) return PRODUCT_FIELDS;
        if (module.contains("客户")) return CUSTOMER_FIELDS;
        if (module.contains("订单")) return ORDER_FIELDS;
        if (module.contains("分类")) return CATEGORY_FIELDS;
        if (module.contains("账单")) return BILL_FIELDS;
        return Collections.emptyMap();
    }
}
