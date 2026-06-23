DELETE FROM ntss.sys_data_set 
WHERE sql_cd='44';

INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (44, 'select
  r.item_cd,
  r.reg_order_class,
  CASE WHEN r.count > 0 THEN ''1'' ELSE ''0'' END as has_plan
from(
  select
    info ->> ''set_cd'' as item_cd,
    count ( p.pat_id ) as count,
    p.reg_order_class
  from
    (
    select m.*
    from
      pat_exam_main as m
    where
      m.is_del = ''0''
      and jsonb_array_length(m.order_exam_set_info) > 0
      and m.pat_id = @patId
      and m.facility_cd = @facilityCd
      and m.reg_exam_date between date_trunc(''day'', @date ::timestamp ) and date_trunc(''day'', @date ::timestamp) + ''1 days - 1 milliseconds''
    )
    p cross join lateral json_array_elements (p.order_exam_set_info :: json) info
  group by
  info ->> ''set_cd'',p.reg_order_class
  ) r;', 2, '[{"preview": "〇", "can_calc": "0", "data_code": "has_plan", "data_name": "予定有無", "data_type": "string", "conv_table": [{"code": "0", "disp": "", "item": "予定無し(変換不可)"}, {"code": "1", "disp": "〇", "item": "予定有り"}], "data_class": "検査予定(セット・指定日)", "field_name": "has_plan", "disp_format": "", "filter_type": "ExamSet", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}]', '0', '{"applications": [1]}', '{"classes": [1, 2, 3, 9, 10, 11]}', '検査予定(セット・指定日)：予定有無 @patId @date 使用', '2020-03-26 16:30:00', CURRENT_TIMESTAMP, NULL);

DELETE FROM ntss.sys_data_set 
WHERE sql_cd='49';

INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (49, 'WITH infection_order AS (
SELECT
  one_json ->> ''code'' AS infection_cd,
  json_idx AS infection_cd_order
FROM
  mst_selector
  CROSS JOIN lateral jsonb_array_elements ( order_settings -> ''items'' ) WITH ordinality AS tmp ( one_json, json_idx )
WHERE
  facility_cd = @facilityCd
  AND master_physical_name = ''mst_exam_item''
)
select
  r.item_cd,
  r.reg_order_class,
  CASE WHEN r.count > 0 THEN ''1'' ELSE ''0'' END as has_plan
from(
SELECT
  info ->> ''item_cd'' AS item_cd,
  p.reg_order_class,
  count ( p.pat_id ) as count
  FROM
    (
    SELECT
      m.*
    FROM
      pat_exam_main AS m
    WHERE
      m.is_del = ''0''
      AND jsonb_array_length ( m.order_exam_set_info ) > 0
      AND m.pat_id = @patId
      AND m.facility_cd = @facilityCd
      AND m.reg_exam_date BETWEEN date_trunc ( ''day'', @date :: TIMESTAMP )
      AND date_trunc ( ''day'', @date :: TIMESTAMP ) + ''1 days - 1 milliseconds''
    ) p
    CROSS JOIN lateral json_array_elements ( p.exam_order_info :: json ) info
    LEFT JOIN infection_order AS inf ON info ->> ''item_cd'':: text = inf.infection_cd
    group by info ->> ''item_cd'',p.reg_order_class ) r;', 2, '[{"preview": "〇", "can_calc": "0", "data_code": "has_plan", "data_name": "予定有無", "data_type": "string", "conv_table": [{"code": "0", "disp": "", "item": "予定無し(変換不可)"}, {"code": "1", "disp": "〇", "item": "予定有り"}], "data_class": "検査予定(単項目・指定日)", "field_name": "has_plan", "disp_format": "", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}]', '0', '{"applications": [1]}', '{"classes": [1, 2, 3, 9, 10, 11]}', '検査予定(単項目・指定日)：予定有無 @patId @date 使用', '2020-03-26 20:00:00', CURRENT_TIMESTAMP, NULL);

DELETE FROM ntss.sys_data_set 
WHERE sql_cd='59';

INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (59, 'select
  CASE WHEN p.count > 0 THEN ''1'' ELSE ''0'' END as has_plan
from(
  select
    count(m.*) as count
  from
    pat_rad_main as m
  where
    m.is_del = ''0''
    and jsonb_array_length(m.order_rad_set_info) > 0
      and m.pat_id = @patId
    and m.reg_rad_date between date_trunc(''day'', @date ::timestamp ) and date_trunc(''day'', @date ::timestamp) + ''1 days - 1 milliseconds''
    ) p
;', 2, '[{"preview": "〇", "can_calc": "0", "data_code": "has_plan", "data_name": "予定有無", "data_type": "string", "conv_table": [{"code": "0", "disp": "", "item": "予定無し(変換不可)"}, {"code": "1", "disp": "〇", "item": "予定有り"}], "data_class": "放射線検査予定(指定日)", "field_name": "has_plan", "disp_format": "", "data_category": "一般撮影", "facility_table": "", "facility_filter_type": "0"}]', '0', '{"applications": [1]}', '{"classes": [1, 2, 3, 9, 10, 11]}', '放射線検査予定(指定日)：予定有無 @patId @date 使用', '2020-03-26 22:00:00', CURRENT_TIMESTAMP, NULL);
