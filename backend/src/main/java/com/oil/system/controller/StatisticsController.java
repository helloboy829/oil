package com.oil.system.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.oil.system.dto.Result;
import com.oil.system.entity.Product;
import com.oil.system.mapper.OrderItemMapper;
import com.oil.system.mapper.OrdersMapper;
import com.oil.system.mapper.ProductMapper;
import com.oil.system.vo.ProfitStatisticsVO;
import com.oil.system.vo.StatisticsVO;
import com.oil.system.vo.StockStatisticsVO;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.Keys;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.*;

import javax.crypto.SecretKey;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.nio.charset.StandardCharsets;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/statistics")
@RequiredArgsConstructor
@CrossOrigin
public class StatisticsController {

    private final OrdersMapper ordersMapper;
    private final OrderItemMapper orderItemMapper;
    private final ProductMapper productMapper;

    @Value("${jwt.secret:oil-system-secret-key-must-be-at-least-32-characters-long}")
    private String jwtSecret;

    /**
     * 获取统计数据
     * @param type  趋势粒度：day / week / month
     * @param start 开始日期，如 2026-01-01
     * @param end   结束日期，如 2026-03-13
     */
    @GetMapping
    public Result<StatisticsVO> getStatistics(
            @RequestParam(defaultValue = "day") String type,
            @RequestParam(required = false) String start,
            @RequestParam(required = false) String end) {

        // 默认最近 30 天
        DateTimeFormatter dayFmt = DateTimeFormatter.ofPattern("yyyy-MM-dd");
        if (end == null || end.isEmpty()) {
            end = LocalDate.now().format(dayFmt);
        }
        if (start == null || start.isEmpty()) {
            start = LocalDate.now().minusDays(29).format(dayFmt);
        }

        String startDateTime = start + " 00:00:00";
        String endDateTime = end + " 23:59:59";

        // 趋势格式
        String fmt;
        if ("month".equals(type)) {
            fmt = "%Y-%m";
        } else if ("week".equals(type)) {
            fmt = "%x-%v";
        } else {
            fmt = "%Y-%m-%d";
        }

        List<StatisticsVO.TrendItem> trend =
                ordersMapper.selectTrend(fmt, startDateTime, endDateTime);

        List<StatisticsVO.ProductRankItem> productRank =
                orderItemMapper.selectProductRank(startDateTime, endDateTime, 10);

        List<StatisticsVO.CustomerRankItem> customerRank =
                orderItemMapper.selectCustomerRank(startDateTime, endDateTime, 10);

        StatisticsVO vo = new StatisticsVO();
        vo.setTrend(trend);
        vo.setProductRank(productRank);
        vo.setCustomerRank(customerRank);

        return Result.success(vo);
    }

    /**
     * 获取利润统计数据（仅管理员）
     */
    @GetMapping("/profit")
    public Result<ProfitStatisticsVO> getProfitStatistics(
            @RequestParam(defaultValue = "day") String type,
            @RequestParam(required = false) String start,
            @RequestParam(required = false) String end,
            @RequestHeader(value = "Authorization", required = false) String authHeader) {

        // 验证管理员权限
        if (!isAdmin(authHeader)) {
            return Result.error("无权限访问");
        }

        // 默认最近 30 天
        DateTimeFormatter dayFmt = DateTimeFormatter.ofPattern("yyyy-MM-dd");
        if (end == null || end.isEmpty()) {
            end = LocalDate.now().format(dayFmt);
        }
        if (start == null || start.isEmpty()) {
            start = LocalDate.now().minusDays(29).format(dayFmt);
        }

        String startDateTime = start + " 00:00:00";
        String endDateTime = end + " 23:59:59";

        // 趋势格式
        String fmt;
        if ("month".equals(type)) {
            fmt = "%Y-%m";
        } else if ("week".equals(type)) {
            fmt = "%x-%v";
        } else {
            fmt = "%Y-%m-%d";
        }

        ProfitStatisticsVO vo = new ProfitStatisticsVO();

        // 1. 利润趋势
        List<Map<String, Object>> trendData = orderItemMapper.selectProfitTrend(fmt, startDateTime, endDateTime);
        List<ProfitStatisticsVO.TrendData> profitTrend = new ArrayList<>();
        for (Map<String, Object> map : trendData) {
            String date = (String) map.get("date");
            BigDecimal profit = (BigDecimal) map.get("profit");
            profitTrend.add(new ProfitStatisticsVO.TrendData(date, profit));
        }
        vo.setProfitTrend(profitTrend);

        // 2. 商品利润排行
        List<Map<String, Object>> productData = orderItemMapper.selectProductProfitRank();
        List<ProfitStatisticsVO.ProductProfitRank> productRank = new ArrayList<>();
        for (Map<String, Object> map : productData) {
            String productName = (String) map.get("productName");
            Long quantity = (Long) map.get("quantity");
            BigDecimal totalProfit = (BigDecimal) map.get("totalProfit");
            BigDecimal avgProfitRate = (BigDecimal) map.get("avgProfitRate");
            productRank.add(new ProfitStatisticsVO.ProductProfitRank(
                    productName, quantity.intValue(), totalProfit, avgProfitRate
            ));
        }
        vo.setProductRank(productRank);

        // 3. 客户利润贡献排行
        List<Map<String, Object>> customerData = orderItemMapper.selectCustomerProfitRank();
        List<ProfitStatisticsVO.CustomerProfitRank> customerRank = new ArrayList<>();
        for (Map<String, Object> map : customerData) {
            String customerName = (String) map.get("customerName");
            Long orderCount = (Long) map.get("orderCount");
            BigDecimal totalProfit = (BigDecimal) map.get("totalProfit");
            customerRank.add(new ProfitStatisticsVO.CustomerProfitRank(
                    customerName, orderCount.intValue(), totalProfit
            ));
        }
        vo.setCustomerRank(customerRank);

        // 4. 利润汇总
        Map<String, Object> summary = orderItemMapper.selectProfitSummary();
        BigDecimal totalProfit = (BigDecimal) summary.get("totalProfit");
        Long profitableProductCount = (Long) summary.get("profitableProductCount");

        vo.setTotalProfit(totalProfit != null ? totalProfit : BigDecimal.ZERO);
        vo.setProfitableProductCount(profitableProductCount != null ? profitableProductCount.intValue() : 0);

        // 5. 计算平均利润率
        if (!productRank.isEmpty()) {
            BigDecimal sumRate = BigDecimal.ZERO;
            for (ProfitStatisticsVO.ProductProfitRank rank : productRank) {
                sumRate = sumRate.add(rank.getAvgProfitRate());
            }
            vo.setAvgProfitRate(sumRate.divide(new BigDecimal(productRank.size()), 2, RoundingMode.HALF_UP));
        } else {
            vo.setAvgProfitRate(BigDecimal.ZERO);
        }

        // 6. 最高利润商品
        if (!productRank.isEmpty()) {
            vo.setTopProfitProduct(productRank.get(0).getProductName());
        } else {
            vo.setTopProfitProduct(null);
        }

        // 7. 总商品数量和无成本商品数量
        Long totalProductCount = productMapper.selectCount(new LambdaQueryWrapper<Product>().eq(Product::getDeleted, 0));
        Long noCostCount = productMapper.selectCount(
                new LambdaQueryWrapper<Product>()
                        .eq(Product::getDeleted, 0)
                        .isNull(Product::getCost)
        );

        vo.setTotalProductCount(totalProductCount != null ? totalProductCount.intValue() : 0);
        vo.setNoCostProductCount(noCostCount != null ? noCostCount.intValue() : 0);

        return Result.success(vo);
    }

    /**
     * 验证是否为管理员
     */
    private boolean isAdmin(String authHeader) {
        if (authHeader == null || !authHeader.startsWith("Bearer ")) {
            return false;
        }

        try {
            String token = authHeader.substring(7);
            SecretKey key = Keys.hmacShaKeyFor(jwtSecret.getBytes(StandardCharsets.UTF_8));
            Jwts.parser()
                    .verifyWith(key)
                    .build()
                    .parseSignedClaims(token);
            return true;
        } catch (Exception e) {
            return false;
        }
    }

    /**
     * 获取库存统计数据
     */
    @GetMapping("/stock")
    public Result<StockStatisticsVO> getStockStatistics() {
        StockStatisticsVO vo = new StockStatisticsVO();

        // 1. 商品总数
        Long totalCount = productMapper.selectCount(
                new LambdaQueryWrapper<Product>().eq(Product::getDeleted, 0)
        );
        vo.setTotalProductCount(totalCount != null ? totalCount.intValue() : 0);

        // 2. 库存总量
        List<Product> allProducts = productMapper.selectList(
                new LambdaQueryWrapper<Product>().eq(Product::getDeleted, 0)
        );
        int totalStock = allProducts.stream()
                .mapToInt(p -> p.getStock() != null ? p.getStock() : 0)
                .sum();
        vo.setTotalStock(totalStock);

        // 3. 库存不足商品数（库存 <= 10）
        Long lowStockCount = productMapper.selectCount(
                new LambdaQueryWrapper<Product>()
                        .eq(Product::getDeleted, 0)
                        .le(Product::getStock, 10)
        );
        vo.setLowStockCount(lowStockCount != null ? lowStockCount.intValue() : 0);

        // 4. 零库存商品数
        Long zeroStockCount = productMapper.selectCount(
                new LambdaQueryWrapper<Product>()
                        .eq(Product::getDeleted, 0)
                        .eq(Product::getStock, 0)
        );
        vo.setZeroStockCount(zeroStockCount != null ? zeroStockCount.intValue() : 0);

        // 5. 商品类别库存分布
        List<Map<String, Object>> categoryStockData = productMapper.selectCategoryStock();
        List<StockStatisticsVO.CategoryStock> categoryStock = new ArrayList<>();
        for (Map<String, Object> map : categoryStockData) {
            String categoryName = (String) map.get("categoryName");
            Long stock = (Long) map.get("stock");
            Long productCount = (Long) map.get("productCount");
            categoryStock.add(new StockStatisticsVO.CategoryStock(
                    categoryName,
                    stock != null ? stock.intValue() : 0,
                    productCount != null ? productCount.intValue() : 0
            ));
        }
        vo.setCategoryStock(categoryStock);

        // 6. 库存不足商品详情
        List<Map<String, Object>> lowStockData = productMapper.selectLowStockProducts();
        List<StockStatisticsVO.LowStockProduct> lowStockProducts = new ArrayList<>();
        for (Map<String, Object> map : lowStockData) {
            Long id = (Long) map.get("id");
            String name = (String) map.get("name");
            String categoryName = (String) map.get("categoryName");
            Integer stock = (Integer) map.get("stock");
            String unit = (String) map.get("unit");
            lowStockProducts.add(new StockStatisticsVO.LowStockProduct(
                    id, name, categoryName, stock, unit
            ));
        }
        vo.setLowStockProducts(lowStockProducts);

        // 7. 库存排行 TOP10
        List<Map<String, Object>> stockRankData = productMapper.selectStockRank();
        List<StockStatisticsVO.StockRank> stockRank = new ArrayList<>();
        for (Map<String, Object> map : stockRankData) {
            String productName = (String) map.get("productName");
            Integer stock = (Integer) map.get("stock");
            String categoryName = (String) map.get("categoryName");
            stockRank.add(new StockStatisticsVO.StockRank(
                    productName, stock, categoryName
            ));
        }
        vo.setStockRank(stockRank);

        return Result.success(vo);
    }
}
