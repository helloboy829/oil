package com.oil.system.util;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.Keys;

import javax.crypto.SecretKey;
import java.nio.charset.StandardCharsets;

/**
 * JWT 工具类 — 统一的 Token 解析逻辑
 */
public class JwtUtil {

    /**
     * 解析 Authorization header 中的 JWT Token
     * @param authHeader Authorization 请求头 (Bearer xxx)
     * @param secret     JWT 密钥
     * @return Claims 载荷，解析失败返回 null
     */
    public static Claims parseToken(String authHeader, String secret) {
        if (authHeader == null || !authHeader.startsWith("Bearer ")) {
            return null;
        }
        try {
            String token = authHeader.substring(7);
            SecretKey key = Keys.hmacShaKeyFor(secret.getBytes(StandardCharsets.UTF_8));
            return Jwts.parser()
                    .verifyWith(key)
                    .build()
                    .parseSignedClaims(token)
                    .getPayload();
        } catch (Exception e) {
            return null;
        }
    }

    /**
     * 从 Authorization header 中获取操作人名称（JWT subject，即用户名）
     */
    public static String getOperatorName(String authHeader, String secret) {
        Claims claims = parseToken(authHeader, secret);
        return claims != null ? claims.getSubject() : "未知用户";
    }

    /**
     * 从 Authorization header 中获取操作人 ID（JWT userId claim）
     */
    public static Long getOperatorId(String authHeader, String secret) {
        Claims claims = parseToken(authHeader, secret);
        if (claims != null) {
            Object userId = claims.get("userId");
            if (userId instanceof Number) {
                return ((Number) userId).longValue();
            }
        }
        return null;
    }

    /**
     * 检查是否为管理员（role claim = "admin"，忽略大小写）
     */
    public static boolean isAdmin(String authHeader, String secret) {
        Claims claims = parseToken(authHeader, secret);
        if (claims != null) {
            String role = claims.get("role", String.class);
            return "admin".equalsIgnoreCase(role);
        }
        return false;
    }
}
