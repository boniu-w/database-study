# 1. sql语句

```sql
# 添加外键
ALTER TABLE "public"."sp_ut_data_tbl"
ADD CONSTRAINT fk_sp_in_complete_data_id
FOREIGN KEY (sp_in_complete_data_id)
REFERENCES sp_in_complete_data(id)
ON DELETE RESTRICT ON UPDATE CASCADE; 

# 添加主键
ALTER TABLE "public"."sp_ut_data_tbl"
ADD PRIMARY KEY (id);

# 移除外键
ALTER TABLE "public"."sp_ut_data_tbl" DROP CONSTRAINT ufps_primary_sp_ut_data_tbl;

```



## 1. 外键约束

```sql
 CONSTRAINT fk_detail_assessment_to_history
        FOREIGN KEY (history_assessment_sp_int_inspect_id)
        REFERENCES history_assessment_sp_int_inspect(id)
        ON DELETE RESTRICT ON UPDATE CASCADE
        
在这个语句中，CONSTRAINT fk_detail_assessment_to_history定义了一个外键约束，其中：

fk_detail_assessment_to_history是这个外键约束的名称，可以根据需要自定义。
FOREIGN KEY (history_assessment_sp_int_inspect_id)指定了哪些字段构成外键。
REFERENCES history_assessment_sp_int_inspect(id)指明了这个外键引用的父表及其列。
ON DELETE RESTRICT意味着当父表中的记录被删除时，如果子表中有相关记录，将阻止父表记录的删除操作，以防止违反外键约束。
ON UPDATE CASCADE则表示如果父表中被引用的记录的id发生更新，子表中对应的history_assessment_sp_int_inspect_id也会自动更新为新的值，保持数据的一致性。
请根据实际情况调整ON DELETE和ON UPDATE的动作策略，以符合您的业务逻辑和数据完整性要求。
```





# 2. 连接数



```sql
-- 查询版本
SELECT VERSION ;

-- 查看所有连接
select * -- datname,pid,application_name,state 
from pg_stat_activity;

-- kill 空闲进程
select 'select pg_terminate_backend('||pid||');' as terminate_script
      ,datname,pid,application_name,state,client_addr,query
from pg_stat_activity
where state = 'idle'
and usename = 'tzq'
order by client_addr;

-- 查询可用连接
select max_conn-now_conn as resi_conn from (select setting::int8 as max_conn,(select count(*) from pg_stat_activity) as now_conn from pg_settings where name = 'max_connections') t;

-- 查询最大连接数
show max_connections;

-- 查询配置
select sourcefile,name,setting,applied from sys_file_settings;
```



```shell
# 重启
sudo systemctl restart kingbase
```

