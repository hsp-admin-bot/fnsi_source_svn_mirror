DELETE FROM "ntss"."sys_data_set" where sql_cd in (208);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (208, 'with input_params_expand as
(
  select
    pat_event_cd
    ,json_idx
    ,input_param
  from
    pat_event
    cross join lateral jsonb_array_elements(input_params) with ordinality as tmp(input_param, json_idx)
  where
    is_del = ''0''
    and pat_id = @patId
 and cast(event_start_date as date) between date_trunc(''day'',@fromDate::timestamp ) and date_trunc(''day'',@toDate::timestamp) + ''1 days - 1 milliseconds''
)
, result_params_expand as
(
  select
    pat_event_cd
    ,json_idx
    ,result_param
  from
    pat_event
    cross join lateral jsonb_array_elements(result_params) with ordinality as tmp(result_param, json_idx)
  where
    is_del = ''0''
    and pat_id = @patId
 and cast(event_start_date as date) between date_trunc(''day'',@fromDate::timestamp ) and date_trunc(''day'',@toDate::timestamp) + ''1 days - 1 milliseconds''
)
, pe_basicinfo as
(
  select
    pat_event_cd
     ,cast(event_start_date as date) as  event_start_date 
  from
    pat_event
  where
    is_del = ''0''
    and pat_id = @patId
 and cast(event_start_date as date) between date_trunc(''day'',@fromDate::timestamp ) and date_trunc(''day'',@toDate::timestamp) + ''1 days - 1 milliseconds''
)
, pe_picked as
(
  select
    ipe.pat_event_cd
    ,ipe.json_idx
    ,input_param
    ,result_param
  from
    input_params_expand as ipe
    inner join result_params_expand as rpe
      on ipe.pat_event_cd = rpe.pat_event_cd and ipe.json_idx = rpe.json_idx
  where
    input_param->>''format_class'' = ''2''
)
, pe_array_agg as
(
  select
    pat_event_cd
    ,array_agg(input_param order by json_idx) as picked_input_params
    ,array_agg(result_param order by json_idx) as picked_result_params
  from
    pe_picked
  group by pat_event_cd
)

select
  pe_array_agg.pat_event_cd
  ,event_start_date
  ,picked_input_params[1]->>''field_name'' as data1_field_name
  
  ,(picked_result_params[1]->''result_value''->0)->>''name'' as data1_pic1_name
  ,(picked_result_params[1]->''result_value''->0)->>''file_name'' as data1_pic1_file_name
  ,''(place)''||((picked_result_params[1]->''result_value''->0)->>''file_path'') as data1_pic1_file_path

from
  pe_array_agg
  inner join pe_basicinfo on pe_array_agg.pat_event_cd = pe_basicinfo.pat_event_cd ORDER BY event_start_date desc LIMIT 1', 2, '[{"preview": "2011/05/20", "can_calc": "0", "data_code": "event_start_date", "data_name": "増設日", "data_type": "DateTime", "conv_table": [], "data_class": "VA情報", "field_name": "event_start_date", "disp_format": "yyyy/mm/dd", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data1_pic1_file_path", "data_name": "画像", "data_type": "byte[]", "conv_table": [], "data_class": "VA情報", "field_name": "data1_pic1_file_path", "disp_format": "", "filter_type": "Category", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/05/20", "can_calc": "0", "data_code": "event_start_date", "data_name": "増設日", "data_type": "DateTime", "conv_table": [], "data_class": "VA情報", "field_name": "event_start_date", "disp_format": "yyyy/mm/dd", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data1_pic1_file_path", "data_name": "画像", "data_type": "byte[]", "conv_table": [], "data_class": "VA情報", "field_name": "data1_pic1_file_path", "disp_format": "", "filter_type": "Category", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}]', '0', '{"applications": [1]}', '{"classes": [1, 2, 3, 9]}', 'VA情報 増設日 画像', '2023-04-23 09:37:00', CURRENT_TIMESTAMP, NULL);
