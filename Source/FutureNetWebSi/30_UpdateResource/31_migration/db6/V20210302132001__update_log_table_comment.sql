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
)