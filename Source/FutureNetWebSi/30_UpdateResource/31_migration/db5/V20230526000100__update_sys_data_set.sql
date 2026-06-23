DELETE FROM "sys_data_set" WHERE "sql_cd" in (208);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (208, 'with input_params_expand as
(SELECT event_start_date,json_info ->>''name'' as data_pic_name,json_info ->>''file_path'' as data1_pic1_file_path
from (
SELECT event_start_date,info->>''result_value'' resul_json

FROM pat_event 
CROSS JOIN LATERAL json_array_elements ( result_params ::json ) info
where is_del = ''0''
    and use_type = 1 
		and pat_id = @patId

		and (info ->>''format_class'') = ''2'') a
		 CROSS JOIN LATERAL json_array_elements ( resul_json :: json ) json_info)
, order_main as
(
  select
    treat_date,
		case when ord.rst_dialysis_state = ''0'' then mst_va.va_name else COALESCE ( ord.ind_cond_info -> ''2'' ->> ''value_name_1'', '''' ) end  as va
  from
    ord_main ord
		left join mst_va on mst_va.va_cd = ( ord.ind_cond_info -> ''2'' ->> ''value'')::INTEGER
  where 
	ord.pat_id = @patId

 
	and ord.treat_date between to_char(date_trunc(''day'', (@fromDate

 )::timestamp), ''yyyymmdd'') and to_char(date_trunc(''day'', (@toDate

 )::timestamp) + ''1 days - 1 milliseconds'', ''yyyymmdd'')
)
select * from ((select a.* from input_params_expand a 
INNER JOIN order_main on order_main.va =a.data_pic_name 
where a.data_pic_name<>'''' 
and order_main.treat_date = a.event_start_date ORDER BY a.event_start_date desc)
 UNION ALL
(select a.* from input_params_expand as a 
INNER JOIN order_main on order_main.va =a.data_pic_name 
where a.data_pic_name<>'''' ORDER BY a.event_start_date desc)
) b 
LIMIT 1', 2, '[{"preview": "2011/05/20", "can_calc": "0", "data_code": "event_start_date", "data_name": "増設日", "data_type": "DateTime", "conv_table": [], "data_class": "VA情報", "field_name": "event_start_date", "disp_format": "yyyy/mm/dd", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data1_pic1_file_path", "data_name": "画像", "data_type": "byte[]", "conv_table": [], "data_class": "VA情報", "field_name": "data1_pic1_file_path", "disp_format": "", "filter_type": "Category", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}]', '0', '{"applications": [1]}', '{"classes": [1, 2, 3, 9]}', 'VA情報 増設日 画像(指示)', '2023-04-23 09:37:00', CURRENT_TIMESTAMP, NULL);

DELETE FROM "sys_data_set" WHERE "sql_cd" in (209);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (209, 'with input_params_expand as
(SELECT event_start_date,json_info ->>''name'' as data_pic_name,json_info ->>''file_path'' as data1_pic1_file_path
from (
SELECT event_start_date,info->>''result_value'' resul_json

FROM pat_event 
CROSS JOIN LATERAL json_array_elements ( result_params ::json ) info
where is_del = ''0''
    and use_type = 1 
		and pat_id = @patId
		and (info ->>''format_class'') = ''2'') a
		 CROSS JOIN LATERAL json_array_elements ( resul_json :: json ) json_info)
, order_main as
(
  select
    treat_date,COALESCE ( ord.rst_cond_info -> ''2'' ->> ''value_name_1'', '''' ) as va
  from
    ord_main ord
  where 
	ord.pat_id = @patId
	and ord.treat_date between to_char(date_trunc(''day'', (@fromDate

 )::timestamp), ''yyyymmdd'') and to_char(date_trunc(''day'', (@toDate

 )::timestamp) + ''1 days - 1 milliseconds'', ''yyyymmdd'')
)
select * from ((select a.* from input_params_expand a 
INNER JOIN order_main on order_main.va =a.data_pic_name 
where a.data_pic_name<>'''' 
and order_main.treat_date = a.event_start_date ORDER BY a.event_start_date desc)
 UNION ALL
(select a.* from input_params_expand as a 
INNER JOIN order_main on order_main.va =a.data_pic_name 
where a.data_pic_name<>'''' ORDER BY a.event_start_date desc)
) b 
LIMIT 1', 2, '[{"preview": "2011/05/20", "can_calc": "0", "data_code": "event_start_date", "data_name": "増設日", "data_type": "DateTime", "conv_table": [], "data_class": "VA情報", "field_name": "event_start_date", "disp_format": "yyyy/mm/dd", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data1_pic1_file_path", "data_name": "画像", "data_type": "byte[]", "conv_table": [], "data_class": "VA情報", "field_name": "data1_pic1_file_path", "disp_format": "", "filter_type": "Category", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}]', '0', '{"applications": [1]}', '{"classes": [1, 2, 3, 9]}', 'VA情報 増設日 画像(実績)', '2023-04-23 09:37:00', CURRENT_TIMESTAMP, NULL);
