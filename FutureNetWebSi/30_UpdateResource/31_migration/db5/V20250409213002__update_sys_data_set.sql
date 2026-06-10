INSERT INTO ntss.sys_data_set (sql_cd,"sql",db_class,detail,can_repeat,use_application,report_class,memo,reg_date,up_date,pre_sql_info) VALUES
	 (-307093,'select
	TO_CHAR(ord.rst_start_date, ''YYYYMMDDHH24MISS'') AS rst_start_date,
	TO_CHAR(ord.up_date, ''YYYYMMDDHH24MISS'') AS up_date
 from
	ord_main ord
 where
	ord.ord_no = @ordNo',2,'[]','0','{"applications": [4]}',NULL,NULL,CURRENT_TIMESTAMP,CURRENT_TIMESTAMP,NULL);
