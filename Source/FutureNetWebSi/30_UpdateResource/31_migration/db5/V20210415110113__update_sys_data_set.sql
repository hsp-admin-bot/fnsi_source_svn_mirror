		
			UPDATE sys_data_set 
SET SQL = 'select
  info->>''set_cd'' as set_cd,
  info->>''set_name'' as set_name,
  item.in_hospital_cd1 as in_hospital_cd1,
  item.in_hospital_cd2 as in_hospital_cd2,
  item.in_hospital_cd3 as in_hospital_cd3,
  item.sbt_cd1 as sbt_cd1,
  item.sbt_cd2 as sbt_cd2,
  item.sbt_cd3 as sbt_cd3,
  p.reg_exam_date,
  p.reg_order_class
from(
  select
    m.*
  from
    pat_exam_main as m
  where
    m.is_del = ''0''
	and jsonb_array_length(m.order_exam_set_info) > 0
  	and m.pat_id = @patId
	and m.reg_exam_date between date_trunc(''day'', @date ::timestamp) and date_trunc(''day'', @date ::timestamp) + ''1 days - 1 milliseconds''
    order by m.reg_exam_date
	) p
  cross join lateral
    json_array_elements (p.order_exam_set_info :: json) info
  left outer join
    mst_exam_set as item on info->>''set_cd'' = (item.exam_set_cd || '''')  and item.is_del =''0'' and item.is_disp =''1''
;' , "detail" = '[{"preview": "1234", "can_calc": "0", "data_code": "in_hospital_cd1", "data_name": "院内コード1", "data_type": "string", "conv_table": [], "data_class": "検査予定(セット・指定日)", "field_name": "in_hospital_cd1", "disp_format": "", "filter_type": "ExamSet", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "4567", "can_calc": "0", "data_code": "in_hospital_cd2", "data_name": "院内コード2", "data_type": "string", "conv_table": [], "data_class": "検査予定(セット・指定日)", "field_name": "in_hospital_cd2", "disp_format": "", "filter_type": "ExamSet", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "7890", "can_calc": "0", "data_code": "in_hospital_cd3", "data_name": "院内コード3", "data_type": "string", "conv_table": [], "data_class": "検査予定(セット・指定日)", "field_name": "in_hospital_cd3", "disp_format": "", "filter_type": "ExamSet", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0123", "can_calc": "0", "data_code": "sbt_cd1", "data_name": "属性コード1", "data_type": "string", "conv_table": [], "data_class": "検査予定(セット・指定日)", "field_name": "sbt_cd1", "disp_format": "", "filter_type": "ExamSet", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "3456", "can_calc": "0", "data_code": "sbt_cd2", "data_name": "属性コード2", "data_type": "string", "conv_table": [], "data_class": "検査予定(セット・指定日)", "field_name": "sbt_cd2", "disp_format": "", "filter_type": "ExamSet", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "6789", "can_calc": "0", "data_code": "sbt_cd3", "data_name": "属性コード3", "data_type": "string", "conv_table": [], "data_class": "検査予定(セット・指定日)", "field_name": "sbt_cd3", "disp_format": "", "filter_type": "ExamSet", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "検査セットテスト", "can_calc": "0", "data_code": "set_name", "data_name": "検査項目名", "data_type": "string", "conv_table": [], "data_class": "検査予定(セット・指定日)", "field_name": "set_name", "disp_format": "", "filter_type": "ExamSet", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/03/12", "can_calc": "0", "data_code": "reg_exam_date", "data_name": "検査日", "data_type": "DateTime", "conv_table": [], "data_class": "検査予定(セット・指定日)", "field_name": "reg_exam_date", "disp_format": "yyyy/mm/dd", "filter_type": "ExamNull", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "透析前", "can_calc": "0", "data_code": "reg_order_class", "data_name": "検査区分", "data_type": "string", "conv_table": [{"code": "0", "disp": "その他", "item": "その他"}, {"code": "1", "disp": "透析前", "item": "透析前"}, {"code": "2", "disp": "透析後", "item": "透析後"}], "data_class": "検査予定(セット・指定日)", "field_name": "reg_order_class", "disp_format": "", "filter_type": "ExamNull", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}]'
WHERE
	sql_cd = '35'