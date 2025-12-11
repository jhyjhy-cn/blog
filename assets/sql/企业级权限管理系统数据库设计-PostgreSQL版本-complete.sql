-- =================================================================
-- 企业级权限管理系统数据库脚本 - PostgreSQL 14+ 版本
-- 创建时间：2025-12-10
-- 作者：Hongyu
-- =================================================================

-- 创建数据库
CREATE DATABASE "rbac_system"
    WITH
    OWNER = postgres
    ENCODING = 'UTF8'
    LC_COLLATE = 'en_US.utf8'
    LC_CTYPE = 'en_US.utf8'
    TABLESPACE = pg_default
    CONNECTION LIMIT = -1;

-- 连接到数据库
\c "rbac_system";

-- 创建扩展
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- =================================================================
-- 1. 枚举类型定义
-- =================================================================

-- 用户性别枚举
CREATE TYPE gender_enum AS ENUM ('0', '1', '2');

-- 状态枚举
CREATE TYPE status_enum AS ENUM ('0', '1');

-- 菜单类型枚举
CREATE TYPE menu_type_enum AS ENUM ('1', '2', '3');

-- 数据权限范围枚举
CREATE TYPE data_scope_enum AS ENUM ('1', '2', '3', '4');

-- 业务类型枚举
CREATE TYPE business_type_enum AS ENUM ('0', '1', '2', '3', '4', '5', '6');

-- 操作类别枚举
CREATE TYPE operator_type_enum AS ENUM ('0', '1', '2');

-- 是否枚举
CREATE TYPE yes_no_enum AS ENUM ('Y', 'N');

-- 周期单位枚举
CREATE TYPE cycle_unit_enum AS ENUM ('1', '2', '3');

-- =================================================================
-- 2. 序列定义
-- =================================================================

-- 创建自增序列
CREATE SEQUENCE IF NOT EXISTS seq_sys_id
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

-- 创建序列函数
CREATE OR REPLACE FUNCTION next_id()
RETURNS BIGINT AS $$
BEGIN
    RETURN nextval('seq_sys_id');
END;
$$ LANGUAGE PLPGSQL;

-- =================================================================
-- 3. 触发器函数
-- =================================================================

-- 更新时间触发器函数
CREATE OR REPLACE FUNCTION update_modified_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.update_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- 密码加密函数
CREATE OR REPLACE FUNCTION encrypt_password(p_password TEXT)
RETURNS TEXT AS $$
BEGIN
    RETURN encode(digest(p_password, 'sha256'), 'hex');
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =================================================================
-- 4. 核心业务表
-- =================================================================

-- 4.1 部门表 (sys_dept)
CREATE TABLE sys_dept (
    id BIGINT PRIMARY KEY DEFAULT next_id(),
    dept_name VARCHAR(50) NOT NULL,
    dept_code VARCHAR(50) NOT NULL,
    parent_id BIGINT NOT NULL DEFAULT 0,
    leader_id BIGINT,
    leader_phone VARCHAR(20),
    leader_email VARCHAR(100),
    status status_enum NOT NULL DEFAULT '1',
    sort INTEGER NOT NULL DEFAULT 0,
    create_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    creator BIGINT,
    update_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updater BIGINT,
    delete_flag status_enum NOT NULL DEFAULT '0',
    delete_at TIMESTAMP,
    version INTEGER NOT NULL DEFAULT 1,
    tenant_id BIGINT,
    CONSTRAINT uk_dept_code UNIQUE (dept_code, tenant_id)
);

-- 添加注释
COMMENT ON TABLE sys_dept IS '部门表';
COMMENT ON COLUMN sys_dept.id IS '部门ID';
COMMENT ON COLUMN sys_dept.dept_name IS '部门名称';
COMMENT ON COLUMN sys_dept.dept_code IS '部门编码';
COMMENT ON COLUMN sys_dept.parent_id IS '父部门ID';
COMMENT ON COLUMN sys_dept.leader_id IS '负责人用户ID';
COMMENT ON COLUMN sys_dept.leader_phone IS '负责人联系电话';
COMMENT ON COLUMN sys_dept.leader_email IS '负责人邮箱';
COMMENT ON COLUMN sys_dept.status IS '状态：0-禁用，1-正常';
COMMENT ON COLUMN sys_dept.sort IS '排序';
COMMENT ON COLUMN sys_dept.create_at IS '创建时间';
COMMENT ON COLUMN sys_dept.creator IS '创建人ID';
COMMENT ON COLUMN sys_dept.update_at IS '更新时间';
COMMENT ON COLUMN sys_dept.updater IS '更新人ID';
COMMENT ON COLUMN sys_dept.delete_flag IS '是否删除：0-否，1-是';
COMMENT ON COLUMN sys_dept.delete_at IS '删除时间';
COMMENT ON COLUMN sys_dept.version IS '乐观锁版本号';
COMMENT ON COLUMN sys_dept.tenant_id IS '租户ID';

-- 创建索引
CREATE INDEX idx_dept_parent_id ON sys_dept (parent_id);
CREATE INDEX idx_dept_status ON sys_dept (status);
CREATE INDEX idx_dept_delete_flag ON sys_dept (delete_flag);
CREATE INDEX idx_dept_tenant_id ON sys_dept (tenant_id);

-- 4.2 岗位表 (sys_post)
CREATE TABLE sys_post (
    id BIGINT PRIMARY KEY DEFAULT next_id(),
    post_name VARCHAR(50) NOT NULL,
    post_code VARCHAR(50) NOT NULL,
    dept_id BIGINT NOT NULL,
    sort INTEGER NOT NULL DEFAULT 0,
    status status_enum NOT NULL DEFAULT '1',
    create_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    creator BIGINT,
    update_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updater BIGINT,
    delete_flag status_enum NOT NULL DEFAULT '0',
    delete_at TIMESTAMP,
    version INTEGER NOT NULL DEFAULT 1,
    tenant_id BIGINT,
    CONSTRAINT uk_post_code UNIQUE (post_code, tenant_id)
);

-- 添加注释
COMMENT ON TABLE sys_post IS '岗位表';
COMMENT ON COLUMN sys_post.id IS '岗位ID';
COMMENT ON COLUMN sys_post.post_name IS '岗位名称';
COMMENT ON COLUMN sys_post.post_code IS '岗位编码';
COMMENT ON COLUMN sys_post.dept_id IS '所属部门ID';
COMMENT ON COLUMN sys_post.sort IS '排序';
COMMENT ON COLUMN sys_post.status IS '状态：0-禁用，1-正常';
COMMENT ON COLUMN sys_post.create_at IS '创建时间';
COMMENT ON COLUMN sys_post.creator IS '创建人ID';
COMMENT ON COLUMN sys_post.update_at IS '更新时间';
COMMENT ON COLUMN sys_post.updater IS '更新人ID';
COMMENT ON COLUMN sys_post.delete_flag IS '是否删除：0-否，1-是';
COMMENT ON COLUMN sys_post.delete_at IS '删除时间';
COMMENT ON COLUMN sys_post.version IS '乐观锁版本号';
COMMENT ON COLUMN sys_post.tenant_id IS '租户ID';

-- 创建索引
CREATE INDEX idx_post_dept_id ON sys_post (dept_id);
CREATE INDEX idx_post_status ON sys_post (status);
CREATE INDEX idx_post_delete_flag ON sys_post (delete_flag);
CREATE INDEX idx_post_tenant_id ON sys_post (tenant_id);

-- 4.3 用户表 (sys_user)
CREATE TABLE sys_user (
    id BIGINT PRIMARY KEY DEFAULT next_id(),
    username VARCHAR(50) NOT NULL,
    password VARCHAR(255) NOT NULL,
    nickname VARCHAR(50),
    real_name VARCHAR(50),
    email VARCHAR(100),
    phone VARCHAR(20),
    avatar VARCHAR(255),
    sex gender_enum DEFAULT '0',
    birthday DATE,
    dept_id BIGINT,
    post_id BIGINT,
    address VARCHAR(200),
    remark VARCHAR(500),
    sort INTEGER NOT NULL DEFAULT 0,
    status status_enum NOT NULL DEFAULT '1',
    last_login_time TIMESTAMP,
    last_login_ip VARCHAR(50),
    create_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    creator BIGINT,
    update_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updater BIGINT,
    delete_flag status_enum NOT NULL DEFAULT '0',
    delete_at TIMESTAMP,
    version INTEGER NOT NULL DEFAULT 1,
    tenant_id BIGINT,
    CONSTRAINT uk_username UNIQUE (username, tenant_id),
    CONSTRAINT uk_email UNIQUE (email, tenant_id),
    CONSTRAINT uk_phone UNIQUE (phone, tenant_id)
);

-- 添加注释
COMMENT ON TABLE sys_user IS '用户表';
COMMENT ON COLUMN sys_user.id IS '用户ID';
COMMENT ON COLUMN sys_user.username IS '用户名';
COMMENT ON COLUMN sys_user.password IS '密码';
COMMENT ON COLUMN sys_user.nickname IS '昵称';
COMMENT ON COLUMN sys_user.real_name IS '真实姓名';
COMMENT ON COLUMN sys_user.email IS '邮箱';
COMMENT ON COLUMN sys_user.phone IS '手机号';
COMMENT ON COLUMN sys_user.avatar IS '头像地址';
COMMENT ON COLUMN sys_user.sex IS '性别：0-未知，1-男，2-女';
COMMENT ON COLUMN sys_user.birthday IS '生日';
COMMENT ON COLUMN sys_user.dept_id IS '部门ID';
COMMENT ON COLUMN sys_user.post_id IS '岗位ID';
COMMENT ON COLUMN sys_user.address IS '地址';
COMMENT ON COLUMN sys_user.remark IS '备注';
COMMENT ON COLUMN sys_user.sort IS '排序';
COMMENT ON COLUMN sys_user.status IS '状态：0-禁用，1-正常';
COMMENT ON COLUMN sys_user.last_login_time IS '最后登录时间';
COMMENT ON COLUMN sys_user.last_login_ip IS '最后登录IP';
COMMENT ON COLUMN sys_user.create_at IS '创建时间';
COMMENT ON COLUMN sys_user.creator IS '创建人ID';
COMMENT ON COLUMN sys_user.update_at IS '更新时间';
COMMENT ON COLUMN sys_user.updater IS '更新人ID';
COMMENT ON COLUMN sys_user.delete_flag IS '是否删除：0-否，1-是';
COMMENT ON COLUMN sys_user.delete_at IS '删除时间';
COMMENT ON COLUMN sys_user.version IS '乐观锁版本号';
COMMENT ON COLUMN sys_user.tenant_id IS '租户ID';

-- 创建索引
CREATE INDEX idx_user_dept_id ON sys_user (dept_id);
CREATE INDEX idx_user_post_id ON sys_user (post_id);
CREATE INDEX idx_user_status ON sys_user (status);
CREATE INDEX idx_user_delete_flag ON sys_user (delete_flag);
CREATE INDEX idx_user_tenant_id ON sys_user (tenant_id);

-- 4.4 角色表 (sys_role)
CREATE TABLE sys_role (
    id BIGINT PRIMARY KEY DEFAULT next_id(),
    role_name VARCHAR(50) NOT NULL,
    role_code VARCHAR(50) NOT NULL,
    remark VARCHAR(200),
    data_scope data_scope_enum NOT NULL DEFAULT '1',
    sort INTEGER NOT NULL DEFAULT 0,
    status status_enum NOT NULL DEFAULT '1',
    create_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    creator BIGINT,
    update_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updater BIGINT,
    delete_flag status_enum NOT NULL DEFAULT '0',
    delete_at TIMESTAMP,
    version INTEGER NOT NULL DEFAULT 1,
    tenant_id BIGINT,
    CONSTRAINT uk_role_code UNIQUE (role_code, tenant_id)
);

-- 添加注释
COMMENT ON TABLE sys_role IS '角色表';
COMMENT ON COLUMN sys_role.id IS '角色ID';
COMMENT ON COLUMN sys_role.role_name IS '角色名称';
COMMENT ON COLUMN sys_role.role_code IS '角色编码';
COMMENT ON COLUMN sys_role.remark IS '备注';
COMMENT ON COLUMN sys_role.data_scope IS '数据权限：1-全部，2-本部门，3-本部门及下级，4-自定义';
COMMENT ON COLUMN sys_role.sort IS '排序';
COMMENT ON COLUMN sys_role.status IS '状态：0-禁用，1-正常';
COMMENT ON COLUMN sys_role.create_at IS '创建时间';
COMMENT ON COLUMN sys_role.creator IS '创建人ID';
COMMENT ON COLUMN sys_role.update_at IS '更新时间';
COMMENT ON COLUMN sys_role.updater IS '更新人ID';
COMMENT ON COLUMN sys_role.delete_flag IS '是否删除：0-否，1-是';
COMMENT ON COLUMN sys_role.delete_at IS '删除时间';
COMMENT ON COLUMN sys_role.version IS '乐观锁版本号';
COMMENT ON COLUMN sys_role.tenant_id IS '租户ID';

-- 创建索引
CREATE INDEX idx_role_status ON sys_role (status);
CREATE INDEX idx_role_data_scope ON sys_role (data_scope);
CREATE INDEX idx_role_delete_flag ON sys_role (delete_flag);
CREATE INDEX idx_role_tenant_id ON sys_role (tenant_id);

-- 4.5 菜单表 (sys_menu)
CREATE TABLE sys_menu (
    id BIGINT PRIMARY KEY DEFAULT next_id(),
    menu_name VARCHAR(50) NOT NULL,
    menu_code VARCHAR(100) NOT NULL,
    parent_id BIGINT NOT NULL DEFAULT 0,
    menu_type menu_type_enum NOT NULL,
    path VARCHAR(200),
    component VARCHAR(200),
    icon VARCHAR(100),
    permission VARCHAR(100),
    target VARCHAR(20) NOT NULL DEFAULT '_self',
    is_cache status_enum NOT NULL DEFAULT '0',
    is_visible status_enum NOT NULL DEFAULT '1',
    is_external status_enum NOT NULL DEFAULT '0',
    sort INTEGER NOT NULL DEFAULT 0,
    status status_enum NOT NULL DEFAULT '1',
    create_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    creator BIGINT,
    update_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updater BIGINT,
    delete_flag status_enum NOT NULL DEFAULT '0',
    delete_at TIMESTAMP,
    version INTEGER NOT NULL DEFAULT 1,
    tenant_id BIGINT,
    CONSTRAINT uk_menu_code UNIQUE (menu_code, tenant_id)
);

-- 添加注释
COMMENT ON TABLE sys_menu IS '菜单表';
COMMENT ON COLUMN sys_menu.id IS '菜单ID';
COMMENT ON COLUMN sys_menu.menu_name IS '菜单名称';
COMMENT ON COLUMN sys_menu.menu_code IS '菜单编码/权限标识';
COMMENT ON COLUMN sys_menu.parent_id IS '父菜单ID';
COMMENT ON COLUMN sys_menu.menu_type IS '菜单类型：1-目录，2-菜单，3-按钮';
COMMENT ON COLUMN sys_menu.path IS '路由路径';
COMMENT ON COLUMN sys_menu.component IS '组件路径';
COMMENT ON COLUMN sys_menu.icon IS '图标';
COMMENT ON COLUMN sys_menu.permission IS '权限标识';
COMMENT ON COLUMN sys_menu.target IS '打开方式：_self-当前页，_blank-新页';
COMMENT ON COLUMN sys_menu.is_cache IS '是否缓存：0-否，1-是';
COMMENT ON COLUMN sys_menu.is_visible IS '是否显示：0-否，1-是';
COMMENT ON COLUMN sys_menu.is_external IS '是否外链：0-否，1-是';
COMMENT ON COLUMN sys_menu.sort IS '排序';
COMMENT ON COLUMN sys_menu.status IS '状态：0-禁用，1-正常';
COMMENT ON COLUMN sys_menu.create_at IS '创建时间';
COMMENT ON COLUMN sys_menu.creator IS '创建人ID';
COMMENT ON COLUMN sys_menu.update_at IS '更新时间';
COMMENT ON COLUMN sys_menu.updater IS '更新人ID';
COMMENT ON COLUMN sys_menu.delete_flag IS '是否删除：0-否，1-是';
COMMENT ON COLUMN sys_menu.delete_at IS '删除时间';
COMMENT ON COLUMN sys_menu.version IS '乐观锁版本号';
COMMENT ON COLUMN sys_menu.tenant_id IS '租户ID';

-- 创建索引
CREATE INDEX idx_menu_parent_id ON sys_menu (parent_id);
CREATE INDEX idx_menu_menu_type ON sys_menu (menu_type);
CREATE INDEX idx_menu_status ON sys_menu (status);
CREATE INDEX idx_menu_delete_flag ON sys_menu (delete_flag);
CREATE INDEX idx_menu_tenant_id ON sys_menu (tenant_id);

-- =================================================================
-- 5. 关联表
-- =================================================================

-- 5.1 用户角色关联表 (sys_user_role)
CREATE TABLE sys_user_role (
    id BIGINT PRIMARY KEY DEFAULT next_id(),
    user_id BIGINT NOT NULL,
    role_id BIGINT NOT NULL,
    CONSTRAINT uk_user_role UNIQUE (user_id, role_id)
);

-- 添加注释
COMMENT ON TABLE sys_user_role IS '用户角色关联表';
COMMENT ON COLUMN sys_user_role.id IS '主键ID';
COMMENT ON COLUMN sys_user_role.user_id IS '用户ID';
COMMENT ON COLUMN sys_user_role.role_id IS '角色ID';

-- 创建索引
CREATE INDEX idx_user_role_user_id ON sys_user_role (user_id);
CREATE INDEX idx_user_role_role_id ON sys_user_role (role_id);

-- 5.2 角色菜单关联表 (sys_role_menu)
CREATE TABLE sys_role_menu (
    id BIGINT PRIMARY KEY DEFAULT next_id(),
    role_id BIGINT NOT NULL,
    menu_id BIGINT NOT NULL,
    CONSTRAINT uk_role_menu UNIQUE (role_id, menu_id)
);

-- 添加注释
COMMENT ON TABLE sys_role_menu IS '角色菜单关联表';
COMMENT ON COLUMN sys_role_menu.id IS '主键ID';
COMMENT ON COLUMN sys_role_menu.role_id IS '角色ID';
COMMENT ON COLUMN sys_role_menu.menu_id IS '菜单ID';

-- 创建索引
CREATE INDEX idx_role_menu_role_id ON sys_role_menu (role_id);
CREATE INDEX idx_role_menu_menu_id ON sys_role_menu (menu_id);

-- 5.3 角色部门关联表 (sys_role_dept)
CREATE TABLE sys_role_dept (
    id BIGINT PRIMARY KEY DEFAULT next_id(),
    role_id BIGINT NOT NULL,
    dept_id BIGINT NOT NULL,
    CONSTRAINT uk_role_dept UNIQUE (role_id, dept_id)
);

-- 添加注释
COMMENT ON TABLE sys_role_dept IS '角色部门关联表';
COMMENT ON COLUMN sys_role_dept.id IS '主键ID';
COMMENT ON COLUMN sys_role_dept.role_id IS '角色ID';
COMMENT ON COLUMN sys_role_dept.dept_id IS '部门ID';

-- 创建索引
CREATE INDEX idx_role_dept_role_id ON sys_role_dept (role_id);
CREATE INDEX idx_role_dept_dept_id ON sys_role_dept (dept_id);

-- =================================================================
-- 6. 日志表
-- =================================================================

-- 6.1 登录日志表 (sys_login_log)
CREATE TABLE sys_login_log (
    id BIGINT PRIMARY KEY DEFAULT next_id(),
    username VARCHAR(50) NOT NULL,
    user_id BIGINT,
    ipaddr VARCHAR(50) NOT NULL,
    login_location VARCHAR(255),
    browser VARCHAR(50),
    os VARCHAR(50),
    device VARCHAR(50),
    status status_enum NOT NULL DEFAULT '0',
    msg VARCHAR(255),
    login_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    create_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- 添加注释
COMMENT ON TABLE sys_login_log IS '登录日志表';
COMMENT ON COLUMN sys_login_log.id IS '日志ID';
COMMENT ON COLUMN sys_login_log.username IS '用户名';
COMMENT ON COLUMN sys_login_log.user_id IS '用户ID';
COMMENT ON COLUMN sys_login_log.ipaddr IS '登录IP地址';
COMMENT ON COLUMN sys_login_log.login_location IS '登录地点';
COMMENT ON COLUMN sys_login_log.browser IS '浏览器类型';
COMMENT ON COLUMN sys_login_log.os IS '操作系统';
COMMENT ON COLUMN sys_login_log.device IS '设备类型';
COMMENT ON COLUMN sys_login_log.status IS '登录状态：0-失败，1-成功';
COMMENT ON COLUMN sys_login_log.msg IS '提示信息';
COMMENT ON COLUMN sys_login_log.login_time IS '登录时间';
COMMENT ON COLUMN sys_login_log.create_at IS '创建时间';

-- 创建索引
CREATE INDEX idx_login_log_user_id ON sys_login_log (user_id);
CREATE INDEX idx_login_log_username ON sys_login_log (username);
CREATE INDEX idx_login_log_login_time ON sys_login_log (login_time);
CREATE INDEX idx_login_log_username_time ON sys_login_log (username, login_time);

-- 6.2 操作日志表 (sys_operation_log)
CREATE TABLE sys_operation_log (
    id BIGINT PRIMARY KEY DEFAULT next_id(),
    title VARCHAR(50),
    business_type business_type_enum NOT NULL DEFAULT '0',
    business_type_name VARCHAR(50),
    method VARCHAR(10) NOT NULL,
    request_method VARCHAR(10) NOT NULL,
    operator_type operator_type_enum DEFAULT '0',
    operator_name VARCHAR(50),
    dept_name VARCHAR(50),
    operation_url VARCHAR(255),
    operation_ip VARCHAR(50) NOT NULL,
    operation_location VARCHAR(255),
    operation_param TEXT,
    json_result TEXT,
    operation_status status_enum DEFAULT '0',
    error_msg VARCHAR(2000),
    operation_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    cost_time BIGINT
);

-- 添加注释
COMMENT ON TABLE sys_operation_log IS '操作日志表';
COMMENT ON COLUMN sys_operation_log.id IS '日志ID';
COMMENT ON COLUMN sys_operation_log.title IS '操作模块';
COMMENT ON COLUMN sys_operation_log.business_type IS '业务类型（0-其他 1-新增 2-修改 3-删除）';
COMMENT ON COLUMN sys_operation_log.business_type_name IS '业务类型名称';
COMMENT ON COLUMN sys_operation_log.method IS '请求方式';
COMMENT ON COLUMN sys_operation_log.request_method IS '请求类型';
COMMENT ON COLUMN sys_operation_log.operator_type IS '操作类别（0-其它 1-后台用户 2-手机端用户）';
COMMENT ON COLUMN sys_operation_log.operator_name IS '操作人员';
COMMENT ON COLUMN sys_operation_log.dept_name IS '部门名称';
COMMENT ON COLUMN sys_operation_log.operation_url IS '请求URL';
COMMENT ON COLUMN sys_operation_log.operation_ip IS '操作地址';
COMMENT ON COLUMN sys_operation_log.operation_location IS '操作地点';
COMMENT ON COLUMN sys_operation_log.operation_param IS '请求参数';
COMMENT ON COLUMN sys_operation_log.json_result IS '返回参数';
COMMENT ON COLUMN sys_operation_log.operation_status IS '操作状态：0-正常，1-异常';
COMMENT ON COLUMN sys_operation_log.error_msg IS '错误消息';
COMMENT ON COLUMN sys_operation_log.operation_time IS '操作时间';
COMMENT ON COLUMN sys_operation_log.cost_time IS '消耗时间';

-- 创建索引
CREATE INDEX idx_operation_log_user_id ON sys_operation_log (operator_name);
CREATE INDEX idx_operation_log_operation_time ON sys_operation_log (operation_time);
CREATE INDEX idx_operation_log_business_type ON sys_operation_log (business_type);
CREATE INDEX idx_operation_log_status ON sys_operation_log (operation_status);

-- 6.3 错误日志表 (sys_error_log)
CREATE TABLE sys_error_log (
    id BIGINT PRIMARY KEY DEFAULT next_id(),
    title VARCHAR(255),
    request_uri VARCHAR(255) NOT NULL,
    request_method VARCHAR(10) NOT NULL,
    request_params TEXT,
    user_id BIGINT,
    username VARCHAR(50),
    user_ip VARCHAR(128),
    user_agent VARCHAR(500),
    exception_info TEXT NOT NULL,
    exception_name VARCHAR(255),
    stack_trace TEXT,
    line_number INTEGER,
    class_name VARCHAR(200),
    method_name VARCHAR(200),
    status status_enum NOT NULL DEFAULT '0',
    process_user_id BIGINT,
    process_user_name VARCHAR(50),
    process_remark VARCHAR(500),
    process_time TIMESTAMP,
    create_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- 添加注释
COMMENT ON TABLE sys_error_log IS '错误日志表';
COMMENT ON COLUMN sys_error_log.id IS '日志ID';
COMMENT ON COLUMN sys_error_log.title IS '错误标题';
COMMENT ON COLUMN sys_error_log.request_uri IS '请求URL';
COMMENT ON COLUMN sys_error_log.request_method IS '请求方式';
COMMENT ON COLUMN sys_error_log.request_params IS '请求参数';
COMMENT ON COLUMN sys_error_log.user_id IS '用户ID';
COMMENT ON COLUMN sys_error_log.username IS '用户名';
COMMENT ON COLUMN sys_error_log.user_ip IS '操作IP地址';
COMMENT ON COLUMN sys_error_log.user_agent IS '用户代理';
COMMENT ON COLUMN sys_error_log.exception_info IS '错误消息';
COMMENT ON COLUMN sys_error_log.exception_name IS '异常名称';
COMMENT ON COLUMN sys_error_log.stack_trace IS '错误堆栈';
COMMENT ON COLUMN sys_error_log.line_number IS '错误行号';
COMMENT ON COLUMN sys_error_log.class_name IS 'Java类名';
COMMENT ON COLUMN sys_error_log.method_name IS '方法名';
COMMENT ON COLUMN sys_error_log.status IS '状态';
COMMENT ON COLUMN sys_error_log.process_user_id IS '处理人ID';
COMMENT ON COLUMN sys_error_log.process_user_name IS '处理人';
COMMENT ON COLUMN sys_error_log.process_remark IS '处理备注';
COMMENT ON COLUMN sys_error_log.process_time IS '处理时间';
COMMENT ON COLUMN sys_error_log.create_time IS '创建时间';

-- 创建索引
CREATE INDEX idx_error_log_user_id ON sys_error_log (user_id);
CREATE INDEX idx_error_log_create_time ON sys_error_log (create_time);
CREATE INDEX idx_error_log_status ON sys_error_log (status);
CREATE INDEX idx_error_log_exception_name ON sys_error_log (exception_name);

-- =================================================================
-- 7. 租户管理表
-- =================================================================

-- 7.1 租户表 (sys_tenant)
CREATE TABLE sys_tenant (
    id BIGINT PRIMARY KEY DEFAULT next_id(),
    tenant_name VARCHAR(50) NOT NULL,
    tenant_code VARCHAR(20) NOT NULL,
    contact_name VARCHAR(30) NOT NULL,
    contact_phone VARCHAR(20),
    contact_email VARCHAR(50),
    company_name VARCHAR(100),
    domain VARCHAR(100),
    address VARCHAR(200),
    phone VARCHAR(20),
    email VARCHAR(100),
    package_id BIGINT,
    expire_time TIMESTAMP,
    account_count INTEGER NOT NULL DEFAULT 0,
    sort INTEGER NOT NULL DEFAULT 0,
    status status_enum NOT NULL DEFAULT '1',
    create_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    creator BIGINT,
    update_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updater BIGINT,
    delete_flag status_enum NOT NULL DEFAULT '0',
    delete_at TIMESTAMP,
    version INTEGER NOT NULL DEFAULT 1,
    CONSTRAINT uk_tenant_code UNIQUE (tenant_code)
);

-- 添加注释
COMMENT ON TABLE sys_tenant IS '租户表';
COMMENT ON COLUMN sys_tenant.id IS '租户ID';
COMMENT ON COLUMN sys_tenant.tenant_name IS '租户名称';
COMMENT ON COLUMN sys_tenant.tenant_code IS '租户编码';
COMMENT ON COLUMN sys_tenant.contact_name IS '联系人';
COMMENT ON COLUMN sys_tenant.contact_phone IS '联系电话';
COMMENT ON COLUMN sys_tenant.contact_email IS '联系邮箱';
COMMENT ON COLUMN sys_tenant.company_name IS '企业名称';
COMMENT ON COLUMN sys_tenant.domain IS '域名';
COMMENT ON COLUMN sys_tenant.address IS '地址';
COMMENT ON COLUMN sys_tenant.phone IS '电话';
COMMENT ON COLUMN sys_tenant.email IS '邮箱';
COMMENT ON COLUMN sys_tenant.package_id IS '套餐ID';
COMMENT ON COLUMN sys_tenant.expire_time IS '到期时间';
COMMENT ON COLUMN sys_tenant.account_count IS '账号数量';
COMMENT ON COLUMN sys_tenant.sort IS '排序';
COMMENT ON COLUMN sys_tenant.status IS '状态：0-禁用，1-正常';
COMMENT ON COLUMN sys_tenant.create_at IS '创建时间';
COMMENT ON COLUMN sys_tenant.creator IS '创建人ID';
COMMENT ON COLUMN sys_tenant.update_at IS '更新时间';
COMMENT ON COLUMN sys_tenant.updater IS '更新人ID';
COMMENT ON COLUMN sys_tenant.delete_flag IS '是否删除：0-否，1-是';
COMMENT ON COLUMN sys_tenant.delete_at IS '删除时间';
COMMENT ON COLUMN sys_tenant.version IS '乐观锁版本号';

-- 创建索引
CREATE INDEX idx_tenant_package_id ON sys_tenant (package_id);
CREATE INDEX idx_tenant_status ON sys_tenant (status);
CREATE INDEX idx_tenant_delete_flag ON sys_tenant (delete_flag);
CREATE INDEX idx_tenant_expire_time ON sys_tenant (expire_time);

-- 7.2 租户套餐表 (sys_tenant_package)
CREATE TABLE sys_tenant_package (
    id BIGINT PRIMARY KEY DEFAULT next_id(),
    package_name VARCHAR(50) NOT NULL,
    package_code VARCHAR(20) NOT NULL,
    max_users INTEGER NOT NULL DEFAULT 10,
    max_storage BIGINT NOT NULL DEFAULT 1073741824,
    price DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    cycle_unit cycle_unit_enum NOT NULL DEFAULT '1',
    features TEXT,
    description VARCHAR(500),
    status status_enum NOT NULL DEFAULT '1',
    sort_order INTEGER NOT NULL DEFAULT 0,
    create_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    creator BIGINT,
    update_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updater BIGINT,
    delete_flag status_enum NOT NULL DEFAULT '0',
    delete_at TIMESTAMP,
    version INTEGER NOT NULL DEFAULT 1,
    CONSTRAINT uk_package_code UNIQUE (package_code)
);

-- 添加注释
COMMENT ON TABLE sys_tenant_package IS '租户套餐表';
COMMENT ON COLUMN sys_tenant_package.id IS '套餐ID';
COMMENT ON COLUMN sys_tenant_package.package_name IS '套餐名称';
COMMENT ON COLUMN sys_tenant_package.package_code IS '套餐编码';
COMMENT ON COLUMN sys_tenant_package.max_users IS '最大用户数';
COMMENT ON COLUMN sys_tenant_package.max_storage IS '最大存储空间（字节）';
COMMENT ON COLUMN sys_tenant_package.price IS '价格';
COMMENT ON COLUMN sys_tenant_package.cycle_unit IS '计费周期：1-月，2-季，3-年';
COMMENT ON COLUMN sys_tenant_package.features IS '功能特性（JSON格式）';
COMMENT ON COLUMN sys_tenant_package.description IS '套餐描述';
COMMENT ON COLUMN sys_tenant_package.status IS '状态：0-禁用，1-正常';
COMMENT ON COLUMN sys_tenant_package.sort_order IS '排序';
COMMENT ON COLUMN sys_tenant_package.create_at IS '创建时间';
COMMENT ON COLUMN sys_tenant_package.creator IS '创建人ID';
COMMENT ON COLUMN sys_tenant_package.update_at IS '更新时间';
COMMENT ON COLUMN sys_tenant_package.updater IS '更新人ID';
COMMENT ON COLUMN sys_tenant_package.delete_flag IS '是否删除：0-否，1-是';
COMMENT ON COLUMN sys_tenant_package.delete_at IS '删除时间';
COMMENT ON COLUMN sys_tenant_package.version IS '乐观锁版本号';

-- 创建索引
CREATE INDEX idx_tenant_package_status ON sys_tenant_package (status);
CREATE INDEX idx_tenant_package_delete_flag ON sys_tenant_package (delete_flag);

-- 7.3 租户配置表 (sys_tenant_config)
CREATE TABLE sys_tenant_config (
    id BIGINT PRIMARY KEY DEFAULT next_id(),
    tenant_id BIGINT NOT NULL,
    config_key VARCHAR(100) NOT NULL,
    config_value TEXT,
    config_type status_enum NOT NULL DEFAULT '0',
    is_encrypted status_enum NOT NULL DEFAULT '0',
    remark VARCHAR(500),
    create_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    creator BIGINT,
    update_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updater BIGINT,
    delete_flag status_enum NOT NULL DEFAULT '0',
    delete_at TIMESTAMP,
    version INTEGER NOT NULL DEFAULT 1,
    CONSTRAINT uk_tenant_key UNIQUE (tenant_id, config_key)
);

-- 添加注释
COMMENT ON TABLE sys_tenant_config IS '租户配置表';
COMMENT ON COLUMN sys_tenant_config.id IS '配置ID';
COMMENT ON COLUMN sys_tenant_config.tenant_id IS '租户ID';
COMMENT ON COLUMN sys_tenant_config.config_key IS '配置键';
COMMENT ON COLUMN sys_tenant_config.config_value IS '配置值';
COMMENT ON COLUMN sys_tenant_config.config_type IS '系统内置（0-否 1-是）';
COMMENT ON COLUMN sys_tenant_config.is_encrypted IS '是否加密（0-否 1-是）';
COMMENT ON COLUMN sys_tenant_config.remark IS '备注';
COMMENT ON COLUMN sys_tenant_config.create_at IS '创建时间';
COMMENT ON COLUMN sys_tenant_config.creator IS '创建人ID';
COMMENT ON COLUMN sys_tenant_config.update_at IS '更新时间';
COMMENT ON COLUMN sys_tenant_config.updater IS '更新人ID';
COMMENT ON COLUMN sys_tenant_config.delete_flag IS '是否删除：0-否，1-是';
COMMENT ON COLUMN sys_tenant_config.delete_at IS '删除时间';
COMMENT ON COLUMN sys_tenant_config.version IS '乐观锁版本号';

-- 创建索引
CREATE INDEX idx_tenant_config_tenant_id ON sys_tenant_config (tenant_id);
CREATE INDEX idx_tenant_config_key ON sys_tenant_config (config_key);
CREATE INDEX idx_tenant_config_type ON sys_tenant_config (config_type);

-- =================================================================
-- 8. 系统配置表
-- =================================================================

-- 8.1 字典类型表 (sys_dict_type)
CREATE TABLE sys_dict_type (
    id BIGINT PRIMARY KEY DEFAULT next_id(),
    dict_name VARCHAR(100) NOT NULL,
    dict_type VARCHAR(100) NOT NULL,
    sort INTEGER NOT NULL DEFAULT 0,
    status status_enum NOT NULL DEFAULT '1',
    create_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    creator BIGINT,
    update_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updater BIGINT,
    delete_flag status_enum NOT NULL DEFAULT '0',
    delete_at TIMESTAMP,
    version INTEGER NOT NULL DEFAULT 1,
    remark VARCHAR(500),
    CONSTRAINT uk_dict_type UNIQUE (dict_type)
);

-- 添加注释
COMMENT ON TABLE sys_dict_type IS '字典类型表';
COMMENT ON COLUMN sys_dict_type.id IS '字典主键';
COMMENT ON COLUMN sys_dict_type.dict_name IS '字典名称';
COMMENT ON COLUMN sys_dict_type.dict_type IS '字典类型';
COMMENT ON COLUMN sys_dict_type.sort IS '排序';
COMMENT ON COLUMN sys_dict_type.status IS '状态（0正常 1停用）';
COMMENT ON COLUMN sys_dict_type.create_at IS '创建时间';
COMMENT ON COLUMN sys_dict_type.creator IS '创建人';
COMMENT ON COLUMN sys_dict_type.update_at IS '更新时间';
COMMENT ON COLUMN sys_dict_type.updater IS '更新人';
COMMENT ON COLUMN sys_dict_type.delete_flag IS '是否删除';
COMMENT ON COLUMN sys_dict_type.delete_at IS '删除时间';
COMMENT ON COLUMN sys_dict_type.version IS '乐观锁版本号';
COMMENT ON COLUMN sys_dict_type.remark IS '备注';

-- 创建索引
CREATE INDEX idx_dict_type_status ON sys_dict_type (status);
CREATE INDEX idx_dict_type_delete_flag ON sys_dict_type (delete_flag);

-- 8.2 字典数据表 (sys_dict_data)
CREATE TABLE sys_dict_data (
    id BIGINT PRIMARY KEY DEFAULT next_id(),
    dict_sort INTEGER NOT NULL DEFAULT 0,
    dict_label VARCHAR(100) NOT NULL,
    dict_value VARCHAR(100) NOT NULL,
    dict_type VARCHAR(100) NOT NULL,
    css_class VARCHAR(100),
    list_class VARCHAR(100),
    is_default yes_no_enum NOT NULL DEFAULT 'N',
    sort INTEGER NOT NULL DEFAULT 0,
    status status_enum NOT NULL DEFAULT '1',
    create_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    creator BIGINT,
    update_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updater BIGINT,
    delete_flag status_enum NOT NULL DEFAULT '0',
    delete_at TIMESTAMP,
    version INTEGER NOT NULL DEFAULT 1,
    remark VARCHAR(500)
);

-- 添加注释
COMMENT ON TABLE sys_dict_data IS '字典数据表';
COMMENT ON COLUMN sys_dict_data.id IS '数据编号';
COMMENT ON COLUMN sys_dict_data.dict_sort IS '字典排序';
COMMENT ON COLUMN sys_dict_data.dict_label IS '字典标签';
COMMENT ON COLUMN sys_dict_data.dict_value IS '字典键值';
COMMENT ON COLUMN sys_dict_data.dict_type IS '字典类型';
COMMENT ON COLUMN sys_dict_data.css_class IS '表格回显样式';
COMMENT ON COLUMN sys_dict_data.list_class IS '表格列表样式';
COMMENT ON COLUMN sys_dict_data.is_default IS '是否默认（Y是 N否）';
COMMENT ON COLUMN sys_dict_data.sort IS '排序';
COMMENT ON COLUMN sys_dict_data.status IS '状态（0正常 1停用）';
COMMENT ON COLUMN sys_dict_data.create_at IS '创建时间';
COMMENT ON COLUMN sys_dict_data.creator IS '创建人';
COMMENT ON COLUMN sys_dict_data.update_at IS '更新时间';
COMMENT ON COLUMN sys_dict_data.updater IS '更新人';
COMMENT ON COLUMN sys_dict_data.delete_flag IS '是否删除';
COMMENT ON COLUMN sys_dict_data.delete_at IS '删除时间';
COMMENT ON COLUMN sys_dict_data.version IS '乐观锁版本号';
COMMENT ON COLUMN sys_dict_data.remark IS '备注';

-- 创建索引
CREATE INDEX idx_dict_data_type_status ON sys_dict_data (dict_type, status);
CREATE INDEX idx_dict_data_sort ON sys_dict_data (dict_sort);
CREATE INDEX idx_dict_data_delete_flag ON sys_dict_data (delete_flag);

-- 8.3 参数配置表 (sys_params)
CREATE TABLE sys_params (
    id BIGINT PRIMARY KEY DEFAULT next_id(),
    param_name VARCHAR(100) NOT NULL,
    param_key VARCHAR(100) NOT NULL,
    param_value VARCHAR(500),
    is_system status_enum NOT NULL DEFAULT '0',
    is_encrypted status_enum NOT NULL DEFAULT '0',
    sort INTEGER NOT NULL DEFAULT 0,
    status status_enum NOT NULL DEFAULT '1',
    remark VARCHAR(500),
    create_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    creator BIGINT,
    update_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updater BIGINT,
    delete_flag status_enum NOT NULL DEFAULT '0',
    delete_at TIMESTAMP,
    version INTEGER NOT NULL DEFAULT 1,
    CONSTRAINT uk_param_key UNIQUE (param_key)
);

-- 添加注释
COMMENT ON TABLE sys_params IS '参数配置表';
COMMENT ON COLUMN sys_params.id IS '参数ID';
COMMENT ON COLUMN sys_params.param_name IS '参数名称';
COMMENT ON COLUMN sys_params.param_key IS '参数键名';
COMMENT ON COLUMN sys_params.param_value IS '参数键值';
COMMENT ON COLUMN sys_params.is_system IS '系统内置（0-否 1-是）';
COMMENT ON COLUMN sys_params.is_encrypted IS '是否加密（0-否 1-是）';
COMMENT ON COLUMN sys_params.sort IS '排序';
COMMENT ON COLUMN sys_params.status IS '状态（0正常 1停用）';
COMMENT ON COLUMN sys_params.remark IS '备注';
COMMENT ON COLUMN sys_params.create_at IS '创建时间';
COMMENT ON COLUMN sys_params.creator IS '创建人ID';
COMMENT ON COLUMN sys_params.update_at IS '更新时间';
COMMENT ON COLUMN sys_params.updater IS '更新人ID';
COMMENT ON COLUMN sys_params.delete_flag IS '是否删除：0-否，1-是';
COMMENT ON COLUMN sys_params.delete_at IS '删除时间';
COMMENT ON COLUMN sys_params.version IS '乐观锁版本号';

-- 创建索引
CREATE INDEX idx_params_is_system ON sys_params (is_system);
CREATE INDEX idx_params_status ON sys_params (status);
CREATE INDEX idx_params_delete_flag ON sys_params (delete_flag);

-- =================================================================
-- 9. 创建触发器
-- =================================================================

-- 部门表触发器
CREATE TRIGGER tr_dept_update BEFORE UPDATE ON sys_dept
    FOR EACH ROW EXECUTE FUNCTION update_modified_column();

-- 岗位表触发器
CREATE TRIGGER tr_post_update BEFORE UPDATE ON sys_post
    FOR EACH ROW EXECUTE FUNCTION update_modified_column();

-- 用户表触发器
CREATE TRIGGER tr_user_update BEFORE UPDATE ON sys_user
    FOR EACH ROW EXECUTE FUNCTION update_modified_column();

-- 角色表触发器
CREATE TRIGGER tr_role_update BEFORE UPDATE ON sys_role
    FOR EACH ROW EXECUTE FUNCTION update_modified_column();

-- 菜单表触发器
CREATE TRIGGER tr_menu_update BEFORE UPDATE ON sys_menu
    FOR EACH ROW EXECUTE FUNCTION update_modified_column();

-- 租户表触发器
CREATE TRIGGER tr_tenant_update BEFORE UPDATE ON sys_tenant
    FOR EACH ROW EXECUTE FUNCTION update_modified_column();

-- 租户套餐表触发器
CREATE TRIGGER tr_tenant_package_update BEFORE UPDATE ON sys_tenant_package
    FOR EACH ROW EXECUTE FUNCTION update_modified_column();

-- 租户配置表触发器
CREATE TRIGGER tr_tenant_config_update BEFORE UPDATE ON sys_tenant_config
    FOR EACH ROW EXECUTE FUNCTION update_modified_column();

-- 字典类型表触发器
CREATE TRIGGER tr_dict_type_update BEFORE UPDATE ON sys_dict_type
    FOR EACH ROW EXECUTE FUNCTION update_modified_column();

-- 字典数据表触发器
CREATE TRIGGER tr_dict_data_update BEFORE UPDATE ON sys_dict_data
    FOR EACH ROW EXECUTE FUNCTION update_modified_column();

-- 参数配置表触发器
CREATE TRIGGER tr_params_update BEFORE UPDATE ON sys_params
    FOR EACH ROW EXECUTE FUNCTION update_modified_column();

-- =================================================================
-- 10. 外键约束
-- =================================================================

-- 部门表外键
ALTER TABLE sys_dept ADD CONSTRAINT fk_dept_leader
FOREIGN KEY (leader_id) REFERENCES sys_user (id) ON DELETE SET NULL;

-- 岗位表外键
ALTER TABLE sys_post ADD CONSTRAINT fk_post_dept
FOREIGN KEY (dept_id) REFERENCES sys_dept (id) ON DELETE CASCADE;

-- 用户表外键
ALTER TABLE sys_user ADD CONSTRAINT fk_user_dept
FOREIGN KEY (dept_id) REFERENCES sys_dept (id) ON DELETE SET NULL;
ALTER TABLE sys_user ADD CONSTRAINT fk_user_post
FOREIGN KEY (post_id) REFERENCES sys_post (id) ON DELETE SET NULL;

-- 用户角色关联表外键
ALTER TABLE sys_user_role ADD CONSTRAINT fk_ur_user
FOREIGN KEY (user_id) REFERENCES sys_user (id) ON DELETE CASCADE;
ALTER TABLE sys_user_role ADD CONSTRAINT fk_ur_role
FOREIGN KEY (role_id) REFERENCES sys_role (id) ON DELETE CASCADE;

-- 角色菜单关联表外键
ALTER TABLE sys_role_menu ADD CONSTRAINT fk_rm_role
FOREIGN KEY (role_id) REFERENCES sys_role (id) ON DELETE CASCADE;
ALTER TABLE sys_role_menu ADD CONSTRAINT fk_rm_menu
FOREIGN KEY (menu_id) REFERENCES sys_menu (id) ON DELETE CASCADE;

-- 角色部门关联表外键
ALTER TABLE sys_role_dept ADD CONSTRAINT fk_rd_role
FOREIGN KEY (role_id) REFERENCES sys_role (id) ON DELETE CASCADE;
ALTER TABLE sys_role_dept ADD CONSTRAINT fk_rd_dept
FOREIGN KEY (dept_id) REFERENCES sys_dept (id) ON DELETE CASCADE;

-- 租户相关外键
ALTER TABLE sys_tenant ADD CONSTRAINT fk_tenant_package
FOREIGN KEY (package_id) REFERENCES sys_tenant_package (id) ON DELETE SET NULL;
ALTER TABLE sys_tenant_config ADD CONSTRAINT fk_config_tenant
FOREIGN KEY (tenant_id) REFERENCES sys_tenant (id) ON DELETE CASCADE;

-- 字典数据外键
ALTER TABLE sys_dict_data ADD CONSTRAINT fk_data_type
FOREIGN KEY (dict_type) REFERENCES sys_dict_type (dict_type) ON DELETE CASCADE;

-- =================================================================
-- 11. 初始化数据
-- =================================================================

-- 默认超级管理员 (密码: admin123)
INSERT INTO sys_user (id, username, password, nickname, real_name, email, status)
VALUES (1, 'admin', encrypt_password('admin123'), '超级管理员', '系统管理员', 'admin@example.com', '1');

-- 默认角色
INSERT INTO sys_role (id, role_name, role_code, remark, data_scope)
VALUES (1, '超级管理员', 'ROLE_ADMIN', '系统超级管理员', '1');

-- 用户角色关联
INSERT INTO sys_user_role (user_id, role_id) VALUES (1, 1);

-- 默认部门
INSERT INTO sys_dept (id, dept_name, dept_code, parent_id, status)
VALUES (1, '总公司', 'ROOT', 0, '1');

-- 更新超级管理员部门
UPDATE sys_user SET dept_id = 1 WHERE id = 1;

-- 默认菜单数据
INSERT INTO sys_menu (menu_name, menu_code, parent_id, menu_type, path, icon, sort) VALUES
('系统管理', 'system', 0, '1', '/system', 'system', 1),
('用户管理', 'system:user', 1, '2', 'user', 'user', 1),
('角色管理', 'system:role', 1, '2', 'role', 'role', 2),
('菜单管理', 'system:menu', 1, '2', 'menu', 'menu', 3),
('部门管理', 'system:dept', 1, '2', 'dept', 'dept', 4),
('岗位管理', 'system:post', 1, '2', 'post', 'post', 5),
('监控中心', 'monitor', 0, '1', '/monitor', 'monitor', 2),
('在线用户', 'monitor:online', 7, '2', 'online', 'online', 1),
('登录日志', 'monitor:logininfor', 7, '2', 'logininfor', 'logininfor', 2),
('操作日志', 'monitor:operlog', 7, '2', 'operlog', 'operlog', 3),
('系统工具', 'tool', 0, '1', '/tool', 'tool', 3),
('表单构建', 'tool:build', 11, '2', 'build', 'build', 1),
('代码生成', 'tool:gen', 11, '2', 'gen', 'code', 2),
('系统接口', 'tool:swagger', 11, '2', 'swagger', 'swagger', 3);

-- 获取最大菜单ID
SELECT setval('seq_sys_id', (SELECT MAX(id) FROM sys_menu));

-- 菜单权限按钮数据
INSERT INTO sys_menu (menu_name, menu_code, parent_id, menu_type, permission, sort) VALUES
('用户查询', 'system:user:query', 2, '3', 'system:user:list', 1),
('用户新增', 'system:user:add', 2, '3', 'system:user:add', 2),
('用户修改', 'system:user:edit', 2, '3', 'system:user:edit', 3),
('用户删除', 'system:user:remove', 2, '3', 'system:user:remove', 4),
('用户导出', 'system:user:export', 2, '3', 'system:user:export', 5),
('角色查询', 'system:role:query', 3, '3', 'system:role:list', 1),
('角色新增', 'system:role:add', 3, '3', 'system:role:add', 2),
('角色修改', 'system:role:edit', 3, '3', 'system:role:edit', 3),
('角色删除', 'system:role:remove', 3, '3', 'system:role:remove', 4),
('菜单查询', 'system:menu:query', 4, '3', 'system:menu:list', 1),
('菜单新增', 'system:menu:add', 4, '3', 'system:menu:add', 2),
('菜单修改', 'system:menu:edit', 4, '3', 'system:menu:edit', 3),
('菜单删除', 'system:menu:remove', 4, '3', 'system:menu:remove', 4),
('部门查询', 'system:dept:query', 5, '3', 'system:dept:list', 1),
('部门新增', 'system:dept:add', 5, '3', 'system:dept:add', 2),
('部门修改', 'system:dept:edit', 5, '3', 'system:dept:edit', 3),
('部门删除', 'system:dept:remove', 5, '3', 'system:dept:remove', 4),
('岗位查询', 'system:post:query', 6, '3', 'system:post:list', 1),
('岗位新增', 'system:post:add', 6, '3', 'system:post:add', 2),
('岗位修改', 'system:post:edit', 6, '3', 'system:post:edit', 3),
('岗位删除', 'system:post:remove', 6, '3', 'system:post:remove', 4);

-- 超级管理员权限
INSERT INTO sys_role_menu (role_id, menu_id)
SELECT 1, id FROM sys_menu;

-- 默认字典类型
INSERT INTO sys_dict_type (dict_name, dict_type, sort) VALUES
('用户性别', 'user_gender', 1),
('菜单类型', 'menu_type', 2),
('数据权限', 'data_scope', 3),
('业务类型', 'business_type', 4),
('操作类别', 'operator_type', 5),
('系统状态', 'sys_status', 6),
('是否默认', 'is_default', 7),
('是否', 'yes_no', 8);

-- 默认字典数据
INSERT INTO sys_dict_data (dict_label, dict_value, dict_type, dict_sort, is_default) VALUES
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
INSERT INTO sys_params (param_name, param_key, param_value, is_system, sort) VALUES
('主框架页-默认主题样式', 'sys.index.skinName', 'skin-blue', '1', 1),
('用户管理-账号初始密码', 'sys.user.initPassword', '123456', '1', 2),
('主框架页-侧边栏主题', 'sys.index.sideTheme', 'theme-dark', '1', 3),
('账号自助-验证码开关', 'sys.account.captchaEnabled', 'true', '1', 4),
('账号自助-是否开启用户注册', 'sys.account.registerUser', 'false', '1', 5);

-- =================================================================
-- 脚本执行完成
-- =================================================================

SELECT 'PostgreSQL数据库脚本执行完成！' AS message;
SELECT '默认管理员账号：admin / admin123' AS admin_info;