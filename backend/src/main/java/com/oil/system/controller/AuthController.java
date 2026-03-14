package com.oil.system.controller;

import cn.hutool.crypto.digest.BCrypt;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.oil.system.dto.LoginDTO;
import com.oil.system.dto.LoginVO;
import com.oil.system.dto.Result;
import com.oil.system.entity.SysUser;
import com.oil.system.mapper.SysUserMapper;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.Keys;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.*;

import javax.crypto.SecretKey;
import java.nio.charset.StandardCharsets;
import java.util.Date;

@RestController
@RequestMapping("/api/auth")
public class AuthController {

    @Autowired
    private SysUserMapper sysUserMapper;

    @Value("${jwt.secret:oil-system-secret-key-must-be-at-least-32-characters-long}")
    private String jwtSecret;

    @Value("${jwt.expiration:86400000}") // 24小时
    private Long jwtExpiration;

    /**
     * 管理员登录
     */
    @PostMapping("/login")
    public Result<LoginVO> login(@RequestBody LoginDTO dto) {
        // 查询用户
        LambdaQueryWrapper<SysUser> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(SysUser::getUsername, dto.getUsername());
        SysUser user = sysUserMapper.selectOne(wrapper);

        if (user == null) {
            return Result.error("用户名或密码错误");
        }

        // 验证密码（使用 BCrypt）
        if (!BCrypt.checkpw(dto.getPassword(), user.getPassword())) {
            return Result.error("用户名或密码错误");
        }

        // 检查用户状态
        if (user.getStatus() != null && user.getStatus() == 0) {
            return Result.error("账号已被禁用");
        }

        // 生成 JWT Token
        SecretKey key = Keys.hmacShaKeyFor(jwtSecret.getBytes(StandardCharsets.UTF_8));
        String token = Jwts.builder()
                .subject(user.getUsername())
                .claim("userId", user.getId())
                .claim("role", user.getRole())
                .issuedAt(new Date())
                .expiration(new Date(System.currentTimeMillis() + jwtExpiration))
                .signWith(key)
                .compact();

        LoginVO vo = new LoginVO(token, user.getUsername(), user.getNickname());
        return Result.success(vo);
    }

    /**
     * 退出登录（前端删除 Token 即可，此接口可选）
     */
    @PostMapping("/logout")
    public Result<Void> logout() {
        return Result.success(null);
    }

    /**
     * 验证 Token（可选，前端可用于检查登录状态）
     */
    @GetMapping("/verify")
    public Result<Boolean> verify(@RequestHeader(value = "Authorization", required = false) String authHeader) {
        if (authHeader == null || !authHeader.startsWith("Bearer ")) {
            return Result.success(false);
        }

        try {
            String token = authHeader.substring(7);
            SecretKey key = Keys.hmacShaKeyFor(jwtSecret.getBytes(StandardCharsets.UTF_8));
            Jwts.parser()
                    .verifyWith(key)
                    .build()
                    .parseSignedClaims(token);
            return Result.success(true);
        } catch (Exception e) {
            return Result.success(false);
        }
    }
}
