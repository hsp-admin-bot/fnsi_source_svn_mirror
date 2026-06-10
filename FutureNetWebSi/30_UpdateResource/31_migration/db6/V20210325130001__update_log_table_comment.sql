COMMENT ON COLUMN "pat_insurance"."old_up_date" IS E'(旧)更新日時';
COMMENT ON COLUMN "pat_personal_main"."old_up_date_personal" IS E'(旧)更新日時';

truncate table log_table_comment;
insert into log_table_comment(tbl_name,tbl_comment,col_name,col_comment,pk_flg,json_flg) 
SELECT 
   tabname,
	 tblcomment,
	 colname,
	 coalesce(colcomment,colname) as colcomment,
   case when (
	   SELECT
    	   count(1)
	   FROM
    	   pg_constraint
	   INNER JOIN pg_class ON pg_constraint.conrelid = pg_class.oid
	   INNER JOIN pg_attribute ON pg_attribute.attrelid = pg_class.oid
	   AND (pg_attribute.attnum = pg_constraint.conkey [1]
	        or pg_attribute.attnum = pg_constraint.conkey [2]
		 	   or pg_attribute.attnum = pg_constraint.conkey [3]
		 	   or pg_attribute.attnum = pg_constraint.conkey [4]
		 	   or pg_attribute.attnum = pg_constraint.conkey [5]
	   		 or pg_attribute.attnum = pg_constraint.conkey [6]
	   		 or pg_attribute.attnum = pg_constraint.conkey [7]
		 	   or pg_attribute.attnum = pg_constraint.conkey [8]
		 	   or pg_attribute.attnum = pg_constraint.conkey [9]
		 	   or pg_attribute.attnum = pg_constraint.conkey [10])
	   INNER JOIN pg_type ON pg_type.oid = pg_attribute.atttypid
	   WHERE
    	   pg_class.relname = tabname
				 AND pg_attribute.attname = colname
	   	   AND pg_constraint.contype = 'p') > 0
	 then 1
	 else 0
	 end as pkflg,
	 case when typname='jsonb' then 1 else 0 end as jsonflg
FROM
(
SELECT 
    c.tabname,
		pg_type.typname,
    c.comment as tblcomment,
    a.attname as colname,
    col_description(a.attrelid,a.attnum) as colcomment
FROM 
     pg_attribute as a ,
		 pg_type,
     (select 
        oid,
        relname as tabname,
        case  
	        when relname = 'sys_report_setting' then '機能帳票マスタ'
	        when relname = 'sys_master_define' then 'マスタ定義'
	        when relname = 'sys_data_set' then 'データセット'
	      else
	        coalesce(cast(obj_description(relfilenode,'pg_class') as varchar) ,
	       (select description from pg_description where objsubid=0 and c.oid=objoid limit 1)) end as comment 
      from 
        pg_class c 
      where  
        relkind = 'r' and 
        relname not like 'pg_%' and 
        relname not like 'flyway_%' and 
        relname not like 'sql_%' and
        relname not in ('log_json_comment','log_table_comment') 
    ) as c
where 
      a.attrelid = c.oid and 
      a.attnum > 0 and
			pg_type.oid = a.atttypid
) T where tblcomment is not null
order by tabname;

update 
    log_table_comment 
set 
    keystep = 0 
where (tbl_name,col_name) in 
(select 
    distinct tbl_name,col_name 
 from (
       select 
		       * 
		   from 
		      log_json_comment 
		   where json_key_name like '%-%'
		  ) a
);