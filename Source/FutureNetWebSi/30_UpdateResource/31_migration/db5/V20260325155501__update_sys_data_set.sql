DELETE FROM "ntss"."sys_data_set" where sql_cd in (53,54,55,321,322);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (53, 'select
  spitz.spitz_name,
	p.exam_main_cd,
  p.reg_exam_date
from(
  select
    m.*
  from
    pat_exam_main as m
  where
    m.is_del = ''0''
    and jsonb_array_length(m.order_exam_set_info) > 0
     and m.pat_id = @patId
    and m.reg_exam_date between date_trunc(''day'',  @date ::timestamp ) and date_trunc(''day'',  @date ::timestamp) + ''1 days - 1 milliseconds''
    order by m.reg_exam_date
    ) p
  cross join lateral
    json_array_elements (p.exam_order_info :: json) info
  left outer join
    mst_exam_item as item on info->>''item_cd'' = (item.exam_item_cd || '''')  and  item.is_del =''0'' and item.is_disp =''1''
  left outer join
    mst_spitz as spitz on item.spitz_cd = spitz.spitz_cd  and spitz.is_del =''0'' and spitz.is_disp =''1''
where
  spitz.spitz_name is not null
	order by p.reg_exam_date,p.exam_main_cd,spitz.spitz_name
;', 2, '[{"preview": "採血管テスト", "can_calc": "0", "data_code": "spitz_name", "data_name": "採血管名", "data_type": "string", "conv_table": [], "data_class": "検査予定(採血管・指定日)", "field_name": "spitz_name", "disp_format": "", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [1, 2, 3, 9, 10]}', '検査予定(採血管・指定日) 単型 @patId @date', '2020-03-26 21:00:00', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (54, 'select
  spitz.spitz_name,
	p.exam_main_cd,
  p.reg_exam_date
from(
  select
    m.*
  from
    pat_exam_main as m
  where
    m.is_del = ''0''
    and jsonb_array_length(m.order_exam_set_info) > 0
     and m.pat_id = @patId
    and m.reg_exam_date between date_trunc(''day'', @fromDate ::timestamp ) and date_trunc(''day'', @toDate ::timestamp) + ''1 days - 1 milliseconds''
    order by m.reg_exam_date
    ) p
  cross join lateral
    json_array_elements (p.exam_order_info :: json) info
  left outer join
    mst_exam_item as item on info->>''item_cd'' = (item.exam_item_cd || '''')  and  item.is_del =''0'' and item.is_disp =''1''
  left outer join
    mst_spitz as spitz on item.spitz_cd = spitz.spitz_cd  and spitz.is_del =''0'' and spitz.is_disp =''1''
where
  spitz.spitz_name is not null
	order by p.reg_exam_date,p.exam_main_cd,spitz.spitz_name
;', 2, '[{"preview": "採血管テスト", "can_calc": "0", "data_code": "spitz_name", "data_name": "採血管名", "data_type": "string", "conv_table": [], "data_class": "検査予定(採血管・日付範囲)", "field_name": "spitz_name", "disp_format": "", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [2, 3]}', '検査予定(採血管・日付範囲) @patId @fromDate @toDate 使用', '2020-03-26 21:00:00', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (55, 'select
  spitz.spitz_name,
	p.exam_main_cd,
  p.reg_exam_date
from(
  select
    m.*
  from
    pat_exam_main as m
  where
    m.is_del = ''0''
    and jsonb_array_length(m.order_exam_set_info) > 0
      and m.pat_id = @patId
    and m.reg_exam_date >= date_trunc(''day'', @date ::timestamp )
    order by m.reg_exam_date
    limit 100
    ) p
  cross join lateral
    json_array_elements (p.exam_order_info :: json) info
  left outer join
    mst_exam_item as item on info->>''item_cd'' = (item.exam_item_cd || '''')  and  item.is_del =''0'' and item.is_disp =''1''
  left outer join
    mst_spitz as spitz on item.spitz_cd = spitz.spitz_cd  and spitz.is_del =''0'' and spitz.is_disp =''1''
where
  spitz.spitz_name is not null
	order by p.reg_exam_date,p.exam_main_cd,spitz.spitz_name
;', 2, '[{"preview": "採血管テスト", "can_calc": "0", "data_code": "spitz_name", "data_name": "採血管名", "data_type": "string", "conv_table": [], "data_class": "検査予定(採血管・指定日以降)", "field_name": "spitz_name", "disp_format": "", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [1, 2, 3, 9, 10]}', '検査予定(採血管・指定日以降) 単型 @patId @date', '2020-03-26 21:00:00', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (321, 'select
  p.pat_id,
	p.exam_main_cd,
	p.reg_exam_date,
	spitz.spitz_name
from(
  select
    m.*
  from
    pat_exam_main as m
  where
    m.is_del = ''0''
    and jsonb_array_length(m.order_exam_set_info) > 0
     and m.pat_id IN (@patIds)
    and m.reg_exam_date between date_trunc(''day'',  @date ::timestamp ) and date_trunc(''day'',  @date ::timestamp) + ''1 days - 1 milliseconds''
    order by m.reg_exam_date
    ) p
  cross join lateral
    json_array_elements (p.exam_order_info :: json) info
  left outer join
    mst_exam_item as item on info->>''item_cd'' = (item.exam_item_cd || '''')  and  item.is_del =''0'' and item.is_disp =''1''
  left outer join
    mst_spitz as spitz on item.spitz_cd = spitz.spitz_cd  and spitz.is_del =''0'' and spitz.is_disp =''1''
where
  spitz.spitz_name is not null
	order by p.reg_exam_date,p.exam_main_cd,spitz.spitz_name
;', 2, '[{"preview": "採血管テスト", "can_calc": "0", "data_code": "spitz_name", "data_name": "採血管名", "data_type": "string", "conv_table": [], "data_class": "検査予定(採血管・指定日)", "field_name": "spitz_name", "disp_format": "", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [11]}', '検査予定(採血管・指定日) 複数型 @patIds @date', '2026-01-29 17:03:46.151', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (322, 'select
  p.pat_id,
	p.exam_main_cd,
	p.reg_exam_date,
	spitz.spitz_name
from(
  select
    m.*
  from
    pat_exam_main as m
  where
    m.is_del = ''0''
    and jsonb_array_length(m.order_exam_set_info) > 0
      and m.pat_id IN (@patIds)
    and m.reg_exam_date >= date_trunc(''day'', @date ::timestamp )
    order by m.reg_exam_date
    limit 100
    ) p
  cross join lateral
    json_array_elements (p.exam_order_info :: json) info
  left outer join
    mst_exam_item as item on info->>''item_cd'' = (item.exam_item_cd || '''')  and  item.is_del =''0'' and item.is_disp =''1''
  left outer join
    mst_spitz as spitz on item.spitz_cd = spitz.spitz_cd  and spitz.is_del =''0'' and spitz.is_disp =''1''
where
  spitz.spitz_name is not null
	order by p.reg_exam_date,p.exam_main_cd,spitz.spitz_name
;', 2, '[{"preview": "採血管テスト", "can_calc": "0", "data_code": "spitz_name", "data_name": "採血管名", "data_type": "string", "conv_table": [], "data_class": "検査予定(採血管・指定日以降)", "field_name": "spitz_name", "disp_format": "", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [11]}', '検査予定(採血管・指定日以降) 複数型 @patIds @date', '2026-01-29 17:03:46.152', CURRENT_TIMESTAMP, NULL);
