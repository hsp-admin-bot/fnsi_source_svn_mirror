DELETE FROM "ntss"."sys_data_set" where sql_cd in (31,247,314);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (31, 'WITH infection_order AS (
  SELECT
    one_json ->> ''code'' AS infection_cd,
    json_idx AS infection_cd_order
  FROM mst_selector
  CROSS JOIN LATERAL jsonb_array_elements(order_settings -> ''items'')
       WITH ORDINALITY AS tmp(one_json, json_idx)
  WHERE facility_cd = @facilityCd
    AND master_physical_name = ''mst_exam_item''
),

params AS (
  SELECT 
      date_trunc(''day'',@fromDate::timestamp) AS target_day,
      date_trunc(''day'',@fromDate::timestamp) - interval ''1 year'' AS from_day
),
base_exam_cd AS (
 SELECT m.exam_main_cd ,m.result_exam_date,m.pat_id FROM pat_exam_main m
 JOIN params p
    ON m.result_exam_date <  p.target_day + interval ''1 day''
		and m.result_exam_date >  p.target_day
		WHERE m.is_del = ''0''
    AND m.exam_status = ''1''
    AND m.pat_id = @patId

    AND m.facility_cd = @facilityCd
		ORDER BY m.result_exam_date LIMIT 1 
),
raw_year AS (
  SELECT
      m.pat_id              AS pat_id,
      k.exam_main_cd        AS exam_main_cd,
      m.result_exam_date    AS result_exam_date,
      m.reg_exam_date       AS reg_exam_date,
      m.reg_order_class     AS m_reg_order_class,

      info_json ->> ''item_cd''   AS item_cd,
      info_json ->> ''item_name'' AS item_name,
      COALESCE(info_json ->> ''reg_order_class'',
               m.reg_order_class::text) AS reg_order_class,
      info_json
  FROM pat_exam_main m
  JOIN params p
    ON m.result_exam_date >= p.from_day
   AND m.result_exam_date <  p.target_day + interval ''1 day''
  CROSS JOIN LATERAL
       json_array_elements(coalesce(m.exam_result_info::json, ''[]''::json)) AS info(info_json)
	left JOIN base_exam_cd k
	   ON	m.pat_id = k.pat_id
  WHERE m.is_del = ''0''
    AND m.exam_status = ''1''
    AND m.pat_id = @patId
    AND m.facility_cd = @facilityCd
),

near_day_date AS (
  SELECT DISTINCT ON (pat_id)
      pat_id,
      result_exam_date AS base_day
  FROM raw_year
  ORDER BY pat_id, result_exam_date DESC
),

raw_day AS (
  SELECT ry.*
  FROM raw_year ry
  LEFT JOIN near_day_date nd
    ON nd.pat_id = ry.pat_id
   AND date_trunc(''day'', ry.result_exam_date)
       = date_trunc(''day'', nd.base_day)
),

base_item AS (
  SELECT DISTINCT ON (pat_id, item_cd)
      pat_id,
      item_cd,
      item_name,
      result_exam_date AS base_result_exam_date,
      reg_exam_date    AS base_reg_exam_date,
      info_json        AS base_info_json,
      exam_main_cd     AS base_exam_main_cd
  FROM raw_day
  ORDER BY
      pat_id,
      item_cd,
      result_exam_date DESC,
      reg_exam_date DESC
),

real_year_nearest AS (
  SELECT DISTINCT ON (pat_id, item_cd, reg_order_class)
      pat_id,
      item_cd,
      item_name,
      reg_order_class,
      result_exam_date AS real_result_exam_date,
      reg_exam_date    AS real_reg_exam_date,
      info_json        AS real_info_json,
      exam_main_cd     AS real_exam_main_cd,
			reg_order_class  AS real_reg_order_class,
			item_name   AS real_item_name
  FROM raw_year ry
  CROSS JOIN params p
  ORDER BY
      pat_id,
      item_cd,
      reg_order_class,
      result_exam_date DESC,
      reg_exam_date DESC
),

class_list AS (
  SELECT ''1'' AS class_cd UNION ALL
  SELECT ''2'' UNION ALL
  SELECT ''0''
),

item_with_class AS (
  SELECT
      b.item_cd,
      b.pat_id,
      b.item_name,
      b.base_result_exam_date,
      b.base_reg_exam_date,
      b.base_exam_main_cd,
      c.class_cd AS reg_order_class,

      r.real_result_exam_date,
      r.real_reg_exam_date,
      r.real_info_json,
      r.real_exam_main_cd,
			r.real_reg_order_class,
			r.real_item_name
  FROM base_item b
  CROSS JOIN class_list c
  LEFT JOIN real_year_nearest r
    ON r.pat_id = b.pat_id
   AND r.item_cd = b.item_cd
   AND r.reg_order_class = c.class_cd
),

item_expanded AS (
  SELECT
      pat_id,
      item_cd,
			item_name,
      real_item_name,

      real_result_exam_date AS result_exam_date,
      real_reg_exam_date    AS reg_exam_date,

      reg_order_class,
			real_reg_order_class,
      COALESCE(real_exam_main_cd, base_exam_main_cd) AS exam_main_cd,
      real_info_json AS info_json
  FROM item_with_class
),

final_join AS (
  SELECT
      e.pat_id,
      e.item_cd,
			e.item_name,
      e.real_item_name,

      itm.in_hospital_cd1,
      itm.in_hospital_cd2,
      itm.in_hospital_cd3,
      itm.sbt_cd1,
      itm.sbt_cd2,
      itm.sbt_cd3,

      e.info_json ->> ''result''   AS result,
      e.info_json ->> ''unit''     AS unit,
      e.info_json ->> ''freememo'' AS freememo,
      e.info_json ->> ''upper''    AS upper,
      e.info_json ->> ''lower''    AS lower,

      e.result_exam_date AS result_exam_output_base_date,
      @fromDate ::date AS reg_exam_date,
      e.reg_exam_date AS real_reg_exam_date,
      e.reg_order_class,
			e.real_reg_order_class,
      e.exam_main_cd,

      inf.infection_cd_order
  FROM item_expanded e
  LEFT JOIN mst_exam_item itm
    ON itm.exam_item_cd::text = e.item_cd
   AND itm.is_del = ''0''
   AND itm.is_disp = ''1''
	 AND e.real_reg_order_class is not null
  LEFT JOIN infection_order inf
    ON e.item_cd = inf.infection_cd
)

SELECT *
FROM final_join
ORDER BY
  pat_id,
  item_cd,
  ARRAY_POSITION(ARRAY[''1'',''2'',''0''], reg_order_class),
  infection_cd_order;
', 2, '[{"preview": "1234", "can_calc": "0", "data_code": "in_hospital_cd1", "data_name": "院内コード1", "data_type": "string", "conv_table": [], "data_class": "検査結果(指定日以前)", "field_name": "in_hospital_cd1", "disp_format": "", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "4567", "can_calc": "0", "data_code": "in_hospital_cd2", "data_name": "院内コード2", "data_type": "string", "conv_table": [], "data_class": "検査結果(指定日以前)", "field_name": "in_hospital_cd2", "disp_format": "", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "7890", "can_calc": "0", "data_code": "in_hospital_cd3", "data_name": "院内コード3", "data_type": "string", "conv_table": [], "data_class": "検査結果(指定日以前)", "field_name": "in_hospital_cd3", "disp_format": "", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0123", "can_calc": "0", "data_code": "sbt_cd1", "data_name": "属性コード1", "data_type": "string", "conv_table": [], "data_class": "検査結果(指定日以前)", "field_name": "sbt_cd1", "disp_format": "", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "3456", "can_calc": "0", "data_code": "sbt_cd2", "data_name": "属性コード2", "data_type": "string", "conv_table": [], "data_class": "検査結果(指定日以前)", "field_name": "sbt_cd2", "disp_format": "", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "6789", "can_calc": "0", "data_code": "sbt_cd3", "data_name": "属性コード3", "data_type": "string", "conv_table": [], "data_class": "検査結果(指定日以前)", "field_name": "sbt_cd3", "disp_format": "", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "検査項目テスト", "can_calc": "0", "data_code": "real_item_name", "data_name": "検査項目名", "data_type": "string", "conv_table": [], "data_class": "検査結果(指定日以前)", "field_name": "real_item_name", "disp_format": "", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "11.2", "can_calc": "0", "data_code": "result", "data_name": "検査結果", "data_type": "string", "conv_table": [], "data_class": "検査結果(指定日以前)", "field_name": "result", "disp_format": "", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "mg/dL", "can_calc": "0", "data_code": "unit", "data_name": "単位", "data_type": "string", "conv_table": [], "data_class": "検査結果(指定日以前)", "field_name": "unit", "disp_format": "", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "検査結果のテストです。", "can_calc": "0", "data_code": "freememo", "data_name": "検査コメント", "data_type": "string", "conv_table": [], "data_class": "検査結果(指定日以前)", "field_name": "freememo", "disp_format": "", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/03/12", "can_calc": "0", "data_code": "result_exam_output_base_date", "data_name": "最終検査日", "data_type": "DateTime", "conv_table": [], "data_class": "検査結果(指定日以前)", "field_name": "result_exam_output_base_date", "disp_format": "yyyy/mm/dd", "filter_type": "ExamNull", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "透析前", "can_calc": "0", "data_code": "real_reg_order_class", "data_name": "検査区分", "data_type": "string", "conv_table": [{"code": "0", "disp": "その他", "item": "その他"}, {"code": "1", "disp": "透析前", "item": "透析前"}, {"code": "2", "disp": "透析後", "item": "透析後"}], "data_class": "検査結果(指定日以前)", "field_name": "real_reg_order_class", "disp_format": "", "filter_type": "ExamNull", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "15.0", "can_calc": "0", "data_code": "upper", "data_name": "正常値上限", "data_type": "decimal", "conv_table": [], "data_class": "検査結果(指定日以前)", "field_name": "upper", "disp_format": "0.0", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10.0", "can_calc": "0", "data_code": "lower", "data_name": "正常値下限", "data_type": "decimal", "conv_table": [], "data_class": "検査結果(指定日以前)", "field_name": "lower", "disp_format": "0.0", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [1, 2, 3, 9, 10]}', '検査結果(指定日以前) 単型 @patId @facilityCd @date', '2024-05-31 09:38:25.175', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (247, 'WITH infection_order AS (
  SELECT
    one_json ->> ''code'' AS infection_cd,
    json_idx AS infection_cd_order
  FROM mst_selector
  CROSS JOIN LATERAL jsonb_array_elements(order_settings -> ''items'')
       WITH ORDINALITY AS tmp(one_json, json_idx)
  WHERE facility_cd = @facilityCd
    AND master_physical_name = ''mst_exam_item''
),

params AS (
  SELECT 
      date_trunc(''day'',@fromDate::timestamp) AS target_day,
      date_trunc(''day'',@fromDate::timestamp) - interval ''1 year'' AS from_day
),

raw_year AS (
  SELECT
      m.pat_id              AS pat_id,
      m.exam_main_cd        AS exam_main_cd,
      m.result_exam_date    AS result_exam_date,
      m.reg_exam_date       AS reg_exam_date,
      m.reg_order_class     AS m_reg_order_class,

      info_json ->> ''item_cd''   AS item_cd,
      info_json ->> ''item_name'' AS item_name,
      COALESCE(info_json ->> ''reg_order_class'',
               m.reg_order_class::text) AS reg_order_class,
      info_json
  FROM pat_exam_main m
  JOIN params p
    ON m.result_exam_date >= p.from_day
   AND m.result_exam_date <  p.target_day + interval ''1 day''
  CROSS JOIN LATERAL
       json_array_elements(coalesce(m.exam_result_info::json, ''[]''::json)) AS info(info_json)
  WHERE m.is_del = ''0''
    AND m.exam_status = ''1''
    AND m.pat_id IN (@patIds)
    AND m.facility_cd = @facilityCd
),

near_day_date AS (
  SELECT DISTINCT ON (pat_id)
      pat_id,
      result_exam_date AS base_day
  FROM raw_year
  ORDER BY pat_id, result_exam_date DESC
),

raw_day AS (
  SELECT ry.*
  FROM raw_year ry
  LEFT JOIN near_day_date nd
    ON nd.pat_id = ry.pat_id
   AND date_trunc(''day'', ry.result_exam_date)
       = date_trunc(''day'', nd.base_day)
),

base_item AS (
  SELECT DISTINCT ON (pat_id, item_cd)
      pat_id,
      item_cd,
      item_name,
      result_exam_date AS base_result_exam_date,
      reg_exam_date    AS base_reg_exam_date,
      info_json        AS base_info_json,
      exam_main_cd     AS base_exam_main_cd
  FROM raw_day
  ORDER BY
      pat_id,
      item_cd,
      result_exam_date DESC,
      reg_exam_date DESC
),

real_year_nearest AS (
  SELECT DISTINCT ON (pat_id, item_cd, reg_order_class)
      pat_id,
      item_cd,
      item_name,
      reg_order_class,
      result_exam_date AS real_result_exam_date,
      reg_exam_date    AS real_reg_exam_date,
      info_json        AS real_info_json,
      exam_main_cd     AS real_exam_main_cd,
			reg_order_class  AS real_reg_order_class,
			item_name   AS real_item_name
  FROM raw_year ry
  CROSS JOIN params p
  ORDER BY
      pat_id,
      item_cd,
      reg_order_class,
      result_exam_date DESC,
      reg_exam_date DESC
),

class_list AS (
  SELECT ''1'' AS class_cd UNION ALL
  SELECT ''2'' UNION ALL
  SELECT ''0''
),

item_with_class AS (
  SELECT
      b.item_cd,
      b.pat_id,
      b.item_name,
      b.base_result_exam_date,
      b.base_reg_exam_date,
      b.base_exam_main_cd,
      c.class_cd AS reg_order_class,

      r.real_result_exam_date,
      r.real_reg_exam_date,
      r.real_info_json,
      r.real_exam_main_cd,
			r.real_reg_order_class,
			r.real_item_name
  FROM base_item b
  CROSS JOIN class_list c
  LEFT JOIN real_year_nearest r
    ON r.pat_id = b.pat_id
   AND r.item_cd = b.item_cd
   AND r.reg_order_class = c.class_cd
),

item_expanded AS (
  SELECT
      pat_id,
      item_cd,
			item_name,
      real_item_name,

      real_result_exam_date AS result_exam_date,
      real_reg_exam_date    AS reg_exam_date,

      reg_order_class,
			real_reg_order_class,
      COALESCE(real_exam_main_cd, base_exam_main_cd) AS exam_main_cd,
      real_info_json AS info_json
  FROM item_with_class
),

final_join AS (
  SELECT
      e.pat_id,
      e.exam_main_cd,
      e.result_exam_date AS result_exam_output_base_date,
      @fromDate ::date AS reg_exam_date,
      e.reg_exam_date AS real_reg_exam_date,
      e.reg_order_class,
      e.real_reg_order_class,
      e.item_cd,
      e.item_name,
      e.real_item_name,
      e.info_json ->> ''result''   AS result,
      e.info_json ->> ''unit''     AS unit,
      e.info_json ->> ''freememo'' AS freememo,
      e.info_json ->> ''upper''    AS upper,
      e.info_json ->> ''lower''    AS lower,
      itm.in_hospital_cd1,
      itm.in_hospital_cd2,
      itm.in_hospital_cd3,
      itm.sbt_cd1,
      itm.sbt_cd2,
      itm.sbt_cd3,
      inf.infection_cd_order
  FROM item_expanded e
  LEFT JOIN mst_exam_item itm
    ON itm.exam_item_cd::text = e.item_cd
   AND itm.is_del = ''0''
   AND itm.is_disp = ''1''
	 AND e.real_reg_order_class is not null
  LEFT JOIN infection_order inf
    ON e.item_cd = inf.infection_cd
)

SELECT *
FROM final_join
ORDER BY
  pat_id,
  item_cd,
  ARRAY_POSITION(ARRAY[''1'',''2'',''0''], reg_order_class),
  infection_cd_order;
', 2, '[]', '1', '{"applications": [1]}', '{"classes": [3]}', '検査結果(指定日以前) @patId @date 複数患者帳票使用', '2025-04-18 10:08:25.083', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (314, 'WITH exam_item_order AS (
	SELECT
    one_json ->> ''code'' as exam_item_cd
    , json_idx as exam_item_order
	FROM
    mst_selector
    CROSS JOIN lateral jsonb_array_elements(order_settings -> ''items'') with ordinality as tmp(one_json, json_idx)
	WHERE
    facility_cd = @facilityCd
    AND master_physical_name = ''mst_exam_item''
),

params AS (
  SELECT 
      date_trunc(''day'',@fromDate::timestamp) AS target_day,
      date_trunc(''day'',@fromDate::timestamp) - interval ''1 year'' AS from_day
),
base_exam_cd AS (
  SELECT DISTINCT ON (m.pat_id)
      m.exam_main_cd,
      m.result_exam_date,
      m.pat_id
  FROM pat_exam_main m
  JOIN params p
    ON m.result_exam_date <  p.target_day + interval ''1 day''
   AND m.result_exam_date >  p.target_day
  WHERE m.is_del = ''0''
    AND m.exam_status = ''1''
    AND m.pat_id IN (@patIds)
    AND m.facility_cd = ''NKKSBR''
  ORDER BY
      m.pat_id,
      m.result_exam_date DESC
),
raw_year AS (
  SELECT
      m.pat_id              AS pat_id,
      k.exam_main_cd        AS exam_main_cd,
      m.result_exam_date    AS result_exam_date,
      m.reg_exam_date       AS reg_exam_date,
      m.reg_order_class     AS m_reg_order_class,

      info_json ->> ''item_cd''   AS item_cd,
      info_json ->> ''item_name'' AS item_name,
      COALESCE(info_json ->> ''reg_order_class'',
               m.reg_order_class::text) AS reg_order_class,
      info_json
  FROM pat_exam_main m
  JOIN params p
    ON m.result_exam_date >= p.from_day
   AND m.result_exam_date <  p.target_day + interval ''1 day''
  CROSS JOIN LATERAL
       json_array_elements(coalesce(m.exam_result_info::json, ''[]''::json)) AS info(info_json)
	left JOIN base_exam_cd k
	   ON	m.pat_id = k.pat_id
  WHERE m.is_del = ''0''
    AND m.exam_status = ''1''
    AND m.pat_id IN (@patIds)
    AND m.facility_cd = @facilityCd
),

near_day_date AS (
  SELECT DISTINCT ON (pat_id)
      pat_id,
      result_exam_date AS base_day
  FROM raw_year
  ORDER BY pat_id, result_exam_date DESC
),

raw_day AS (
  SELECT ry.*
  FROM raw_year ry
  LEFT JOIN near_day_date nd
    ON nd.pat_id = ry.pat_id
   AND date_trunc(''day'', ry.result_exam_date)
       = date_trunc(''day'', nd.base_day)
),

base_item AS (
  SELECT DISTINCT ON (pat_id, item_cd)
      pat_id,
      item_cd,
      item_name,
      result_exam_date AS base_result_exam_date,
      reg_exam_date    AS base_reg_exam_date,
      info_json        AS base_info_json,
      exam_main_cd     AS base_exam_main_cd
  FROM raw_day
  ORDER BY
      pat_id,
      item_cd,
      result_exam_date DESC,
      reg_exam_date DESC
),

real_year_nearest AS (
  SELECT DISTINCT ON (pat_id, item_cd, reg_order_class)
      pat_id,
      item_cd,
      item_name,
      reg_order_class,
      result_exam_date AS real_result_exam_date,
      reg_exam_date    AS real_reg_exam_date,
      info_json        AS real_info_json,
      exam_main_cd     AS real_exam_main_cd,
			reg_order_class  AS real_reg_order_class,
			item_name   AS real_item_name
  FROM raw_year ry
  CROSS JOIN params p
  ORDER BY
      pat_id,
      item_cd,
      reg_order_class,
      result_exam_date DESC,
      reg_exam_date DESC
),

class_list AS (
  SELECT ''1'' AS class_cd UNION ALL
  SELECT ''2'' UNION ALL
  SELECT ''0''
),

item_with_class AS (
  SELECT
      b.item_cd,
      b.pat_id,
      b.item_name,
      b.base_result_exam_date,
      b.base_reg_exam_date,
      b.base_exam_main_cd,
      c.class_cd AS reg_order_class,

      r.real_result_exam_date,
      r.real_reg_exam_date,
      r.real_info_json,
      r.real_exam_main_cd,
			r.real_reg_order_class,
			r.real_item_name
  FROM base_item b
  CROSS JOIN class_list c
  LEFT JOIN real_year_nearest r
    ON r.pat_id = b.pat_id
   AND r.item_cd = b.item_cd
   AND r.reg_order_class = c.class_cd
),

item_expanded AS (
  SELECT
      pat_id,
      item_cd,
			item_name,
      real_item_name,

      real_result_exam_date AS result_exam_date,
      real_reg_exam_date    AS reg_exam_date,

      reg_order_class,
			real_reg_order_class,
      COALESCE(real_exam_main_cd, base_exam_main_cd) AS exam_main_cd,
      real_info_json AS info_json
  FROM item_with_class
),

final_join AS (
  SELECT
      e.pat_id,
      e.exam_main_cd,
      e.result_exam_date AS result_exam_output_base_date,
      @fromDate ::date AS reg_exam_date,
      e.reg_exam_date AS real_reg_exam_date,
      e.reg_order_class,
      e.real_reg_order_class,
      e.item_cd,
      e.item_name,
      e.real_item_name,
      e.info_json ->> ''result''   AS result,
      e.info_json ->> ''unit''     AS unit,
      e.info_json ->> ''freememo'' AS freememo,
      e.info_json ->> ''upper''    AS upper,
      e.info_json ->> ''lower''    AS lower,
      itm.in_hospital_cd1,
      itm.in_hospital_cd2,
      itm.in_hospital_cd3,
      itm.sbt_cd1,
      itm.sbt_cd2,
      itm.sbt_cd3,
      inf.exam_item_order
  FROM item_expanded e
  LEFT JOIN mst_exam_item itm
    ON itm.exam_item_cd::text = e.item_cd
   AND itm.is_del = ''0''
   AND itm.is_disp = ''1''
	 AND e.real_reg_order_class is not null
  LEFT JOIN exam_item_order inf
    ON e.item_cd = inf.exam_item_cd
)

SELECT *
FROM final_join
ORDER BY
  pat_id,
  item_cd,
  ARRAY_POSITION(ARRAY[''1'',''2'',''0''], reg_order_class),
  exam_item_order;
', 2, '[{"preview": "1234", "can_calc": "0", "data_code": "in_hospital_cd1", "data_name": "院内コード1", "data_type": "string", "conv_table": [], "data_class": "検査結果(指定日以前)", "field_name": "in_hospital_cd1", "disp_format": "", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "4567", "can_calc": "0", "data_code": "in_hospital_cd2", "data_name": "院内コード2", "data_type": "string", "conv_table": [], "data_class": "検査結果(指定日以前)", "field_name": "in_hospital_cd2", "disp_format": "", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "7890", "can_calc": "0", "data_code": "in_hospital_cd3", "data_name": "院内コード3", "data_type": "string", "conv_table": [], "data_class": "検査結果(指定日以前)", "field_name": "in_hospital_cd3", "disp_format": "", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0123", "can_calc": "0", "data_code": "sbt_cd1", "data_name": "属性コード1", "data_type": "string", "conv_table": [], "data_class": "検査結果(指定日以前)", "field_name": "sbt_cd1", "disp_format": "", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "3456", "can_calc": "0", "data_code": "sbt_cd2", "data_name": "属性コード2", "data_type": "string", "conv_table": [], "data_class": "検査結果(指定日以前)", "field_name": "sbt_cd2", "disp_format": "", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "6789", "can_calc": "0", "data_code": "sbt_cd3", "data_name": "属性コード3", "data_type": "string", "conv_table": [], "data_class": "検査結果(指定日以前)", "field_name": "sbt_cd3", "disp_format": "", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "検査項目テスト", "can_calc": "0", "data_code": "real_item_name", "data_name": "検査項目名", "data_type": "string", "conv_table": [], "data_class": "検査結果(指定日以前)", "field_name": "real_item_name", "disp_format": "", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "11.2", "can_calc": "0", "data_code": "result", "data_name": "検査結果", "data_type": "string", "conv_table": [], "data_class": "検査結果(指定日以前)", "field_name": "result", "disp_format": "", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "mg/dL", "can_calc": "0", "data_code": "unit", "data_name": "単位", "data_type": "string", "conv_table": [], "data_class": "検査結果(指定日以前)", "field_name": "unit", "disp_format": "", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "検査結果のテストです。", "can_calc": "0", "data_code": "freememo", "data_name": "検査コメント", "data_type": "string", "conv_table": [], "data_class": "検査結果(指定日以前)", "field_name": "freememo", "disp_format": "", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/03/12", "can_calc": "0", "data_code": "result_exam_output_base_date", "data_name": "最終検査日", "data_type": "DateTime", "conv_table": [], "data_class": "検査結果(指定日以前)", "field_name": "result_exam_output_base_date", "disp_format": "yyyy/mm/dd", "filter_type": "ExamNull", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "透析前", "can_calc": "0", "data_code": "real_reg_order_class", "data_name": "検査区分", "data_type": "string", "conv_table": [{"code": "0", "disp": "その他", "item": "その他"}, {"code": "1", "disp": "透析前", "item": "透析前"}, {"code": "2", "disp": "透析後", "item": "透析後"}], "data_class": "検査結果(指定日以前)", "field_name": "real_reg_order_class", "disp_format": "", "filter_type": "ExamNull", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "15.0", "can_calc": "0", "data_code": "upper", "data_name": "正常値上限", "data_type": "decimal", "conv_table": [], "data_class": "検査結果(指定日以前)", "field_name": "upper", "disp_format": "0.0", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10.0", "can_calc": "0", "data_code": "lower", "data_name": "正常値下限", "data_type": "decimal", "conv_table": [], "data_class": "検査結果(指定日以前)", "field_name": "lower", "disp_format": "0.0", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [11]}', '検査結果(指定日以前) 複数型 @patIds @facilityCd @fromDate', '2025-12-10 12:39:23.222', CURRENT_TIMESTAMP, NULL);
