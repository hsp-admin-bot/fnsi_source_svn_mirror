UPDATE "ntss"."sys_data_set" SET "sql" = 'WITH pat_in_out_visit_history_tbl AS (
SELECT
	to_number ( info ->> ''ctl_no'', ''99999'' ) AS ctl_no,
	to_number ( info ->> ''disp_order'', ''99999'' ) AS disp_order,
	info ->> ''facility_cd'' AS facility_cd,
	info ->> ''move_in_out'' AS move_in_out,
	info ->> ''period_start'' AS period_start,
	info ->> ''period_end'' period_end,
	info ->> ''in_out'' AS in_out,
	info ->> ''reason'' AS reason,
	info ->> ''from_facility'' AS from_facility,
	info ->> ''from_course'' AS from_course,
	info ->> ''from_doctor'' AS from_doctor,
	info ->> ''to_facility'' AS to_facility,
	info ->> ''to_course'' AS to_course,
	info ->> ''to_doctor'' AS to_doctor,
	info ->> ''is_reply'' AS is_reply,
	info ->> ''comment'' AS COMMENT 
FROM
	pat_unique
	CROSS JOIN lateral json_array_elements ( pat_unique.in_out_visit_history_info :: json ) info 
WHERE
	pat_id = @patId 
	AND is_del = ''0'' 
	) SELECT
	to_date ( pat_in_out_visit_history_tbl.period_start, ''YYYYMMDD'' ) AS period_start,
	pat_in_out_visit_history_tbl.ctl_no,
	pat_in_out_visit_history_tbl.disp_order,
	pat_in_out_visit_history_tbl.facility_cd,
	pat_in_out_visit_history_tbl.move_in_out,
	to_date ( pat_in_out_visit_history_tbl.period_end, ''YYYYMMDD'' ) AS period_end,
	pat_in_out_visit_history_tbl.in_out,
	pat_in_out_visit_history_tbl.reason,
	pat_in_out_visit_history_tbl.from_facility,
	pat_in_out_visit_history_tbl.from_course,
	pat_in_out_visit_history_tbl.from_doctor,
	pat_in_out_visit_history_tbl.to_facility,
	pat_in_out_visit_history_tbl.to_course,
	pat_in_out_visit_history_tbl.to_doctor,
	pat_in_out_visit_history_tbl.is_reply,
	pat_in_out_visit_history_tbl.COMMENT,
CASE
	
	WHEN from_facility_tbl.facility_name IS NULL THEN
	pat_in_out_visit_history_tbl.from_facility ELSE from_facility_tbl.facility_name 
	END AS from_facility_name,
CASE
		
		WHEN from_course_tbl.course_name IS NULL THEN
		pat_in_out_visit_history_tbl.from_course ELSE from_course_tbl.course_name 
	END AS from_course_name,
CASE
		
		WHEN to_facility_tbl.facility_name IS NULL THEN
		pat_in_out_visit_history_tbl.from_facility ELSE to_facility_tbl.facility_name 
	END AS to_facility_name,
	
	CASE
		
		WHEN facility_cd_tbl.facility_name IS NULL THEN
		pat_in_out_visit_history_tbl.facility_cd ELSE facility_cd_tbl.facility_name 
	END AS facility_cd_name,
	
	
CASE
		
		WHEN to_course_tbl.course_name IS NULL THEN
		pat_in_out_visit_history_tbl.from_course ELSE to_course_tbl.course_name 
	END AS to_course_name 
FROM
	pat_in_out_visit_history_tbl
	LEFT JOIN mst_facility AS from_facility_tbl ON pat_in_out_visit_history_tbl.from_facility = from_facility_tbl.facility_cd
	LEFT JOIN mst_course AS from_course_tbl ON pat_in_out_visit_history_tbl.from_course = from_course_tbl.course_cd :: text 
	AND from_course_tbl.is_disp = ''1'' 
	AND from_course_tbl.is_del = ''0''
	LEFT JOIN mst_facility AS to_facility_tbl ON pat_in_out_visit_history_tbl.to_facility = to_facility_tbl.facility_cd
	LEFT JOIN mst_course AS to_course_tbl ON pat_in_out_visit_history_tbl.to_course = to_course_tbl.course_cd :: text 
	AND to_course_tbl.is_disp = ''1'' 
	AND to_course_tbl.is_del = ''0''
	LEFT JOIN mst_facility AS facility_cd_tbl ON pat_in_out_visit_history_tbl.facility_cd = facility_cd_tbl.facility_cd 
ORDER BY
	disp_order,
ctl_no', "detail" = '[{"preview": "2011/04/21", "can_calc": "0", "data_code": "period_start", "data_name": "発生日", "data_type": "DateTime", "conv_table": [], "data_class": "転入・転出", "field_name": "period_start", "disp_format": "yyyy/mm/dd", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/04/21", "can_calc": "0", "data_code": "period_end", "data_name": "転入出期間(終了)", "data_type": "DateTime", "conv_table": [], "data_class": "転入・転出", "field_name": "period_end", "disp_format": "yyyy/mm/dd", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "facility_cd_name", "data_name": "登録施設コード", "data_type": "DateTime", "conv_table": [], "data_class": "転入・転出", "field_name": "facility_cd_name", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "転出", "can_calc": "0", "data_code": "move_in_out", "data_name": "区分", "data_type": "string", "conv_table": [{"code": "0", "disp": "転入", "item": "転入"}, {"code": "1", "disp": "転出", "item": "転出"}, {"code": "2", "disp": "その他", "item": "その他"}], "data_class": "転入・転出", "field_name": "move_in_out", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "入院", "can_calc": "0", "data_code": "in_out", "data_name": "入外区分", "data_type": "string", "conv_table": [{"code": "0", "disp": "外来", "item": "外来"}, {"code": "1", "disp": "入院", "item": "入院"}, {"code": "2", "disp": "死亡", "item": "死亡"}, {"code": "3", "disp": "－(不在)", "item": "－(不在)"}], "data_class": "転入・転出", "field_name": "in_out", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "日機装第二クリニック", "can_calc": "0", "data_code": "from_facility_name", "data_name": "転入元施設名", "data_type": "string", "conv_table": [], "data_class": "転入・転出", "field_name": "from_facility_name", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "第二透析科", "can_calc": "0", "data_code": "from_course_name", "data_name": "転入元科", "data_type": "string", "conv_table": [], "data_class": "転入・転出", "field_name": "from_course_name", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト医師１", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "from_doctor", "data_name": "転入元医師", "data_type": "string", "conv_table": [], "data_class": "転入・転出", "field_name": "from_doctor", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "日機装第一クリニック", "can_calc": "0", "data_code": "to_facility_name", "data_name": "転出先施設名", "data_type": "string", "conv_table": [], "data_class": "転入・転出", "field_name": "to_facility_name", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "第一透析科", "can_calc": "0", "data_code": "to_course_name", "data_name": "転出先科", "data_type": "string", "conv_table": [], "data_class": "転入・転出", "field_name": "to_course_name", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト医師２", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "to_doctor", "data_name": "転出先医師", "data_type": "string", "conv_table": [], "data_class": "転入・転出", "field_name": "to_doctor", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "入出理由です。", "can_calc": "0", "data_code": "reason", "data_name": "入出理由", "data_type": "string", "conv_table": [], "data_class": "転入・転出", "field_name": "reason", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "転入・転出コメントです。", "can_calc": "0", "data_code": "comment", "data_name": "コメント", "data_type": "string", "conv_table": [], "data_class": "転入・転出", "field_name": "comment", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}]' WHERE "sql_cd" = 43;
UPDATE "ntss"."sys_data_set" SET "sql" = 'select
  CASE WHEN p.count > 0 THEN ''1'' ELSE ''0'' END as has_plan
from(
  select
    count(m.pat_id) as count
  from
    pat_exam_main as m
  where
    m.is_del = ''0''
    and jsonb_array_length(m.order_exam_set_info) > 0
      and m.pat_id = @patId
    and m.reg_exam_date between date_trunc(''day'', @date ::timestamp ) and date_trunc(''day'', @date ::timestamp) + ''1 days - 1 milliseconds''
    ) p
;' WHERE "sql_cd" = 44;
UPDATE "ntss"."sys_data_set" SET "sql" = 'with input_params_expand as
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
    --and use_type = 2 and ord_no = @ordNo
    and use_type = 2 and pat_id = @patId and cast(event_start_date as date) between to_date(@fromDate, ''YYYY/MM/DD'') and to_date(@toDate, ''YYYY/MM/DD'')
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
    --and use_type = 2 and ord_no = @ordNo
    and use_type = 2 and pat_id = @patId and cast(event_start_date as date) between to_date(@fromDate, ''YYYY/MM/DD'') and to_date(@toDate, ''YYYY/MM/DD'')
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
    --and use_type = 2 and ord_no = @ordNo
    and use_type = 2 and pat_id = @patId and cast(event_start_date as date) between to_date(@fromDate, ''YYYY/MM/DD'') and to_date(@toDate, ''YYYY/MM/DD'')
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
    input_param->>''format_class'' in (''0'',''1'')
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
  ,to_date(event_start_date, ''YYYYMMDD'') as event_start_date                                
  ,to_date(event_end_date, ''YYYYMMDD'') as event_end_date
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
  ,picked_input_params[11]->>''field_name'' as data11_field_name
  ,picked_input_params[12]->>''field_name'' as data12_field_name
  ,picked_input_params[13]->>''field_name'' as data13_field_name
  ,picked_input_params[14]->>''field_name'' as data14_field_name
  ,picked_input_params[15]->>''field_name'' as data15_field_name
  ,picked_input_params[16]->>''field_name'' as data16_field_name
  ,picked_input_params[17]->>''field_name'' as data17_field_name
  ,picked_input_params[18]->>''field_name'' as data18_field_name
  ,picked_input_params[19]->>''field_name'' as data19_field_name
  ,picked_input_params[20]->>''field_name'' as data20_field_name
  ,picked_input_params[21]->>''field_name'' as data21_field_name
  ,picked_input_params[22]->>''field_name'' as data22_field_name
  ,picked_input_params[23]->>''field_name'' as data23_field_name
  ,picked_input_params[24]->>''field_name'' as data24_field_name
  ,picked_input_params[25]->>''field_name'' as data25_field_name
  ,picked_input_params[26]->>''field_name'' as data26_field_name
  ,picked_input_params[27]->>''field_name'' as data27_field_name
  ,picked_input_params[28]->>''field_name'' as data28_field_name
  ,picked_input_params[29]->>''field_name'' as data29_field_name
  ,picked_input_params[30]->>''field_name'' as data30_field_name
  ,picked_result_params[1]->>''result_value'' as data1 
  ,picked_result_params[2]->>''result_value'' as data2
  ,picked_result_params[3]->>''result_value'' as data3
  ,picked_result_params[4]->>''result_value'' as data4
  ,picked_result_params[5]->>''result_value'' as data5
  ,picked_result_params[6]->>''result_value'' as data6
  ,picked_result_params[7]->>''result_value'' as data7
  ,picked_result_params[8]->>''result_value'' as data8
  ,picked_result_params[9]->>''result_value'' as data9
  ,picked_result_params[10]->>''result_value'' as data10
  ,picked_result_params[11]->>''result_value'' as data11
  ,picked_result_params[12]->>''result_value'' as data12
  ,picked_result_params[13]->>''result_value'' as data13
  ,picked_result_params[14]->>''result_value'' as data14
  ,picked_result_params[15]->>''result_value'' as data15
  ,picked_result_params[16]->>''result_value'' as data16
  ,picked_result_params[17]->>''result_value'' as data17
  ,picked_result_params[18]->>''result_value'' as data18
  ,picked_result_params[19]->>''result_value'' as data19
  ,picked_result_params[20]->>''result_value'' as data20
  ,picked_result_params[21]->>''result_value'' as data21
  ,picked_result_params[22]->>''result_value'' as data22
  ,picked_result_params[23]->>''result_value'' as data23
  ,picked_result_params[24]->>''result_value'' as data24
  ,picked_result_params[25]->>''result_value'' as data25
  ,picked_result_params[26]->>''result_value'' as data26
  ,picked_result_params[27]->>''result_value'' as data27
  ,picked_result_params[28]->>''result_value'' as data28
  ,picked_result_params[29]->>''result_value'' as data29
  ,picked_result_params[30]->>''result_value'' as data30
from
  pe_array_agg
  inner join pe_basicinfo on pe_array_agg.pat_event_cd = pe_basicinfo.pat_event_cd
	order  by   event_start_date, reg_date
;' WHERE "sql_cd" = 50;
