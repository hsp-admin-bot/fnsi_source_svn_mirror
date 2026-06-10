UPDATE "ntss"."sys_data_set" SET "sql" = 'SELECT COUNT(om.treat_date) AS dialysis_conunt
,string_agg(CASE WHEN om.treat_week =1 THEN ''月'' 
WHEN om.treat_week =3 THEN ''水''
WHEN om.treat_week =4 THEN ''木''
WHEN om.treat_week =5 THEN ''金''
WHEN om.treat_week =6 THEN ''土''
ELSE ''日'' END
, '','') AS treat_week
FROM  
(select pat_id,treat_date,treat_week 
FROM  
ord_main 
where facility_cd = @facilityCd
AND pat_id=@patId
AND	treat_date BETWEEN to_char(cast(@fromDate as timestamp)
, ''YYYYMMDD'') AND to_char(cast(@fromDate as timestamp)::timestamp + ''6 day'', ''YYYYMMDD'' )
ORDER BY treat_week DESC)  om

 GROUP BY om.pat_id', "db_class" = 2, "detail" = '[{"preview": "5", "can_calc": "0", "data_code": "dialysis_conunt", "data_name": "透析パターン回数", "data_type": "decimal", "conv_table": [], "data_class": "透析パターン", "field_name": "dialysis_conunt", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "月", "can_calc": "0", "data_code": "treat_week", "data_name": "透析パターン曜日", "data_type": "string", "conv_table": [], "data_class": "透析パターン", "field_name": "treat_week", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}]', "can_repeat" = '0', "use_application" = '{"applications": [1]}', "report_class" = '{"classes": [1, 2, 9]}', "memo" = '指示：透析パターン', "reg_date" = '2021-12-16 17:10:00', "up_date" = '2021-12-16 16:10:00', "pre_sql_info" = NULL WHERE "sql_cd" = 202;
