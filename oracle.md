#### 1. 创建用户并授权

```sql
create user C##DYSJ identified by 密码;
grant connect,resource to C##DYSJ;
```

```sql
alter user C##DYSJ account unlock;
alter user C##DYSJ identified by 新密码;  -- 修改密码为 123456
```

#### 2. 查询Oracle所有表

```sql
select * from tabs;
```



---

**Oracle 是大小写敏感的，但是 Oracle 同样支持""语法，将表名或字段名加上""后，Oracle不会将其转换成大写**

---

#### 3. 修改oracle 密码

alter user system identified by 新密码;



#### 4. Oracle的 left join on 与 普通where(inner join on) 区别

举个例子就明白了:

```sql
		SELECT
			* 
		FROM
			`tb_player` p
			INNER JOIN db_club c ON p.club_id = c.id 
		WHERE
			p.id = 320941;
```

```sql
		SELECT
			* 
		FROM
			`tb_player` p
			left JOIN db_club c ON p.club_id = c.id 
		WHERE
			p.id = 320941;
```

​    **第一个 inner join 当p.id 不存在时,是没有输出结果的**

**but 第二个 left join 当p.id 不存在时,会输出左表的数据**



#### 5. 查询Oracle版本

```sql
	select * from v$version;
```



#### 6. to_date , to_char

```sql
SELECT to_date('2020-05-12 16:24:32','yyyy-MM-dd hh24:mi:ss') from dual;
```

```sql
SELECT to_char(sysdate,'yyyy-MM-dd hh24:mi:ss') from dual;
```

注意: 

1. 这里必须用单引号, 双引号报错;

2. hh:mm:ss 在oracle中,是错误的, 在java中没问题;



#### 7. 单引号, 双引号

字段用双引号 ,其他单引号

#### 8. nvarchar2  varchar2

nvarchar2(10) : 可以10个汉字

varchar2(10): 不可以



#### 9. listagg(字段,分隔符) within group(order by 字段) : 列转行 , 与 mysql group_concat()异曲同工

```sql
	SELECT
        type,
        field_name,
        field_code,
        listagg( matching_field_name,',') within group (order by type )AS matching_name
        FROM
            (
            SELECT
                w.field_name,
                w.field_code,
                w.type,
                m.field_name AS matching_field_name
            FROM
                wordbook w
                LEFT JOIN matching_to_wordbook m ON w.type = m.type
                ) test
        GROUP BY
            type,
            field_name,
            field_code
```



#### 10. 检查约束

检查约束

```sql
SELECT * FROM user_constraints WHERE table_name='TABLE_NAME';
```



删除约束

```sql
ALTER TABLE TABLE_NAME DROP CONSTRAINT SYS_C00180123;
```



#### 11. 添加列,删除列,修改列

删除列: 

```sql
ALTER TABLE BANK_STATEMENT DROP COLUMN create_time;
```

添加列: 

```sql
ALTER TABLE BANK_STATEMENT ADD relation_id varchar2(36) ;
```

修改列: 

```sql
Alter table 表名 modify 列名 varchar2(20);
```

注: 添加,修改列 不需要 column 关键字

#### 12. oracle 常用命令

| 命令                            | 例                             | 描述                                     |
| ------------------------------- | ------------------------------ | ---------------------------------------- |
| sqlplus 用户名/密码 [as sysdba] | sqlplus scott/123456 as sysdba | 超级管理员 加上 as sysdba,普通用户不用加 |
| show user                       |                                | 查看当前用户                             |
| conn  用户名/密码 [as sysdba]   | conn scott/123456              | 切换用户                                 |
| select * from tab;              |                                | 查看所有表                               |
| desc 表名                       | desc emp;                      | 查看表结构                               |
|                                 |                                |                                          |
|                                 |                                |                                          |
|                                 |                                |                                          |
|                                 |                                |                                          |

 