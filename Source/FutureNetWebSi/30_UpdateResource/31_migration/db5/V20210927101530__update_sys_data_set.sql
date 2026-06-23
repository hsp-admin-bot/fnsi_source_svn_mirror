UPDATE "ntss"."sys_data_set" SET "sql" = 'select
  spitz.spitz_name,
	spitz.label_print,
	spitz.is_in_hospital,
	p.pat_id,
	p.reg_order_class
from(
  select
    m.*
  from
    pat_exam_main as m
  where
    m.is_del = ''0''
    and jsonb_array_length(m.order_exam_set_info) > 0
      and m.pat_id in (@patIds)
    and m.reg_exam_date between date_trunc(''day'',  @treatDate ::timestamp ) and date_trunc(''day'',  @treatDate ::timestamp) + ''1 days - 1 milliseconds''
    order by m.reg_exam_date
    ) p
  cross join lateral
    json_array_elements (p.order_label_info :: json) info
  left outer join
    mst_spitz as spitz on info->>''spitz_cd'' = spitz.spitz_cd::TEXT and spitz.is_del =''0'' and spitz.is_disp =''1''
where
  spitz.spitz_name is not null', "db_class" = 2, "detail" = '[{"preview": "採血管テスト", "can_calc": "0", "data_code": "spitz_name", "data_name": "採血管名", "data_type": "string", "conv_table": [], "data_class": "採血管", "field_name": "spitz_name", "disp_format": "", "data_category": "ラベル", "facility_table": "", "facility_filter_type": "0"}, {"preview": "検査区分", "can_calc": "0", "data_code": "reg_order_class", "data_name": "検査区分", "data_type": "string", "conv_table": [{"code": "0", "disp": "その他", "item": "その他"}, {"code": "1", "disp": "透析前", "item": "透析前"}, {"code": "2", "disp": "透析後", "item": "透析後"}], "data_class": "採血管", "field_name": "reg_order_class", "disp_format": "", "data_category": "ラベル", "facility_table": "", "facility_filter_type": "0"}, {"preview": "ラベル印字項目", "can_calc": "0", "data_code": "label_print", "data_name": "ラベル印字項目", "data_type": "string", "conv_table": [], "data_class": "採血管", "field_name": "label_print", "disp_format": "", "data_category": "ラベル", "facility_table": "", "facility_filter_type": "0"}, {"preview": "院内・院外", "can_calc": "0", "data_code": "is_in_hospital", "data_name": "院内・院外", "data_type": "string", "conv_table": [{"code": "0", "disp": "院内", "item": "院内"}, {"code": "1", "disp": "院外", "item": "院外"}], "data_class": "採血管", "field_name": "is_in_hospital", "disp_format": "", "data_category": "ラベル", "facility_table": "", "facility_filter_type": "0"}]', "can_repeat" = '0', "use_application" = '{"applications": [1]}', "report_class" = '{"classes": [8]}', "memo" = '検査予定(採血管・指定日) @patId @date 使用', "reg_date" = '2020-03-26 21:00:00', "up_date" = '2020-03-28 14:00:00', "pre_sql_info" = NULL WHERE "sql_cd" = 17;
