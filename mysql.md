
# 1. mysql 根据 日期 查询 数据

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



```sql
			SELECT
				id,
				basic_data_id,
				inspection_date,
				inspection_type,
				inspection_kp_s,
				inspection_kp_e,
				length_accurancy,
				depth_accurancy,
				confidence_level 
			FROM
				ili_history 
			WHERE
				(
				 inspection_date
				BETWEEN 
					STR_TO_DATE('2021-07-09', '%Y-%m-%d %H:%i:%s')
				AND
					STR_TO_DATE('2021-07-10', '%Y-%m-%d %H:%i:%s')	
				)
```



数据库字段是 datetime, 后台传入的是string: 

```sql
SELECT
	id,
	basic_data_id,
	inspection_date,
	inspection_type,
	inspection_kp_s,
	inspection_kp_e,
	length_accurancy,
	depth_accurancy,
	confidence_level 
FROM
	ili_history
WHERE
	( DATE_FORMAT(inspection_date,'%Y-%m-%d') = "2021-07-09" )
```



mysql 的日期问题

java 类型 util.date

mysql-8 类型 datetime

mybatis 如何处理?



## 日期函数

```sql
SELECT  
  YEAR("2022-04-11 15:44:28") AS '年',
  MONTH("2022-04-11 15:44:28") AS '月',
  DAY("2022-04-11 15:44:28") AS '日',
  HOUR("2022-04-11 15:44:28") AS '小时',
  MINUTE("2022-04-11 15:44:28") AS '分钟',
  SECOND("2022-04-11 15:44:28") AS '秒',
  DAYNAME("2022-04-11 15:44:28") AS '星期几',
  MONTHNAME("2022-04-11 15:44:28") AS '几月';
  
DELETE FROM pipe where
YEAR(create_time)="2023"
and
MONTH(create_time)="1"
and
DAY(create_time)="13"; 
```









# 2.  mysql uuid

```sql
UPDATE wordbook set id=REPLACE( UUID(),"-","") WHERE id = "123"
```

# 3. 查看MySQL版本号

```sql
select version();	
```

# 4.  把从一个表中查询的数据 直接插入到第二张表中 两张表的字段不一致

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



# 5. sql注入

防护
归纳一下，主要有以下几点：
1.永远不要信任用户的输入。对用户的输入进行校验，可以通过正则表达式，或限制长度；对单引号和
双"-"进行转换等。
2.永远不要使用动态拼装sql，可以使用参数化的sql或者直接使用存储过程进行数据查询存取。
3.永远不要使用管理员权限的数据库连接，为每个应用使用单独的权限有限的数据库连接。
4.不要把机密信息直接存放，加密或者hash掉密码和敏感的信息。
5.应用的异常信息应该给出尽可能少的提示，最好使用自定义的错误信息对原始错误信息进行包装
6.sql注入的检测方法一般采取辅助软件或网站平台来检测，软件一般采用sql注入检测工具jsky，网站平台就有亿思网站安全平台检测工具。MDCSOFT SCAN等。采用MDCSOFT-IPS可以有效的防御SQL注入，XSS攻击等。

# 6. mybatis xml中大于号,小于号问题

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

# 7.mysql 时区问题

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



# 8. mysql 8.0 修改root 密码,前提是进入了mysql,忘记了密码这个问题,还待解决

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





# 9. mysql 的 group_cancat(字段) 方法查询一对多 非常好用, 列转行

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



# 10. mysql 日志

	1. 手动开启日志 set global general_log = "on"
	2. 检查是否开启成功 show variables like "general_log%"
	3. 



# 11. 数据类型的长度

| 类型       | 长度               | comment              |
| :--------- | :----------------- | :------------------- |
| char       | 1-255 字符         | 定长                 |
| varchar    | 1-255              | 变长                 |
| tinyblob   | 1-255              | binary large objects |
| tinytext   | 2^8-1(255)         |                      |
| blob       | 2^16-1(65535) 字符 |                      |
| text       | 2^16-1             |                      |
| mediumblob | 2^24-1(16777215)   |                      |
| mediumtext | 2^24-1             |                      |
| longblob   | 2^32-1             |                      |
| longtext   | 2^32-1             |                      |

​		

注意是字符, 而不是字节, 比如 varchar(255), 如果使用 `utf8mb4` 字符集和 `utf8mb4_0900_ai_ci` 排序规则，一个 `VARCHAR(255)` 字段可以存储的最大字符数是 **255**，而不是 85。

`utf8mb4` 字符集下，每个字符最多占用 4 个字节，而 `VARCHAR(255)` 表示 255 个字符，因此总的最大字节数是 `255 * 4 = 1020` 字节。因此，`utf8mb4` 字符集下 `utf8mb4_0900_ai_ci` 排序规则的 `VARCHAR(255)` 可以存储最多 255 个字符。

# 12. distinct 与 group by

distinct关键字必须位于所有字段的前面，且作用于其后所有字段



# 13. 普通索引, unique索引(唯一索引), 主键索引

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



注: 主键上的索引, 与 创建的 索引 不一样, 



# 14. 视图, 视图的查询, 修改 等与 普通表基本类似

- 创建视图

create view 视图名 as select * from 表名;



| description  | command                                   | example                      |
| ------------ | ----------------------------------------- | ---------------------------- |
| 创建视图     | create view 视图名 as select * from 表名; |                              |
| 查询视图结构 | DESC 视图名 或者 SHOW FIELDS FROM 视图名  |                              |
| 查询视图     | SELECT * FROM 视图名;                     | SELECT * FROM sp_basic_view; |



# 15. 查出时间最大的一条记录, 有问题

```sql
    select * from 
    (select * from liushui order by jiao_yi_shi_jian desc) a 
    group by a.card_no;
```

解释: 先按时间排序, 再group by 分组, 这样会把 分组后的第一条数组拿出来,

```sql
	select * from liushui order by jiao_yi_shi_jian desc limit 0,1;
```



# 16. 主键自增归0

空表时: 删除 主键 再添加;



# 17. like用法

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





# 18. limit

limit m,n : 从第m+1条开始,取n条数据;

limit n : 是 limit 0,n 的缩写;

# 19. group by 与 临时表

1. 如果GROUP BY 的列没有索引,产生临时表. 

　　2. 如果GROUP BY时,SELECT的列不止GROUP BY列一个,并且GROUP BY的列不是主键 ,产生临时表. 
　　3. 如果GROUP BY的列有索引,ORDER BY的列没索引.产生临时表. 
　　4. 如果GROUP BY的列和ORDER BY的列不一样,即使都有索引也会产生临时表. 
　　5. 如果GROUP BY或ORDER BY的列不是来自JOIN语句第一个表.会产生临时表. 
　　6. 如果DISTINCT 和 ORDER BY的列没有索引,产生临时表.



# 20. sql语句的执行顺序

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



# 21. mysql 中 datetime 与 timestamp

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



# 22. mysql 的存储过程

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



创建 存储过程 例子2:  插入表数据 300w条

```sql
DELIMITER ;;
CREATE PROCEDURE batch_insert_log()
BEGIN
  DECLARE i INT DEFAULT 1;
  DECLARE userId INT DEFAULT 3000000;
 set @execSql = 'INSERT INTO `wg`.`user_operation_log`(`user_id`, `ip`, `op_data`, `attr1`, `attr2`, `attr3`, `attr4`, `attr5`, `attr6`, `attr7`, `attr8`, `attr9`, `attr10`, `attr11`, `attr12`) VALUES';
 set @execData = '';
  WHILE i<=3000000 DO
   set @attr = "'测试很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长的属性'";
  set @execData = concat(@execData, "(", userId + i, ", '10.0.69.175', '用户登录操作'", ",", @attr, ",", @attr, ",", @attr, ",", @attr, ",", @attr, ",", @attr, ",", @attr, ",", @attr, ",", @attr, ",", @attr, ",", @attr, ",", @attr, ")");
  if i % 1000 = 0
  then
     set @stmtSql = concat(@execSql, @execData,";");
    prepare stmt from @stmtSql;
    execute stmt;
    DEALLOCATE prepare stmt;
    commit;
    set @execData = "";
   else
     set @execData = concat(@execData, ",");
   end if;
  SET i=i+1;
  END WHILE;

END;;
DELIMITER ;
```



## 2. 将数据库wg 中 所有 数据类型为 decimal(10,2) 的列 改为 decimal(10,4)

创建存储过程

```sql
DELIMITER $$
CREATE PROCEDURE `update_precision`()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE COLUMN_NAME VARCHAR(255);
    DECLARE TABLE_NAME VARCHAR(255);
    DECLARE cols_cursor CURSOR FOR 
        SELECT COLUMN_NAME, TABLE_NAME 
        FROM INFORMATION_SCHEMA.COLUMNS 
        WHERE TABLE_SCHEMA='wg' 
          AND DATA_TYPE='decimal' AND NUMERIC_PRECISION=10 AND NUMERIC_SCALE=2;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
	
    OPEN cols_cursor;

    read_cols_loop: LOOP
        FETCH cols_cursor INTO COLUMN_NAME, TABLE_NAME;
        IF done THEN
            LEAVE read_cols_loop;
        END IF;
        SELECT CONCAT('ALTER TABLE `', TABLE_NAME, '` MODIFY COLUMN `', COLUMN_NAME, '` decimal(10,4);');
    END LOOP;

    CLOSE cols_cursor;
END$$
DELIMITER ;
```

执行存储过程

```
call update_precision();
```



20230904: 不知是版本问题, 还是怎么的, 不太管用了





# 23. 日期字段有时分秒, 我只查 年月日

```sql
		SELECT
			count(*)
		FROM
			`bank_flow` 
		WHERE
			DATE_FORMAT(transaction_date,'%Y-%m-%d') ='2019-11-19';
```

也可以直接使用函数 date();

# 24. ` 符号

mysql 的转义符,只要你不在表名，列名中的使用**保留字或中文**，就不需要转义。

# 25. 修改整列的值

```sql
UPDATE bank_flow set id= replace(uuid(),"-","");
```



# 26. mysql 把一列的值 挪到 另一列

```sql
update bank_flow set b=a;
```



# 27. 使用navicat 链接mysql 使用 replace uuid 会出现uuid 重复





# 28. sql语句 形式 导入文件 示例:

```sql
LOAD DATA LOCAL INFILE 'C:\\Users\\LPH\\Desktop\\ml-1m\\ml-1m\\movies.dat'

INTO TABLE movies

FIELDS TERMINATED BY '::'

LINES TERMINATED BY '\n'

(id, title, type);
```



# 29. sql语句中的 !=  与 <>

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





# 30 insert or update

```sql
REPLACE into user_role VALUES ('1','cad5v165sdv616wd5v','c1a6s1c6as16c51as');
```





# 31. mysql.help_topic 以字符拆分,一行转多行

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





# 32. substring_index(str,delimiter,count);  以正则 分割字符串





# 33. mysql各种命令

```sql
show create table bs_user; ---查看表的创建语句
show variable;  --- 查看配置
desc t_your_table; --- 查看表的设计
show binary logs; --- 查看日志
select version(); --- 查数据库版本
```



# 34. 千万级表的优化

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





查询优化 实例 1: 

1. 使用子查询方式, 效率会高很多, 在id字段上创建索引, 比没有索引快几十倍, 没有索引用时2.6秒左右, 有索引 用时0.17秒左右

```sql
SELECT * FROM `user_operation_log` WHERE id >= (SELECT id FROM `user_operation_log` where id = 1000000) LIMIT 10; // id是数字,且自增或雪花, 可以比较大小
SELECT * FROM `user_operation_log` WHERE id IN (SELECT t.id FROM (SELECT id FROM `user_operation_log` LIMIT 1000000, 10) AS t); // id 不必自增
```







# 35. insert into 表  select ---谨慎使用, 会锁定表



查询条件导致全表扫描,避免,在条件上加索引,就不会扫描全表而锁定表,只会锁定符合条件的记录;





总结:
使用insert into tableA select * from tableB语句时，一定要确保tableB后面的where，order或者其他条件，都需要有对应的索引，来避免出现tableB全部记录被锁定的情况



# 36. between

表示>= and <= ;

# 37. 函数整理



| <span style="white-space: nowrap;">函数&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;</span> | <span style="white-space: nowrap;">解释&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;</span> | <span style="white-space: nowrap;">例子&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;</span> |
| ------------------------------------------------------------ | ------------------------------------------------------------ | ------------------------------------------------------------ |
| between                                                      | 表示 >= and <= ;                                             | BETWEEN 1 and 60; -- >=1 <=60                                |
| date(field)                                                  | 函数返回日期或日期/时间表达式的日期部分, 没有时间部分, 只有日期部分; | select date(create_time) from traffic_restriction; -- 2008-08-08 |
| date_format(date, format)                                    | 日期转字符串                                                 | select date_format(create_time, '%Y-%m-%d %H:%i:%s') from traffic_restriction;  -- 2008-08-08 22:23:01 |
| str_to_date(str, format)                                     | 转换成日期格式,                                              | select str_to_date('08/09/2008', '%m/%d/%Y'); -- 2008-08-09<br>select str_to_date('08.09.2008 08:09:30', '%m.%d.%Y %h:%i:%s'); -- 2008-08-09 08:09:30 |
| concat(str1, str2, ...)                                      | 拼接字符串                                                   | CONCAT('%','我','%')                                         |
| now()                                                        | now() 在执行开始时值就得到了                                 | select now(), sleep(3), now();                               |
| sysydate()                                                   | sysdate() 在函数执行时动态得到值                             | select sysdate(), sleep(3), sysdate();                       |
| current_date()                                               | 当前 年月日                                                  |                                                              |
| current_time()<br />curtime()                                | 当前 时分秒                                                  |                                                              |
| current_timestamp()                                          | 当前 年月日时分秒                                            |                                                              |
| time_format(date, format)                                    |                                                              | select time_format('2008-08-08 22:23:01', '%Y-%m-%d %H:%i:%s');  -- 0000-00-00 22:23:01 |
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
| strcmp(expr1, expr2)                                         | 如果字符串相同，STRCMP()返回0，如果第一参数根据当前的次序小于第二个，返回-1，否则返回1。 | SELECT STRCMP('test','test'), STRCMP('a','b'), STRCMP('d','c'); -- 0	-1	1 |
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
| cast(expression AS dataType)                                 | 转换数据类型                                                 | cast('12' as int)                                            |
| find_in_set(str, strList)                                    | 查找字符串所在下标,从1开始,  没找到输出0, <br />见下面详情   |                                                              |
| case when then end                                           | 见下面详情                                                   |                                                              |
| select database()                                            | 查询当前数据库名称;                                          |                                                              |









---



**find_in_set(str, strList)**

str: 要查询的字符串

field: 查询的字段

>  SELECT FIND_IN_SET('b', 'a,b,c,d');
>
> 输出 2, 可见是
>
> select FIND_IN_SET('6', '1'); 输出 0



下面2个sql 等效; 虽然 171,152,157 这些都是content_category_id 且都存在, 但是, 一旦查找到一个, 就返回了

```sql
    SELECT
        * 
    FROM
        cms_content 
    WHERE
        FIND_IN_SET( content_category_id, '171,
        152,
        157,
        172,
        163' )
	
	SELECT * FROM cms_content WHERE content_category_id=171
```



可以和in() 函数做个比较, in 是 在in里面的所有都会输出, 而 find_in_set 只会输出 满足条件的第一个

----------------------------------------------------------------

**case when then end 和 if 和 ifnull 函数 **

```sql
---------- if --------------
SELECT  b.*, (if( b.jydszkh='0216014040000489', 'yes', 'no') ) are_node FROM new_bankFlow b WHERE b.jyzh IN ( '0302016501300082666' ,'50000000000082623968' ) AND b.jyje 		  BETWEEN 10000 AND 20000 AND b.jyrq BETWEEN '2016-08-04' AND '2016-08-20' 

---------- ifnull --------------
SELECT  b.*, ( IFNULL(b.dshm,'kong') ) are_node FROM new_bankFlow b WHERE b.jyzh IN ( '0302016501300082666' ,'50000000000082623968' ) AND b.jyje 		  BETWEEN 10000 AND 20000 AND b.jyrq BETWEEN '2016-08-04' AND '2016-08-20' 

---------- case when then end  --------------
SELECT  b.*, ( case b.jydszkh when  '0216014040000489' then 'feikong' else '' end) are_node FROM new_bankFlow b WHERE b.jyzh IN ( '0302016501300082666' ,'50000000000082623968' ) AND b.jyje 		  BETWEEN 10000 AND 20000 AND b.jyrq BETWEEN '2016-08-04' AND '2016-08-20' 
```



**case 的空值判断 必须用这种**

```sql
SELECT  b.*, ( case when b.ip= '' then 'kong' when  b.ip is NULL then 'kong'  end) are_node FROM new_bankFlow b WHERE b.jyzh IN ( '0302016501300082666' ,'50000000000082623968' ) AND b.jyje 		  BETWEEN 10000 AND 20000 AND b.jyrq BETWEEN '2016-08-04' AND '2016-08-20' 

------------------------------------
	select bf.*, 
	( case  
		when bf.jydszkh='0216014040000489' then 'feikong'
		when bf.jydszkh is NULL then 'kong' 
		when bf.jydszkh='' then 'kong' 
		else  'qita'
		end
	) are_node
   from new_bankFlow bf 
```









# 38. 各种命令



| command                                                      | <span style="white-space: nowrap;">description&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;</span> | example                                                      |
| ------------------------------------------------------------ | ------------------------------------------------------------ | ------------------------------------------------------------ |
| show engines;                                                | 查看数据库 的 引擎                                           | show engines;                                                |
| desc table_name;                                             | 查看表结构                                                   | desc student;                                                |
| show create table table_name;                                | 显示表的创建语句, 可查看外键约束                             | show create table student;                                   |
| show table status like 'table_name';                         | 显示表的当前状态值                                           | show table status like 'liushui';                            |
| alter table table_name engine=MyISAM; （或 InnoDB 等其它引擎） | 修改表的数据库引擎                                           | alter table liushui engine=InnoDB;                           |
| show variables like '%general_log%';                         | 查看日志记录是否开启, 和日志文件位置                         | show variables like '%general_log%';                         |
| set global general_log = on;                                 | 开启查询日志                                                 | set global general_log = on;                                 |
| show variables like 'log_output';                            | 查看日志 输出类型                                            | show variables like 'log_output';                            |
| set global log_output='table';                               | 设置日志输出类型为table                                      | set global log_output='table';                               |
| select * from mysql.general_log;                             | 查询日志信息                                                 | select * from mysql.general_log;                             |
| alter table 表名 drop foreign key 外键的key(别名);           | 移除外键约束                                                 | alter table app drop foreign key app_ibfk_1;                 |
| alter table 表名 add constraint FK_ID foreign key(你的外键字段名) REFERENCES 外表表名(对应的表的主键字段名); | 新增外键约束                                                 | alter table tb_active add constraint FK_ID foreign key(user_id) REFERENCES tb_user(id) |
| select version();                                            | 查询版本                                                     |                                                              |
| show processlist;                                            | 查看mysql 进程正在干嘛                                       |                                                              |
| show variables like 'lower%';                                | 查看是否区分大小写, {on,1}: 不区分, {off,0}: 区分, windows默认不区分, linux默认区分 |                                                              |
| alter table 表名 modify column 字段名 类型                   | 修改字段数据类型                                             |                                                              |
| SELECT<br/>	table_name <br/>FROM<br/>	information_schema.TABLES <br/>WHERE<br/>	table_schema = 'v7098_pipeline_integrity_assessment_system' <br/>	AND table_type = 'base table'; | 查询数据库中所有表名;<br/>查询表名                           |                                                              |
| SELECT<br/>*, COLUMN_NAME<br/>FROM<br/>	information_schema.COLUMNS <br/>WHERE<br/>	table_schema = 'v7098_pipeline_integrity_assessment_system' <br/>	AND table_name = 'construction_data'; | 查询列名<br />查询一个表中的所有列名                         |                                                              |
| SELECT<br/>	TABLE_NAME,<br/>	COLUMN_NAME,<br/>	CONSTRAINT_NAME,<br/>	REFERENCED_TABLE_NAME,<br/>	REFERENCED_COLUMN_NAME <br/>FROM<br/>INFORMATION_SCHEMA.KEY_COLUMN_USAGE <br/>WHERE<br/>	table_name = 'basic_data';<br/> | 查询外键, 一个表的主键是那些表的外键                         | mysql和oracle一样也是有数据字典表的，是存在单独的一个库叫INFORMATION_SCHEMA，要查看某张表的外键要从字典表中查找 |
| SELECT<br/>	* <br/>FROM<br/>INFORMATION_SCHEMA.KEY_COLUMN_USAGE <br/>WHERE<br/>	referenced_table_name = 'basic_data'; | 查询 所有 以a表的id 为外键的表<br />查询一个表的主键是哪些表的外键 |                                                              |
| SELECT @@foreign_key_checks;                                 | 查询外键关联情况, 1为有外键关联                              |                                                              |
| SET FOREIGN_KEY_CHECKS = 0;                                  | 禁用外键关联                                                 | 删除有外键约束的表时,可以用                                  |
| SET FOREIGN_KEY_CHECKS = 1;                                  | 开启外键关联                                                 |                                                              |
| SELECT * from INFORMATION_SCHEMA.TABLE_CONSTRAINTS;          | 查询所有数据库的约束情况                                     |                                                              |
| select @@transaction_isolation;<br />select @@tx_isolation;  | 查询事务级别(看版本使用不同的)                               | show variables like '%tx_isolation%';                        |
| show global varibales like 'port'                            | 查询端口号                                                   |                                                              |
| select database()                                            | 查询当前数据库名称                                           |                                                              |
| SELECT User FROM mysql.db WHERE Db = 'wg';                   | 查询数据库名为wg 的 所有用户                                 |                                                              |
| REVOKE ALTER ON database.table FROM 'user'@'host';  FLUSH PRIVILEGES; | 关闭用户 修改数据表数据类型的 权限                           | REVOKE ALTER ON wg.* FROM 'test001'@'localhost'; FLUSH PRIVILEGES; |
| GRANT ALTER ON database.table TO 'user'@'host';  FLUSH PRIVILEGES; | 开启用户 修改数据表数据类型的 权限                           |                                                              |
| REVOKE ALTER, CREATE, DROP ON wg.* FROM 'test001'@'%';       | 在数据库wg 中, 关闭用户 test001对所有表的更改数据表结构的权限 |                                                              |
| GRANT ALTER, CREATE, DROP ON wg.* TO 'test001'@'%';          | 在数据库wg 中, 赋予用户 test001对所有表的更改数据表结构的权限 |                                                              |
| FLUSH PRIVILEGES;                                            | 刷新授权使其生效：                                           |                                                              |
| CREATE USER 'user1'@'localhost' IDENTIFIED BY 'password1'; GRANT ALL PRIVILEGES ON wg.* TO 'user1'@'localhost'; FLUSH PRIVILEGES; | 为数据库wg, 添加用户,                                        | CREATE USER 'test001' @'localhost' IDENTIFIED BY 'test001'; GRANT ALL PRIVILEGES ON wg.* TO 'test001' @'localhost'; FLUSH PRIVILEGES; |
| DROP USER '用户名'@'主机名/IP';  FLUSH PRIVILEGES;           | 为数据库wg, 删除某个用户                                     |                                                              |










# 39. mysql 的boolean 类型



tinyint  1 -> true,  0 -> false 



tinyint 型的字段如果设置为UNSIGNED类型，只能存储从0到255的整数,不能用来储存负数。

tinyint 型的字段如果不设置UNSIGNED类型,存储-128到127的整数。

1个tinyint型数据只占用一个字节;一个INT型数据占用四个字节。

这看起来似乎差别不大，但是在比较大的表中，字节数的增长是很快的。



**tinyint(1)与tinyint(2)的区别**

```
CREATE TABLE `test` (                                  
          `id` int(11) NOT NULL AUTO_INCREMENT,                
          `str` varchar(255) NOT NULL,                                     
          `state` tinyint(1) unsigned zerofill DEFAULT NULL,   
          `state2` tinyint(2) unsigned zerofill DEFAULT NULL,  
          `state3` tinyint(3) unsigned zerofill DEFAULT NULL,  
          `state4` tinyint(4) unsigned zerofill DEFAULT NULL,  
          PRIMARY KEY (`id`)                                   
        ) ENGINE=MyISAM AUTO_INCREMENT=6 DEFAULT CHARSET=utf8  
 
insert into test (str,state,state2,state3,state4) values('csdn',4,4,4,4);
select * from test;
```

| id   | str  | state | state2 | state3 | state4 |
| ---- | ---- | ----- | ------ | ------ | ------ |
| 1    | csdn | 4     | 04     | 004    | 0004   |



# 40. mysql触发器, 存储过程, 函数

触发器

```sql
DELIMITER $$
CREATE
    /*[DEFINER = { user | CURRENT_USER }]*/
    TRIGGER `ssm`.`id_trigger` -- 触发器名称
    BEFORE INSERT             -- 触发器被触发的时机
    ON `ssm`.`traveller`       -- 触发器所作用的表名称
    FOR EACH ROW BEGIN
		SET new.id=REPLACE(UUID(),'-',''); -- 触发器执行的逻辑
    END$$

DELIMITER ;
```



函数

```sql
CREATE DEFINER=`root`@`localhost` PROCEDURE `batch_insert_log`()
BEGIN
  DECLARE i INT DEFAULT 1;
  DECLARE userId INT DEFAULT 3000000;
 set @execSql = 'INSERT INTO `wg`.`user_operation_log`(`user_id`, `ip`, `op_data`, `attr1`, `attr2`, `attr3`, `attr4`, `attr5`, `attr6`, `attr7`, `attr8`, `attr9`, `attr10`, `attr11`, `attr12`) VALUES';
 set @execData = '';
  WHILE i<=3000000 DO
   set @attr = "'测试很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长的属性'";
  set @execData = concat(@execData, "(", userId + i, ", '10.0.69.175', '用户登录操作'", ",", @attr, ",", @attr, ",", @attr, ",", @attr, ",", @attr, ",", @attr, ",", @attr, ",", @attr, ",", @attr, ",", @attr, ",", @attr, ",", @attr, ")");
  if i % 1000 = 0
  then
     set @stmtSql = concat(@execSql, @execData,";");
    prepare stmt from @stmtSql;
    execute stmt;
    DEALLOCATE prepare stmt;
    commit;
    set @execData = "";
   else
     set @execData = concat(@execData, ",");
   end if;
  SET i=i+1;
  END WHILE;

END
```





# 41. 字符串列的排序问题 不仅是排序, 在between时也有这个问题

- 字符串的排序

  对于字符串的排序原理是按位（每个字符）进行比较的，并且是按照每个字符的ASCII码值，包括数字（数字的ASCII值等于该数字的值）

  一般会根据字符串的首字母：大些字母>小写字母>[特殊字符](https://www.baidu.com/s?wd=特殊字符&tn=44039180_cpr&fenlei=mv6quAkxTZn0IZRqIHckPjm4nH00T1dWmhN-mHwBnycLuWF9mymd0ZwV5Hcvrjm3rH6sPfKWUMw85HfYnjn4nH6sgvPsT6KdThsqpZwYTjCEQLGCpyw9Uz4Bmy-bIi4WUvYETgN-TLwGUv3EnHmsPjnzn1bLn1bvnW0YP1n3Ps)>数字。如果首位相同继续排列第二位，直到不同的位。

  比如:

  select id FROM new_bankFlow ORDER BY id asc limit 100;

  结果为:

  1
  10
  100
  1000
  10000
  100000
  1000000
  1000001
  1000002
  1000003
  1000004
  1000005
  1000006
  1000007
  1000008
  1000009
  100001
  1000010
  1000011
  1000012
  1000013
  1000014
  1000015
  1000016
  1000017
  1000018
  1000019
  100002
  1000020
  1000021

  观察  1000009   100001 两个值 可看出 在从左数 第6位 1 确实比 0 大, 

  **结论: 字符串的比较是从左首个字符 开始依次比较的**

  > select id FROM new_bankFlow ORDER BY (id+0) asc limit 100;
  >
  > 1
  > 2
  > 3
  > 4
  > 5
  > 6
  > 7
  > 8
  > 9
  > 10
  > 11
  > 12
  > 13
  > 14
  > 15
  > 16
  > 17
  > 18
  > 19
  > 20

(id+0) 把 字符 转成了数字, 但是 只对 是纯数字的字段有用, 如果id 里面有字符 那id+0 就不管用了

```java
AND (b.jyje+0) BETWEEN ${minMoney} AND ${maxMoney}
```







# 42. 主要事项

 ## 1. 关于排序, 字符串形式的数字

当数据库字段 数据类型是 varchar, 但是, 实际上都是些数字的时候, 使用order by 容易产生错误, 因为 varchar 的排序 和 数字 排序 规则 不一样

这时候应该 +0 转成 数字

> select * from  student order by (age+0);



## 2. 数据库设计规约

1. 能用int 不用varchar

2. 默认值最好不要为null,

3. 不适用 float, double 一律使用 decimal

4. 【强制】表达是与否概念的字段，必须使用 is_xxx 的方式命名，数据类型是 unsigned tinyint
   （1 表示是，0 表示否）

   注意：POJO 类中的任何布尔类型的变量，都不要加 is 前缀，所以，需要在设置从 is_xxx 到
   Xxx 的映射关系。数据库表示是与否的值，使用 tinyint 类型，坚持 is_xxx 的命名方式是为了明确其取值含
   义与取值范围。
   正例：表达逻辑删除的字段名 is_deleted，1 表示删除，0 表示未删除

5. 【强制】表名、字段名必须使用小写字母或数字，禁止出现数字开头，禁止两个下划线中间只
   出现数字。数据库字段名的修改代价很大，因为无法进行预发布，所以字段名称需要慎重考虑。
   说明：MySQL 在 Windows 下不区分大小写，但在 Linux 下默认是区分大小写。因此，数据库名、表名、
   字段名，都不允许出现任何大写字母，避免节外生枝。
   正例：aliyun_admin，rdc_config，level3_name
   反例：AliyunAdmin，rdcConfig，level_3_name

6. 【强制】表名不使用复数名词。

7. 【强制】禁用保留字，如 desc、range、match、delayed 等，请参考 MySQL 官方保留字

8. 【强制】主键索引名为 pk_字段名；唯一索引名为 uk_字段名；普通索引名则为 idx_字段名。
   说明：pk_ 即 primary key；uk_ 即 unique key；idx_ 即 index 的简称。

9. 【推荐】单表行数超过 500 万行或者单表容量超过 2GB，才推荐进行分库分表。

10. 

## 3. 索引规约

1. 【强制】业务上具有唯一特性的字段，即使是组合字段，也必须建成唯一索引。

   说明：不要以为唯一索引影响了 insert 速度，这个速度损耗可以忽略，但提高查找速度是明显的；另外，
   即使在应用层做了非常完善的校验控制，只要没有唯一索引，根据墨菲定律，必然有脏数据产生。

2. 【强制】超过三个表禁止 join。需要 join 的字段，数据类型保持绝对一致；多表关联查询时，
   保证被关联的字段需要有索引。

   说明：即使双表 join 也要注意表索引、SQL 性能。

3. 【强制】在 varchar 字段上建立索引时，必须指定索引长度，没必要对全字段建立索引，根据
   实际文本区分度决定索引长度。
   说明：索引的长度与区分度是一对矛盾体，一般对字符串类型数据，长度为 20 的索引，区分度会高达 90%
   以上，可以使用 count(distinct left(列名, 索引长度))/count(*)的区分度来确定。

4. 【强制】页面搜索严禁左模糊或者全模糊，如果需要请走搜索引擎来解决。
   说明：索引文件具有 B-Tree 的最左前缀匹配特性，如果左边的值未确定，那么无法使用此索引。

5. 【推荐】如果有 order by 的场景，请注意利用索引的有序性。order by 最后的字段是组合索
   引的一部分，并且放在索引组合顺序的最后，避免出现 file_sort 的情况，影响查询性能。
   正例：where a=? and b=? order by c; 索引：a_b_c
   反例：索引如果存在范围查询，那么索引有序性无法利用，如：WHERE a>10 ORDER BY b; 索引 a_b 无
   法排序。

## 4. sql语句 规约

1. 【强制】不得使用外键与级联，一切外键概念必须在应用层解决。
   说明：（概念解释）学生表中的 student_id 是主键，那么成绩表中的 student_id 则为外键。如果更新学
   生表中的 student_id，同时触发成绩表中的 student_id 更新，即为级联更新。外键与级联更新适用于单机
   低并发，不适合分布式、高并发集群；级联更新是强阻塞，存在数据库更新风暴的风险；外键影响数据库
   的插入速度。
2. 【强制】禁止使用存储过程，存储过程难以调试和扩展，更没有移植性。
3. 【强制】数据订正（特别是删除或修改记录操作）时，要先 select，避免出现误删除，确认无
   误才能执行更新语句。

# 43. sql语句

 ## 1. sql 语句



| sql语句                                                      | description                                                  | example                                                      |
| ------------------------------------------------------------ | ------------------------------------------------------------ | ------------------------------------------------------------ |
| alter table TABLE_NAME add column NEW_COLUMN_NAME varchar(255) not null default ''  COMMENT  '裂纹距管壁最小距离[mm]'  after  某个字段; | 添加列                                                       |                                                              |
| alter table 表名 modify column 字段名 类型                   | 修改字段数据类型                                             |                                                              |
| alter table 表名 rename to 新表名;                           | 修改表名                                                     |                                                              |
| ALTER TABLE 表名 CHANGE 列名 新列名 列类型                   | 修改列名                                                     |                                                              |
| ALTER TABLE table_name COMMENT 'new_table_comment';          | 修改表注释                                                   |                                                              |
| ALTER TABLE table_name MODIFY COLUMN column_name COMMENT 'new comment'; | 只修改列的注释                                               |                                                              |
| update bank_flow set b=a;                                    | 把一列的值 挪到 另一列                                       |                                                              |
| UPDATE bank_flow set id= replace(uuid(),"-","");             | 修改整列的值                                                 |                                                              |
| delete from api5792007_detail where corrosion_assessment_history_id = ? | 删除语句                                                     |                                                              |
| DROP INDEX 约束名 ON 表名;                                   | 移除约束, 索引                                               | DROP INDEX table_name ON common_file_meta;                   |
| ALTER TABLE 表名 ADD CONSTRAINT 约束名 UNIQUE(列名);<br />ALTER TABLE 表名 ADD UNIQUE (列名1, 列名2); | 添加唯一约束                                                 | ALTER TABLE common_dict ADD CONSTRAINT yueshumng UNIQUE(history_id); |
| alter table 表名 drop foreign key 外键名                     | 移除外键约束                                                 |                                                              |
| DROP TABLE if exists 表名;                                   | 删除表                                                       | DROP TABLE if exists  \`detail_water_dept\`;                 |
| ALTER TABLE  表名  drop COLUMN   列名;                       | 删除列                                                       | ALTER TABLE \`result_water_depth\` drop COLUMN  \`doc_path\`; |
| ALTER TABLE 表名 ADD CONSTRAINT 外键名称 FOREIGN KEY (外键字段) REFERENCES 主表名 (主表字段名) ON UPDATE CASCADE ON DELETE CASCADE; | 添加外键约束类型, 修改的话, 先drop掉, 再添加, 详见下方56     |                                                              |
|                                                              | 将数据库 wg中 所有 数据类型为 decimal(10,2) 的列 改为 decimal(10,4), 详见22 存储过程 |                                                              |
|                                                              |                                                              |                                                              |
|                                                              |                                                              |                                                              |
|                                                              |                                                              |                                                              |
|                                                              |                                                              |                                                              |
|                                                              |                                                              |                                                              |
|                                                              |                                                              |                                                              |
|                                                              |                                                              |                                                              |
|                                                              |                                                              |                                                              |



  ## 2.  将数据库 XXX 中 所有 数据类型为 decimal(10,2) 的列 改为 decimal(20,8),

拼接法, 经测试, 好用,

```sql
SELECT COLUMN_NAME,
	table_name,
	DATA_TYPE,
	COLUMN_COMMENT,
	CONCAT( 'ALTER TABLE ', table_name, ' MODIFY ', COLUMN_NAME,
	 'decimal(20,8) default null', 'comment "', COLUMN_COMMENT, '";' ) 
FROM
	information_schema.COLUMNS 
WHERE
	table_schema = 'v7127_process_pipe_inspection_and_assessment_system_xian' 
	AND DATA_TYPE = 'decimal' 
	AND NUMERIC_PRECISION = 10 
	AND NUMERIC_SCALE = 2;
```


# 44. delete 对比  truncate



truncate的效率高于delete

truncate 清除数据后不记录日志，不可以恢复数据，

delete清除数据后记录日志，可以恢复数据，相当于将表中所有记录一条一条删除



# 45. 各种优化语句

## 1. 查询是否存在

- select count(*) from tablename where a=? ;
- select 1 from tablename where a=? limit 1 ;

第二种更好

## 2. 查询优化

查询优化 实例 1: 

1. 使用子查询方式(存疑), 效率会高很多, 在id字段上创建索引, 比没有索引快几十倍, 没有索引用时2.6秒左右, 有索引 用时0.17秒左右

```sql
SELECT * FROM `user_operation_log` WHERE id >=1000000 LIMIT 10; # 实践后, 这种是最快的
SELECT * FROM `user_operation_log` WHERE id >= (SELECT id FROM `user_operation_log` where id = 1000000) LIMIT 10; // 并不快,  id是数字,且自增或雪花, 可以比较大小
SELECT * FROM `user_operation_log` WHERE id IN (SELECT t.id FROM (SELECT id FROM `user_operation_log` LIMIT 1000000, 10) AS t); // id 不必自增 最慢, 简直不能用
```





# 46. 关于用户权限的设计

分为这样几张表 

- 用户表
- 角色表
- 用户-角色 关联表
- 菜单表
- 菜单-角色关联表



1.  当加载页面时, 在 菜单-角色 关联表里 根据 角色id 查 关联的 菜单id
2.  在菜单表里, 根据菜单id 查 权限
3.  如果有此权限, 则通过



菜单表的设计: 

```sql
CREATE TABLE `sys_menu` (
  `menu_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `parent_id` bigint(20) DEFAULT NULL COMMENT '父菜单ID，一级菜单为0',
  `name` varchar(50) DEFAULT NULL COMMENT '菜单名称',
  `url` varchar(200) DEFAULT NULL COMMENT '菜单URL',
  `perms` varchar(500) DEFAULT NULL COMMENT '授权(多个用逗号分隔，如：user:list,user:create)',
  `type` int(11) DEFAULT NULL COMMENT '类型   0：目录   1：菜单   2：按钮',
  `icon` varchar(50) DEFAULT NULL COMMENT '菜单图标',
  `order_num` int(11) DEFAULT NULL COMMENT '排序',
  `create_time` datetime DEFAULT current_timestamp(),
  `update_time` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`menu_id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=1483265908959068163 DEFAULT CHARSET=utf8mb4 COMMENT='菜单管理';
```



# 47. ubuntu mysql8

## 1.  远程连接

1. 

```sql
use mysql;

--  将所有用户视为root  ---
update user set host='%' where user="root"; 

flush privileges;
grant all privileges on *.* to 'root'@'%' with grant option;
flush privileges;
```

​	

2. **mysql 配置文件**:  /etc/mysql/mysql.conf.d/mysqld.cnf

 修改这个文件 

修改为:  bind-address=0.0.0.1

3. 防火墙设置

   1. 开启防火墙

   ```shell
   # 关闭防火墙
   systemctl stop firewalld.service
   # 开启防火墙
   systemctl start firewalld.service
   # 查看防火墙状态
   firewall-cmd --state
   ```

   2. 开放 3306 端口

      ```shell
      sudo firewall-cmd --zone=public --add-port=3306/tcp --permanent  
      #  重新载入一下防火墙设置，使设置生效 
      sudo firewall-cmd --reload
      ```



# 48. 英语



 

|                  |              |      |
| ---------------- | ------------ | ---- |
| Case sensitive   | 区分大小写   |      |
| Case Insensitive | 不区分大小写 |      |
|                  |              |      |
|                  |              |      |
|                  |              |      |
|                  |              |      |
|                  |              |      |
|                  |              |      |
|                  |              |      |
|                  |              |      |
|                  |              |      |
|                  |              |      |
|                  |              |      |
|                  |              |      |
|                  |              |      |
|                  |              |      |
|                  |              |      |
|                  |              |      |
|                  |              |      |
|                  |              |      |
|                  |              |      |
|                  |              |      |
|                  |              |      |
|                  |              |      |
|                  |              |      |
|                  |              |      |
|                  |              |      |
|                  |              |      |
|                  |              |      |
|                  |              |      |
|                  |              |      |
|                  |              |      |
|                  |              |      |
|                  |              |      |
|                  |              |      |
|                  |              |      |
|                  |              |      |
|                  |              |      |
|                  |              |      |
|                  |              |      |



# 49. 一次查询一千条数据 和  每次查询 一条数据 查询一千次 哪个好? 



MySQL 中，每一次查询要经过如下过程：

1. SQL 接口（SQL Interface）接受用户输入的 SQL 命令，此时会建立 Socket 连接；
2. SQL 命令传递到解析器（Parser）的时候会被解析器验证和解析，将 SQL 语句分解成数据结构，并将这个结构传递到后续步骤，以后 SQL 语句的传递和处理就是基于这个结构；如果在分解构成中遇到错误，那么就说明这个 SQL 语句是不合理的。
3. SQL 语句在查询之前会使用查询优化器（Optimizer）对查询进行优化，构建查询计划；
4. 如果查询缓存有命中的查询结果，查询语句就可以直接去查询缓存中取数据。这一部分是通过查询缓存（Cache 和 Buffer）实现。
5. 利用存储引擎（Engine）和磁盘进行交互，从硬盘读取数据；
6. SQL 接口（SQL Interface）返回用户需要查询的结果。此时 SQL 执行已经完成，关闭 Socket 连接。





# 50. information_schema



​	

# 51. 数据类型 与 java 数据类型 对照



| jdbc       | jdbc范围                        | sql 类型         | java                                               |
| ---------- | ------------------------------- | ---------------- | -------------------------------------------------- |
| bit        | 0,1                             | bit              | Boolean                                            |
| tinyint    | 0--255                          | tinyint          | Byte Short                                         |
| smallint   | -32,768 -- 32,767               | smallint         | Short                                              |
| integer    | -2,147,483,648 -- 2,147,483,647 | integer          | Integer                                            |
| bigint     |                                 | bigint           | Long                                               |
| real       | 7位尾数的单精度浮点数           | real             | Float                                              |
| double     | 15位位数的双精度浮点数          | double precision | Double                                             |
| float      | 15位位数的双精度浮点数          | float            | Double                                             |
| decimal    |                                 | decimal          | Bigdecimal                                         |
| numberic   |                                 |                  | Bigdecimal                                         |
| date       |                                 | date             | Date                                               |
| time       |                                 | time             | Date                                               |
| timestamp  |                                 | timestamp        | Date                                               |
| binary     | 固定长度的小二进制              |                  | java.sql.ResultSet.getByte()        byte[]         |
| varbinary  | 长度可变的小二进制              |                  | java.sql.ResultSet.getByte()        byte[]         |
| longbinary | 长度可变的大二进制              |                  | java.sql.ResultSet.getBinaryStream()        byte[] |
|            |                                 |                  |                                                    |
|            |                                 |                  |                                                    |
|            |                                 |                  |                                                    |



# 52. 事务, 锁, for update

## 1. 第一种情况

1. 在我的 ubuntu 电脑上 执行: 

   ```sql
   begin;
   select * from goods where id =1 for update; # stock =100
   ```

   此时, id=1 的这条数据被锁住

2. 这时, 我在我的windows 电脑上执行

   ```sql
   update goods set stock =99 where id =1;
   ```

   这时, 这条语句并没有执行, 而是处于被挂起状态, 

3. 在我的 ubuntu 电脑上 执行: 

   ```sql
   commit;
   ```

4. 此时, 我的 windows 电脑 的那条update语句立马执行了, 

5. 查询结果, 

   ```sql
   select * from goods where id =1; # stock=99
   ```

   



## 2. 第二种情况

1. 在我的 ubuntu 电脑上 执行: 

   ```sql
   begin;
   select * from goods where id =1 for update;
   update goods set stock =98 where id =1;
   ```

2. 此时, 在我的windows 电脑上查询

   ```sql
   select * from goods where id=1;
   ```

3. 查询结果: stock 字段 没有变化

4. 在我的 ubuntu 电脑上 执行:

   ```sql
   commit;
   ```

5. 再在我的windows 电脑上查询

6. 此时, 可以看到 stock 字段有了变化



## 3. 第三种情况

1. 在我的 ubuntu 电脑上 执行: 

   ```sql
   begin;
   select * from goods where id =1;  # stock =99 
   ```

   不加 `for update`

2. 此时 在我的windows 电脑上 执行: 

   ```sql
   UPDATE goods SET stock=98 WHERE id=1;
   ```

3. 这条语句被执行了

4. 在我的windows 电脑上 查询

   ```
   select * from goods where id =1;  # stock =98
   ```

5. 在我的 ubuntu 电脑上 执行查询

   ```sql
   select * from goods where id =1;  # stock = 99 
   ```

   stock 仍然 等于 99

6. 在我的 ubuntu 电脑上执行

   ```sql
   commit;
   ```

7. 在我的 ubuntu 电脑上执行查询

   ```sql
   select * from goods where id =1;  # stock = 98
   ```

   可见 查询到了 windows 电脑上 更新后的数据



# 53. error

1. errno: 150 "Foreign key constraint is incorrectly formed"

   原因: 字段类型不一致, 我遇到的是, 无符号整数, 一个是无符号, 一个没有设置无符号

   解决: 都设置成无符号整数

2. Cannot add or update a child row: a foreign key constraint fails

   原因: 数据库里有值, 但不与其值对应, 

   解决: 修改数据库对应的值 



# 54. 删除数据库下所有表

```sql
SET @database_name = 'v7127_process_pipe_inspection_and_assessment_system_xian';
SELECT CONCAT('DROP TABLE IF EXISTS ', table_name, ';') AS query
FROM information_schema.tables
WHERE table_schema = @database_name;

################################################# linux 下用: 
SET @database_name = 'v7127_process_pipe_inspection_and_assessment_system_xian';
SELECT CONCAT('DROP TABLE IF EXISTS ', table_name, ';') AS query
FROM information_schema.tables
WHERE table_schema = @database_name
INTO OUTFILE '/tmp/drop_all_tables.sql';
SOURCE /tmp/drop_all_tables.sql;
```



这将生成一个名为`drop_all_tables.sql`的文件，其中包含所有DROP语句，然后将该文件导入到MySQL中，以依次执行这些语句。

```sql
SELECT CONCAT(
    'COMMENT ON COLUMN ', 
    table_name, 
    '.del_flag IS ''删除标识(0-未删除 1-已删除)'';'
) AS query
FROM information_schema.tables
WHERE table_schema = 'pias' AND table_type = 'BASE TABLE'
```



# 55. 数据库ID自增 有上限吗

## 1. 自定义自增主键

这里产生唯一键冲突的错误，说明执行第二条插入语句时，表increment_id_test的auto_increment的值和表中已有的主键id值 4294967295相同，也即表明：当auto_incement达到上限后，再次申请下一个id时，得到的值保持不变。

当把主键id的数据类型设置为int时，我们需要考虑表未来的数据量大小，毕竟 4294967295 并不是一个很大的值，对于一个每秒插入100行的业务，不到500天，就可以达到主键id上限。

其实在建表时，无论主键id是否设置为可自增，当id值大小超过这个上限后，都是会报错的。主键自增的情况下，报错信息为：唯一键冲突：

对于普通字段的情况，报错信息为：插入数据超出数据类型范围：



## 2. row_id

我们都知道，使用InnoDB存储引擎时，如果数据表没有设置主键，那么Innodb会给该表设置一个不可见，长度为6字节的默认主键 row_id。Innodb维护了一个全局的dict_sys.row_id值，这个值，被所有无主键的数据表共同使用，每个无主键的数据表，插入一行数据，都会是当前的dict_sys.row_id的值增加1.来源公众号：【码农编程进阶笔记】



总结: 

从上面 Innodb对row_id重复情况下的处理机制来看，在设计表时，最好还是使用自定义主键，而不要使用Innodb的默认主键，至少在自定义主键的场景下，当自增id达到上限时，插入数据，系统会提示报错信息，而不是覆盖数据，因为数据覆盖意味着数据丢失，影响的是数据可靠性，而插入失败产生的报错，影响是可用性。在数据业务中，可靠性通常是优先于可用性的。





# 56. 外键约束关系



|             |                                                              |
| ----------- | ------------------------------------------------------------ |
| no action   |                                                              |
| restrict    |                                                              |
| cascade     |                                                              |
| set null    | 父表删除数据时, 首先先检查此数据是否有对应外键, 如果有则设置子表此处为null |
| set default | 父表有变更时, 子表数据更改为默认值                           |



## 1. mysql 修改 外键关联的约束, 如 cascade,  sql语句是什么

```sql
-- 修改外键约束的 ON DELETE 选项为 CASCADE
ALTER TABLE 表名 DROP FOREIGN KEY 外键约束名;
ALTER TABLE 表名 ADD CONSTRAINT 外键约束名 FOREIGN KEY (外键列名) REFERENCES 主表名(主键列名) ON DELETE CASCADE;

-- 修改外键约束的 ON UPDATE 选项为 CASCADE
ALTER TABLE 表名 DROP FOREIGN KEY 外键约束名;
ALTER TABLE 表名 ADD CONSTRAINT 外键约束名 FOREIGN KEY (外键列名) REFERENCES 主表名(主键列名) ON UPDATE CASCADE;
```





# 57. 大小写

## 1. 字段的大小写

字段值的大小写由mysql的校对规则来控制。提到校对规则，就不得不说字符集。字符集是一套符号和编码，校对规则是在字符集内用于比较字符的一套规则  .
  一般而言，校对规则以其相关的字符集名开始，通常包括一个语言名，并且以_ci（大小写不敏感）、_cs（大小写敏感）或_bin（二元）结束 。比如 utf8字符集，utf8_general_ci,表示不区分大小写，这个是utf8字符集默认的校对规则；utf8_general_cs表示区分大小写，utf8_bin表示二进制比较，同样也区分大小写 。

## 2. 表名, 库名的大小写



```sql
show variables like 'lower%';
```

![](.\image\大小写-表名.png)



如图: 是不区分大小写的,  {off, 0} 是 区分大小写





# 58. 汉字为啥占3个字节



UTF-8编码是一种可变长度的字符编码方式，它设计的初衷是为了实现对ASCII字符的兼容并能够有效编码Unicode字符集中的所有字符。具体到为什么UTF-8编码中一个汉字通常占用3个字节，原因如下：

1. **兼容性与效率**：UTF-8保留了ASCII字符的编码方式，即对于ASCII字符（0-127的字符），UTF-8使用1个字节表示，与ASCII编码完全相同。这样做确保了对现有大量使用ASCII字符文本的向下兼容，并且对于英语等主要使用ASCII字符的语言来说，UTF-8编码是非常高效的，只占用最少的空间。
2. **多字节编码策略**：对于非ASCII字符，比如汉字，UTF-8采用了多字节编码策略。每个字节的最高位用于表示该字节在当前字符编码中的位置（起始、中间还是结束）。对于汉字这类Unicode范围内的字符，它们的Unicode编码通常大于128，无法用单字节表示，因此需要更多的字节。
3. **字节分布**：在UTF-8中，一个汉字通常需要3个字节来编码。这三个字节的分布规则是：
   - 第一个字节以 `1110` 开头，后面跟着字符编码的高 5 位；
   - 第二个字节以 `10` 开头，后面跟着字符编码的中间 6 位中的高 6 位；
   - 第三个字节同样以 `10` 开头，后面跟着字符编码的最低 6 位。

例如，汉字“你”的Unicode编码是U+4F60（十进制20320），转换为二进制后，UTF-8编码表示为 `11100110 10011100 10101010`，即E6 9C AA。

综上所述，UTF-8使用3个字节来编码一个汉字是为了在保持ASCII字符兼容性和编码效率的同时，能够支持更广泛的Unicode字符集，确保全球各种语言文字的编码需求。