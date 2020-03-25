1: 把从一个表中查询的数据 直接插入到第二张表中 两张表的字段不一致

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