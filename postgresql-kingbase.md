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