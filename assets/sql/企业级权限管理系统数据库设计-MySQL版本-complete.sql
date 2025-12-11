-- =================================================================
-- 企业级权限管理系统数据库脚本 - MySQL 8.0+ 版本
-- 创建时间：2025-12-10
-- 作者：Hongyu
-- =================================================================

-- 创建数据库
CREATE DATABASE IF NOT EXISTS `rbac_system`
DEFAULT CHARACTER SET utf8mb4
DEFAULT COLLATE utf8mb4_unicode_ci;

USE `rbac_system`;

-- =================================================================
-- 1. 核心业务表
-- =================================================================

-- 1.1 部门表 (sys_dept)
CREATE TABLE `sys_dept` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '部门ID',
  `dept_name` VARCHAR(50) NOT NULL COMMENT '部门名称',
  `dept_code` VARCHAR(50) NOT NULL COMMENT '部门编码',
  `parent_id` BIGINT NOT NULL DEFAULT 0 COMMENT '父部门ID',
  `leader_id` BIGINT DEFAULT NULL COMMENT '负责人用户ID',
  `leader_phone` VARCHAR(20) DEFAULT NULL COMMENT '负责人联系电话',
  `leader_email` VARCHAR(100) DEFAULT NULL COMMENT '负责人邮箱',
  `status` TINYINT NOT NULL DEFAULT 1 COMMENT '状态：0-禁用，1-正常',
  `sort` INT NOT NULL DEFAULT 0 COMMENT '排序',
  `create_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `creator` BIGINT DEFAULT NULL COMMENT '创建人ID',
  `update_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `updater` BIGINT DEFAULT NULL COMMENT '更新人ID',
  `delete_flag` TINYINT NOT NULL DEFAULT 0 COMMENT '是否删除：0-否，1-是',
  `delete_at` DATETIME DEFAULT NULL COMMENT '删除时间',
  `version` INT NOT NULL DEFAULT 1 COMMENT '乐观锁版本号',
  `tenant_id` BIGINT DEFAULT NULL COMMENT '租户ID',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_dept_code` (`dept_code`, `tenant_id`),
  KEY `idx_parent_id` (`parent_id`),
  KEY `idx_status` (`status`),
  KEY `idx_delete_flag` (`delete_flag`),
  KEY `idx_tenant_id` (`tenant_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='部门表';

-- 1.2 岗位表 (sys_post)
CREATE TABLE `sys_post` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '岗位ID',
  `post_name` VARCHAR(50) NOT NULL COMMENT '岗位名称',
  `post_code` VARCHAR(50) NOT NULL COMMENT '岗位编码',
  `dept_id` BIGINT NOT NULL COMMENT '所属部门ID',
  `sort` INT NOT NULL DEFAULT 0 COMMENT '排序',
  `status` TINYINT NOT NULL DEFAULT 1 COMMENT '状态：0-禁用，1-正常',
  `create_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `creator` BIGINT DEFAULT NULL COMMENT '创建人ID',
  `update_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `updater` BIGINT DEFAULT NULL COMMENT '更新人ID',
  `delete_flag` TINYINT NOT NULL DEFAULT 0 COMMENT '是否删除：0-否，1-是',
  `delete_at` DATETIME DEFAULT NULL COMMENT '删除时间',
  `version` INT NOT NULL DEFAULT 1 COMMENT '乐观锁版本号',
  `tenant_id` BIGINT DEFAULT NULL COMMENT '租户ID',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_post_code` (`post_code`, `tenant_id`),
  KEY `idx_dept_id` (`dept_id`),
  KEY `idx_status` (`status`),
  KEY `idx_delete_flag` (`delete_flag`),
  KEY `idx_tenant_id` (`tenant_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='岗位表';

-- 1.3 用户表 (sys_user)
CREATE TABLE `sys_user` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '用户ID',
  `username` VARCHAR(50) NOT NULL COMMENT '用户名',
  `password` VARCHAR(255) NOT NULL COMMENT '密码',
  `nickname` VARCHAR(50) DEFAULT NULL COMMENT '昵称',
  `real_name` VARCHAR(50) DEFAULT NULL COMMENT '真实姓名',
  `email` VARCHAR(100) DEFAULT NULL COMMENT '邮箱',
  `phone` VARCHAR(20) DEFAULT NULL COMMENT '手机号',
  `avatar` VARCHAR(255) DEFAULT NULL COMMENT '头像地址',
  `sex` CHAR(1) DEFAULT '0' COMMENT '性别：0-未知，1-男，2-女',
  `birthday` DATE DEFAULT NULL COMMENT '生日',
  `dept_id` BIGINT DEFAULT NULL COMMENT '部门ID',
  `post_id` BIGINT DEFAULT NULL COMMENT '岗位ID',
  `address` VARCHAR(200) DEFAULT NULL COMMENT '地址',
  `remark` VARCHAR(500) DEFAULT NULL COMMENT '备注',
  `sort` INT NOT NULL DEFAULT 0 COMMENT '排序',
  `status` TINYINT NOT NULL DEFAULT 1 COMMENT '状态：0-禁用，1-正常',
  `last_login_time` DATETIME DEFAULT NULL COMMENT '最后登录时间',
  `last_login_ip` VARCHAR(50) DEFAULT NULL COMMENT '最后登录IP',
  `create_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `creator` BIGINT DEFAULT NULL COMMENT '创建人ID',
  `update_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `updater` BIGINT DEFAULT NULL COMMENT '更新人ID',
  `delete_flag` TINYINT NOT NULL DEFAULT 0 COMMENT '是否删除：0-否，1-是',
  `delete_at` DATETIME DEFAULT NULL COMMENT '删除时间',
  `version` INT NOT NULL DEFAULT 1 COMMENT '乐观锁版本号',
  `tenant_id` BIGINT DEFAULT NULL COMMENT '租户ID',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_username` (`username`, `tenant_id`),
  UNIQUE KEY `uk_email` (`email`, `tenant_id`),
  UNIQUE KEY `uk_phone` (`phone`, `tenant_id`),
  KEY `idx_dept_id` (`dept_id`),
  KEY `idx_post_id` (`post_id`),
  KEY `idx_status` (`status`),
  KEY `idx_delete_flag` (`delete_flag`),
  KEY `idx_tenant_id` (`tenant_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户表';

-- 1.4 角色表 (sys_role)
CREATE TABLE `sys_role` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '角色ID',
  `role_name` VARCHAR(50) NOT NULL COMMENT '角色名称',
  `role_code` VARCHAR(50) NOT NULL COMMENT '角色编码',
  `remark` VARCHAR(200) DEFAULT NULL COMMENT '备注',
  `data_scope` TINYINT NOT NULL DEFAULT 1 COMMENT '数据权限：1-全部，2-本部门，3-本部门及下级，4-自定义',
  `sort` INT NOT NULL DEFAULT 0 COMMENT '排序',
  `status` TINYINT NOT NULL DEFAULT 1 COMMENT '状态：0-禁用，1-正常',
  `create_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `creator` BIGINT DEFAULT NULL COMMENT '创建人ID',
  `update_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `updater` BIGINT DEFAULT NULL COMMENT '更新人ID',
  `delete_flag` TINYINT NOT NULL DEFAULT 0 COMMENT '是否删除：0-否，1-是',
  `delete_at` DATETIME DEFAULT NULL COMMENT '删除时间',
  `version` INT NOT NULL DEFAULT 1 COMMENT '乐观锁版本号',
  `tenant_id` BIGINT DEFAULT NULL COMMENT '租户ID',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_role_code` (`role_code`, `tenant_id`),
  KEY `idx_status` (`status`),
  KEY `idx_data_scope` (`data_scope`),
  KEY `idx_delete_flag` (`delete_flag`),
  KEY `idx_tenant_id` (`tenant_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='角色表';

-- 1.5 菜单表 (sys_menu)
CREATE TABLE `sys_menu` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '菜单ID',
  `menu_name` VARCHAR(50) NOT NULL COMMENT '菜单名称',
  `menu_code` VARCHAR(100) NOT NULL COMMENT '菜单编码/权限标识',
  `parent_id` BIGINT NOT NULL DEFAULT 0 COMMENT '父菜单ID',
  `menu_type` TINYINT NOT NULL COMMENT '菜单类型：1-目录，2-菜单，3-按钮',
  `path` VARCHAR(200) DEFAULT NULL COMMENT '路由路径',
  `component` VARCHAR(200) DEFAULT NULL COMMENT '组件路径',
  `icon` VARCHAR(100) DEFAULT NULL COMMENT '图标',
  `permission` VARCHAR(100) DEFAULT NULL COMMENT '权限标识',
  `target` VARCHAR(20) NOT NULL DEFAULT '_self' COMMENT '打开方式：_self-当前页，_blank-新页',
  `is_cache` TINYINT NOT NULL DEFAULT 0 COMMENT '是否缓存：0-否，1-是',
  `is_visible` TINYINT NOT NULL DEFAULT 1 COMMENT '是否显示：0-否，1-是',
  `is_external` TINYINT NOT NULL DEFAULT 0 COMMENT '是否外链：0-否，1-是',
  `sort` INT NOT NULL DEFAULT 0 COMMENT '排序',
  `status` TINYINT NOT NULL DEFAULT 1 COMMENT '状态：0-禁用，1-正常',
  `create_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `creator` BIGINT DEFAULT NULL COMMENT '创建人ID',
  `update_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `updater` BIGINT DEFAULT NULL COMMENT '更新人ID',
  `delete_flag` TINYINT NOT NULL DEFAULT 0 COMMENT '是否删除：0-否，1-是',
  `delete_at` DATETIME DEFAULT NULL COMMENT '删除时间',
  `version` INT NOT NULL DEFAULT 1 COMMENT '乐观锁版本号',
  `tenant_id` BIGINT DEFAULT NULL COMMENT '租户ID',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_menu_code` (`menu_code`, `tenant_id`),
  KEY `idx_parent_id` (`parent_id`),
  KEY `idx_menu_type` (`menu_type`),
  KEY `idx_status` (`status`),
  KEY `idx_delete_flag` (`delete_flag`),
  KEY `idx_tenant_id` (`tenant_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='菜单表';

-- =================================================================
-- 2. 关联表
-- =================================================================

-- 2.1 用户角色关联表 (sys_user_role)
CREATE TABLE `sys_user_role` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `user_id` BIGINT NOT NULL COMMENT '用户ID',
  `role_id` BIGINT NOT NULL COMMENT '角色ID',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_user_role` (`user_id`, `role_id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_role_id` (`role_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户角色关联表';

-- 2.2 角色菜单关联表 (sys_role_menu)
CREATE TABLE `sys_role_menu` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `role_id` BIGINT NOT NULL COMMENT '角色ID',
  `menu_id` BIGINT NOT NULL COMMENT '菜单ID',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_role_menu` (`role_id`, `menu_id`),
  KEY `idx_role_id` (`role_id`),
  KEY `idx_menu_id` (`menu_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='角色菜单关联表';

-- 2.3 角色部门关联表 (sys_role_dept)
CREATE TABLE `sys_role_dept` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `role_id` BIGINT NOT NULL COMMENT '角色ID',
  `dept_id` BIGINT NOT NULL COMMENT '部门ID',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_role_dept` (`role_id`, `dept_id`),
  KEY `idx_role_id` (`role_id`),
  KEY `idx_dept_id` (`dept_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='角色部门关联表';

-- =================================================================
-- 3. 日志表
-- =================================================================

-- 3.1 登录日志表 (sys_login_log)
CREATE TABLE `sys_login_log` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '日志ID',
  `username` VARCHAR(50) NOT NULL COMMENT '用户名',
  `user_id` BIGINT DEFAULT NULL COMMENT '用户ID',
  `ipaddr` VARCHAR(50) NOT NULL COMMENT '登录IP地址',
  `login_location` VARCHAR(255) DEFAULT NULL COMMENT '登录地点',
  `browser` VARCHAR(50) DEFAULT NULL COMMENT '浏览器类型',
  `os` VARCHAR(50) DEFAULT NULL COMMENT '操作系统',
  `device` VARCHAR(50) DEFAULT NULL COMMENT '设备类型',
  `status` TINYINT NOT NULL DEFAULT 0 COMMENT '登录状态：0-失败，1-成功',
  `msg` VARCHAR(255) DEFAULT NULL COMMENT '提示信息',
  `login_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '登录时间',
  `create_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_username` (`username`),
  KEY `idx_login_time` (`login_time`),
  KEY `idx_username_time` (`username`, `login_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='登录日志表';

-- 3.2 操作日志表 (sys_operation_log)
CREATE TABLE `sys_operation_log` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '日志ID',
  `title` VARCHAR(50) DEFAULT NULL COMMENT '操作模块',
  `business_type` TINYINT NOT NULL DEFAULT 0 COMMENT '业务类型（0-其他 1-新增 2-修改 3-删除）',
  `business_type_name` VARCHAR(50) DEFAULT NULL COMMENT '业务类型名称',
  `method` VARCHAR(10) NOT NULL COMMENT '请求方式',
  `request_method` VARCHAR(10) NOT NULL COMMENT '请求类型',
  `operator_type` TINYINT DEFAULT 0 COMMENT '操作类别（0-其它 1-后台用户 2-手机端用户）',
  `operator_name` VARCHAR(50) DEFAULT NULL COMMENT '操作人员',
  `dept_name` VARCHAR(50) DEFAULT NULL COMMENT '部门名称',
  `operation_url` VARCHAR(255) DEFAULT NULL COMMENT '请求URL',
  `operation_ip` VARCHAR(50) NOT NULL COMMENT '操作地址',
  `operation_location` VARCHAR(255) DEFAULT NULL COMMENT '操作地点',
  `operation_param` TEXT DEFAULT NULL COMMENT '请求参数',
  `json_result` TEXT DEFAULT NULL COMMENT '返回参数',
  `operation_status` TINYINT DEFAULT 0 COMMENT '操作状态：0-正常，1-异常',
  `error_msg` VARCHAR(2000) DEFAULT NULL COMMENT '错误消息',
  `operation_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '操作时间',
  `cost_time` BIGINT DEFAULT NULL COMMENT '消耗时间',
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`operator_name`),
  KEY `idx_operation_time` (`operation_time`),
  KEY `idx_business_type` (`business_type`),
  KEY `idx_operation_status` (`operation_status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='操作日志表';

-- 3.3 错误日志表 (sys_error_log)
CREATE TABLE `sys_error_log` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '日志ID',
  `title` VARCHAR(255) DEFAULT NULL COMMENT '错误标题',
  `request_uri` VARCHAR(255) NOT NULL COMMENT '请求URL',
  `request_method` VARCHAR(10) NOT NULL COMMENT '请求方式',
  `request_params` TEXT DEFAULT NULL COMMENT '请求参数',
  `user_id` BIGINT DEFAULT NULL COMMENT '用户ID',
  `username` VARCHAR(50) DEFAULT NULL COMMENT '用户名',
  `user_ip` VARCHAR(128) DEFAULT NULL COMMENT '操作IP地址',
  `user_agent` VARCHAR(500) DEFAULT NULL COMMENT '用户代理',
  `exception_info` TEXT NOT NULL COMMENT '错误消息',
  `exception_name` VARCHAR(255) DEFAULT NULL COMMENT '异常名称',
  `stack_trace` TEXT DEFAULT NULL COMMENT '错误堆栈',
  `line_number` INT DEFAULT NULL COMMENT '错误行号',
  `class_name` VARCHAR(200) DEFAULT NULL COMMENT 'Java类名',
  `method_name` VARCHAR(200) DEFAULT NULL COMMENT '方法名',
  `status` TINYINT NOT NULL DEFAULT 0 COMMENT '状态',
  `process_user_id` BIGINT DEFAULT NULL COMMENT '处理人ID',
  `process_user_name` VARCHAR(50) DEFAULT NULL COMMENT '处理人',
  `process_remark` VARCHAR(500) DEFAULT NULL COMMENT '处理备注',
  `process_time` DATETIME DEFAULT NULL COMMENT '处理时间',
  `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_create_time` (`create_time`),
  KEY `idx_status` (`status`),
  KEY `idx_exception_name` (`exception_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='错误日志表';

-- =================================================================
-- 4. 租户管理表
-- =================================================================

-- 4.1 租户表 (sys_tenant)
CREATE TABLE `sys_tenant` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '租户ID',
  `tenant_name` VARCHAR(50) NOT NULL COMMENT '租户名称',
  `tenant_code` VARCHAR(20) NOT NULL COMMENT '租户编码',
  `contact_name` VARCHAR(30) NOT NULL COMMENT '联系人',
  `contact_phone` VARCHAR(20) DEFAULT NULL COMMENT '联系电话',
  `contact_email` VARCHAR(50) DEFAULT NULL COMMENT '联系邮箱',
  `company_name` VARCHAR(100) DEFAULT NULL COMMENT '企业名称',
  `domain` VARCHAR(100) DEFAULT NULL COMMENT '域名',
  `address` VARCHAR(200) DEFAULT NULL COMMENT '地址',
  `phone` VARCHAR(20) DEFAULT NULL COMMENT '电话',
  `email` VARCHAR(100) DEFAULT NULL COMMENT '邮箱',
  `package_id` BIGINT DEFAULT NULL COMMENT '套餐ID',
  `expire_time` DATETIME DEFAULT NULL COMMENT '到期时间',
  `account_count` INT NOT NULL DEFAULT 0 COMMENT '账号数量',
  `sort` INT NOT NULL DEFAULT 0 COMMENT '排序',
  `status` TINYINT NOT NULL DEFAULT 1 COMMENT '状态：0-禁用，1-正常',
  `create_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `creator` BIGINT DEFAULT NULL COMMENT '创建人ID',
  `update_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `updater` BIGINT DEFAULT NULL COMMENT '更新人ID',
  `delete_flag` TINYINT NOT NULL DEFAULT 0 COMMENT '是否删除：0-否，1-是',
  `delete_at` DATETIME DEFAULT NULL COMMENT '删除时间',
  `version` INT NOT NULL DEFAULT 1 COMMENT '乐观锁版本号',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_tenant_code` (`tenant_code`),
  KEY `idx_package_id` (`package_id`),
  KEY `idx_status` (`status`),
  KEY `idx_delete_flag` (`delete_flag`),
  KEY `idx_expire_time` (`expire_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='租户表';

-- 4.2 租户套餐表 (sys_tenant_package)
CREATE TABLE `sys_tenant_package` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '套餐ID',
  `package_name` VARCHAR(50) NOT NULL COMMENT '套餐名称',
  `package_code` VARCHAR(20) NOT NULL COMMENT '套餐编码',
  `max_users` INT NOT NULL DEFAULT 10 COMMENT '最大用户数',
  `max_storage` BIGINT NOT NULL DEFAULT 1073741824 COMMENT '最大存储空间（字节）',
  `price` DECIMAL(10,2) NOT NULL DEFAULT 0.00 COMMENT '价格',
  `cycle_unit` TINYINT NOT NULL DEFAULT 1 COMMENT '计费周期：1-月，2-季，3-年',
  `features` TEXT DEFAULT NULL COMMENT '功能特性（JSON格式）',
  `description` VARCHAR(500) DEFAULT NULL COMMENT '套餐描述',
  `status` TINYINT NOT NULL DEFAULT 1 COMMENT '状态：0-禁用，1-正常',
  `sort_order` INT NOT NULL DEFAULT 0 COMMENT '排序',
  `create_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `creator` BIGINT DEFAULT NULL COMMENT '创建人ID',
  `update_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `updater` BIGINT DEFAULT NULL COMMENT '更新人ID',
  `delete_flag` TINYINT NOT NULL DEFAULT 0 COMMENT '是否删除：0-否，1-是',
  `delete_at` DATETIME DEFAULT NULL COMMENT '删除时间',
  `version` INT NOT NULL DEFAULT 1 COMMENT '乐观锁版本号',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_package_code` (`package_code`),
  KEY `idx_status` (`status`),
  KEY `idx_delete_flag` (`delete_flag`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='租户套餐表';

-- 4.3 租户配置表 (sys_tenant_config)
CREATE TABLE `sys_tenant_config` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '配置ID',
  `tenant_id` BIGINT NOT NULL COMMENT '租户ID',
  `config_key` VARCHAR(100) NOT NULL COMMENT '配置键',
  `config_value` TEXT DEFAULT NULL COMMENT '配置值',
  `config_type` TINYINT NOT NULL DEFAULT 0 COMMENT '系统内置（0-否 1-是）',
  `is_encrypted` TINYINT NOT NULL DEFAULT 0 COMMENT '是否加密（0-否 1-是）',
  `remark` VARCHAR(500) DEFAULT NULL COMMENT '备注',
  `create_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `creator` BIGINT DEFAULT NULL COMMENT '创建人ID',
  `update_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `updater` BIGINT DEFAULT NULL COMMENT '更新人ID',
  `delete_flag` TINYINT NOT NULL DEFAULT 0 COMMENT '是否删除：0-否，1-是',
  `delete_at` DATETIME DEFAULT NULL COMMENT '删除时间',
  `version` INT NOT NULL DEFAULT 1 COMMENT '乐观锁版本号',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_tenant_key` (`tenant_id`, `config_key`),
  KEY `idx_tenant_id` (`tenant_id`),
  KEY `idx_config_key` (`config_key`),
  KEY `idx_config_type` (`config_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='租户配置表';

-- =================================================================
-- 5. 系统配置表
-- =================================================================

-- 5.1 字典类型表 (sys_dict_type)
CREATE TABLE `sys_dict_type` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '字典主键',
  `dict_name` VARCHAR(100) NOT NULL COMMENT '字典名称',
  `dict_type` VARCHAR(100) NOT NULL COMMENT '字典类型',
  `sort` INT NOT NULL DEFAULT 0 COMMENT '排序',
  `status` TINYINT NOT NULL DEFAULT 1 COMMENT '状态（0正常 1停用）',
  `create_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `creator` BIGINT DEFAULT NULL COMMENT '创建人',
  `update_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `updater` BIGINT DEFAULT NULL COMMENT '更新人',
  `delete_flag` TINYINT NOT NULL DEFAULT 0 COMMENT '是否删除',
  `delete_at` DATETIME DEFAULT NULL COMMENT '删除时间',
  `version` INT NOT NULL DEFAULT 1 COMMENT '乐观锁版本号',
  `remark` VARCHAR(500) DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_dict_type` (`dict_type`),
  KEY `idx_status` (`status`),
  KEY `idx_delete_flag` (`delete_flag`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='字典类型表';

-- 5.2 字典数据表 (sys_dict_data)
CREATE TABLE `sys_dict_data` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '数据编号',
  `dict_sort` INT NOT NULL DEFAULT 0 COMMENT '字典排序',
  `dict_label` VARCHAR(100) NOT NULL COMMENT '字典标签',
  `dict_value` VARCHAR(100) NOT NULL COMMENT '字典键值',
  `dict_type` VARCHAR(100) NOT NULL COMMENT '字典类型',
  `css_class` VARCHAR(100) DEFAULT NULL COMMENT '表格回显样式',
  `list_class` VARCHAR(100) DEFAULT NULL COMMENT '表格列表样式',
  `is_default` CHAR(1) NOT NULL DEFAULT 'N' COMMENT '是否默认（Y是 N否）',
  `sort` INT NOT NULL DEFAULT 0 COMMENT '排序',
  `status` TINYINT NOT NULL DEFAULT 1 COMMENT '状态（0正常 1停用）',
  `create_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `creator` BIGINT DEFAULT NULL COMMENT '创建人',
  `update_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `updater` BIGINT DEFAULT NULL COMMENT '更新人',
  `delete_flag` TINYINT NOT NULL DEFAULT 0 COMMENT '是否删除',
  `delete_at` DATETIME DEFAULT NULL COMMENT '删除时间',
  `version` INT NOT NULL DEFAULT 1 COMMENT '乐观锁版本号',
  `remark` VARCHAR(500) DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`id`),
  KEY `idx_dict_type_status` (`dict_type`, `status`),
  KEY `idx_dict_sort` (`dict_sort`),
  KEY `idx_delete_flag` (`delete_flag`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='字典数据表';

-- 5.3 参数配置表 (sys_params)
CREATE TABLE `sys_params` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '参数ID',
  `param_name` VARCHAR(100) NOT NULL COMMENT '参数名称',
  `param_key` VARCHAR(100) NOT NULL COMMENT '参数键名',
  `param_value` VARCHAR(500) DEFAULT NULL COMMENT '参数键值',
  `is_system` TINYINT NOT NULL DEFAULT 0 COMMENT '系统内置（0-否 1-是）',
  `is_encrypted` TINYINT NOT NULL DEFAULT 0 COMMENT '是否加密（0-否 1-是）',
  `sort` INT NOT NULL DEFAULT 0 COMMENT '排序',
  `status` TINYINT NOT NULL DEFAULT 1 COMMENT '状态（0正常 1停用）',
  `remark` VARCHAR(500) DEFAULT NULL COMMENT '备注',
  `create_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `creator` BIGINT DEFAULT NULL COMMENT '创建人ID',
  `update_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `updater` BIGINT DEFAULT NULL COMMENT '更新人ID',
  `delete_flag` TINYINT NOT NULL DEFAULT 0 COMMENT '是否删除：0-否，1-是',
  `delete_at` DATETIME DEFAULT NULL COMMENT '删除时间',
  `version` INT NOT NULL DEFAULT 1 COMMENT '乐观锁版本号',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_param_key` (`param_key`),
  KEY `idx_is_system` (`is_system`),
  KEY `idx_status` (`status`),
  KEY `idx_delete_flag` (`delete_flag`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='参数配置表';

-- =================================================================
-- 6. 外键约束
-- =================================================================

-- 部门表外键
ALTER TABLE `sys_dept` ADD CONSTRAINT `fk_dept_leader`
FOREIGN KEY (`leader_id`) REFERENCES `sys_user` (`id`) ON DELETE SET NULL;

-- 岗位表外键
ALTER TABLE `sys_post` ADD CONSTRAINT `fk_post_dept`
FOREIGN KEY (`dept_id`) REFERENCES `sys_dept` (`id`) ON DELETE CASCADE;

-- 用户表外键
ALTER TABLE `sys_user` ADD CONSTRAINT `fk_user_dept`
FOREIGN KEY (`dept_id`) REFERENCES `sys_dept` (`id`) ON DELETE SET NULL;
ALTER TABLE `sys_user` ADD CONSTRAINT `fk_user_post`
FOREIGN KEY (`post_id`) REFERENCES `sys_post` (`id`) ON DELETE SET NULL;

-- 用户角色关联表外键
ALTER TABLE `sys_user_role` ADD CONSTRAINT `fk_ur_user`
FOREIGN KEY (`user_id`) REFERENCES `sys_user` (`id`) ON DELETE CASCADE;
ALTER TABLE `sys_user_role` ADD CONSTRAINT `fk_ur_role`
FOREIGN KEY (`role_id`) REFERENCES `sys_role` (`id`) ON DELETE CASCADE;

-- 角色菜单关联表外键
ALTER TABLE `sys_role_menu` ADD CONSTRAINT `fk_rm_role`
FOREIGN KEY (`role_id`) REFERENCES `sys_role` (`id`) ON DELETE CASCADE;
ALTER TABLE `sys_role_menu` ADD CONSTRAINT `fk_rm_menu`
FOREIGN KEY (`menu_id`) REFERENCES `sys_menu` (`id`) ON DELETE CASCADE;

-- 角色部门关联表外键
ALTER TABLE `sys_role_dept` ADD CONSTRAINT `fk_rd_role`
FOREIGN KEY (`role_id`) REFERENCES `sys_role` (`id`) ON DELETE CASCADE;
ALTER TABLE `sys_role_dept` ADD CONSTRAINT `fk_rd_dept`
FOREIGN KEY (`dept_id`) REFERENCES `sys_dept` (`id`) ON DELETE CASCADE;

-- 租户相关外键
ALTER TABLE `sys_tenant` ADD CONSTRAINT `fk_tenant_package`
FOREIGN KEY (`package_id`) REFERENCES `sys_tenant_package` (`id`) ON DELETE SET NULL;
ALTER TABLE `sys_tenant_config` ADD CONSTRAINT `fk_config_tenant`
FOREIGN KEY (`tenant_id`) REFERENCES `sys_tenant` (`id`) ON DELETE CASCADE;

-- 字典数据外键
ALTER TABLE `sys_dict_data` ADD CONSTRAINT `fk_data_type`
FOREIGN KEY (`dict_type`) REFERENCES `sys_dict_type` (`dict_type`) ON DELETE CASCADE;

-- =================================================================
-- 7. 初始化数据
-- =================================================================

-- 默认超级管理员 (密码: admin123)
INSERT INTO `sys_user` (`id`, `username`, `password`, `nickname`, `real_name`, `email`, `status`)
VALUES (1, 'admin', '$2a$10$7JB720yubVSOfvVtlWGIH.9wNHNl.WPs4F9QDmHtzvpZf4MxOb8.K', '超级管理员', '系统管理员', 'admin@example.com', 1);

-- 默认角色
INSERT INTO `sys_role` (`id`, `role_name`, `role_code`, `remark`, `data_scope`)
VALUES (1, '超级管理员', 'ROLE_ADMIN', '系统超级管理员', 1);

-- 用户角色关联
INSERT INTO `sys_user_role` (`user_id`, `role_id`) VALUES (1, 1);

-- 默认部门
INSERT INTO `sys_dept` (`id`, `dept_name`, `dept_code`, `parent_id`, `status`)
VALUES (1, '总公司', 'ROOT', 0, 1);

-- 更新超级管理员部门
UPDATE `sys_user` SET `dept_id` = 1 WHERE `id` = 1;

-- 默认菜单数据
INSERT INTO `sys_menu` (`menu_name`, `menu_code`, `parent_id`, `menu_type`, `path`, `icon`, `sort`) VALUES
('系统管理', 'system', 0, 1, '/system', 'system', 1),
('用户管理', 'system:user', 1, 2, 'user', 'user', 1),
('角色管理', 'system:role', 1, 2, 'role', 'role', 2),
('菜单管理', 'system:menu', 1, 2, 'menu', 'menu', 3),
('部门管理', 'system:dept', 1, 2, 'dept', 'dept', 4),
('岗位管理', 'system:post', 1, 2, 'post', 'post', 5),
('监控中心', 'monitor', 0, 1, '/monitor', 'monitor', 2),
('在线用户', 'monitor:online', 7, 2, 'online', 'online', 1),
('登录日志', 'monitor:logininfor', 7, 2, 'logininfor', 'logininfor', 2),
('操作日志', 'monitor:operlog', 7, 2, 'operlog', 'operlog', 3),
('系统工具', 'tool', 0, 1, '/tool', 'tool', 3),
('表单构建', 'tool:build', 11, 2, 'build', 'build', 1),
('代码生成', 'tool:gen', 11, 2, 'gen', 'code', 2),
('系统接口', 'tool:swagger', 11, 2, 'swagger', 'swagger', 3);

-- 获取最大菜单ID
SET @max_menu_id = (SELECT MAX(id) FROM sys_menu);

-- 菜单权限按钮数据
INSERT INTO `sys_menu` (`menu_name`, `menu_code`, `parent_id`, `menu_type`, `permission`, `sort`) VALUES
('用户查询', 'system:user:query', 2, 3, 'system:user:list', 1),
('用户新增', 'system:user:add', 2, 3, 'system:user:add', 2),
('用户修改', 'system:user:edit', 2, 3, 'system:user:edit', 3),
('用户删除', 'system:user:remove', 2, 3, 'system:user:remove', 4),
('用户导出', 'system:user:export', 2, 3, 'system:user:export', 5),
('角色查询', 'system:role:query', 3, 3, 'system:role:list', 1),
('角色新增', 'system:role:add', 3, 3, 'system:role:add', 2),
('角色修改', 'system:role:edit', 3, 3, 'system:role:edit', 3),
('角色删除', 'system:role:remove', 3, 3, 'system:role:remove', 4),
('菜单查询', 'system:menu:query', 4, 3, 'system:menu:list', 1),
('菜单新增', 'system:menu:add', 4, 3, 'system:menu:add', 2),
('菜单修改', 'system:menu:edit', 4, 3, 'system:menu:edit', 3),
('菜单删除', 'system:menu:remove', 4, 3, 'system:menu:remove', 4),
('部门查询', 'system:dept:query', 5, 3, 'system:dept:list', 1),
('部门新增', 'system:dept:add', 5, 3, 'system:dept:add', 2),
('部门修改', 'system:dept:edit', 5, 3, 'system:dept:edit', 3),
('部门删除', 'system:dept:remove', 5, 3, 'system:dept:remove', 4),
('岗位查询', 'system:post:query', 6, 3, 'system:post:list', 1),
('岗位新增', 'system:post:add', 6, 3, 'system:post:add', 2),
('岗位修改', 'system:post:edit', 6, 3, 'system:post:edit', 3),
('岗位删除', 'system:post:remove', 6, 3, 'system:post:remove', 4);

-- 超级管理员权限
INSERT INTO `sys_role_menu` (`role_id`, `menu_id`)
SELECT 1, id FROM sys_menu;

-- 默认字典类型
INSERT INTO `sys_dict_type` (`dict_name`, `dict_type`, `sort`) VALUES
('用户性别', 'user_gender', 1),
('菜单类型', 'menu_type', 2),
('数据权限', 'data_scope', 3),
('业务类型', 'business_type', 4),
('操作类别', 'operator_type', 5),
('系统状态', 'sys_status', 6),
('是否默认', 'is_default', 7),
('是否', 'yes_no', 8);

-- 默认字典数据
INSERT INTO `sys_dict_data` (`dict_label`, `dict_value`, `dict_type`, `dict_sort`, `is_default`) VALUES
('未知', '0', 'user_gender', 1, 'N'),
('男', '1', 'user_gender', 2, 'N'),
('女', '2', 'user_gender', 3, 'N'),
('目录', '1', 'menu_type', 1, 'N'),
('菜单', '2', 'menu_type', 2, 'N'),
('按钮', '3', 'menu_type', 3, 'N'),
('全部数据', '1', 'data_scope', 1, 'N'),
('本部门数据', '2', 'data_scope', 2, 'N'),
('本部门及下级', '3', 'data_scope', 3, 'N'),
('自定义数据', '4', 'data_scope', 4, 'N'),
('其他', '0', 'business_type', 1, 'N'),
('新增', '1', 'business_type', 2, 'N'),
('修改', '2', 'business_type', 3, 'N'),
('删除', '3', 'business_type', 4, 'N'),
('授权', '4', 'business_type', 5, 'N'),
('导出', '5', 'business_type', 6, 'N'),
('导入', '6', 'business_type', 7, 'N'),
('其他', '0', 'operator_type', 1, 'N'),
('后台用户', '1', 'operator_type', 2, 'N'),
('手机端用户', '2', 'operator_type', 3, 'N'),
('停用', '0', 'sys_status', 1, 'N'),
('正常', '1', 'sys_status', 2, 'N'),
('否', 'N', 'is_default', 1, 'Y'),
('是', 'Y', 'is_default', 2, 'N'),
('否', 'N', 'yes_no', 1, 'Y'),
('是', 'Y', 'yes_no', 2, 'N');

-- 默认参数配置
INSERT INTO `sys_params` (`param_name`, `param_key`, `param_value`, `is_system`, `sort`) VALUES
('主框架页-默认主题样式', 'sys.index.skinName', 'skin-blue', 1, 1),
('用户管理-账号初始密码', 'sys.user.initPassword', '123456', 1, 2),
('主框架页-侧边栏主题', 'sys.index.sideTheme', 'theme-dark', 1, 3),
('账号自助-验证码开关', 'sys.account.captchaEnabled', 'true', 1, 4),
('账号自助-是否开启用户注册', 'sys.account.registerUser', 'false', 1, 5);

-- =================================================================
-- 脚本执行完成
-- =================================================================

SELECT 'MySQL数据库脚本执行完成！' AS message;
SELECT '默认管理员账号：admin / admin123' AS admin_info;