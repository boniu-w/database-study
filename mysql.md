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

```sql
	select * from liushui order by jiao_yi_shi_jian desc limit 0,1;
```



#### 16. 主键自增归0

空表时: 删除 主键 再添加;



#### 17. like用法

1. %(百分号)

表示任何字符出现任意次数 0-无数次;

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
	select * from liushui where zhai_yao like "%备用金%" ;
```

2. like 之 _ (下划线)

"_"表示匹配单个字符 例:

```sql
select * from human where name like '_雨';
```

将查询出 名字长度是2个字,且最后一个字是 雨 的 人;





#### 18. limit

limit m,n : 从第m+1条开始,取n条数据;

limit n : 是 limit 0,n 的缩写;

#### 19. group by 与 临时表

1. 如果GROUP BY 的列没有索引,产生临时表. 

　　2. 如果GROUP BY时,SELECT的列不止GROUP BY列一个,并且GROUP BY的列不是主键 ,产生临时表. 
　　3. 如果GROUP BY的列有索引,ORDER BY的列没索引.产生临时表. 
　　4. 如果GROUP BY的列和ORDER BY的列不一样,即使都有索引也会产生临时表. 
　　5. 如果GROUP BY或ORDER BY的列不是来自JOIN语句第一个表.会产生临时表. 
　　6. 如果DISTINCT 和 ORDER BY的列没有索引,产生临时表.



#### 20. sql语句的执行顺序

```tex
1、执行FROM语句
2、执行ON过滤
3、添加外部行
4、执行where条件过滤
5、执行group by分组语句
6、执行having
7、select列表
8、执行distinct去重复数据
9、执行order by字句
10、执行limit字句
```



#### 21. mysql 中 datetime 与 timestamp

1. datetime的默认值为null，timestamp的默认值不为null，且为系统当前时间（current_timestatmp）。如果不做特殊处理，且update没有指定该列更新，则默认更新为当前时间。
2. datetime占用8个字节，timestamp占用4个字节。timestamp利用率更高。
3. 二者存储方式不一样，对于timestamp，它把客户端插入的时间从当前时区转化为世界标准时间（UTC）进行存储，查询时，逆向返回。但对于datetime，基本上存什么是什么。
4. 二者范围不一样。timestamp范围：‘1970-01-01 00:00:01.000000’ 到 ‘2038-01-19 03:14:07.999999’； datetime范围：’1000-01-01 00:00:00.000000’ 到 ‘9999-12-31 23:59:59.999999’。原因是，timestamp占用4字节，能表示最大的时间毫秒为2的31次方减1，也就是2147483647，换成时间刚好是2038-01-19 03:14:07.999999。

| curdate() CURRENT_DATE()          | 当前日期                                     |
| --------------------------------- | -------------------------------------------- |
| curtime() CURRENT_TIME()          | 当前时间                                     |
| now() CURRENT_TIMESTAMP()         | 当前日期和时间                               |
| unix_timestamp(date)              | 返回date的linux时间戳                        |
| from_unixttime                    | 返回linux的时间戳的日期值                    |
| week(date)                        | 日期date为一年中的第几周                     |
| year(date)                        | date的年份值                                 |
| hour(date)                        | date的小时值                                 |
| minute(date)                      | date的分钟值                                 |
| date_format(date,fmt)             | 按fmt格式化date                              |
| date_add(date,interval expr type) | 返回一个日期或时间值加上一个时间间隔的时间值 |
| datediff(expr,expr2)              | expr 与 expr2 之间的天数                     |

#### 22. mysql 的存储过程

```sql
CREATE PROCEDURE pro()
BEGIN
declare i int;
set i=0 ;
while i<10000 do 
INSERT into user VALUES (replace(md5(uuid()),'-',''),'123');
set i=i+1;
end while ;
end;
```



1. 通常存储过程有助于提高应用程序的性能。当创建，存储过程被编译之后，就存储在数据库中.**但是，MySQL实现的存储过程略有不同。 MySQL存储过程按需编译。 **在编译存储过程之后，MySQL将其放入缓存中。MySQL为每个连接维护自己的存储过程高速缓存.如果应用程序在单个连接中多次使用存储过程，则使用编译版本，否则存储过程的工作方式类似于查询。
2. 存储过程有助于减少应用程序和数据库服务器之间的流量，因为应用程序不必发送多个冗长的SQL语句，而只能发送存储过程的名称和参数。
3. 存储的程序对任何应用程序都是可重用的和透明的。存储过程将数据库接口暴露给所有应用程序，以便开发人员不必开发存储过程中已支持的功能。
4. 存储的程序是安全的。数据库管理员可以向访问数据库中存储过程的应用程序授予适当的权限，而不向基础数据库表提供任何权限。



mysql 存储过程的缺点:

1. 如果使用大量存储过程，那么使用这些存储过程的每个连接的内存使用量将会大大增加.此外，如果您在存储过程中过度使用大量逻辑操作，则CPU使用率也会增加，因为数据库服务器的设计不当于逻辑运算。
2. 存储过程的构造使得开发具有复杂业务逻辑的存储过程变得更加困难。
3. 很难调试存储过程。只有少数数据库管理系统允许您调试存储过程。而且，MySQL不提供调试存储过程的功能。
4. 开发和维护存储过程并不容易。开发和维护存储过程通常需要一个不是所有应用程序开发人员拥有的专业技能。这可能会导致应用程序开发和维护阶段的问题。



#### 23. 日期字段有时分秒, 我只查 年月日

```sql
		SELECT
			count(*)
		FROM
			`bank_flow` 
		WHERE
			DATE_FORMAT(transaction_date,'%Y-%m-%d') ='2019-11-19';
```



#### 24. ` 符号

mysql 的转义符,只要你不在表名，列名中的使用**保留字或中文**，就不需要转义。

#### 25. 修改整列的值

```sql
UPDATE bank_flow set id= replace(uuid(),"-","");
```



#### 26. mysql 把一列的值 挪到 另一列

```sql
update bank_flow set b=a;
```



#### 27. 使用navicat 链接mysql 使用 replace uuid 会出现uuid 重复





#### 28. sql语句 形式 导入文件 示例:

```sql
LOAD DATA LOCAL INFILE 'C:\\Users\\LPH\\Desktop\\ml-1m\\ml-1m\\movies.dat'

INTO TABLE movies

FIELDS TERMINATED BY '::'

LINES TERMINATED BY '\n'

(id, title, type);
```



#### 29. sql语句中的 !=  与 <>

ANSI标准中是用<>(所以建议用<>)，但为了跟大部分数据库保持一致，数据库中一般都提供了 !=(高级语言一般用来表示不等于) 与 <> 来表示不等于：

- MySQL 5.1: 支持 `!=` 和 `<>`
- PostgreSQL 8.3: 支持 `!=` 和 `<>`
- SQLite: 支持 `!=` 和 `<>`
- Oracle 10g: 支持 `!=` 和 `<>`
- Microsoft SQL Server 2000/2005/2008: 支持 `!=` 和 `<>`
- IBM Informix Dynamic Server 10: 支持 `!=` 和 `<>`
- InterBase/Firebird: 支持 `!=` 和 `<>`

最后两个只支持ANSI标准的数据库：

- IBM DB2 UDB 9.5:仅支持 `<>`
- Apache Derby:仅支持 `<>`





#### 30 insert or update

```sql
REPLACE into user_role VALUES ('1','cad5v165sdv616wd5v','c1a6s1c6as16c51as');
```





#### 31. mysql.help_topic 以字符拆分,一行转多行

````sql
select substring_index(substring_index('82,83,84,85,86',',',help_topic_id+1),',',-1) as Id
 
from mysql.help_topic
 
where help_topic_id<(length('82,83,84,85,86')-ength(replace('82,83,84,85,86',',',''))+1);
````



```sql
create table personnel_participation_frequency
SELECT
	count(*) as count,
	SUBSTRING_INDEX( SUBSTRING_INDEX( player_ids, ',', help_topic_id + 1 ), ',',- 1 ) as play_id
FROM
		db_room as db
-- 	( SELECT player_ids FROM db_room) AS db
	LEFT JOIN mysql.help_topic 
	ON help_topic_id < ( length( db.player_ids ) - length( REPLACE ( db.player_ids, ',', '' ) ) + 1 )
	GROUP BY play_id
```





#### 32. substring_index(str,delimiter,count);  以正则 分割字符串





#### 33. mysql各种命令

```sql
show create table bs_user; ---查看表的创建语句
show variable;  --- 查看配置
desc t_your_table; --- 查看表的设计
show binary logs; --- 查看日志
```





