#### 1. 创建用户并授权

```sql
create user C##DYSJ identified by password;
grant connect,resource to C##DYSJ;
```

#### 2. 查看数据库用户名和密码

```sql
alter user C##DYSJ account unlock;
alter user C##DYSJ identified by 123456;  -- 修改密码为 123456
```

#### 3. 查询Oracle所有表

```sql
select * from tabs;
```



---

**Oracle 是大小写敏感的，但是 Oracle 同样支持""语法，将表名或字段名加上""后，Oracle不会将其转换成大写**

---



