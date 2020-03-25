#### 1. mysql 根据 日期 查询 数据

​		transaction_date : 是字段名

```sql
SELECT * from bank_statement b WHERE date(transaction_date) = "2020-03-02" and case_id = 1
```

```mysql
SELECT * from bank_statement b WHERE transaction_date = "2020-03-02" and case_id = 1
```



```sql
select * from table1 where second(order_date) between 2 and 12;
```

```sql
select * from table1 where date(order_date) between '2019-08-04' and '2019-08-04';
```

### 2. mysql uuid

```sql
UPDATE wordbook set id=REPLACE( UUID(),"-","") WHERE id = "123"
```

### 3. 查看MySQL版本号

```sql
select version();	
```

