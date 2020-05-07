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

