
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

#### 2.  mysql uuid

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

#### 7.mysql 时区问题

```sql
set global time_zone = '+8:00';
set time_zone = '+8:00';
flush privileges;
```

在配置文件中也要加

```xml
default-time-zone='+8:00'
```



运行命令 show variables like "%time_zone";

```sql
system_time_zone	EDT
time_zone	+08:00
```



system_time_zone  要为 cst 才是 中国时区



注意: datetime 和 timestamp 在数据库字段定义时,要弄清楚, 建议 定义为 datetime



#### 8. mysql 8.0 修改root 密码,前提是进入了mysql,忘记了密码这个问题,还待解决

```sql
use mysql；
ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '123456';
FLUSH PRIVILEGES;
```



更改 user 表中的 host 项，将“localhost”改称“%”（表示所有用户都可以访问），并给 root 用户授权：

```mysql
$ mysql -u root -p
 
mysql> use mysql;
mysql>
mysql> update user set host = '%' where user = 'root';
mysql>
mysql> grant all on *.* to root@'%' identified by '123456' with grant option;
mysql>
mysql> flush privileges;  # 刷新权限
mysql>
mysql> exit
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

| function and keywords                | description                                  | example                                                      |
| ------------------------------------ | -------------------------------------------- | ------------------------------------------------------------ |
| curdate()   CURRENT_DATE             | 当前日期                                     | SELECT CURRENT_DATE; // 2020-08-12                           |
| curtime()   CURRENT_TIME             | 当前时间                                     | SELECT CURRENT_TIME;  // 14:59:36                            |
| now()   CURRENT_TIMESTAMP            | 当前日期和时间                               | SELECT CURRENT_TIMESTAMP;  // 2020-08-12 15:00:46            |
| unix_timestamp(date)                 | 返回date的linux时间戳                        | SELECT unix_timestamp(create_time) FROM role;  // 1594890321 |
| from_unixtime(unix_timestamp,format) | 返回linux的时间戳的日期值                    | SELECT from_unixtime(1594890321,'%Y-%M-%D %H:%I:%S') ;  // 2020-July-16th 17:05:21 |
| week(date)                           | 日期date为一年中的第几周                     |                                                              |
| year(date)                           | date的年份值                                 |                                                              |
| hour(date)                           | date的小时值                                 |                                                              |
| minute(date)                         | date的分钟值                                 | SELECT MINUTE( create_time ),<br/>	count( * ) <br/>FROM<br/>	role <br/>WHERE<br/>	date( create_time ) = '2020-7-16' <br/>	AND HOUR ( create_time ) = '11 ' <br/>GROUP BY<br/>	MINUTE ( create_time ); |
| date_format(date,fmt)                | 按fmt格式化date                              |                                                              |
| date_add(date,interval expr type)    | 返回一个日期或时间值加上一个时间间隔的时间值 |                                                              |
| datediff(expr,expr2)                 | expr 与 expr2 之间的天数                     |                                                              |
| date(expr)                           | 取年月日                                     | SELECT date(create_time) FROM role; // 2020-07-16            |
| time(expr)                           | 取时分秒                                     | SELECT TIME(create_time) FROM role;  // 17:05:21             |
| timestamp(expr)                      | 取完整时间                                   | SELECT TIMESTAMP(create_time) FROM role;  // 2020-07-16 17:05:21 |

另: format格式说明：

%M 月名字(January～December)
%W 星期名字(Sunday～Saturday)
%D 有英语前缀的月份的日期(1st, 2nd, 3rd, 等等。）
%Y 年, 数字, 4 位
%y 年, 数字, 2 位
%a 缩写的星期名字(Sun～Sat)
%d 月份中的天数, 数字(00～31)
%e 月份中的天数, 数字(0～31)
%m 月, 数字(01～12)
%c 月, 数字(1～12)
%b 缩写的月份名字(Jan～Dec)
%j 一年中的天数(001～366)
%H 小时(00～23)
%k 小时(0～23)
%h 小时(01～12)
%I 小时(01～12)
%l 小时(1～12)
%i 分钟, 数字(00～59)
%r 时间,12 小时(hh:mm:ss [AP]M)
%T 时间,24 小时(hh:mm:ss)
%S 秒(00～59)
%s 秒(00～59)
%p AM或PM
%w 一个星期中的天数(0=Sunday ～6=Saturday ）
%U 星期(0～52), 这里星期天是星期的第一天
%u 星期(0～52), 这里星期一是星期的第一天
%% 一个文字%



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

也可以直接使用函数 date();

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
select version(); --- 查数据库版本
```



#### 34. 千万级表的优化

**设计表时注意:**

1. 表字段避免null 出现, null值很难查询优化且占用额外的索引空间，推荐默认数字0代替;
2. 尽量使用int 而不是 bigint, 如果非负 加上 unsigned 这样数值容量会扩大一倍, 使用tinyint,smallint,medium_int 更好
3. 使用枚举 或 整数 代替字符串类型
4. 尽量使用timestamp 代替 datetime
5. 单表不要有太多字段,在20以内
6. 用整型存ip



**选择合适的数据类型 **

1. 使用可存下数据的最小的数据类型，整型 < date,time < char,varchar < blob 

2. 使用简单的数据类型，整型比字符处理开销更小，因为字符串的比较更复杂。如，int类型存储时间类型，bigint类型转ip函数 

3. 使用合理的字段属性长度，固定长度的表会更快。使用enum、char而不是varchar 

4. 尽可能使用not null定义字段 

5. 尽量少用text，非用不可最好分表

   

**选择合适的索引列 **

1. 查询频繁的列，在where，group by，order by，on从句中出现的列 
2. where条件中<，<=，=，>，>=，between，in，以及like 字符串+通配符（%）出现的列 
3. 长度小的列，索引字段越小越好，因为数据库的存储单位是页，一页中能存下的数据越多越好 
4. 离散度大（不同的值多）的列，放在联合索引前面。查看离散度，通过统计不同的列值来实现，count越大，离散程度越高：



**sql的编写需要注意优化**

- 使用limit对查询结果的记录进行限定
- 避免select *，将需要查找的字段列出来
- 使用连接（join）来代替子查询
- 拆分大的delete或insert语句
- 可通过开启慢查询日志来找出较慢的SQL
- 不做列运算：SELECT id WHERE age + 1 = 10，任何对列的操作都将导致表扫描，它包括数据库教程函数、计算表达式等等，查询时要尽可能将操作移至等号右边
- sql语句尽可能简单：一条sql只能在一个cpu运算；大语句拆小语句，减少锁时间；一条大sql可以堵死整个库
- OR改写成IN：OR的效率是n级别，IN的效率是log(n)级别，in的个数建议控制在200以内
- 不用函数和触发器，在应用程序实现
- 避免%xxx式查询
- 少用JOIN
- 使用同类型进行比较，比如用'123'和'123'比，123和123比
- 尽量避免在WHERE子句中使用!=或<>操作符，否则将引擎放弃使用索引而进行全表扫描
- 对于连续数值，使用BETWEEN不用IN：SELECT id FROM t WHERE num BETWEEN 1 AND 5
- 列表数据不要拿全表，要使用LIMIT来分页，每页数量也不要太大



**引擎**
目前广泛使用的是MyISAM和InnoDB两种引擎：

1.MyISAM
MyISAM引擎是MySQL 5.1及之前版本的默认引擎，它的特点是：

- 不支持行锁，读取时对需要读到的所有表加锁，写入时则对表加排它锁
- 不支持事务
- 不支持外键
- 不支持崩溃后的安全恢复
- 在表有读取查询的同时，支持往表中插入新纪录
- 支持BLOB和TEXT的前500个字符索引，支持全文索引
- 支持延迟更新索引，极大提升写入性能
- 对于不会进行修改的表，支持压缩表，极大减少磁盘空间占用

2.InnoDB
InnoDB在MySQL 5.5后成为默认索引，它的特点是：

- 支持行锁，采用MVCC来支持高并发
- 支持事务
- 支持外键
- 支持崩溃后的安全恢复
- 不支持全文索引

***总体来讲，MyISAM适合SELECT密集型的表，而InnoDB适合INSERT和UPDATE密集型的表***



**分区**

MySQL在5.1版引入的分区是一种简单的水平拆分，用户需要在建表的时候加上分区参数，对应用是透明的无需修改代码
对用户来说，分区表是一个独立的逻辑表，但是底层由多个物理子表组成，实现分区的代码实际上是通过对一组底层表的对象封装，但对SQL层来说是一个完全封装底层的黑盒子。MySQL实现分区的方式也意味着索引也是按照分区的子表定义，没有全局索引
用户的SQL语句是需要针对分区表做优化，SQL条件中要带上分区条件的列，从而使查询定位到少量的分区上，否则就会扫描全部分区，可以通过EXPLAIN PARTITIONS来查看某条SQL语句会落在那些分区上，从而进行SQL优化，我测试，查询时不带分区条件的列，也会提高速度，故该措施值得一试。

分区的好处是：

- 可以让单表存储更多的数据
- 分区表的数据更容易维护，可以通过清楚整个分区批量删除大量数据，也可以增加新的分区来支持新插入的数据。另外，还可以对一个独立分区进行优化、检查、修复等操作
- 部分查询能够从查询条件确定只落在少数分区上，速度会很快
- 分区表的数据还可以分布在不同的物理设备上，从而搞笑利用多个硬件设备
- 可以使用分区表赖避免某些特殊瓶颈，例如InnoDB单个索引的互斥访问、ext3文件系统的inode锁竞争
- 可以备份和恢复单个分区

分区的限制和缺点：

- 一个表最多只能有1024个分区
- 如果分区字段中有主键或者唯一索引的列，那么所有主键列和唯一索引列都必须包含进来
- 分区表无法使用外键约束
- NULL值会使分区过滤无效
- 所有分区必须使用相同的存储引擎

分区的类型：

- RANGE分区：基于属于一个给定连续区间的列值，把多行分配给分区
- LIST分区：类似于按RANGE分区，区别在于LIST分区是基于列值匹配一个离散值集合中的某个值来进行选择
- HASH分区：基于用户定义的表达式的返回值来进行选择的分区，该表达式使用将要插入到表中的这些行的列值进行计算。这个函数可以包含MySQL中有效的、产生非负整数值的任何表达式
- KEY分区：类似于按HASH分区，区别在于KEY分区只支持计算一列或多列，且MySQL服务器提供其自身的哈希函数。必须有一列或多列包含整数值
- 具体关于mysql分区的概念请自行google或查询官方文档，我这里只是抛砖引玉了。





**分表**

分表就是把一张大表，按照如上过程都优化了，还是查询卡死，那就把这个表分成多张表，把一次查询分成多次查询，然后把结果组合返回给用户。
分表分为垂直拆分和水平拆分，通常以某个字段做拆分项。比如以id字段拆分为100张表： 表名为 tableName_id%100
但：分表需要修改源程序代码，会给开发带来大量工作，极大的增加了开发成本，故：只适合在开发初期就考虑到了大量数据存在，做好了分表处理，不适合应用上线了再做修改，成本太高！！！而且选择这个方案，都不如选择我提供的第二第三个方案的成本低！故不建议采用。



**分库**

把一个数据库分成多个，建议做个读写分离就行了，真正的做分库也会带来大量的开发成本，得不偿失！不推荐使用。

方案二详细说明：升级数据库，换一个100%兼容mysql的数据库

mysql性能不行，那就换个。为保证源程序代码不修改，保证现有业务平稳迁移，故需要换一个100%兼容mysql的数据库。

1.开源选择

- tiDB https://github.com/pingcap/tidb
- Cubrid https://www.cubrid.org/
  开源数据库会带来大量的运维成本且其工业品质和MySQL尚有差距，有很多坑要踩，如果你公司要求必须自建数据库，那么选择该类型产品。

2.云数据选择

- 阿里云POLARDB
  https://www.aliyun.com/product/polardb?spm=a2c4g.11174283.cloudEssentials.47.7a984b5cS7h4wH

> 官方介绍语：POLARDB 是阿里云自研的下一代关系型分布式云原生数据库，100%兼容MySQL，存储容量最高可达 100T，性能最高提升至 MySQL 的 6 倍。POLARDB 既融合了商业数据库稳定、可靠、高性能的特征，又具有开源数据库简单、可扩展、持续迭代的优势，而成本只需商用数据库的 1/10。

我开通测试了一下，支持免费mysql的数据迁移，无操作成本，性能提升在10倍左右，价格跟rds相差不多，是个很好的备选解决方案！

- 阿里云OcenanBase
  淘宝使用的，扛得住双十一，性能卓著，但是在公测中，我无法尝试，但值得期待
- 阿里云HybridDB for MySQL (原PetaData)
  https://www.aliyun.com/product/petadata?spm=a2c4g.11174283.cloudEssentials.54.7a984b5cS7h4wH

> 官方介绍：云数据库HybridDB for MySQL （原名PetaData）是同时支持海量数据在线事务（OLTP）和在线分析（OLAP）的HTAP（Hybrid Transaction/Analytical Processing）关系型数据库。

我也测试了一下，是一个olap和oltp兼容的解决方案，但是价格太高，每小时高达10块钱，用来做存储太浪费了，适合存储和分析一起用的业务。

- 腾讯云DCDB
  https://cloud.tencent.com/product/dcdb_for_tdsql

> 官方介绍：DCDB又名TDSQL，一种兼容MySQL协议和语法，支持自动水平拆分的高性能分布式数据库——即业务显示为完整的逻辑表，数据却均匀的拆分到多个分片中；每个分片默认采用主备架构，提供灾备、恢复、监控、不停机扩容等全套解决方案，适用于TB或PB级的海量数据场景。



方案三详细说明：去掉mysql，换大数据引擎处理数据

数据量过亿了，没得选了，只能上大数据了。

1.开源解决方案
hadoop家族。hbase/hive怼上就是了。但是有很高的运维成本，一般公司是玩不起的，没十万投入是不会有很好的产出的！
2.云解决方案
这个就比较多了，也是一种未来趋势，大数据由专业的公司提供专业的服务，小公司或个人购买服务，大数据就像水/电等公共设施一样，存在于社会的方方面面。

> 国内做的最好的当属阿里云。

我选择了阿里云的MaxCompute配合DataWorks，使用超级舒服，按量付费，成本极低。
MaxCompute可以理解为开源的Hive，提供sql/mapreduce/ai算法/python脚本/shell脚本等方式操作数据，数据以表格的形式展现，以分布式方式存储，采用定时任务和批处理的方式处理数据。DataWorks提供了一种工作流的方式管理你的数据处理任务和调度监控。
当然你也可以选择阿里云hbase等其他产品，我这里主要是离线处理，故选择MaxCompute，基本都是图形界面操作，大概写了300行sql，费用不超过100块钱就解决了数据处理问题。







#### 35. insert into 表  select ---谨慎使用, 会锁定表



查询条件导致全表扫描,避免,在条件上加索引,就不会扫描全表而锁定表,只会锁定符合条件的记录;





总结:
使用insert into tablA select * from tableB语句时，一定要确保tableB后面的where，order或者其他条件，都需要有对应的索引，来避免出现tableB全部记录被锁定的情况



#### 36. between

表示>= and <= ;



#### 37. 函数整理



| <span style="white-space: nowrap;">函数&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;</span> | <span style="white-space: nowrap;">解释&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;</span> | <span style="white-space: nowrap;">例子&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;</span> |
| ------------------------------------------------------------ | ------------------------------------------------------------ | ------------------------------------------------------------ |
| between                                                      | 表示 >= and <= ;                                             | BETWEEN 1 and 60;                                            |
| date(date)                                                   | 函数返回日期或日期/时间表达式的日期部分, 没有时间部分, 只有日期部分; | select date('2008-08-08 22:23:01'); -- 2008-08-08            |
| date_format(date, format)                                    |                                                              | select date_format('2008-08-08 22:23:01', '%Y-%m-%d %H:%i:%s');  -- 2008-08-08 22:23:01 |
| concat(str1, str2, ...)                                      | 拼接字符串                                                   | CONCAT('%','我','%')                                         |
| now()                                                        | now() 在执行开始时值就得到了                                 | select now(), sleep(3), now();                               |
| sysydate()                                                   | sysdate() 在函数执行时动态得到值                             | select sysdate(), sleep(3), sysdate();                       |
| current_timestamp()                                          |                                                              |                                                              |
| time_format(date, format)                                    |                                                              | select time_format('2008-08-08 22:23:01', '%Y-%m-%d %H:%i:%s');  -- 0000-00-00 22:23:01 |
| str_to_date(str, format)                                     | 转换成日期格式                                               | select str_to_date('08/09/2008', '%m/%d/%Y'); -- 2008-08-09<br>select str_to_date('08.09.2008 08:09:30', '%m.%d.%Y %h:%i:%s'); -- 2008-08-09 08:09:30 |
| left(str, length)                                            | 返回字符串str最左边的length个字符                            | select left('foobarbar', 5) -- fooba                         |
| right(str, length)                                           | 返回字符串str最右边的length个字符                            |                                                              |
| substring(str, position)                                     | 从字符串str的position位置返回一个子串。从1开始, 而java 是从0开始 | select substring('foobarbar', 5); -- arbar                   |
| substring(str, position ,length)                             | 从position开始截, 截length长度, 和java不一样                 | SELECT substring('abcdefghijklmn', 2, 4); -- bcde            |
| trim(str)                                                    | 去除前后空格, 和java 一样                                    | select length(TRIM('  bar ')) as bar,length('  bar ');  --3 6 |
| replace(str, derected_str, to_str)                           | 替换                                                         | select REPLACE('www.mysql.com', 'w', 'sy'); -- sysysy.mysql.com |
| repeat(str, count)                                           | 把str 字符串重复 count次, 然后返回                           | select REPEAT('MySQL', 3); -- MySQLMySQLMySQL                |
| reverse(str)                                                 | 颠倒字符串                                                   | select REVERSE('abc'); -- cba                                |
| insert(str, pos, len, newstr)                                | 从position位置开始的length个长度, 用newstr替换,              | select INSERT('whatareyou', 5, 3, 'is'); -- whatisyou        |
| if(expr1, expr2, expr3)                                      |                                                              | SELECT IF(1<2,'it is true','it is false'); -- it is true     |
| strcmp(expr1, expr2)                                         | 如果字符串相同，STRCMP()返回0，如果第一参数根据当前的排序次序小于第二个，返回-1，否则返回1。 | SELECT STRCMP('test','test'), STRCMP('a','b'), STRCMP('d','c'); -- 0	-1	1 |
| user()<br>system_user()<br>current_user()<br>session_user()  | 获取用户名                                                   | SELECT user(), SYSTEM_USER(), CURRENT_USER(),CURRENT_USER, SESSION_USER(); --root@10.10.8.18	root@10.10.8.18	root@%	root@%	root@10.10.8.18 |
| database()<br>schema()                                       | 获取当前数据库                                               | select database(), schema(); -- yxkj_yjgl	yxkj_yjgl       |
| connection_id()                                              | 返回服务器的连接数，也就是到现在为止MySQL服务的连接次数      | SELECT connection_id();                                      |
| charset(str)                                                 | 查字符集                                                     | SELECT CHARSET('b'), COLLATION('a');                         |
| collation(str)                                               | 查字符的排列方式                                             | utf8mb4	utf8mb4_0900_ai_ci                                |
| password(str)                                                | 加密字符串 , 5.7之后移除了                                   |                                                              |
| md5(str)                                                     | md5加密                                                      |                                                              |
| encode(str,pwd_str)                                          | 使用目标字符串进行加密                                       |                                                              |
| decode(str, pwd_str)                                         | 解密                                                         |                                                              |
| format(numeral, length)                                      | 将数字保留到小数点后length位                                 | SELECT format(123.2345,2), format(123.2131231,1); -- 123.23	123.2 |
| ascii(str)                                                   | 返回字符串str的第一个字符的ASCII码                           | SELECT ascii('a'),ascii('b'); -- 97	98                    |
| bin(x)                                                       | 返回x的二进制                                                | SELECT bin(123);-- 1111011                                   |
| hex(x)                                                       | 十六进制编码                                                 | SELECT hex(123);-- 7B                                        |
| oct(x)                                                       | 八进制编码                                                   | SELECT oct(123); -- 173                                      |
| conv(x,f1,f2)                                                | 将x从f1进制数变成f2进制数                                    | SELECT conv(123456789, 10, 3); -- 22121022020212200          |
| inet_aton(ip)                                                | 将IP地址转换为数字表示                                       | SELECT inet_aton('121.0.0.1') ;-- 2030043137                 |
| inet_ntoa(n)                                                 | 将数字n转换成IP的形式                                        | select inet_ntoa(2030043137); -- 121.0.0.1                   |
|                                                              |                                                              |                                                              |
|                                                              |                                                              |                                                              |
|                                                              |                                                              |                                                              |







#### 38. 各种命令



| command                                                      | description                          | example                                      |
| ------------------------------------------------------------ | ------------------------------------ | -------------------------------------------- |
| show engines;                                                | 查看数据库 的 引擎                   | show engines;                                |
| desc table_name;                                             | 查看表结构                           | desc student;                                |
| show create table table_name;                                | 显示表的创建语句, 可查看外键约束     | show create table student;                   |
| show table status like 'table_name';                         | 显示表的当前状态值                   | show table status like 'liushui';            |
| alter table table_name engine=MyISAM; （或 InnoDB 等其它引擎） | 修改表的数据库引擎                   | alter table liushui engine=InnoDB;           |
| show variables like '%general_log%';                         | 查看日志记录是否开启, 和日志文件位置 | show variables like '%general_log%';         |
| set global general_log = on;                                 | 开启查询日志                         | set global general_log = on;                 |
| show variables like 'log_output';                            | 查看日志 输出类型                    | show variables like 'log_output';            |
| set global log_output='table';                               | 设置日志输出类型为table              | set global log_output='table';               |
| select * from mysql.general_log;                             | 查询日志信息                         | select * from mysql.general_log;             |
| alter table 表名 drop foreign key 外键的key(别名);           | 移除外键约束                         | alter table app drop foreign key app_ibfk_1; |
|                                                              |                                      |                                              |
|                                                              |                                      |                                              |
|                                                              |                                      |                                              |
|                                                              |                                      |                                              |
|                                                              |                                      |                                              |
|                                                              |                                      |                                              |
|                                                              |                                      |                                              |
|                                                              |                                      |                                              |
|                                                              |                                      |                                              |
|                                                              |                                      |                                              |
|                                                              |                                      |                                              |
|                                                              |                                      |                                              |
|                                                              |                                      |                                              |
|                                                              |                                      |                                              |
|                                                              |                                      |                                              |
|                                                              |                                      |                                              |
|                                                              |                                      |                                              |
|                                                              |                                      |                                              |

