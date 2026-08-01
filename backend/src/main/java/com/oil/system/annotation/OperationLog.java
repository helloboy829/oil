package com.oil.system.annotation;

import java.lang.annotation.ElementType;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.annotation.Target;

/**
 * 操作日志注解 — 标注在 Controller 方法上自动记录操作日志
 */
@Target(ElementType.METHOD)
@Retention(RetentionPolicy.RUNTIME)
public @interface OperationLog {
    /** 操作模块，如 "商品管理" */
    String module();

    /** 操作类型，如 "新增" */
    String action();

    /** 目标实体类（用于查询操作前的旧数据），仅 UPDATE/DELETE 需设置 */
    Class<?> targetEntity() default Void.class;
}
