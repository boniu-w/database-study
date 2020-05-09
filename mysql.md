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

#### 6. mybatis xml中大于号,小于号问题

  附：XML转义字符

```java
&lt;     	<   	小于号   
&gt;     	>   	大于号   
&amp;     	&   	和   
&apos;     	’   	单引号   
&quot;     	"   	双引号 
```



第二种方法：
因为这个是xml格式的，所以不允许出现类似">"这样的字符，但是可以使用<![CDATA[ ]]>符号进行说明，将此类符号不进行解析 
mapper文件示例代码:

```xml
	<if test="startTime != null ">
			AND <![CDATA[ order_date >= #{startTime,jdbcType=DATE}  ]]>
	</if>
	<if test="endTime != null ">
			AND <![CDATA[ order_date <= #{endTime,jdbcType=DATE}  ]]>
	</if>
```

### 7.mysql 时区问题

```sql
set global time_zone = '+8:00';
set time_zone = '+8:00';
flush privileges;
```

在配置文件中加

```xml
default-time-zone='+8:00'
```



#### 8. mysql 8.0 修改root 密码,前提是进入了mysql,忘记了密码这个问题,还待解决

```sql
use mysql；
ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '123456';
FLUSH PRIVILEGES;
```

#### 9. mysql 的 group_cancat(字段) 方法查询一对多 非常好用

```sql
SELECT
	type,
	field_name,
	field_code,
	GROUP_CONCAT(matching_field_name) as matching_name
FROM
	(
SELECT
	w.field_name,
	w.field_code,
	w.type,
	m.field_name as matching_field_name
FROM
	wordbook w
	LEFT JOIN matching_to_wordbook m ON w.type = m.type 
	) test 
GROUP BY
	type,
	field_name,
	field_code
```



#### 10. mysql 日志

	1. 手动开启日志 set global general_log = "on"
 	2. 检查是否开启成功 show variables like "general_log%"
 	3. 



#### 11. 数据类型的长度

| 类型       | 长度               | comment              |
| :--------- | :----------------- | :------------------- |
| char       | 1-255 字节         | 定长                 |
| varchar    | 1-255              | 变长                 |
| tinyblob   | 1-255              | binary large objects |
| tinytext   | 2^8-1(255)         |                      |
| blob       | 2^16-1(65535) 字节 |                      |
| text       | 2^16-1             |                      |
| mediumblob | 2^24-1(16777215)   |                      |
| mediumtext | 2^24-1             |                      |
| longblob   | 2^32-1             |                      |
| longtext   | 2^32-1             |                      |

​		

#### 12. distinct 与 group by

distinct关键字必须位于所有字段的前面，且作用于其后所有字段



#### 13. 普通索引, unique索引(唯一索引), 主键索引

- 创建索引

create index 索引名 on 表名(列名);

create unique index 索引名 on 表名(列名);

- 删除索引

drop index 索引名 on 表名;

alter table 表名 drop index 索引名;

alter table 表名 drop primary key;

- 查看索引

show index from 表名;

show keys from 表名;



#### 14. 视图

- 创建视图

create view 视图名 as select * from 表名;



#### 15. 查出时间最大的一条记录

```sql
    select * from 
    (select * from liushui order by jiao_yi_shi_jian desc) a 
    group by a.card_no;
```

解释: 先按时间排序, 再group by 分组, 这样会把 分组后的第一条数组拿出来,



#### 16. 主键自增归0

空表时: 删除 主键 再添加;



#### 17. like用法

```sql
	select * from liushui where zhai_yao like "%atm%" UNION
			select * from liushui where zhai_yao like "%取款%" UNION
				select * from liushui where zhai_yao like "%现支%" UNION
					select * from liushui where zhai_yao like "%支取%" UNION
						select * from liushui where zhai_yao like "%卡取%" UNION
							select * from liushui where zhai_yao like "%柜台转取%" UNION
							select * from liushui where zhai_yao like "%现销%" UNION
							select * from liushui where zhai_yao like "%取现%" UNION
							select * from liushui where zhai_yao like "%消费%" UNION
							select * from liushui where zhai_yao like "%备用金%" 
```

