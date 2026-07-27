package com.oil.system.aspect;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.oil.system.annotation.OperationLog;
import com.oil.system.mapper.OperationLogMapper;
import com.oil.system.util.JwtUtil;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.aspectj.lang.ProceedingJoinPoint;
import org.aspectj.lang.annotation.Around;
import org.aspectj.lang.annotation.Aspect;
import org.aspectj.lang.reflect.MethodSignature;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;
import org.springframework.web.context.request.RequestContextHolder;
import org.springframework.web.context.request.ServletRequestAttributes;

import javax.servlet.http.HttpServletRequest;
import java.lang.reflect.Parameter;
import java.time.LocalDateTime;
import java.util.LinkedHashMap;
import java.util.Map;

/**
 * 操作日志 AOP 切面 — 拦截 @OperationLog 注解的方法，自动记录操作日志
 */
@Aspect
@Component
@RequiredArgsConstructor
@Slf4j
public class OperationLogAspect {

    private final OperationLogMapper operationLogMapper;
    private final ObjectMapper objectMapper;

    @Value("${jwt.secret:oil-system-secret-key-must-be-at-least-32-characters-long}")
    private String jwtSecret;

    // 请求参数最大长度（字符）
    private static final int MAX_PARAMS_LENGTH = 2000;

    @Around("@annotation(operationLog)")
    public Object around(ProceedingJoinPoint joinPoint, OperationLog operationLog) throws Throwable {
        // 1. 构建日志实体
        com.oil.system.entity.OperationLog log = new com.oil.system.entity.OperationLog();
        log.setModule(operationLog.module());
        log.setAction(operationLog.action());
        log.setDescription(operationLog.module() + "-" + operationLog.action());
        log.setCreateTime(LocalDateTime.now());

        // 2. 获取请求信息
        ServletRequestAttributes attributes = (ServletRequestAttributes) RequestContextHolder.getRequestAttributes();
        if (attributes != null) {
            HttpServletRequest request = attributes.getRequest();
            log.setRequestIp(getClientIp(request));
            log.setRequestMethod(request.getMethod());
            log.setRequestUrl(request.getRequestURI());
            log.setRequestParams(extractParams(joinPoint, request));
        }

        // 3. 从 Authorization header 获取操作人信息
        if (attributes != null) {
            String authHeader = attributes.getRequest().getHeader("Authorization");
            log.setOperatorName(JwtUtil.getOperatorName(authHeader, jwtSecret));
            log.setOperatorId(JwtUtil.getOperatorId(authHeader, jwtSecret));
        }

        // 4. 执行目标方法
        try {
            Object result = joinPoint.proceed();
            // 成功
            log.setStatus("成功");
            saveLog(log);
            return result;
        } catch (Throwable e) {
            // 失败
            log.setStatus("失败");
            log.setErrorMsg(truncate(e.getMessage(), 1000));
            saveLog(log);
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
     * 提取请求参数
     */
    private String extractParams(ProceedingJoinPoint joinPoint, HttpServletRequest request) {
        try {
            MethodSignature signature = (MethodSignature) joinPoint.getSignature();
            Parameter[] parameters = signature.getMethod().getParameters();
            Object[] args = joinPoint.getArgs();

            Map<String, Object> paramMap = new LinkedHashMap<>();

            for (int i = 0; i < parameters.length; i++) {
                Object arg = args[i];
                if (arg == null) continue;

                // 跳过 HttpServletRequest 和 HttpServletResponse 参数
                if (arg instanceof HttpServletRequest || arg instanceof javax.servlet.http.HttpServletResponse) {
                    continue;
                }

                String paramName = parameters[i].getName();
                // 对于没有参数名的情况（编译时未加 -parameters），使用类型名
                if (paramName == null || paramName.isEmpty()) {
                    paramName = "arg" + i;
                }

                paramMap.put(paramName, arg);
            }

            if (paramMap.isEmpty()) {
                // 兜底：记录查询参数
                Map<String, String[]> queryParams = request.getParameterMap();
                if (!queryParams.isEmpty()) {
                    paramMap.put("queryParams", queryParams);
                }
            }

            if (paramMap.isEmpty()) {
                return null;
            }

            String json = objectMapper.writeValueAsString(paramMap);
            return truncate(json, MAX_PARAMS_LENGTH);
        } catch (Exception e) {
            log.warn("操作日志参数序列化失败: {}", e.getMessage());
            return null;
        }
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
        // 多级代理时取第一个 IP
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
