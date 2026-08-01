package com.oil.system.aspect;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.oil.system.annotation.OperationLog;
import com.oil.system.entity.*;
import com.oil.system.mapper.*;
import com.oil.system.util.JwtUtil;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.aspectj.lang.ProceedingJoinPoint;
import org.aspectj.lang.annotation.Around;
import org.aspectj.lang.annotation.Aspect;
import org.aspectj.lang.reflect.MethodSignature;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.context.request.RequestContextHolder;
import org.springframework.web.context.request.ServletRequestAttributes;

import javax.annotation.PostConstruct;
import javax.servlet.http.HttpServletRequest;
import java.lang.reflect.Method;
import java.lang.reflect.Parameter;
import java.time.LocalDateTime;
import java.util.*;

/**
 * 操作日志 AOP 切面 — 拦截 @OperationLog 注解的方法，自动记录操作日志
 * 支持记录操作前（beforeData）和操作后（afterData）的数据快照
 */
@Aspect
@Component
@RequiredArgsConstructor
@Slf4j
public class OperationLogAspect {

    private final OperationLogMapper operationLogMapper;
    private final ObjectMapper objectMapper;

    // 实体 Mapper
    private final ProductMapper productMapper;
    private final ProductCategoryMapper productCategoryMapper;
    private final CustomerMapper customerMapper;
    private final OrdersMapper ordersMapper;
    private final MonthlyBillMapper monthlyBillMapper;

    @Value("${jwt.secret:oil-system-secret-key-must-be-at-least-32-characters-long}")
    private String jwtSecret;

    private static final int MAX_DATA_LENGTH = 4000;
    private static final int MAX_PARAMS_LENGTH = 2000;

    private final Map<Class<?>, BaseMapper<?>> mapperMap = new HashMap<>();

    @PostConstruct
    void initMapperMap() {
        mapperMap.put(Product.class, productMapper);
        mapperMap.put(ProductCategory.class, productCategoryMapper);
        mapperMap.put(Customer.class, customerMapper);
        mapperMap.put(Orders.class, ordersMapper);
        mapperMap.put(MonthlyBill.class, monthlyBillMapper);
    }

    @Around("@annotation(operationLog)")
    public Object around(ProceedingJoinPoint joinPoint, OperationLog operationLog) throws Throwable {
        // 1. 构建日志实体
        com.oil.system.entity.OperationLog logEntry = new com.oil.system.entity.OperationLog();
        logEntry.setModule(operationLog.module());
        logEntry.setAction(operationLog.action());
        logEntry.setDescription(operationLog.module() + "-" + operationLog.action());
        logEntry.setCreateTime(LocalDateTime.now());

        // 2. 获取请求信息
        ServletRequestAttributes attributes = (ServletRequestAttributes) RequestContextHolder.getRequestAttributes();
        if (attributes != null) {
            HttpServletRequest request = attributes.getRequest();
            logEntry.setRequestIp(getClientIp(request));
            logEntry.setRequestMethod(request.getMethod());
            logEntry.setRequestUrl(request.getRequestURI());
        }

        // 3. 从 Authorization header 获取操作人信息
        if (attributes != null) {
            String authHeader = attributes.getRequest().getHeader("Authorization");
            logEntry.setOperatorName(JwtUtil.getOperatorName(authHeader, jwtSecret));
            logEntry.setOperatorId(JwtUtil.getOperatorId(authHeader, jwtSecret));
        }

        // 4. 查询操作前数据（仅当指定了 targetEntity 时）
        Object entityId = null;
        if (operationLog.targetEntity() != Void.class) {
            entityId = extractEntityId(joinPoint);
            if (entityId != null) {
                logEntry.setTargetId(String.valueOf(entityId));
                logEntry.setBeforeData(queryBeforeData(operationLog.targetEntity(), entityId));
            }
        }

        // 5. 执行目标方法
        try {
            Object result = joinPoint.proceed();
            // 成功
            logEntry.setStatus("成功");
            // 操作后数据 = 请求参数
            logEntry.setAfterData(buildAfterData(joinPoint, operationLog));
            saveLog(logEntry);
            return result;
        } catch (Throwable e) {
            // 失败
            logEntry.setStatus("失败");
            logEntry.setErrorMsg(truncate(e.getMessage(), 1000));
            saveLog(logEntry);
            throw e;
        }
    }

    /**
     * 保存日志（失败不影响业务）
     */
    private void saveLog(com.oil.system.entity.OperationLog logEntry) {
        try {
            operationLogMapper.insert(logEntry);
        } catch (Exception e) {
            log.warn("操作日志保存失败: module={}, action={}, error={}",
                    logEntry.getModule(), logEntry.getAction(), e.getMessage());
        }
    }

    /**
     * 从方法参数中提取实体 ID
     */
    private Long extractEntityId(ProceedingJoinPoint joinPoint) {
        MethodSignature signature = (MethodSignature) joinPoint.getSignature();
        Method method = signature.getMethod();
        Parameter[] parameters = method.getParameters();
        Object[] args = joinPoint.getArgs();

        for (int i = 0; i < parameters.length; i++) {
            Object arg = args[i];
            if (arg == null) continue;

            // 优先：@PathVariable("id") 场景（DELETE、PUT /{id}）
            PathVariable pathVar = parameters[i].getAnnotation(PathVariable.class);
            if (pathVar != null && "id".equals(pathVar.value()) && arg instanceof Long) {
                return (Long) arg;
            }

            // 其次：@RequestBody 实体中有 getId() 方法（PUT 场景）
            RequestBody reqBody = parameters[i].getAnnotation(RequestBody.class);
            if (reqBody != null) {
                try {
                    Method getId = arg.getClass().getMethod("getId");
                    Object id = getId.invoke(arg);
                    if (id instanceof Long && (Long) id != null) {
                        return (Long) id;
                    }
                } catch (Exception ignored) {
                }
            }
        }
        return null;
    }

    /**
     * 查询实体操作前的数据快照
     */
    @SuppressWarnings("unchecked")
    private String queryBeforeData(Class<?> entityClass, Object entityId) {
        try {
            BaseMapper<?> mapper = mapperMap.get(entityClass);
            if (mapper == null) return null;
            Object entity = mapper.selectById((Long) entityId);
            if (entity == null) return null;
            String json = objectMapper.writeValueAsString(entity);
            return truncate(json, MAX_DATA_LENGTH);
        } catch (Exception e) {
            log.warn("查询操作前数据失败: entity={}, id={}, error={}",
                    entityClass.getSimpleName(), entityId, e.getMessage());
            return null;
        }
    }

    /**
     * 构建操作后数据快照（从请求参数提取）
     */
    private String buildAfterData(ProceedingJoinPoint joinPoint, OperationLog opLog) {
        // CREATE 和 UPDATE 有操作后数据，DELETE 没有
        if ("删除".equals(opLog.action())) {
            return null;
        }
        try {
            MethodSignature signature = (MethodSignature) joinPoint.getSignature();
            Parameter[] parameters = signature.getMethod().getParameters();
            Object[] args = joinPoint.getArgs();

            for (int i = 0; i < parameters.length; i++) {
                Object arg = args[i];
                if (arg == null) continue;
                // 跳过 HttpServletRequest/Response
                if (arg instanceof HttpServletRequest
                        || arg instanceof javax.servlet.http.HttpServletResponse) {
                    continue;
                }
                // 跳过基本类型和字符串（路径变量等零散参数）
                if (arg instanceof String || arg instanceof Number || arg instanceof Boolean
                        || arg instanceof Collection) {
                    return null;
                }
                // 取第一个"有意义"的对象（DTO 或 Entity）
                String json = objectMapper.writeValueAsString(arg);
                return truncate(json, MAX_DATA_LENGTH);
            }
        } catch (Exception e) {
            log.warn("构建操作后数据失败: {}", e.getMessage());
        }
        return null;
    }

    /**
     * 获取客户端真实 IP
     */
    private String getClientIp(HttpServletRequest request) {
        String ip = request.getHeader("X-Forwarded-For");
        if (ip == null || ip.isEmpty() || "unknown".equalsIgnoreCase(ip)) {
            ip = request.getHeader("X-Real-IP");
        }
        if (ip == null || ip.isEmpty() || "unknown".equalsIgnoreCase(ip)) {
            ip = request.getHeader("Proxy-Client-IP");
        }
        if (ip == null || ip.isEmpty() || "unknown".equalsIgnoreCase(ip)) {
            ip = request.getHeader("WL-Proxy-Client-IP");
        }
        if (ip == null || ip.isEmpty() || "unknown".equalsIgnoreCase(ip)) {
            ip = request.getRemoteAddr();
        }
        if (ip != null && ip.contains(",")) {
            ip = ip.split(",")[0].trim();
        }
        return ip;
    }

    /**
     * 字符串截断
     */
    private String truncate(String str, int maxLength) {
        if (str == null) return null;
        if (str.length() <= maxLength) return str;
        String suffix = "...[已截断]";
        return str.substring(0, maxLength - suffix.length()) + suffix;
    }
}
