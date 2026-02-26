package com.oil.system.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.oil.system.entity.Customer;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Select;

import java.util.List;
import java.util.Set;

@Mapper
public interface CustomerMapper extends BaseMapper<Customer> {

    // 查询已被软删除的客户ID（忽略 deleted 过滤）
    @Select("<script>SELECT id FROM customer WHERE deleted = 1 AND id IN " +
            "<foreach collection='ids' item='id' open='(' separator=',' close=')'>#{id}</foreach>" +
            "</script>")
    List<Long> selectDeletedIdsByIds(@org.apache.ibatis.annotations.Param("ids") Set<Long> ids);
}
