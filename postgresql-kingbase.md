# 1. sql语句

```sql
# 添加外键
ALTER TABLE "public"."sp_ut_data_tbl"
ADD CONSTRAINT fk_sp_in_complete_data_id
FOREIGN KEY (sp_in_complete_data_id)
REFERENCES sp_in_complete_data(id)
ON DELETE RESTRICT ON UPDATE CASCADE; 

# 添加主键
ALTER TABLE "public"."sp_ut_data_tbl"
ADD PRIMARY KEY (id);

# 移除外键
ALTER TABLE "public"."sp_ut_data_tbl" DROP CONSTRAINT ufps_primary_sp_ut_data_tbl;

```



| 语句                                                | 描述                                                         | 例子 |
| --------------------------------------------------- | ------------------------------------------------------------ | ---- |
| where assessment_date::date = '2024-05-20'          | 类似MySQL的 DATE_FORMAT(assessment_date,'%Y-%m-%d') = '2024-05-20' |      |
| SELECT * FROM pg_extension;                         | 查询已安装的插件                                             |      |
| select version();                                   | 查询数据库版本                                               |      |
| ALTER TABLE [当前表名] RENAME TO [新表名];          | 改表名                                                       |      |
| TO_CHAR(CURRENT_TIMESTAMP, 'YYYY-MM-DD HH24:MI:SS') | tochar 函数                                                  |      |
|                                                     |                                                              |      |
|                                                     |                                                              |      |
|                                                     |                                                              |      |
|                                                     |                                                              |      |
|                                                     |                                                              |      |
|                                                     |                                                              |      |
|                                                     |                                                              |      |
|                                                     |                                                              |      |


```sql
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public'  -- 这里假设表在 public 模式下，你可以根据实际情况修改
AND table_name LIKE 'defect_%';  -- 查询 数据库下所有表
```



```sql
SHOW server_version;   -- 查看数据库版本（可能包含 Oracle 兼容信息） 
SELECT * FROM user_tables;      -- Oracle 兼容模式下，Kingbase 可能会创建一些与 Oracle 类似的系统表或视图
SELECT name, setting FROM pg_settings 
WHERE name LIKE '%compatible_mode%';  -- 在 Kingbase 中，可以查询系统表或动态视图来检查数据库的兼容模式配置
```





## 1. 外键约束

```sql
 CONSTRAINT fk_detail_assessment_to_history
        FOREIGN KEY (history_assessment_sp_int_inspect_id)
        REFERENCES history_assessment_sp_int_inspect(id)
        ON DELETE RESTRICT ON UPDATE CASCADE
        
在这个语句中，CONSTRAINT fk_detail_assessment_to_history定义了一个外键约束，其中：

fk_detail_assessment_to_history是这个外键约束的名称，可以根据需要自定义。
FOREIGN KEY (history_assessment_sp_int_inspect_id)指定了哪些字段构成外键。
REFERENCES history_assessment_sp_int_inspect(id)指明了这个外键引用的父表及其列。
ON DELETE RESTRICT意味着当父表中的记录被删除时，如果子表中有相关记录，将阻止父表记录的删除操作，以防止违反外键约束。
ON UPDATE CASCADE则表示如果父表中被引用的记录的id发生更新，子表中对应的history_assessment_sp_int_inspect_id也会自动更新为新的值，保持数据的一致性。
请根据实际情况调整ON DELETE和ON UPDATE的动作策略，以符合您的业务逻辑和数据完整性要求。
```





# 2. 连接数



```sql
-- 查询版本
SELECT VERSION ;

-- 查看所有连接
select * -- datname,pid,application_name,state 
from pg_stat_activity;

-- kill 空闲进程
select 'select pg_terminate_backend('||pid||');' as terminate_script
      ,datname,pid,application_name,state,client_addr,query
from pg_stat_activity
where state = 'idle'
and usename = 'tzq'
order by client_addr;

-- 查询可用连接
select max_conn-now_conn as resi_conn from (select setting::int8 as max_conn,(select count(*) from pg_stat_activity) as now_conn from pg_settings where name = 'max_connections') t;

-- 查询最大连接数
show max_connections;

-- 查询配置
select sourcefile,name,setting,applied from sys_file_settings;
```



```shell
# 重启
sudo systemctl restart kingbase
```





# 3. domain, date, timestamp

在 PostgreSQL 中，`domain` 和 `date` 是两种不同的类型概念。它们在使用和定义上有显著的区别：

### `date` 类型

- **用途**: 存储日期值（年、月、日）。
- **内置类型**: `date` 是 PostgreSQL 内置的数据类型。
- **存储格式**: 存储为一个固定的四字节整数，表示从公元2000年1月1日起的天数。
- **操作和函数**: 支持丰富的日期操作和函数，如加减天数、日期比较、提取年份、月份等。

#### 示例

```
sql
复制代码
CREATE TABLE events (
    event_id SERIAL PRIMARY KEY,
    event_date DATE NOT NULL
);

INSERT INTO events (event_date) VALUES ('2024-07-17');

SELECT * FROM events WHERE event_date = '2024-07-17';
```

### `domain` 类型

- **用途**: 创建自定义数据类型，通常基于已有的基础数据类型，且可以附加约束条件。
- **自定义类型**: `domain` 不是一个新的基础数据类型，而是对现有类型的封装，添加了额外的约束。
- **约束**: 可以为 `domain` 添加检查约束（CHECK constraints），用来限制数据的合法性。
- **灵活性**: 通过使用 `domain`，可以重用相同的约束逻辑，确保数据一致性和约束的集中管理。

#### 示例

创建一个基于 `date` 类型的 `domain`，要求日期必须是2020年之后的日期。

```
sql
复制代码
CREATE DOMAIN future_date AS DATE
    CHECK (VALUE > '2020-01-01');

CREATE TABLE future_events (
    event_id SERIAL PRIMARY KEY,
    event_date future_date NOT NULL
);

-- 以下插入操作将会成功
INSERT INTO future_events (event_date) VALUES ('2024-07-17');

-- 以下插入操作将会失败，因为日期不满足 domain 的约束条件
INSERT INTO future_events (event_date) VALUES ('2019-12-31');
```

### 主要区别

1. **基本类型 vs. 自定义类型**:
   - `date` 是一个基本的内置数据类型，用于存储日期。
   - `domain` 是一种自定义类型，可以基于 `date` 或其他类型，并附加额外的约束。
2. **使用场景**:
   - `date` 类型用于存储和操作日期值。
   - `domain` 类型用于增强数据完整性，提供一致的约束逻辑。
3. **定义和约束**:
   - `date` 类型没有自定义的约束。
   - `domain` 类型可以添加自定义的检查约束，使其更加灵活和安全。

通过结合使用 `date` 和 `domain`，你可以既享受 PostgreSQL 提供的日期操作的便利性，又能确保数据的一致性和完整性。



在 PostgreSQL 中，`date`、`domain` 和 `timestamp` 是三种不同的数据类型或概念。它们在用途、定义和功能上有显著的区别。

### `date` 类型

**用途**: 存储日期值（年、月、日）。

**内置类型**: `date` 是 PostgreSQL 内置的数据类型。

**存储格式**: 存储为一个固定的四字节整数，表示从公元2000年1月1日起的天数。

**操作和函数**: 支持丰富的日期操作和函数，如加减天数、日期比较、提取年份、月份等。

**示例**:

```
sql
复制代码
CREATE TABLE events (
    event_id SERIAL PRIMARY KEY,
    event_date DATE NOT NULL
);

INSERT INTO events (event_date) VALUES ('2024-07-17');

SELECT * FROM events WHERE event_date = '2024-07-17';
```

### `domain` 类型

**用途**: 创建自定义数据类型，通常基于已有的基础数据类型，且可以附加约束条件。

**自定义类型**: `domain` 不是一个新的基础数据类型，而是对现有类型的封装，添加了额外的约束。

**约束**: 可以为 `domain` 添加检查约束（CHECK constraints），用来限制数据的合法性。

**灵活性**: 通过使用 `domain`，可以重用相同的约束逻辑，确保数据一致性和约束的集中管理。

**示例**: 创建一个基于 `date` 类型的 `domain`，要求日期必须是2020年之后的日期。

```
sql
复制代码
CREATE DOMAIN future_date AS DATE
    CHECK (VALUE > '2020-01-01');

CREATE TABLE future_events (
    event_id SERIAL PRIMARY KEY,
    event_date future_date NOT NULL
);

-- 以下插入操作将会成功
INSERT INTO future_events (event_date) VALUES ('2024-07-17');

-- 以下插入操作将会失败，因为日期不满足 domain 的约束条件
INSERT INTO future_events (event_date) VALUES ('2019-12-31');
```

### `timestamp` 类型

**用途**: 存储日期和时间，包括年、月、日、时、分、秒。

**内置类型**: `timestamp` 是 PostgreSQL 内置的数据类型。

**存储格式**: 存储为一个固定的八字节整数，表示从公元2000年1月1日午夜（UTC）以来的微秒数。

**操作和函数**: 支持丰富的日期和时间操作和函数，如加减时间、时间比较、提取年份、月份、小时、分钟等。

**类型变种**:

- `timestamp without time zone`：不带时区的时间戳。
- `timestamp with time zone`：带时区的时间戳（即 `timestamptz`）。

**示例**:

```
sql
复制代码
CREATE TABLE log_entries (
    log_id SERIAL PRIMARY KEY,
    log_timestamp TIMESTAMP NOT NULL
);

INSERT INTO log_entries (log_timestamp) VALUES ('2024-07-17 15:30:00');

SELECT * FROM log_entries WHERE log_timestamp = '2024-07-17 15:30:00';
```

### 主要区别

1. **数据内容**:
   - `date` 类型仅存储日期（年、月、日）。
   - `timestamp` 类型存储日期和时间（年、月、日、时、分、秒），可选带时区信息。
   - `domain` 不是一种数据类型，而是对现有数据类型的扩展，可以附加约束条件。
2. **时间精度**:
   - `date` 类型没有时间部分，仅精确到天。
   - `timestamp` 类型精确到秒或更高，可以存储时间的具体时刻。
3. **约束和自定义**:
   - `date` 和 `timestamp` 是基础数据类型，用于存储特定格式的数据。
   - `domain` 是自定义类型，用于在基础数据类型上附加约束条件，实现数据一致性和完整性。
4. **使用场景**:
   - 使用 `date` 类型时，仅关心日期，不关心具体时间。
   - 使用 `timestamp` 类型时，需要记录具体的时间点。
   - 使用 `domain` 类型时，希望在基础数据类型上增加特定约束，确保数据的合法性。

通过理解这些区别，可以更好地选择和使用 PostgreSQL 提供的不同类型，满足特定的数据存储和操作需求。





# 4. kingbase

重启kingbase

```
/apps/Kingbase/Server/bin$ ./sys_ctl -D /apps/Kingbase/data/ restart
```





# 5. pg_catalog

pg_catalog 是 PostgreSQL 数据库系统中的一个特殊模式（schema），它包含了所有系统目录表和一些核心函数。这些目录表存储了数据库元数据，如表定义、索引、视图、用户权限等信息。pg_catalog 是 PostgreSQL 内置的一部分，对所有数据库用户可见，但通常不建议对其进行直接修改，因为这可能会导致数据库不稳定或损坏。

以下是一些常见的 pg_catalog 表和函数：

常见的 pg_catalog 表
pg_class:
存储了所有的表、索引、视图和其他关系对象的信息。
包括 relname（关系名称）、relkind（关系类型，如表、索引、视图等）、relowner（所有者ID）等字段。
pg_namespace:
存储了所有模式的信息。
包括 nspname（模式名称）、nspowner（所有者ID）等字段。
pg_attribute:
存储了所有表和索引的列信息。
包括 attname（列名）、atttypid（列的数据类型ID）、attnum（列的位置编号）等字段。
pg_type:
存储了所有数据类型的信息。
包括 typname（数据类型名称）、typcategory（数据类型类别）等字段。
pg_index:
存储了所有索引的信息。
包括 indexrelid（索引关系ID）、indrelid（表关系ID）、indkey（索引列的数组）等字段。
pg_constraint:
存储了所有约束的信息。
包括 conname（约束名称）、contype（约束类型，如主键、外键等）、conrelid（表关系ID）等字段。
常见的 pg_catalog 函数
pg_get_viewdef(viewname text):
返回指定视图的定义。
pg_get_indexdef(indexrelid oid, column int, pretty bool):
返回指定索引的定义。
pg_total_relation_size(relation regclass):
返回指定表的总大小，包括表本身、索引和Toast表。
pg_table_size(relation regclass):
返回指定表的大小，不包括索引和Toast表。
pg_indexes_size(relation regclass):
返回指定表的所有索引的总大小。
pg_stat_get_tuples_inserted(tableoid oid):
返回指定表自上次统计以来插入的元组数。
使用示例
以下是一些使用 pg_catalog 表和函数的示例：

```Sql
-- 查询所有表的信息
SELECT * FROM pg_catalog.pg_class WHERE relkind = 'r';

-- 查询所有模式的信息
SELECT * FROM pg_catalog.pg_namespace;

-- 查询特定表的列信息
SELECT * FROM pg_catalog.pg_attribute WHERE attrelid = 'public.my_table'::regclass;

-- 获取视图的定义
SELECT pg_catalog.pg_get_viewdef('public.my_view');

-- 获取表的总大小
SELECT pg_catalog.pg_total_relation_size('public.my_table');
通过这些表和函数，您可以获取和操作数据库的元数据，进行各种管理和诊断任务
```



# 6.  COLLATE "pg_catalog"."default"  排序规则

创建数据库
首先，我们创建一个数据库，并设置默认的排序规则为 en_US.UTF8：

Sql
深色版本
CREATE DATABASE mydb WITH ENCODING 'UTF8' LC_COLLATE 'en_US.UTF8' LC_CTYPE 'en_US.UTF8';
创建表
接下来，我们创建两个表，一个使用默认排序规则，另一个使用 de_DE.UTF8 排序规则：

Sql
深色版本
-- 使用默认排序规则
CREATE TABLE example_default (
    id SERIAL PRIMARY KEY,
    name TEXT COLLATE "pg_catalog"."default"
);

-- 使用特定的 de_DE.UTF8 排序规则
CREATE TABLE example_de (
    id SERIAL PRIMARY KEY,
    name TEXT COLLATE "de_DE.UTF8"
);
插入数据
我们在两个表中插入相同的数据：

Sql
深色版本
INSERT INTO example_default (name) VALUES ('apple'), ('Apple'), ('äpple'), ('apple');
INSERT INTO example_de (name) VALUES ('apple'), ('Apple'), ('äpple'), ('apple');
查询结果
使用 en_US.UTF8 排序规则
Sql
深色版本
SELECT name FROM example_default ORDER BY name;
输出可能是：

深色版本
Apple
apple
apple
äpple
解释：

Apple 在 apple 之前，因为大写字母在小写字母之前。
äpple 在最后，因为 ä 在 a 之后。
使用 de_DE.UTF8 排序规则
Sql
深色版本
SELECT name FROM example_de ORDER BY name;
输出可能是：

深色版本
Apple
apple
apple
äpple
解释：

Apple 在 apple 之前，因为大写字母在小写字母之前。
äpple 在 apple 之后，因为在德语中，ä 通常被视为 ae，所以 äpple 会被排序为 aepple，即在 apple 之后。
更明显的例子
为了更清楚地展示德语排序规则的特殊性，我们可以插入更多的数据：

Sql
深色版本
INSERT INTO example_default (name) VALUES ('aepple'), ('oepple'), ('oepple');
INSERT INTO example_de (name) VALUES ('aepple'), ('oepple'), ('oepple');
使用 en_US.UTF8 排序规则
Sql
深色版本
SELECT name FROM example_default ORDER BY name;
输出可能是：

深色版本
Apple
apple
apple
aepple
oepple
oepple
äpple
解释：

aepple 在 oepple 和 oepple 之前，因为 a 在 o 之前。
äpple 在最后，因为 ä 在 a 之后。
使用 de_DE.UTF8 排序规则
Sql
深色版本
SELECT name FROM example_de ORDER BY name;
输出可能是：

深色版本
Apple
apple
apple
äpple
aepple
oepple
oepple
解释：

äpple 被视为 aepple，所以在 aepple 之前。
aepple 在 oepple 之前，因为 a 在 o 之前。
oepple 在 oepple 之前，因为 e 在 i 之前。
总结
pg_catalog.default：使用数据库的默认排序规则，确保所有列在默认情况下使用相同的排序规则，减少配置复杂性。
特定的排序规则：根据具体需求选择适合的排序规则，提供更高的灵活性和定制化。
通过这些具体的例子，可以看到 en_US.UTF8 和 de_DE.UTF8 在字符比较和排序上的不同行为。希望这些示例能更好地帮助你理解两者的区别



# 7. 删外键



```sql
SELECT concat('ALTER TABLE ', conrelid::regclass, ' DROP CONSTRAINT ', conname, ';') AS drop_statement  
FROM pg_constraint  
JOIN pg_attribute AS a ON conrelid = a.attrelid AND a.attnum = ANY(conkey)  
JOIN pg_attribute AS af ON confrelid = af.attrelid AND af.attnum = ANY(confkey)  
WHERE connamespace = (SELECT oid FROM pg_namespace WHERE nspname = 'public')  
  AND contype = 'f';  -- 确保只选择外键约束
```



```sql
ALTER TABLE sp_ii_as_dt DROP CONSTRAINT ufps_sp_ii_as_dt_sp_ii_os_opera_cs_rsk_anl_dt_id;
ALTER TABLE sp_ii_bea_end DROP CONSTRAINT ufps_sp_ii_bea_end_sp_ii_pqdt_id;
ALTER TABLE sp_ii_bea_start DROP CONSTRAINT ufps_sp_ii_bea_start_sp_ii_pqdt_id;
ALTER TABLE sp_ii_cm DROP CONSTRAINT ufps_sp_ii_cm_sp_ii_jo_id;
ALTER TABLE sp_ii_co DROP CONSTRAINT ufps_sp_ii_co_sp_ii_jo_id;
ALTER TABLE sp_ii_cons_tasks_dt DROP CONSTRAINT ufps_sp_ii_cons_tasks_dt_sp_ii_jo_id;
ALTER TABLE sp_ii_contra_sign_s_proa_dt DROP CONSTRAINT ufps_sp_ii_contra_sign_s_proa_dt_sp_ii_jo_id;
ALTER TABLE sp_ii_de_equ_par_dt DROP CONSTRAINT fkey_public_sp_ii_de_equ_par_dt_fkey_1;
ALTER TABLE sp_ii_dr_dt DROP CONSTRAINT ufps_sp_ii_dr_dt_sp_ii_jo_id;
ALTER TABLE sp_ii_equ_ei_dt DROP CONSTRAINT ufps_sp_ii_equ_ei_dt_sp_ii_jo_id;
ALTER TABLE sp_ii_equ_ws DROP CONSTRAINT ufps_sp_ii_equ_ws_sp_oi_dt_id;
ALTER TABLE sp_ii_lm_equ_par_dt DROP CONSTRAINT fkey_public_sp_ii_lm_equ_par_dt_fkey_1;
ALTER TABLE sp_ii_mat_prepare_conf_dt DROP CONSTRAINT ufps_sp_ii_mat_prepare_conf_dt_sp_ii_jo_id;
ALTER TABLE sp_ii_op DROP CONSTRAINT ufps_sp_ii_op_sp_ii_jo_id;
ALTER TABLE sp_ii_op_dt DROP CONSTRAINT fkey_public_sp_ii_op_dt_fkey_2;
ALTER TABLE sp_ii_op_equ_dt DROP CONSTRAINT ufps_sp_ii_op_equ_dt_sp_ii_op_dt_id;
ALTER TABLE sp_ii_opera_psl_hc_dt DROP CONSTRAINT ufps_sp_ii_opera_psl_hc_dt_sp_ii_jo_id;
ALTER TABLE sp_ii_os_opera_cs_rsk_anl_dt DROP CONSTRAINT ufps_sp_ii_os_opera_cs_rsk_anl_dt_sp_ii_jo_id;
ALTER TABLE sp_ii_pj_manage_rd_dt DROP CONSTRAINT ufps_sp_ii_pj_manage_rd_dt_sp_ii_jo_id;
ALTER TABLE sp_ii_po_cn_dt DROP CONSTRAINT ufps_sp_ii_po_cn_dt_sp_ii_jo_id;
ALTER TABLE sp_ii_po_cpa_dt DROP CONSTRAINT ufps_sp_ii_po_cpa_dt_sp_ii_jo_id;
ALTER TABLE sp_ii_po_psl_rr_dt DROP CONSTRAINT ufps_sp_ii_po_psl_rr_dt_sp_ii_jo_id;
ALTER TABLE sp_ii_pqdt DROP CONSTRAINT ufps_sp_ii_pqdt_sp_ii_jo_id;
ALTER TABLE sp_ii_pqrd_dt DROP CONSTRAINT ufps_sp_ii_pqrd_dt_sp_ii_pqdt_id;
ALTER TABLE sp_ii_tbrh_dt DROP CONSTRAINT ufps_sp_ii_tbrh_dt_sp_ii_pqdt_id;
ALTER TABLE sp_ii_us_equ_par_dt DROP CONSTRAINT fkey_public_sp_ii_us_equ_par_dt_fkey_1;
ALTER TABLE sp_pig_data_tbl DROP CONSTRAINT ufps_sp_pig_data_tbl_sp_oi_dt_id;
ALTER TABLE sp_rpt DROP CONSTRAINT ufps_sp_rpt_sp_ii_jo_id;
ALTER TABLE history_assessment_sp_int_inspect_dt DROP CONSTRAINT fk_code_history_ilia_id;
ALTER TABLE sp_ii_ut_data_tbl DROP CONSTRAINT fk_sp_in_complete_data_id;
ALTER TABLE sp_ii_et_data_tbl DROP CONSTRAINT fk_sp_in_complete_data_id;
ALTER TABLE detail_assessment_b31g DROP CONSTRAINT fk_history_assessment_sp_int_inspect_dt_id;
ALTER TABLE detail_assessment_dnvb DROP CONSTRAINT fk_history_assessment_sp_int_inspect_dt_id;
ALTER TABLE detail_assessment_dnva DROP CONSTRAINT fk_history_assessment_sp_int_inspect_dt_id;
ALTER TABLE history_assessment_sp_int_inspect_dt DROP CONSTRAINT fk_sp_oi_dt_id;
ALTER TABLE history_assessment_sp_icda DROP CONSTRAINT fk_sp_oi_dt_id;
ALTER TABLE sp_ic_dg_med_ic_asmt_op_dt DROP CONSTRAINT fk_history_assessment_sp_icda_id;
ALTER TABLE sp_ic_dg_med_ic_asmt_op_dt DROP CONSTRAINT fk_material_type_id;
ALTER TABLE sp_ic_dg_med_ic_asmt_op_dt DROP CONSTRAINT fk_code_history_nace_0110_id;
ALTER TABLE sp_ic_dg_med_ic_asmt_op_dt DROP CONSTRAINT fk_code_history_b31g_id;
ALTER TABLE sp_op_cond_dt DROP CONSTRAINT fk_sp_oi_dt_id;
ALTER TABLE sp_nat_gas_comp_full_dt DROP CONSTRAINT fk_sp_oi_dt_id;
ALTER TABLE sp_water_cond_comp_full_dt DROP CONSTRAINT fk_sp_oi_dt_id;
ALTER TABLE detail_assessment_dg_icda DROP CONSTRAINT fk_sp_ic_dg_med_ic_asmt_op_dt_id;
ALTER TABLE sp_op_cond_dt_copy1 DROP CONSTRAINT sp_op_cond_dt_copy1_sp_oi_dt_id_fkey;
```





# 8. 数据类型



|                             |                                                              |      |
| --------------------------- | ------------------------------------------------------------ | ---- |
| int8                        | bigint , 范围从 -9223372036854775808 到 9223372036854775807。 |      |
| int4, int                   | 存储有符号整数，范围从 -2,147,483,648 到 2,147,483,647。     |      |
| int2                        | smallint , 范围从 -32,768 到 32,767                          |      |
| serial                      | 自动生成整数值，用于主键的自增字段。实际上是 `integer` 类型的别名，并使用序列来自动生成唯一值 |      |
| bigserial                   | 类似于 `serial`，但用于生成更大的整数值，对应 `bigint` 类型。 |      |
| numeric (或 decimal)        | 精确数值类型，可以存储任意大小的数值，适合需要高精度计算的场景（如货币等）。 |      |
| real (`float4`)             | 单精度浮点数，存储 4 字节的浮动小数点值                      |      |
| double precision (`float8`) | 双精度浮点数，存储 8 字节的浮动小数点值                      |      |
| char(n)                     | 固定长度的字符类型，`n` 表示字符的长度。如果存储的数据少于 `n`，则会填充空格 |      |
| varchar(n)                  | 可变长度的字符类型，`n` 表示最大长度。通常用于存储短文本     |      |
| text                        | 可变长度的文本类型，没有最大长度限制，适合存储长文本数据     |      |
| date                        | 存储日期，格式为 `YYYY-MM-DD`                                |      |
| time                        | 存储时间，格式为 `HH:MI:SS`                                  |      |
| timestamp                   | 存储日期和时间，格式为 `YYYY-MM-DD HH:MI:SS`。还有一个带时区的变种 `timestamp with time zone`。 |      |
| interval                    | 用于表示时间间隔，表示两个日期/时间之间的差值                |      |
| boolean                     | 存储布尔值，取值为 `TRUE`、`FALSE` 或 `NULL`                 |      |
| bytea                       | 存储二进制数据，如图像、文件等                               |      |
| cidr                        | 用于存储 IPv4 或 IPv6 地址及其网络掩码                       |      |
| inet                        | 存储 IPv4 或 IPv6 地址，不包括网络掩码                       |      |
| macaddr                     | 存储 MAC 地址                                                |      |
| json                        | 用于存储 JSON 格式的数据                                     |      |
| jsonb                       | 类似于 `json` 类型，但存储格式更高效，并且支持索引、查询优化等 |      |
| int4range                   | 存储整数的范围                                               |      |
| numrange                    | 存储数字的范围                                               |      |
| tsrange                     | 存储时间戳的范围                                             |      |
|                             |                                                              |      |
|                             |                                                              |      |
|                             |                                                              |      |
|                             |                                                              |      |





# 9. 批量修改列数据类型

```sql

SELECT COLUMN_NAME,
	table_name,
	column_name,
	DATA_TYPE,
	CONCAT( 'ALTER TABLE ', table_name, ' alter ', COLUMN_NAME,
	 ' type timestamp(0);' ) 
FROM
	information_schema.COLUMNS 
WHERE
	table_schema = 'pias' 
	and table_name like '%defect_%'
	AND data_type = 'timestamp without time zone' 
	AND datetime_precision = 6 ;
	
SELECT * from  information_schema.COLUMNS 
WHERE
	table_schema = 'pias' ;
	
```



chatgpt 推荐使用这个, 但我没验证过,

```sql
DO $$ 
DECLARE 
    r RECORD;
BEGIN
    FOR r IN 
        SELECT table_name, column_name
        FROM information_schema.columns
        WHERE table_schema = 'pias'
          AND table_name LIKE 'defect_%'
          AND data_type = 'timestamp without time zone'
          AND datetime_precision = 6
    LOOP
        EXECUTE format(
            'ALTER TABLE %I.%I ALTER COLUMN %I TYPE timestamp(0);',
            'pias',
            r.table_name,
            r.column_name
        );
    END LOOP;
END $$;

```



代码块 **(DO $$ ... $$)** 不是一个函数，而是 **PostgreSQL 的匿名代码块（PL/pgSQL 代码块）**。

### **什么是 DO $ 代码块？**

`DO $$` 是 PostgreSQL 中执行 **PL/pgSQL 代码** 的一种方式，适用于 **一次性执行的批处理任务**，比如：

- 遍历数据库表
- 动态执行 SQL 语句
- 进行条件判断

它本质上相当于一个 **匿名存储过程**，但不会存储在数据库中。

在 **PostgreSQL** 中，`DO $$` 代码块 **是匿名的 PL/pgSQL 代码块**，它在运行时 **直接执行**，不需要像存储过程一样 `CALL`。



## 1. 批量删除

```sql
DO $$ 
DECLARE 
    r RECORD;
BEGIN
    FOR r IN 
        SELECT table_name 
        FROM information_schema.tables 
        WHERE table_schema = 'public' 
          AND table_name LIKE 'old_data_%'
    LOOP
        EXECUTE format('DROP TABLE %I.%I CASCADE;', 'public', r.table_name);
    END LOOP;
END $$;

```



## 2.  批量加注释

```sql

SELECT COLUMN_NAME,
	table_name,
	column_name,
	DATA_TYPE,
	CONCAT( 'comment on column ', table_name, '.', COLUMN_NAME,
	 ' is',  ' \'分段历史表ID\' ;') 
FROM
	information_schema.COLUMNS 
WHERE
	table_schema = 'guandaogongsi' 

		and table_name like '%pia_'
	and column_name = 'table_name'
	
;
```



## 3. 批量修改列的值

```sql

SELECT 
    C.TABLE_NAME,
    C.COLUMN_NAME,
    C.DATA_TYPE,
    CONCAT(
        'UPDATE guandaogongsi.', 
        C.TABLE_NAME, 
        ' SET ', 
        C.COLUMN_NAME, 
        ' = ''96D92361ED5F42449F4E1DA205BCB03D'', ',
        'update_time = CURRENT_TIMESTAMP ',
        'WHERE ',
        C.COLUMN_NAME,
        ' = ''df84d6b356474d9ab08b8b50b415c5d9'';'
    ) AS UPDATE_SQL
FROM 
    information_schema.COLUMNS C
WHERE 
    C.TABLE_SCHEMA = 'guandaogongsi'
    AND C.TABLE_NAME LIKE '%pia_%'
    AND C.COLUMN_NAME = 'sp_oi_dt_id';
```







# 10. 函数



| 函数名            | 说明     | 例子                                                         |
| ----------------- | -------- | ------------------------------------------------------------ |
| date()            | 日期函数 | SELECT * FROM DEFECT_corrosion_assessment_history WHERE DEL_FLAG = 0 AND date(assessment_date) = '2025-03-05' |
| CURRENT_TIMESTAMP |          |                                                              |
|                   |          |                                                              |
|                   |          |                                                              |
|                   |          |                                                              |
|                   |          |                                                              |
|                   |          |                                                              |
|                   |          |                                                              |
|                   |          |                                                              |
|                   |          |                                                              |
|                   |          |                                                              |
|                   |          |                                                              |
|                   |          |                                                              |
|                   |          |                                                              |
|                   |          |                                                              |
|                   |          |                                                              |
|                   |          |                                                              |
|                   |          |                                                              |
|                   |          |                                                              |
|                   |          |                                                              |
|                   |          |                                                              |
|                   |          |                                                              |
|                   |          |                                                              |





# 11. 问题 bug 等

## 1. 问题1 磁盘空间不足

```
Cause: com.kingbase8.util.KSQLException: ERROR: could not create temporary file "base/syssql_tmp/syssql_tmp18055.0": No space left on device
; uncategorized SQLException; SQL state [XX000]; error code [0]; ERROR: could not create temporary file "base/syssql_tmp/syssql_tmp18055.0": No space left on device
```



该错误主要由以下原因导致：

1. ‌**磁盘空间不足**‌
   错误信息明确提示`No space left on device`，表明数据库所在磁盘分区已满，无法创建临时文件。KingbaseES在执行复杂查询、排序等操作时会生成临时文件，若存储空间不足将直接导致操作失败‌36。
2. ‌**临时目录权限问题**‌
   若临时文件目录`base/syssql_tmp`的权限设置不当（如所属用户或组权限不足），即使空间充足，数据库也无法正常写入文件。需检查目录权限是否允许数据库进程读写‌38。
3. ‌**Inode耗尽**‌
   在Linux系统中，若磁盘分区的Inode数量耗尽（即使剩余存储空间充足），也会导致无法创建新文件。可通过`df -i`命令检查Inode使用情况‌36。

‌**排查步骤建议**‌：

- 使用`df -h`检查磁盘空间使用率，清理大文件或日志释放空间。
- 通过`ls -ld base/syssql_tmp`验证临时目录权限及所属用户。
- 执行`df -i`确认Inode是否耗尽，必要时删除冗余小文件。
- 调整数据库配置，指定更大容量的临时表空间路径（若存在多磁盘分区





# 12. 查询 guandaogongsi 模式下 所有表 没有注释的字段

```sql
SELECT 
    n.nspname AS schema_name,
    c.relname AS table_name,
    a.attname AS column_name
FROM 
    pg_namespace n
JOIN 
    pg_class c ON n.oid = c.relnamespace
JOIN 
    pg_attribute a ON c.oid = a.attrelid
LEFT JOIN 
    pg_description d ON a.attrelid = d.objoid AND a.attnum = d.objsubid
WHERE 
    n.nspname = 'guandaogongsi'
    AND c.relkind = 'r'  -- 只考虑普通表
    AND a.attnum > 0     -- 排除系统列
    AND a.attisdropped = false  -- 排除已删除的列
    AND d.objoid IS NULL;  -- 只选择没有注释的字段
```

### 代码解释：

1. **pg_namespace**：该系统视图存储了数据库中的所有模式信息。
2. **pg_class**：存储了数据库中的所有表、索引、序列等对象信息。
3. **pg_attribute**：存储了表的所有字段信息。
4. **pg_description**：存储了数据库对象的注释信息。

通过连接这些系统视图，并使用`LEFT JOIN`来确保即使字段没有注释也会被包含在结果中。最后，使用`WHERE`子句筛选出`guandaogongsi`模式下的普通表，排除系统列和已删除的列，并只选择没有注释的字段。

你可以将上述 SQL 语句在 Kingbase8 的客户端工具（如`ksql`）中执行，即可得到所需的结果。



# 13. 分页语句

```sql
            SELECT * FROM (
                SELECT t.*, ROWNUM AS rn FROM (
                    SELECT * FROM sp_ii_mfl_data_tbl
                    WHERE del_flag = 0
                    AND sp_in_complete_data_id = #{spInCompleteDataId}
                    AND create_time IS NOT NULL
                    AND kp_value IS NOT NULL
                    ORDER BY create_time DESC
                ) t
                WHERE ROWNUM <= #{page} * #{pageSize}
            )
            WHERE rn > (#{page} - 1) * #{pageSize};
```



在 v8R3 及以上版本可使用

```sql
SELECT *
FROM sp_ii_mfl_data_tbl
WHERE del_flag = 0
AND sp_in_complete_data_id = #{spInCompleteDataId}
AND create_time IS NOT NULL
AND kp_value IS NOT NULL
ORDER BY create_time DESC
OFFSET (#{page}-1)*#{pageSize} ROWS
FETCH NEXT #{pageSize} ROWS ONLY;
```



# 14. 怎么确定 是 oracle 风格的

## 1. 验证oracle 语法兼容性

```sql

-- Oracle 风格的日期格式化
SELECT TO_CHAR(SYSDATE, 'YYYY-MM-DD') FROM DUAL;

-- Oracle 风格的递归查询
WITH RECURSIVE t(n) AS (
  SELECT 1
  UNION ALL
  SELECT n+1 FROM t WHERE n < 10
)
SELECT * FROM t;
```

## 2. 检查系统表结构

```sql
SELECT * FROM user_tables;  -- Oracle 风格的系统视图
```



## 3. 查看会话参数

```sql
SHOW sql_compatibility;  -- 显示 SQL 兼容模式
SHOW server_version;     -- 查看数据库版本（可能包含 Oracle 兼容信息）
```



## 4. 查询系统表(推荐)

```sql
SELECT name, setting 
FROM pg_settings 
WHERE name LIKE '%database_mode%';
```

