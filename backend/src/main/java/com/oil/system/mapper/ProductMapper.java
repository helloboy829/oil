package com.oil.system.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.oil.system.entity.Product;
import org.apache.ibatis.annotations.Mapper;

import java.util.List;
import java.util.Map;

@Mapper
public interface ProductMapper extends BaseMapper<Product> {
    /**
     * 查询商品类别库存分布
     */
    List<Map<String, Object>> selectCategoryStock();

    /**
     * 查询库存不足商品详情（库存 <= 10）
     */
    List<Map<String, Object>> selectLowStockProducts();

    /**
     * 查询库存排行 TOP10
     */
    List<Map<String, Object>> selectStockRank();
}
