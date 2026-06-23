DELETE FROM "ntss"."sys_data_set" where sql_cd in (219);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (219, 'with input_params_expand as
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
    ,pat_id
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
  ,pe_basicinfo.pat_id as pat_id
  ,pe_basicinfo.pat_id as pat_id_to_name
  ,to_timestamp(event_start_date||
    case when event_start_time is null then ''0000''
         else event_start_time
    end, ''yyyyMMDDHH24mi'') AS event_start_date
  ,to_timestamp(event_end_date||
    case when event_end_time is null then ''0000''
         else event_end_time
    end, ''yyyyMMDDHH24mi'') AS event_end_date
	,pe_basicinfo.category_cd
	,pe_basicinfo.category_name
	,pe_basicinfo.sub_category_cd
  ,pe_basicinfo.sub_category_name
  ,reg_staff_name
  ,pe_basicinfo.reg_date
  ,up_staff_name
  ,pe_basicinfo.up_date
from
  pe_array_agg
  inner join pe_basicinfo on pe_array_agg.pat_event_cd = pe_basicinfo.pat_event_cd
ORDER BY event_start_date desc, reg_date desc
;', 2, '[{"preview": "2020/03/26", "can_calc": "0", "data_code": "event_start_date", "data_name": "イベント開始日", "data_type": "DateTime", "conv_table": [], "data_class": "共通情報", "field_name": "event_start_date", "disp_format": "yyyy/mm/dd", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020/03/26", "can_calc": "0", "data_code": "event_end_date", "data_name": "イベント終了日", "data_type": "DateTime", "conv_table": [], "data_class": "共通情報", "field_name": "event_end_date", "disp_format": "yyyy/mm/dd", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト看護師１", "can_calc": "0", "data_code": "reg_staff_name", "data_name": "起票者", "data_type": "string", "conv_table": [], "data_class": "共通情報", "field_name": "reg_staff_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020/03/25", "can_calc": "0", "data_code": "reg_date", "data_name": "起票日", "data_type": "DateTime", "conv_table": [], "data_class": "共通情報", "field_name": "reg_date", "disp_format": "yyyy/mm/dd", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト看護師２", "can_calc": "0", "data_code": "up_staff_name", "data_name": "最終編集者", "data_type": "string", "conv_table": [], "data_class": "共通情報", "field_name": "up_staff_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020/03/26", "can_calc": "0", "data_code": "up_date", "data_name": "最終編集日", "data_type": "DateTime", "conv_table": [], "data_class": "共通情報", "field_name": "up_date", "disp_format": "yyyy/mm/dd", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "123456789012", "can_calc": "0", "conv_sql": {"sql_cd": -1, "field_name": "hosp_pat_id", "target_var": "@patId"}, "data_code": "hosp_pat_id", "data_name": "患者ID", "data_type": "string", "conv_table": [], "data_class": "共通情報", "field_name": "pat_id", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_filter_type": "0"}, {"preview": "テスト患者", "can_calc": "0", "conv_sql": {"sql_cd": -1, "field_name": "pat_name", "target_var": "@patId"}, "data_code": "pat_id_to_name", "data_name": "患者名", "data_type": "string", "conv_table": [], "data_class": "共通情報", "field_name": "pat_id_to_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント", "can_calc": "0", "data_code": "category_name", "data_name": "カテゴリ名", "data_type": "string", "conv_table": [], "data_class": "共通情報", "field_name": "category_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント", "can_calc": "0", "data_code": "sub_category_name", "data_name": "サブカテゴリ名", "data_type": "string", "conv_table": [], "data_class": "共通情報", "field_name": "sub_category_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [1, 2, 3, 9, 10, 11]}', '患者イベント 共通情報　@patId @facilityCd @fromDate @toDate使用', '2024-04-12 11:29:28.607', CURRENT_TIMESTAMP, NULL);
