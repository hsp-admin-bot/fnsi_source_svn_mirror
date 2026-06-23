DELETE FROM "ntss"."sys_data_set" where sql_cd in (31,209);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (31, 'with  pat_facility as (
  select facility_cd
  from
    pat_exam_main
  where  
    pat_id =  @patId limit 1
),
infection_order AS (
  select
    one_json ->> ''code'' as infection_cd
    , json_idx as infection_cd_order 
  from
    mst_selector 
    cross join lateral jsonb_array_elements(order_settings -> ''items'') with ordinality as tmp(one_json, json_idx)
  where
    facility_cd =  (select facility_cd from pat_facility )
    and master_physical_name = ''mst_exam_item''
)
select
  info->>''item_cd'' as item_cd,
  item.in_hospital_cd1 as in_hospital_cd1,
  item.in_hospital_cd2 as in_hospital_cd2,
  item.in_hospital_cd3 as in_hospital_cd3,
  item.sbt_cd1 as sbt_cd1,
  item.sbt_cd2 as sbt_cd2,
  item.sbt_cd3 as sbt_cd3,
  info->>''item_name'' as item_name,
  info->>''result'' as result,
  info->>''unit'' as unit,
  info->>''freememo'' as freememo,
  p.result_exam_date as result_exam_date,
  p.reg_exam_date,
  p.reg_order_class,
  p.exam_main_cd as exam_main_cd,
  info->>''upper'' as upper,
  info->>''lower'' as lower
from (
  select
    m.*
  from
    pat_exam_main as m
  where
    m.is_del = ''0''
    and m.exam_status = ''1''
    and m.pat_id = @patId
    and m.result_exam_date < date_trunc(''day'', @fromDate ::timestamp) + ''1 days''
    and m.result_exam_date >= (date_trunc(''day'', @fromDate ::timestamp) - interval ''1 year'')
    order by m.result_exam_date desc
    limit 1
  ) as p
  cross join lateral
    json_array_elements (p.exam_result_info :: json) info
  left outer join
    mst_exam_item as item on info->>''item_cd'' = (item.exam_item_cd || '''')  and item.is_del = ''0'' and item.is_disp =''1''
  left  join  infection_order as inf  on  info->>''item_cd''=inf.infection_cd
order by
  infection_cd_order,reg_exam_date
;', 2, '[{"preview": "1234", "can_calc": "0", "data_code": "in_hospital_cd1", "data_name": "院内コード1", "data_type": "string", "conv_table": [], "data_class": "検査結果(指定日以前)", "field_name": "in_hospital_cd1", "disp_format": "", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "4567", "can_calc": "0", "data_code": "in_hospital_cd2", "data_name": "院内コード2", "data_type": "string", "conv_table": [], "data_class": "検査結果(指定日以前)", "field_name": "in_hospital_cd2", "disp_format": "", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "7890", "can_calc": "0", "data_code": "in_hospital_cd3", "data_name": "院内コード3", "data_type": "string", "conv_table": [], "data_class": "検査結果(指定日以前)", "field_name": "in_hospital_cd3", "disp_format": "", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0123", "can_calc": "0", "data_code": "sbt_cd1", "data_name": "属性コード1", "data_type": "string", "conv_table": [], "data_class": "検査結果(指定日以前)", "field_name": "sbt_cd1", "disp_format": "", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "3456", "can_calc": "0", "data_code": "sbt_cd2", "data_name": "属性コード2", "data_type": "string", "conv_table": [], "data_class": "検査結果(指定日以前)", "field_name": "sbt_cd2", "disp_format": "", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "6789", "can_calc": "0", "data_code": "sbt_cd3", "data_name": "属性コード3", "data_type": "string", "conv_table": [], "data_class": "検査結果(指定日以前)", "field_name": "sbt_cd3", "disp_format": "", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "検査項目テスト", "can_calc": "0", "data_code": "item_name", "data_name": "検査項目名", "data_type": "string", "conv_table": [], "data_class": "検査結果(指定日以前)", "field_name": "item_name", "disp_format": "", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "11.2", "can_calc": "0", "data_code": "result", "data_name": "検査結果", "data_type": "string", "conv_table": [], "data_class": "検査結果(指定日以前)", "field_name": "result", "disp_format": "", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "mg/dL", "can_calc": "0", "data_code": "unit", "data_name": "単位", "data_type": "string", "conv_table": [], "data_class": "検査結果(指定日以前)", "field_name": "unit", "disp_format": "", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "検査結果のテストです。", "can_calc": "0", "data_code": "freememo", "data_name": "検査コメント", "data_type": "string", "conv_table": [], "data_class": "検査結果(指定日以前)", "field_name": "freememo", "disp_format": "", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/03/12", "can_calc": "0", "data_code": "result_exam_date", "data_name": "検査日", "data_type": "DateTime", "conv_table": [], "data_class": "検査結果(指定日以前)", "field_name": "result_exam_date", "disp_format": "yyyy/mm/dd", "filter_type": "ExamNull", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "透析前", "can_calc": "0", "data_code": "reg_order_class", "data_name": "検査区分", "data_type": "string", "conv_table": [{"code": "0", "disp": "その他", "item": "その他"}, {"code": "1", "disp": "透析前", "item": "透析前"}, {"code": "2", "disp": "透析後", "item": "透析後"}], "data_class": "検査結果(指定日以前)", "field_name": "reg_order_class", "disp_format": "", "filter_type": "ExamNull", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "15.0", "can_calc": "0", "data_code": "upper", "data_name": "正常値上限", "data_type": "decimal", "conv_table": [], "data_class": "検査結果(指定日以前)", "field_name": "upper", "disp_format": "0.0", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10.0", "can_calc": "0", "data_code": "lower", "data_name": "正常値下限", "data_type": "decimal", "conv_table": [], "data_class": "検査結果(指定日以前)", "field_name": "lower", "disp_format": "0.0", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [1, 2, 3, 9, 10, 11]}', '検査結果(指定日以前) @patId @date 使用', '2020-03-25 18:00:00', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (209, 'with input_params_expand as
(SELECT event_start_date,json_info ->>''name'' as data_pic_name,json_info ->>''file_path'' as data1_pic1_file_path,pat_event_cd
from (
SELECT pat_event_cd,event_start_date,info->>''result_value'' resul_json

FROM pat_event 
CROSS JOIN LATERAL json_array_elements ( result_params ::json ) info
where is_del = ''0''
    and use_type = 1 
		and pat_id = @patId
		and (info ->>''format_class'') = ''2'') a
		 CROSS JOIN LATERAL json_array_elements ( resul_json :: json ) json_info)
 , input_params_expand_5 as (
SELECT event_start_date,info->>''result_value'' resul_json,pat_event_cd
FROM pat_event 
CROSS JOIN LATERAL json_array_elements ( result_params ::json ) info
where is_del = ''0''
    and use_type = 1 
		and pat_id = @patId
		and (info ->>''format_class'') = ''5''
 )
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
select * from ((select a.*,parms_5.resul_json  as make_start_date from input_params_expand a 
INNER JOIN order_main on order_main.va =a.data_pic_name 
LEFT JOIN input_params_expand_5 parms_5 on parms_5.pat_event_cd = a.pat_event_cd
where a.data_pic_name<>'''' 
and order_main.treat_date = a.event_start_date ORDER BY a.event_start_date desc)
 UNION ALL
(select a.*,parms_5.resul_json  as make_start_date from input_params_expand as a 
INNER JOIN order_main on order_main.va =a.data_pic_name 
LEFT JOIN input_params_expand_5 parms_5 on parms_5.pat_event_cd = a.pat_event_cd
where a.data_pic_name<>'''' and a.event_start_date < to_char(date_trunc(''day'', @fromDate::timestamp), ''yyyymmdd'') ORDER BY a.event_start_date desc)
) b 
LIMIT 1', 2, '[{"preview": "2011/05/20", "can_calc": "0", "data_code": "event_start_date", "data_name": "開始日時", "data_type": "DateTime", "conv_table": [], "data_class": "VA情報", "field_name": "event_start_date", "disp_format": "yyyy/mm/dd", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/05/20", "can_calc": "0", "data_code": "make_start_date", "data_name": "造設日", "data_type": "DateTime", "conv_table": [], "data_class": "VA情報", "field_name": "make_start_date", "disp_format": "yyyy/mm/dd", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data1_pic1_file_path", "data_name": "画像", "data_type": "byte[]", "conv_table": [], "data_class": "VA情報", "field_name": "data1_pic1_file_path", "disp_format": "", "filter_type": "Category", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}]', '0', '{"applications": [1]}', '{"classes": [1, 2, 3, 9]}', 'VA情報 増設日 画像(実績)', '2023-04-23 09:37:00', CURRENT_TIMESTAMP, NULL);
