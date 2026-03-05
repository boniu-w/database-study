# 一、建表规约

1. 【强制】布尔类型字段命名与类型
    表达 “是 / 否” 的字段，使用 is_xxx 命名，数据类型优先使用 boolean（PostgreSQL 原生支持布尔类型，无需用 unsigned tinyint 模拟）。
    说明：布尔类型仅存储 true（是）、false（否），语义更清晰，避免数值类型的歧义。
    正例：逻辑删除字段 is_deleted（true 表示删除，false 表示未删除）。

2. 【强制】命名规范（表名、字段名、库名）
    必须使用小写字母或数字，禁止数字开头，禁止 “两个下划线中间仅含数字”（如 user_123_info 不允许）。
    说明：PostgreSQL 默认区分大小写（需用双引号包裹大写名称，否则自动转为小写），为统一风格，避免引号冗余，所有命名统一小写。
    正例：aliyun_admin、rdc_config、level3_name。
    反例：AliyunAdmin（需双引号）、rdcConfig（驼峰易混淆）、level_3_name（中间仅数字）。

3. 【强制】表名不使用复数名词
    说明：表名应表示实体本身（如 user、order），而非数量，对应 DO 类名也为单数，符合表达习惯。

4. 【强制】禁用保留字
    禁止使用 PostgreSQL 保留字（如 desc、range、match、delayed、user、table 等）作为库名、表名或字段名。
    参考：PostgreSQL 官方保留字列表。

5. 【强制】索引命名规范
    主键索引：默认命名为 pk_表名_字段名（PostgreSQL 主键默认创建索引，可手动指定名称）。
    唯一索引：uk_表名_字段名（多字段用下划线连接，如 uk_user_phone_email）。
    普通索引：idx_表名_字段名。
    说明：pk=primary key，uk=unique key，idx=index，统一命名便于维护。

6. 【强制】小数类型
    使用 numeric(precision, scale) 存储小数，禁止使用 float 或 double precision。
    说明：float/double 存在精度损失，numeric 为精确小数类型，适合存储金额、比例等场景。
    示例：金额字段 amount numeric(10,2)（10 位有效数字，2 位小数）。

7. 【强制】字符串类型选择
    字符串长度几乎相等时，使用 char(n)（定长字符串）。
    长度可变且不超过 10485760 字节（约 10MB）时，使用 varchar(n)（n 为最大长度）；超过则使用 text 类型（无需指定长度，自动适配）。
    说明：PostgreSQL 的 varchar 无性能劣势（与 text 存储机制一致），但 char(n) 适合固定长度场景（如手机号、身份证号），避免空间浪费。

8. 【强制】大字段处理
    若字符串长度超过 10MB，或需存储大文本、二进制数据（如文件、图片），使用 text（文本）或 bytea（二进制）类型，并建议：
    独立建表存储（如 user_avatar 表存储用户头像，通过主键与 user 表关联）。
    或使用 PostgreSQL 扩展 pg_largeobject（适合超大二进制对象）。
    说明：避免大字段与普通字段同表，以免影响查询效率（大字段会增加行存储体积，导致一页数据存储行数减少）。

9. 【强制】表必备字段
    每张表必须包含以下三个字段：
    字段名	类型	说明
    id	bigint	主键，建议使用 GENERATED AS IDENTITY。
    gmt_create	timestamp	创建时间，默认值 CURRENT_TIMESTAMP。
    gmt_modified	timestamp	更新时间，默认值 CURRENT_TIMESTAMP，且通过触发器自动更新。
    示例：

  ```sql
  CREATE TABLE user (
    id bigint GENERATED AS IDENTITY PRIMARY KEY,
    username varchar(50) NOT NULL,
    gmt_create timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    gmt_modified timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
  );
  -- 创建触发器函数，自动更新 gmt_modified
  CREATE OR REPLACE FUNCTION update_modified_column()
  RETURNS TRIGGER AS $$
  BEGIN
    NEW.gmt_modified = CURRENT_TIMESTAMP;
    RETURN NEW;
  END;
  $$ LANGUAGE plpgsql;
  -- 为表添加触发器
  CREATE TRIGGER update_user_modtime
  BEFORE UPDATE ON user
  FOR EACH ROW
  EXECUTE FUNCTION update_modified_column();
  ```

10. 【推荐】表命名规范
    表名格式：业务模块_实体名称（下划线分隔，清晰区分业务场景）。
    正例：alipay_task（支付宝任务表）、force_project（Force 项目表）、trade_config（交易配置表）。

11. 【推荐】库名与应用名称一致
    说明：便于部署和维护，如应用名为 user-service，库名可设为 user_service_db。

12. 【推荐】字段注释维护
    修改字段含义或状态值时，及时更新字段注释（使用 COMMENT 语句）。
    示例：ALTER TABLE user ALTER COLUMN status SET COMMENT '用户状态：0-禁用，1-正常'。

13. 【推荐】字段冗余原则
    允许适当冗余字段提升查询性能，但需保证数据一致性，冗余字段需满足：
    不频繁修改（如商品类目名称、用户昵称）。
    非超长字段（避免 varchar(1000+) 或 text 类型）。
    正例：订单表 order 冗余商品类目名称 category_name，避免关联 product_category 表查询。

14. 【推荐】分库分表阈值
    单表行数超过 1000 万行，或单表容量超过 10GB 时，建议分库分表。

15. 【参考】字符存储长度优化
    根据实际业务场景选择最小可行的字符串长度，减少存储空间和索引体积，提升检索速度。
    示例：手机号固定 11 位，用 char(11) 而非 varchar(20)；用户名最大 20 位，用 varchar(20) 而非 varchar(50)。
    二、索引规约

16. 【强制】唯一特性字段必须建唯一索引
      业务上具有唯一特性的字段（如手机号、邮箱），或多字段组合唯一（如 user_id + role_id），必须创建唯一索引。
      说明：唯一索引可避免脏数据（即使应用层有校验），且查询效率远高于普通索引。
      示例：CREATE UNIQUE INDEX uk_user_phone ON user(phone)。

17. 【强制】多表 JOIN 限制
      禁止超过 3 张表 JOIN 查询；JOIN 字段的数据类型必须完全一致（如 user.id 为 bigint，order.user_id 也必须是 bigint）。
      说明：多表 JOIN 会增加查询复杂度和执行时间，PostgreSQL 虽支持 hash join、merge join 优化，但仍需控制 JOIN 表数量。

18. 【强制】varchar 字段索引长度
      在 varchar(n) 或 text 字段上创建索引时，需指定索引长度（避免全字段索引占用过多空间），长度根据字段区分度确定。
      说明：区分度计算公式：SELECT count(DISTINCT left(字段名, 索引长度)) / count(*) AS distinct_rate FROM 表名，目标区分度≥90%。
      示例：CREATE INDEX idx_user_name ON user(left(username, 10))（用户名前 10 位区分度达 95%）。

19. 【强制】模糊查询限制
      严禁使用左模糊（LIKE '%keyword'）或全模糊（LIKE '%keyword%'）查询，此类查询无法使用索引。
      替代方案：
      前缀匹配（LIKE 'keyword%'），可使用普通索引。
      全文检索（PostgreSQL 原生支持 tsvector/tsquery，适合文本搜索场景）。
      搜索引擎（如 Elasticsearch），适合大规模全文搜索。

20. 【推荐】利用索引优化 ORDER BY
      ORDER BY 的字段应作为组合索引的最后一部分，避免出现 Sort Method: External Merge Disk（外部排序，性能差）。
      正例：查询 WHERE a=? AND b=? ORDER BY c，创建索引 idx_a_b_c（索引有序性可直接满足排序需求）。
      反例：WHERE a>10 ORDER BY b，索引 idx_a_b 无法利用有序性（范围查询后索引无序），会触发排序。

21. 【推荐】覆盖索引优化
      尽量使用覆盖索引（查询的所有字段均在索引中），避免回表查询（从索引跳回主键索引获取数据）。
      说明：覆盖索引查询的 EXPLAIN 结果中，Extra 列会显示 Index Only Scan（仅扫描索引），效率极高。
      示例：查询 SELECT id, username FROM user WHERE username LIKE 'a%'，创建索引 idx_user_name_id（包含 username 和 id），避免回表。

22. 【推荐】超大分页优化
      分页查询时，若 OFFSET 过大（如 LIMIT 100000, 20），效率极低（PostgreSQL 需扫描前 100020 行数据）。
      优化方案：
      延迟关联（先查主键，再关联数据）：
      sql
      SELECT a.* 
      FROM user a
      JOIN (SELECT id FROM user WHERE status=1 LIMIT 20 OFFSET 100000) b 
      ON a.id = b.id;
      主键过滤（适合连续分页）：
      sql
      SELECT * FROM user WHERE id > 100000 AND status=1 LIMIT 20;

23. 【推荐】SQL 性能目标
      查询的 EXPLAIN 结果中，type 字段优先级：const > eq_ref > ref > range > index > seq_scan（全表扫描）。
      目标：至少达到 range 级别，优先 ref 级别，核心查询争取 const/eq_ref。
      说明：
      const：单表中仅 1 行匹配（主键 / 唯一索引等值查询）。
      eq_ref：多表 JOIN 时，被 JOIN 表的每行仅匹配 1 行（如主键 JOIN）。
      ref：普通索引等值查询（匹配多行）。
      range：索引范围查询（如 >、<、BETWEEN）。

24. 【推荐】组合索引字段顺序
      组合索引的字段顺序遵循 “高频过滤在前、区分度高在前、等值查询在前” 原则。
      正例：
      查询 WHERE status=1 AND username LIKE 'a%'，索引 idx_status_username（status 是等值查询，高频过滤）。
      查询 WHERE a=? AND b>10，索引 idx_a_b（a 是等值查询，在前）。

25. 【推荐】避免隐式类型转换
    确保查询条件中字段类型与传入参数类型一致，避免隐式转换导致索引失效。
    反例：user.id 是 bigint，查询 WHERE id='123'（字符串转数字，索引失效）。
    正例：WHERE id=123（类型一致）。

26. 【参考】索引创建误区
    避免 “宁滥勿缺”：过多索引会拖慢 INSERT/UPDATE/DELETE（每次写操作需维护所有索引）。
    避免 “宁缺勿滥”：必要的索引可大幅提升查询效率，需平衡读写性能。
    不抵制唯一索引：业务唯一逻辑优先用数据库唯一索引保证，而非仅依赖应用层校验。
    三、PostgreSQL 特有优化

27. 【推荐】使用 GENERATED AS IDENTITY 替代自增
      PostgreSQL 的 GENERATED AS IDENTITY 是 SQL 标准语法，比传统 SERIAL 更安全（支持 START WITH、INCREMENT BY 等配置，且可防止手动修改）。
      示例：id bigint GENERATED AS IDENTITY (START WITH 1 INCREMENT BY 1) PRIMARY KEY。

28. 【推荐】使用 BRIN 索引优化大表
      对于超大规模表（如亿级行），且字段具有连续性（如 gmt_create、id），使用 BRIN 索引（块范围索引），空间占用仅为普通索引的 1%~10%。
      示例：CREATE INDEX idx_order_create_time ON order USING BRIN(gmt_create)。

29. 【推荐】使用 GIN 索引优化数组 / 全文检索
      若字段为数组类型（如 tags varchar[]），创建 GIN 索引提升数组查询效率（如 WHERE tags @> ARRAY['java']）。
      示例：CREATE INDEX idx_article_tags ON article USING GIN(tags)。

30. 【推荐】分区表优化大表
      单表行数超过 5000 万行时，使用 PostgreSQL 分区表（按时间、地区等维度分区），提升查询效率（仅扫描对应分区）。
      示例：按时间分区的订单表：
      sql
      CREATE TABLE order (
     id bigint,
     order_no varchar(32),
     gmt_create timestamp
      ) PARTITION BY RANGE (gmt_create);
      -- 创建 2024 年 1 月分区
      CREATE TABLE order_202401 PARTITION OF order FOR VALUES FROM ('2024-01-01') TO ('2024-02-01');

31. 【参考】开启 pg_stat_statements 监控 SQL
      启用 pg_stat_statements 扩展（需在 postgresql.conf 中配置 shared_preload_libraries = 'pg_stat_statements'），监控慢 SQL 和高频 SQL，便于优化。
      示例：查询 Top 10 慢 SQL：
      sql
      SELECT queryid, query, calls, total_time, mean_time
      FROM pg_stat_statements
      ORDER BY mean_time DESC
      LIMIT 10;



# 2. ubuntu

## 1. 一些常用命令

```
# 查询状态
sudo systemctl status postgresql
# 直接以postgres超级用户登录psql
sudo -u postgres psql
```



| 命令                | 作用                   |
| ------------------- | ---------------------- |
| `\l`                | 列出所有数据库         |
| `\c 数据库名`       | 切换到指定数据库       |
| `\dt`               | 列出当前数据库的所有表 |
| `\du`               | 列出所有用户及权限     |
| `\q`                | 退出 psql 终端（重要） |
| `SELECT version();` | 查看 PostgreSQL 版本   |



```
 # 查询用户
 SELECT usename, passwd FROM pg_shadow;
 usename  |               passwd                
----------+-------------------------------------
 postgres | 
 chatuser | md523706d44ca073dd7c32aacf5a304ffb7
(2 rows)
```

