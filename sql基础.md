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

#### 3. 查看MySQL版本号

```sql
select version();	
```

#### 4.  把从一个表中查询的数据 直接插入到第二张表中 两张表的字段不一致

```sql
INSERT INTO maximum_balance ( id, date, card_id, max_money, max_balance, case_id, Reserve1, Reserve2 ) 

SELECT
"001",
now( ),
"111",
MAX( account_balance ),
max( transaction_amount ),
"1",
NULL,
NULL 
FROM
	( SELECT case_id, transaction_date, account_balance, transaction_amount FROM bank_statement b WHERE transaction_date = "2020-03-02" AND full_name = "张三" AND query_card_number = "111" ) cc;
```

​	注意: 没有普通插入语句的 values , 也没有括号;



#### 5. sql注入

防护
归纳一下，主要有以下几点：
1.永远不要信任用户的输入。对用户的输入进行校验，可以通过正则表达式，或限制长度；对单引号和
双"-"进行转换等。
2.永远不要使用动态拼装sql，可以使用参数化的sql或者直接使用存储过程进行数据查询存取。
3.永远不要使用管理员权限的数据库连接，为每个应用使用单独的权限有限的数据库连接。
4.不要把机密信息直接存放，加密或者hash掉密码和敏感的信息。
5.应用的异常信息应该给出尽可能少的提示，最好使用自定义的错误信息对原始错误信息进行包装
6.sql注入的检测方法一般采取辅助软件或网站平台来检测，软件一般采用sql注入检测工具jsky，网站平台就有亿思网站安全平台检测工具。MDCSOFT SCAN等。采用MDCSOFT-IPS可以有效的防御SQL注入，XSS攻击等。