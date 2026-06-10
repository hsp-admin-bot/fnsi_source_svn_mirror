DELETE FROM "ntss"."sys_data_set" where sql_cd in (51, 60, 85);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (51, 'with input_params_expand as
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
    and use_type = 2
		and ord_no = @ordNo
		and facility_cd = @facilityCd
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
    and use_type = 2
		and ord_no = @ordNo
		and facility_cd = @facilityCd
)
, pe_basicinfo as
(
  select
		ord_no
    ,pat_event_cd
    ,event_start_date
    ,event_end_date
    ,category_name
    ,sub_category_name
    ,reg_staff_info->>''reg_staff_name'' as reg_staff_name
    ,reg_date
    ,up_staff_info->>''up_staff_name'' as up_staff_name
    ,up_date
  from
    pat_event
  where
    is_del = ''0''
    and use_type = 2
		and ord_no = @ordNo
		and facility_cd = @facilityCd
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
    input_param->>''format_class'' = ''1''
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
  ord_no
  ,pe_array_agg.pat_event_cd
  ,event_start_date
  ,event_end_date
  ,category_name
  ,sub_category_name
  ,reg_staff_name
  ,reg_date
  ,up_staff_name
  ,up_date
  ,picked_input_params[1]->>''field_name'' as data1_field_name
  ,picked_input_params[2]->>''field_name'' as data2_field_name
  ,picked_input_params[3]->>''field_name'' as data3_field_name
  ,picked_input_params[4]->>''field_name'' as data4_field_name
  ,picked_input_params[5]->>''field_name'' as data5_field_name
  ,picked_input_params[6]->>''field_name'' as data6_field_name
  ,picked_input_params[7]->>''field_name'' as data7_field_name
  ,picked_input_params[8]->>''field_name'' as data8_field_name
  ,picked_input_params[9]->>''field_name'' as data9_field_name
  ,picked_input_params[10]->>''field_name'' as data10_field_name
  	,case when  picked_result_params[1]->>''result_value'' is null or picked_result_params[1]->>''result_value'' = '''' then '''' else (case when (picked_input_params [ 1 ]-> ''item_json'') ->> ''is_formatting'' = ''0'' then picked_result_params [ 1 ]->> ''result_value'' else (unescape_html(regexp_replace(substring(regexp_replace(picked_result_params[1]->>''result_value'' , ''</[p^>]*>'', E''\n'', ''g'') from 1 for length(regexp_replace(picked_result_params[1]->>''result_value'' , ''</[p^>]*>'', E''\n'', ''g''))), ''<[^>]*>'', '''', ''g''))) end) end as data1
	,case when  picked_result_params[2]->>''result_value'' is null or picked_result_params[2]->>''result_value'' = '''' then '''' else (case when (picked_input_params [ 2 ]-> ''item_json'') ->> ''is_formatting'' = ''0'' then picked_result_params [ 2 ]->> ''result_value'' else (unescape_html(regexp_replace(substring(regexp_replace(picked_result_params[2]->>''result_value'' , ''</[p^>]*>'', E''\n'', ''g'') from 1 for length(regexp_replace(picked_result_params[2]->>''result_value'' , ''</[p^>]*>'', E''\n'', ''g''))), ''<[^>]*>'', '''', ''g''))) end) end as data2
	,case when  picked_result_params[3]->>''result_value'' is null or picked_result_params[3]->>''result_value'' = '''' then '''' else (case when (picked_input_params [ 3 ]-> ''item_json'') ->> ''is_formatting'' = ''0'' then picked_result_params [ 3 ]->> ''result_value'' else (unescape_html(regexp_replace(substring(regexp_replace(picked_result_params[3]->>''result_value'' , ''</[p^>]*>'', E''\n'', ''g'') from 1 for length(regexp_replace(picked_result_params[3]->>''result_value'' , ''</[p^>]*>'', E''\n'', ''g''))), ''<[^>]*>'', '''', ''g''))) end) end as data3
	,case when  picked_result_params[4]->>''result_value'' is null or picked_result_params[4]->>''result_value'' = '''' then '''' else (case when (picked_input_params [ 4 ]-> ''item_json'') ->> ''is_formatting'' = ''0'' then picked_result_params [ 4 ]->> ''result_value'' else (unescape_html(regexp_replace(substring(regexp_replace(picked_result_params[4]->>''result_value'' , ''</[p^>]*>'', E''\n'', ''g'') from 1 for length(regexp_replace(picked_result_params[4]->>''result_value'' , ''</[p^>]*>'', E''\n'', ''g''))), ''<[^>]*>'', '''', ''g''))) end) end as data4
	,case when  picked_result_params[5]->>''result_value'' is null or picked_result_params[5]->>''result_value'' = '''' then '''' else (case when (picked_input_params [ 5 ]-> ''item_json'') ->> ''is_formatting'' = ''0'' then picked_result_params [ 5 ]->> ''result_value'' else (unescape_html(regexp_replace(substring(regexp_replace(picked_result_params[5]->>''result_value'' , ''</[p^>]*>'', E''\n'', ''g'') from 1 for length(regexp_replace(picked_result_params[5]->>''result_value'' , ''</[p^>]*>'', E''\n'', ''g''))), ''<[^>]*>'', '''', ''g''))) end) end as data5
	,case when  picked_result_params[6]->>''result_value'' is null or picked_result_params[6]->>''result_value'' = '''' then '''' else (case when (picked_input_params [ 6 ]-> ''item_json'') ->> ''is_formatting'' = ''0'' then picked_result_params [ 6 ]->> ''result_value'' else (unescape_html(regexp_replace(substring(regexp_replace(picked_result_params[6]->>''result_value'' , ''</[p^>]*>'', E''\n'', ''g'') from 1 for length(regexp_replace(picked_result_params[6]->>''result_value'' , ''</[p^>]*>'', E''\n'', ''g''))), ''<[^>]*>'', '''', ''g''))) end) end as data6
	,case when  picked_result_params[7]->>''result_value'' is null or picked_result_params[7]->>''result_value'' = '''' then '''' else (case when (picked_input_params [ 7 ]-> ''item_json'') ->> ''is_formatting'' = ''0'' then picked_result_params [ 7 ]->> ''result_value'' else (unescape_html(regexp_replace(substring(regexp_replace(picked_result_params[7]->>''result_value'' , ''</[p^>]*>'', E''\n'', ''g'') from 1 for length(regexp_replace(picked_result_params[7]->>''result_value'' , ''</[p^>]*>'', E''\n'', ''g''))), ''<[^>]*>'', '''', ''g''))) end) end as data7
	,case when  picked_result_params[8]->>''result_value'' is null or picked_result_params[8]->>''result_value'' = '''' then '''' else (case when (picked_input_params [ 8 ]-> ''item_json'') ->> ''is_formatting'' = ''0'' then picked_result_params [ 8 ]->> ''result_value'' else (unescape_html(regexp_replace(substring(regexp_replace(picked_result_params[8]->>''result_value'' , ''</[p^>]*>'', E''\n'', ''g'') from 1 for length(regexp_replace(picked_result_params[8]->>''result_value'' , ''</[p^>]*>'', E''\n'', ''g''))), ''<[^>]*>'', '''', ''g''))) end) end as data8
	,case when  picked_result_params[9]->>''result_value'' is null or picked_result_params[9]->>''result_value'' = '''' then '''' else (case when (picked_input_params [ 9 ]-> ''item_json'') ->> ''is_formatting'' = ''0'' then picked_result_params [ 9 ]->> ''result_value'' else (unescape_html(regexp_replace(substring(regexp_replace(picked_result_params[9]->>''result_value'' , ''</[p^>]*>'', E''\n'', ''g'') from 1 for length(regexp_replace(picked_result_params[9]->>''result_value'' , ''</[p^>]*>'', E''\n'', ''g''))), ''<[^>]*>'', '''', ''g''))) end) end as data9
	,case when  picked_result_params[10]->>''result_value'' is null or picked_result_params[10]->>''result_value'' = '''' then '''' else (case when (picked_input_params [ 10 ]-> ''item_json'') ->> ''is_formatting'' = ''0'' then picked_result_params [ 10 ]->> ''result_value'' else (unescape_html(regexp_replace(substring(regexp_replace(picked_result_params[10]->>''result_value'' , ''</[p^>]*>'', E''\n'', ''g'') from 1 for length(regexp_replace(picked_result_params[10]->>''result_value'' , ''</[p^>]*>'', E''\n'', ''g''))), ''<[^>]*>'', '''', ''g''))) end) end as data10
from
  pe_array_agg
  inner join pe_basicinfo on pe_array_agg.pat_event_cd = pe_basicinfo.pat_event_cd
;', 2, '[{"preview": "S", "can_calc": "0", "data_code": "data1_field_name", "data_name": "データ1 フィールド名", "data_type": "string", "conv_table": [], "data_class": "テキストエリア", "field_name": "data1_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "S", "can_calc": "0", "data_code": "data2_field_name", "data_name": "データ2 フィールド名", "data_type": "string", "conv_table": [], "data_class": "テキストエリア", "field_name": "data2_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "S", "can_calc": "0", "data_code": "data3_field_name", "data_name": "データ3 フィールド名", "data_type": "string", "conv_table": [], "data_class": "テキストエリア", "field_name": "data3_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "S", "can_calc": "0", "data_code": "data4_field_name", "data_name": "データ4 フィールド名", "data_type": "string", "conv_table": [], "data_class": "テキストエリア", "field_name": "data4_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "S", "can_calc": "0", "data_code": "data5_field_name", "data_name": "データ5 フィールド名", "data_type": "string", "conv_table": [], "data_class": "テキストエリア", "field_name": "data5_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "S", "can_calc": "0", "data_code": "data6_field_name", "data_name": "データ6 フィールド名", "data_type": "string", "conv_table": [], "data_class": "テキストエリア", "field_name": "data6_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "S", "can_calc": "0", "data_code": "data7_field_name", "data_name": "データ7 フィールド名", "data_type": "string", "conv_table": [], "data_class": "テキストエリア", "field_name": "data7_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "S", "can_calc": "0", "data_code": "data8_field_name", "data_name": "データ8 フィールド名", "data_type": "string", "conv_table": [], "data_class": "テキストエリア", "field_name": "data8_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "S", "can_calc": "0", "data_code": "data9_field_name", "data_name": "データ9 フィールド名", "data_type": "string", "conv_table": [], "data_class": "テキストエリア", "field_name": "data9_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "S", "can_calc": "0", "data_code": "data10_field_name", "data_name": "データ10 フィールド名", "data_type": "string", "conv_table": [], "data_class": "テキストエリア", "field_name": "data10_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "コメントです。", "can_calc": "0", "data_code": "data1", "data_name": "データ1", "data_type": "string", "conv_table": [], "data_class": "テキストエリア", "field_name": "data1", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "コメントです。", "can_calc": "0", "data_code": "data2", "data_name": "データ2", "data_type": "string", "conv_table": [], "data_class": "テキストエリア", "field_name": "data2", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "コメントです。", "can_calc": "0", "data_code": "data3", "data_name": "データ3", "data_type": "string", "conv_table": [], "data_class": "テキストエリア", "field_name": "data3", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "コメントです。", "can_calc": "0", "data_code": "data4", "data_name": "データ4", "data_type": "string", "conv_table": [], "data_class": "テキストエリア", "field_name": "data4", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "コメントです。", "can_calc": "0", "data_code": "data5", "data_name": "データ5", "data_type": "string", "conv_table": [], "data_class": "テキストエリア", "field_name": "data5", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "コメントです。", "can_calc": "0", "data_code": "data6", "data_name": "データ6", "data_type": "string", "conv_table": [], "data_class": "テキストエリア", "field_name": "data6", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "コメントです。", "can_calc": "0", "data_code": "data7", "data_name": "データ7", "data_type": "string", "conv_table": [], "data_class": "テキストエリア", "field_name": "data7", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "コメントです。", "can_calc": "0", "data_code": "data8", "data_name": "データ8", "data_type": "string", "conv_table": [], "data_class": "テキストエリア", "field_name": "data8", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "コメントです。", "can_calc": "0", "data_code": "data9", "data_name": "データ9", "data_type": "string", "conv_table": [], "data_class": "テキストエリア", "field_name": "data9", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "コメントです。", "can_calc": "0", "data_code": "data10", "data_name": "データ10", "data_type": "string", "conv_table": [], "data_class": "テキストエリア", "field_name": "data10", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [1, 2, 3, 9, 10, 11]}', '観察記録 透析レポート テキストエリア @ordNo @facilityCd 使用', '2020-03-27 23:59:59', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (60, 'with input_params_expand as
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
    and use_type = 2
		and pat_id = @patId
		and facility_cd = @facilityCd
		and cast(event_start_date as date) between date_trunc(''day'', @fromDate::timestamp) and date_trunc(''day'', @toDate::timestamp)
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
    and use_type = 2
		and pat_id = @patId
		and facility_cd = @facilityCd
		and cast(event_start_date as date) between date_trunc(''day'', @fromDate::timestamp) and date_trunc(''day'', @toDate::timestamp)
)
, pe_basicinfo as
(
  select
    pat_event_cd
    ,event_start_date
    ,event_end_date
    ,category_name
    ,sub_category_name
    ,reg_staff_info->>''reg_staff_name'' as reg_staff_name
    ,reg_date
    ,up_staff_info->>''up_staff_name'' as up_staff_name
    ,up_date
  from
    pat_event
  where
    is_del = ''0''
    and use_type = 2
		and pat_id = @patId
		and facility_cd = @facilityCd
		and cast(event_start_date as date) between date_trunc(''day'', @fromDate::timestamp) and date_trunc(''day'', @toDate::timestamp)
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
    input_param->>''format_class'' = ''1''
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
  ,event_end_date
  ,category_name
  ,sub_category_name
  ,reg_staff_name
  ,reg_date
  ,up_staff_name
  ,up_date
  ,picked_input_params[1]->>''field_name'' as data1_field_name
  ,picked_input_params[2]->>''field_name'' as data2_field_name
  ,picked_input_params[3]->>''field_name'' as data3_field_name
  ,picked_input_params[4]->>''field_name'' as data4_field_name
  ,picked_input_params[5]->>''field_name'' as data5_field_name
  ,picked_input_params[6]->>''field_name'' as data6_field_name
  ,picked_input_params[7]->>''field_name'' as data7_field_name
  ,picked_input_params[8]->>''field_name'' as data8_field_name
  ,picked_input_params[9]->>''field_name'' as data9_field_name
  ,picked_input_params[10]->>''field_name'' as data10_field_name
  	,case when  picked_result_params[1]->>''result_value'' is null or picked_result_params[1]->>''result_value'' = '''' then '''' else (case when (picked_input_params [ 1 ]-> ''item_json'') ->> ''is_formatting'' = ''0'' then picked_result_params [ 1 ]->> ''result_value'' else (unescape_html(regexp_replace(substring(regexp_replace(picked_result_params[1]->>''result_value'' , ''</[p^>]*>'', E''\n'', ''g'') from 1 for length(regexp_replace(picked_result_params[1]->>''result_value'' , ''</[p^>]*>'', E''\n'', ''g''))), ''<[^>]*>'', '''', ''g''))) end) end as data1
	,case when  picked_result_params[2]->>''result_value'' is null or picked_result_params[2]->>''result_value'' = '''' then '''' else (case when (picked_input_params [ 2 ]-> ''item_json'') ->> ''is_formatting'' = ''0'' then picked_result_params [ 2 ]->> ''result_value'' else (unescape_html(regexp_replace(substring(regexp_replace(picked_result_params[2]->>''result_value'' , ''</[p^>]*>'', E''\n'', ''g'') from 1 for length(regexp_replace(picked_result_params[2]->>''result_value'' , ''</[p^>]*>'', E''\n'', ''g''))), ''<[^>]*>'', '''', ''g''))) end) end as data2
	,case when  picked_result_params[3]->>''result_value'' is null or picked_result_params[3]->>''result_value'' = '''' then '''' else (case when (picked_input_params [ 3 ]-> ''item_json'') ->> ''is_formatting'' = ''0'' then picked_result_params [ 3 ]->> ''result_value'' else (unescape_html(regexp_replace(substring(regexp_replace(picked_result_params[3]->>''result_value'' , ''</[p^>]*>'', E''\n'', ''g'') from 1 for length(regexp_replace(picked_result_params[3]->>''result_value'' , ''</[p^>]*>'', E''\n'', ''g''))), ''<[^>]*>'', '''', ''g''))) end) end as data3
	,case when  picked_result_params[4]->>''result_value'' is null or picked_result_params[4]->>''result_value'' = '''' then '''' else (case when (picked_input_params [ 4 ]-> ''item_json'') ->> ''is_formatting'' = ''0'' then picked_result_params [ 4 ]->> ''result_value'' else (unescape_html(regexp_replace(substring(regexp_replace(picked_result_params[4]->>''result_value'' , ''</[p^>]*>'', E''\n'', ''g'') from 1 for length(regexp_replace(picked_result_params[4]->>''result_value'' , ''</[p^>]*>'', E''\n'', ''g''))), ''<[^>]*>'', '''', ''g''))) end) end as data4
	,case when  picked_result_params[5]->>''result_value'' is null or picked_result_params[5]->>''result_value'' = '''' then '''' else (case when (picked_input_params [ 5 ]-> ''item_json'') ->> ''is_formatting'' = ''0'' then picked_result_params [ 5 ]->> ''result_value'' else (unescape_html(regexp_replace(substring(regexp_replace(picked_result_params[5]->>''result_value'' , ''</[p^>]*>'', E''\n'', ''g'') from 1 for length(regexp_replace(picked_result_params[5]->>''result_value'' , ''</[p^>]*>'', E''\n'', ''g''))), ''<[^>]*>'', '''', ''g''))) end) end as data5
	,case when  picked_result_params[6]->>''result_value'' is null or picked_result_params[6]->>''result_value'' = '''' then '''' else (case when (picked_input_params [ 6 ]-> ''item_json'') ->> ''is_formatting'' = ''0'' then picked_result_params [ 6 ]->> ''result_value'' else (unescape_html(regexp_replace(substring(regexp_replace(picked_result_params[6]->>''result_value'' , ''</[p^>]*>'', E''\n'', ''g'') from 1 for length(regexp_replace(picked_result_params[6]->>''result_value'' , ''</[p^>]*>'', E''\n'', ''g''))), ''<[^>]*>'', '''', ''g''))) end) end as data6
	,case when  picked_result_params[7]->>''result_value'' is null or picked_result_params[7]->>''result_value'' = '''' then '''' else (case when (picked_input_params [ 7 ]-> ''item_json'') ->> ''is_formatting'' = ''0'' then picked_result_params [ 7 ]->> ''result_value'' else (unescape_html(regexp_replace(substring(regexp_replace(picked_result_params[7]->>''result_value'' , ''</[p^>]*>'', E''\n'', ''g'') from 1 for length(regexp_replace(picked_result_params[7]->>''result_value'' , ''</[p^>]*>'', E''\n'', ''g''))), ''<[^>]*>'', '''', ''g''))) end) end as data7
	,case when  picked_result_params[8]->>''result_value'' is null or picked_result_params[8]->>''result_value'' = '''' then '''' else (case when (picked_input_params [ 8 ]-> ''item_json'') ->> ''is_formatting'' = ''0'' then picked_result_params [ 8 ]->> ''result_value'' else (unescape_html(regexp_replace(substring(regexp_replace(picked_result_params[8]->>''result_value'' , ''</[p^>]*>'', E''\n'', ''g'') from 1 for length(regexp_replace(picked_result_params[8]->>''result_value'' , ''</[p^>]*>'', E''\n'', ''g''))), ''<[^>]*>'', '''', ''g''))) end) end as data8
	,case when  picked_result_params[9]->>''result_value'' is null or picked_result_params[9]->>''result_value'' = '''' then '''' else (case when (picked_input_params [ 9 ]-> ''item_json'') ->> ''is_formatting'' = ''0'' then picked_result_params [ 9 ]->> ''result_value'' else (unescape_html(regexp_replace(substring(regexp_replace(picked_result_params[9]->>''result_value'' , ''</[p^>]*>'', E''\n'', ''g'') from 1 for length(regexp_replace(picked_result_params[9]->>''result_value'' , ''</[p^>]*>'', E''\n'', ''g''))), ''<[^>]*>'', '''', ''g''))) end) end as data9
	,case when  picked_result_params[10]->>''result_value'' is null or picked_result_params[10]->>''result_value'' = '''' then '''' else (case when (picked_input_params [ 10 ]-> ''item_json'') ->> ''is_formatting'' = ''0'' then picked_result_params [ 10 ]->> ''result_value'' else (unescape_html(regexp_replace(substring(regexp_replace(picked_result_params[10]->>''result_value'' , ''</[p^>]*>'', E''\n'', ''g'') from 1 for length(regexp_replace(picked_result_params[10]->>''result_value'' , ''</[p^>]*>'', E''\n'', ''g''))), ''<[^>]*>'', '''', ''g''))) end) end as data10
from
  pe_array_agg
  inner join pe_basicinfo on pe_array_agg.pat_event_cd = pe_basicinfo.pat_event_cd
	order  by  event_start_date,  reg_date
;', 2, '[{"preview": "S", "can_calc": "0", "data_code": "data1_field_name", "data_name": "データ1 フィールド名", "data_type": "string", "conv_table": [], "data_class": "テキストエリア", "field_name": "data1_field_name", "disp_format": "", "data_category": "観察記録(患者指定)", "facility_table": "", "facility_filter_type": "0"}, {"preview": "S", "can_calc": "0", "data_code": "data2_field_name", "data_name": "データ2 フィールド名", "data_type": "string", "conv_table": [], "data_class": "テキストエリア", "field_name": "data2_field_name", "disp_format": "", "data_category": "観察記録(患者指定)", "facility_table": "", "facility_filter_type": "0"}, {"preview": "S", "can_calc": "0", "data_code": "data3_field_name", "data_name": "データ3 フィールド名", "data_type": "string", "conv_table": [], "data_class": "テキストエリア", "field_name": "data3_field_name", "disp_format": "", "data_category": "観察記録(患者指定)", "facility_table": "", "facility_filter_type": "0"}, {"preview": "S", "can_calc": "0", "data_code": "data4_field_name", "data_name": "データ4 フィールド名", "data_type": "string", "conv_table": [], "data_class": "テキストエリア", "field_name": "data4_field_name", "disp_format": "", "data_category": "観察記録(患者指定)", "facility_table": "", "facility_filter_type": "0"}, {"preview": "S", "can_calc": "0", "data_code": "data5_field_name", "data_name": "データ5 フィールド名", "data_type": "string", "conv_table": [], "data_class": "テキストエリア", "field_name": "data5_field_name", "disp_format": "", "data_category": "観察記録(患者指定)", "facility_table": "", "facility_filter_type": "0"}, {"preview": "S", "can_calc": "0", "data_code": "data6_field_name", "data_name": "データ6 フィールド名", "data_type": "string", "conv_table": [], "data_class": "テキストエリア", "field_name": "data6_field_name", "disp_format": "", "data_category": "観察記録(患者指定)", "facility_table": "", "facility_filter_type": "0"}, {"preview": "S", "can_calc": "0", "data_code": "data7_field_name", "data_name": "データ7 フィールド名", "data_type": "string", "conv_table": [], "data_class": "テキストエリア", "field_name": "data7_field_name", "disp_format": "", "data_category": "観察記録(患者指定)", "facility_table": "", "facility_filter_type": "0"}, {"preview": "S", "can_calc": "0", "data_code": "data8_field_name", "data_name": "データ8 フィールド名", "data_type": "string", "conv_table": [], "data_class": "テキストエリア", "field_name": "data8_field_name", "disp_format": "", "data_category": "観察記録(患者指定)", "facility_table": "", "facility_filter_type": "0"}, {"preview": "S", "can_calc": "0", "data_code": "data9_field_name", "data_name": "データ9 フィールド名", "data_type": "string", "conv_table": [], "data_class": "テキストエリア", "field_name": "data9_field_name", "disp_format": "", "data_category": "観察記録(患者指定)", "facility_table": "", "facility_filter_type": "0"}, {"preview": "S", "can_calc": "0", "data_code": "data10_field_name", "data_name": "データ10 フィールド名", "data_type": "string", "conv_table": [], "data_class": "テキストエリア", "field_name": "data10_field_name", "disp_format": "", "data_category": "観察記録(患者指定)", "facility_table": "", "facility_filter_type": "0"}, {"preview": "コメントです。", "can_calc": "0", "data_code": "data1", "data_name": "データ1", "data_type": "string", "conv_table": [], "data_class": "テキストエリア", "field_name": "data1", "disp_format": "", "data_category": "観察記録(患者指定)", "facility_table": "", "facility_filter_type": "0"}, {"preview": "コメントです。", "can_calc": "0", "data_code": "data2", "data_name": "データ2", "data_type": "string", "conv_table": [], "data_class": "テキストエリア", "field_name": "data2", "disp_format": "", "data_category": "観察記録(患者指定)", "facility_table": "", "facility_filter_type": "0"}, {"preview": "コメントです。", "can_calc": "0", "data_code": "data3", "data_name": "データ3", "data_type": "string", "conv_table": [], "data_class": "テキストエリア", "field_name": "data3", "disp_format": "", "data_category": "観察記録(患者指定)", "facility_table": "", "facility_filter_type": "0"}, {"preview": "コメントです。", "can_calc": "0", "data_code": "data4", "data_name": "データ4", "data_type": "string", "conv_table": [], "data_class": "テキストエリア", "field_name": "data4", "disp_format": "", "data_category": "観察記録(患者指定)", "facility_table": "", "facility_filter_type": "0"}, {"preview": "コメントです。", "can_calc": "0", "data_code": "data5", "data_name": "データ5", "data_type": "string", "conv_table": [], "data_class": "テキストエリア", "field_name": "data5", "disp_format": "", "data_category": "観察記録(患者指定)", "facility_table": "", "facility_filter_type": "0"}, {"preview": "コメントです。", "can_calc": "0", "data_code": "data6", "data_name": "データ6", "data_type": "string", "conv_table": [], "data_class": "テキストエリア", "field_name": "data6", "disp_format": "", "data_category": "観察記録(患者指定)", "facility_table": "", "facility_filter_type": "0"}, {"preview": "コメントです。", "can_calc": "0", "data_code": "data7", "data_name": "データ7", "data_type": "string", "conv_table": [], "data_class": "テキストエリア", "field_name": "data7", "disp_format": "", "data_category": "観察記録(患者指定)", "facility_table": "", "facility_filter_type": "0"}, {"preview": "コメントです。", "can_calc": "0", "data_code": "data8", "data_name": "データ8", "data_type": "string", "conv_table": [], "data_class": "テキストエリア", "field_name": "data8", "disp_format": "", "data_category": "観察記録(患者指定)", "facility_table": "", "facility_filter_type": "0"}, {"preview": "コメントです。", "can_calc": "0", "data_code": "data9", "data_name": "データ9", "data_type": "string", "conv_table": [], "data_class": "テキストエリア", "field_name": "data9", "disp_format": "", "data_category": "観察記録(患者指定)", "facility_table": "", "facility_filter_type": "0"}, {"preview": "コメントです。", "can_calc": "0", "data_code": "data10", "data_name": "データ10", "data_type": "string", "conv_table": [], "data_class": "テキストエリア", "field_name": "data10", "disp_format": "", "data_category": "観察記録(患者指定)", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [1, 2, 3, 9, 10, 11]}', '観察記録 単／複数患者帳票 テキストエリア @patId @facilityCd @fromDate @toDate 使用', '2020-03-27 23:59:59', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (85, 'with input_params_expand as
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
    and input_params != ''null''
    and pat_id = @patId
		and facility_cd = @facilityCd
		and cast(event_start_date as date) between date_trunc(''day'', @fromDate ::timestamp ) and date_trunc(''day'', @toDate ::timestamp) + ''1 days - 1 milliseconds''
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
		and facility_cd = @facilityCd
		and cast(event_start_date as date) between date_trunc(''day'', @fromDate ::timestamp ) and date_trunc(''day'', @toDate ::timestamp) + ''1 days - 1 milliseconds''
)
, pe_basicinfo as
(
  select
    pat_event_cd
    ,event_start_date
    ,event_end_date
    ,event_start_time
    ,event_end_time
    ,category_cd
		,category_name
    ,sub_category_cd
    ,sub_category_name
    ,reg_staff_info->>''reg_staff_name'' as reg_staff_name
    ,reg_date
    ,up_staff_info->>''up_staff_name'' as up_staff_name
    ,up_date
  from
    pat_event
  where
    is_del = ''0''
    and pat_id = @patId
		and facility_cd = @facilityCd
		and cast(event_start_date as date) between date_trunc(''day'', @fromDate ::timestamp ) and date_trunc(''day'', @toDate ::timestamp) + ''1 days - 1 milliseconds''
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
    input_param->>''format_class'' = ''1''
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
   ,to_timestamp(event_start_date||
     case when event_start_time is null then ''0000''
          else event_start_time
     end, ''yyyyMMDDHH24mi'') AS event_start_date
--   ,to_timestamp(event_end_date||
--     case when event_end_time is null then ''0000''
--          else event_end_time
--     end, ''yyyyMMDDHH24mi'') AS event_end_date
  ,category_cd
  ,category_name
  ,pe_basicinfo.sub_category_cd
  ,pe_basicinfo.sub_category_name
--   ,reg_staff_name
   ,pe_basicinfo.reg_date
--   ,up_staff_name
--   ,pe_basicinfo.up_date
  ,picked_input_params[1]->>''field_name'' as data1_field_name
  ,picked_input_params[2]->>''field_name'' as data2_field_name
  ,picked_input_params[3]->>''field_name'' as data3_field_name
  ,picked_input_params[4]->>''field_name'' as data4_field_name
  ,picked_input_params[5]->>''field_name'' as data5_field_name
  ,picked_input_params[6]->>''field_name'' as data6_field_name
  ,picked_input_params[7]->>''field_name'' as data7_field_name
  ,picked_input_params[8]->>''field_name'' as data8_field_name
  ,picked_input_params[9]->>''field_name'' as data9_field_name
  ,picked_input_params[10]->>''field_name'' as data10_field_name
  ,case when picked_result_params[1]->>''result_value'' is null or picked_result_params[1]->>''result_value'' = '''' then picked_input_params[1]->''item_json''->>''default_value''
else (case when  (picked_input_params [ 1 ]-> ''item_json'') ->> ''is_formatting'' = ''1'' then unescape_html(regexp_replace(substring(regexp_replace(picked_result_params[1]->>''result_value'' , ''</[p^>]*>'', E''\n'', ''g'') from 1 for length(regexp_replace(picked_result_params[1]->>''result_value'' , ''</[p^>]*>'', E''\n'', ''g''))), ''<[^>]*>'', '''', ''g'')) else picked_result_params[1]->>''result_value'' end)
end as data1
  ,case when picked_result_params[2]->>''result_value'' is null or picked_result_params[2]->>''result_value'' = '''' then picked_input_params[2]->''item_json''->>''default_value''
else (case when  (picked_input_params [ 2 ]-> ''item_json'') ->> ''is_formatting'' = ''1'' then unescape_html(regexp_replace(substring(regexp_replace(picked_result_params[2]->>''result_value'' , ''</[p^>]*>'', E''\n'', ''g'') from 1 for length(regexp_replace(picked_result_params[2]->>''result_value'' , ''</[p^>]*>'', E''\n'', ''g''))), ''<[^>]*>'', '''', ''g'')) else picked_result_params[2]->>''result_value'' end)
end as data2
  ,case when picked_result_params[3]->>''result_value'' is null or picked_result_params[2]->>''result_value'' = '''' then picked_input_params[3]->''item_json''->>''default_value''
else (case when  (picked_input_params [ 3 ]-> ''item_json'') ->> ''is_formatting'' = ''1'' then unescape_html(regexp_replace(substring(regexp_replace(picked_result_params[3]->>''result_value'' , ''</[p^>]*>'', E''\n'', ''g'') from 1 for length(regexp_replace(picked_result_params[3]->>''result_value'' , ''</[p^>]*>'', E''\n'', ''g''))), ''<[^>]*>'', '''', ''g'')) else picked_result_params[3]->>''result_value'' end)
end as data3
 ,case when picked_result_params[4]->>''result_value'' is null or picked_result_params[4]->>''result_value'' = '''' then picked_input_params[4]->''item_json''->>''default_value''
else (case when  (picked_input_params [ 4 ]-> ''item_json'') ->> ''is_formatting'' = ''1'' then unescape_html(regexp_replace(substring(regexp_replace(picked_result_params[4]->>''result_value'' , ''</[p^>]*>'', E''\n'', ''g'') from 1 for length(regexp_replace(picked_result_params[4]->>''result_value'' , ''</[p^>]*>'', E''\n'', ''g''))), ''<[^>]*>'', '''', ''g'')) else picked_result_params[4]->>''result_value'' end)
end as data4
,case when picked_result_params[5]->>''result_value'' is null or picked_result_params[5]->>''result_value'' = '''' then picked_input_params[5]->''item_json''->>''default_value''
else (case when  (picked_input_params [ 5 ]-> ''item_json'') ->> ''is_formatting'' = ''1'' then unescape_html(regexp_replace(substring(regexp_replace(picked_result_params[5]->>''result_value'' , ''</[p^>]*>'', E''\n'', ''g'') from 1 for length(regexp_replace(picked_result_params[5]->>''result_value'' , ''</[p^>]*>'', E''\n'', ''g''))), ''<[^>]*>'', '''', ''g'')) else picked_result_params[5]->>''result_value'' end)
end as data5
,case when picked_result_params[6]->>''result_value'' is null or picked_result_params[6]->>''result_value'' = '''' then picked_input_params[6]->''item_json''->>''default_value''
else (case when  (picked_input_params [ 6 ]-> ''item_json'') ->> ''is_formatting'' = ''1'' then unescape_html(regexp_replace(substring(regexp_replace(picked_result_params[6]->>''result_value'' , ''</[p^>]*>'', E''\n'', ''g'') from 1 for length(regexp_replace(picked_result_params[6]->>''result_value'' , ''</[p^>]*>'', E''\n'', ''g''))), ''<[^>]*>'', '''', ''g'')) else picked_result_params[6]->>''result_value'' end)
end as data6
 ,case when picked_result_params[7]->>''result_value'' is null or picked_result_params[7]->>''result_value'' = '''' then picked_input_params[7]->''item_json''->>''default_value'' else 
(case when  (picked_input_params [ 7 ]-> ''item_json'') ->> ''is_formatting'' = ''1'' then unescape_html(regexp_replace(substring(regexp_replace(picked_result_params[7]->>''result_value'' , ''</[p^>]*>'', E''\n'', ''g'') from 1 for length(regexp_replace(picked_result_params[7]->>''result_value'' , ''</[p^>]*>'', E''\n'', ''g''))), ''<[^>]*>'', '''', ''g'')) else picked_result_params[7]->>''result_value'' end)
end as data7
 ,case when picked_result_params[8]->>''result_value'' is null or picked_result_params[8]->>''result_value'' = '''' then picked_input_params[8]->''item_json''->>''default_value''
else (case when  (picked_input_params [ 8 ]-> ''item_json'') ->> ''is_formatting'' = ''1'' then unescape_html(regexp_replace(substring(regexp_replace(picked_result_params[8]->>''result_value'' , ''</[p^>]*>'', E''\n'', ''g'') from 1 for length(regexp_replace(picked_result_params[8]->>''result_value'' , ''</[p^>]*>'', E''\n'', ''g''))), ''<[^>]*>'', '''', ''g'')) else picked_result_params[8]->>''result_value'' end)
end as data8
,case when picked_result_params[9]->>''result_value'' is null or picked_result_params[9]->>''result_value'' = '''' then picked_input_params[9]->''item_json''->>''default_value''
else (case when  (picked_input_params [ 9 ]-> ''item_json'') ->> ''is_formatting'' = ''1'' then unescape_html(regexp_replace(substring(regexp_replace(picked_result_params[9]->>''result_value'' , ''</[p^>]*>'', E''\n'', ''g'') from 1 for length(regexp_replace(picked_result_params[9]->>''result_value'' , ''</[p^>]*>'', E''\n'', ''g''))), ''<[^>]*>'', '''', ''g'')) else picked_result_params[9]->>''result_value'' end)
end as data9
,case when picked_result_params[10]->>''result_value'' is null or picked_result_params[10]->>''result_value'' = '''' then picked_input_params[10]->''item_json''->>''default_value''
else (case when  (picked_input_params [ 10 ]-> ''item_json'') ->> ''is_formatting'' = ''1'' then unescape_html(regexp_replace(substring(regexp_replace(picked_result_params[10]->>''result_value'' , ''</[p^>]*>'', E''\n'', ''g'') from 1 for length(regexp_replace(picked_result_params[10]->>''result_value'' , ''</[p^>]*>'', E''\n'', ''g''))), ''<[^>]*>'', '''', ''g'')) else picked_result_params[10]->>''result_value'' end)
end as data10
from
  pe_array_agg
  inner join pe_basicinfo on pe_array_agg.pat_event_cd = pe_basicinfo.pat_event_cd
ORDER BY event_start_date, reg_date
;', 2, '[{"preview": "", "can_calc": "0", "data_code": "data1_field_name", "data_name": "データ1フィールド名", "data_type": "string", "conv_table": [], "data_class": "テキストエリア", "field_name": "data1_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "data2_field_name", "data_name": "データ2フィールド名", "data_type": "string", "conv_table": [], "data_class": "テキストエリア", "field_name": "data2_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "data3_field_name", "data_name": "データ3フィールド名", "data_type": "string", "conv_table": [], "data_class": "テキストエリア", "field_name": "data3_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "data4_field_name", "data_name": "データ4フィールド名", "data_type": "string", "conv_table": [], "data_class": "テキストエリア", "field_name": "data4_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "data5_field_name", "data_name": "データ5フィールド名", "data_type": "string", "conv_table": [], "data_class": "テキストエリア", "field_name": "data5_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "data6_field_name", "data_name": "データ6フィールド名", "data_type": "string", "conv_table": [], "data_class": "テキストエリア", "field_name": "data6_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "data7_field_name", "data_name": "データ7フィールド名", "data_type": "string", "conv_table": [], "data_class": "テキストエリア", "field_name": "data7_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "data8_field_name", "data_name": "データ8フィールド名", "data_type": "string", "conv_table": [], "data_class": "テキストエリア", "field_name": "data8_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "data9_field_name", "data_name": "データ9フィールド名", "data_type": "string", "conv_table": [], "data_class": "テキストエリア", "field_name": "data9_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "data10_field_name", "data_name": "データ10フィールド名", "data_type": "string", "conv_table": [], "data_class": "テキストエリア", "field_name": "data10_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "コメントです。", "can_calc": "0", "data_code": "data1", "data_name": "データ1", "data_type": "string", "conv_table": [], "data_class": "テキストエリア", "field_name": "data1", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "コメントです。", "can_calc": "0", "data_code": "data2", "data_name": "データ2", "data_type": "string", "conv_table": [], "data_class": "テキストエリア", "field_name": "data2", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "コメントです。", "can_calc": "0", "data_code": "data3", "data_name": "データ3", "data_type": "string", "conv_table": [], "data_class": "テキストエリア", "field_name": "data3", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "コメントです。", "can_calc": "0", "data_code": "data4", "data_name": "データ4", "data_type": "string", "conv_table": [], "data_class": "テキストエリア", "field_name": "data4", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "コメントです。", "can_calc": "0", "data_code": "data5", "data_name": "データ5", "data_type": "string", "conv_table": [], "data_class": "テキストエリア", "field_name": "data5", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "コメントです。", "can_calc": "0", "data_code": "data6", "data_name": "データ6", "data_type": "string", "conv_table": [], "data_class": "テキストエリア", "field_name": "data6", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "コメントです。", "can_calc": "0", "data_code": "data7", "data_name": "データ7", "data_type": "string", "conv_table": [], "data_class": "テキストエリア", "field_name": "data7", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "コメントです。", "can_calc": "0", "data_code": "data8", "data_name": "データ8", "data_type": "string", "conv_table": [], "data_class": "テキストエリア", "field_name": "data8", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "コメントです。", "can_calc": "0", "data_code": "data9", "data_name": "データ9", "data_type": "string", "conv_table": [], "data_class": "テキストエリア", "field_name": "data9", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "コメントです。", "can_calc": "0", "data_code": "data10", "data_name": "データ10", "data_type": "string", "conv_table": [], "data_class": "テキストエリア", "field_name": "data10", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [1, 2, 3, 9, 10, 11]}', '患者イベント テキストエリア @patId @facilityCd @fromDate @toDate使用', '2021-08-26 13:50:14', CURRENT_TIMESTAMP, NULL);
