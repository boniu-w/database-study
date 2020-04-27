select * from dept where deptno in (select deptno from emp t);
select * from dept where exists (select * from emp,dept where emp.deptno=dept.deptno);
select * from dept where exists (select * from emp where emp.deptno=dept.deptno);

select ora_rowscn ,deptno timestamp from dept;

select * from emp for update;

select ora_rowscn,student.* from student;
select timestamp_to_scn,student.* from student;

update student set ssex='汉' where sno='S1004';
select * from student ;

select count(sname) as count_sname,sname from student where sno='s1006' group by sname;
select count(sno) from student where sno='s1006';

--------sys用户下----------------------------------------
select GROUP#, STATUS, FIRST_CHANGE# from v$log;
select current_scn from v$database;

select checkpoint_change# from v$database;
select dbms_flashback.get_system_change_number from dual;


----------切换用户 scott ---------------------------------
select scn_to_timestamp(ora_rowscn),emp.* from emp;
update emp set sal='999' where empno=7782;

create table test_rowscn rowdependencies as select * from emp;

select ora_rowscn, t.* from test_rowscn t;
update test_rowscn set sal='888' where empno=7782;

-----------视图没有  ora_rowscn -------------------------
create view testviewofrowscn rowdependencies as select * from emp;

create or replace view testviewof as
  select *
    from emp
    
    select ora_rowscn, t.* from testviewof t;

--------------decode() 只能用select 语句 update 不管用----------------------------------
select * from test_rowscn;

select  decode(sign(sal-1000),-1,sal+100), t.*  from test_rowscn t;

update test_rowscn set decode(sign(sal-1000),-1,sal+100);

select  decode(deptno,10,20,20,30,30,10), t.*  from test_rowscn t;

select * from student;
select sum(decode(ssex,'男',1,0)) as sum_man,sum(decode(ssex,'女',1,0)) as sum_woman from student;

----------nvl() ------------------------------------------------------
select ename,NVL(comm, -1),emp.*  from emp;
