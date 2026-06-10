DELETE FROM "ntss"."sys_data_set" where sql_cd in (29, 246);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (29, 'WITH infection_order AS (
  select
    one_json ->> ''code'' as infection_cd
    , json_idx as infection_cd_order
from
    mst_selector
    cross join lateral jsonb_array_elements(order_settings -> ''items'') with ordinality as tmp(one_json, json_idx)
where
    facility_cd = @facilityCd
    and master_physical_name = ''mst_exam_item''
),
result_table as (
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
  case p.reg_order_class
  when ''0'' then ''9''
  else p.reg_order_class
  end as reg_order_class_sort,
  p.exam_main_cd as exam_main_cd,
  case
		when info->>''upper''::TEXT = ''null'' then ''''
		when info->>''upper''::TEXT is null then ''''
		else info->>''upper''::TEXT end as upper,
  case
		when info->>''lower''::TEXT = ''null'' then ''''
		when info->>''lower''::TEXT is null then ''''
		else info->>''lower''::TEXT end as lower
from (
  select
    m.*
  from
    pat_exam_main as m
  where
    m.is_del = ''0''
    and m.exam_status = ''1''
    and m.pat_id = @patId
	AND m.facility_cd = @facilityCd
    and m.result_exam_date between date_trunc(''day'', @fromDate ::timestamp) and date_trunc(''day'', @toDate ::timestamp) + ''1 days - 1 milliseconds''
    order by m.result_exam_date desc
  ) as p
  cross join lateral
  json_array_elements (p.exam_result_info :: json) info
  left outer join
  mst_exam_item as item on info->>''item_cd'' = (item.exam_item_cd || '''') and item.is_del =''0'' and is_disp =''1''
	  left join   infection_order as inf   on info->>''item_cd''::text=inf.infection_cd
ORDER BY
  result_exam_date, ARRAY_POSITION(ARRAY[''1'',''2'',''0''], reg_order_class),infection_cd_order
)

SELECT rt.*, case when lower = '''' and upper = '''' then '''' else COALESCE(lower, '''') || ''~'' || COALESCE(upper, '''')  end as normal_value FROM result_table AS rt
;', 2, '[{"preview": "1234", "can_calc": "0", "data_code": "in_hospital_cd1", "data_name": "院内コード1", "data_type": "string", "conv_table": [], "data_class": "検査結果(指定日)", "field_name": "in_hospital_cd1", "disp_format": "", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "4567", "can_calc": "0", "data_code": "in_hospital_cd2", "data_name": "院内コード2", "data_type": "string", "conv_table": [], "data_class": "検査結果(指定日)", "field_name": "in_hospital_cd2", "disp_format": "", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "7890", "can_calc": "0", "data_code": "in_hospital_cd3", "data_name": "院内コード3", "data_type": "string", "conv_table": [], "data_class": "検査結果(指定日)", "field_name": "in_hospital_cd3", "disp_format": "", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0123", "can_calc": "0", "data_code": "sbt_cd1", "data_name": "属性コード1", "data_type": "string", "conv_table": [], "data_class": "検査結果(指定日)", "field_name": "sbt_cd1", "disp_format": "", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "3456", "can_calc": "0", "data_code": "sbt_cd2", "data_name": "属性コード2", "data_type": "string", "conv_table": [], "data_class": "検査結果(指定日)", "field_name": "sbt_cd2", "disp_format": "", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "6789", "can_calc": "0", "data_code": "sbt_cd3", "data_name": "属性コード3", "data_type": "string", "conv_table": [], "data_class": "検査結果(指定日)", "field_name": "sbt_cd3", "disp_format": "", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "検査項目テスト", "can_calc": "0", "data_code": "item_name", "data_name": "検査項目名", "data_type": "string", "conv_table": [], "data_class": "検査結果(指定日)", "field_name": "item_name", "disp_format": "", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "11.2", "can_calc": "0", "data_code": "result", "data_name": "検査結果", "data_type": "string", "conv_table": [], "data_class": "検査結果(指定日)", "field_name": "result", "disp_format": "", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "mg/dL", "can_calc": "0", "data_code": "unit", "data_name": "単位", "data_type": "string", "conv_table": [], "data_class": "検査結果(指定日)", "field_name": "unit", "disp_format": "", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "検査結果のテストです。", "can_calc": "0", "data_code": "freememo", "data_name": "検査コメント", "data_type": "string", "conv_table": [], "data_class": "検査結果(指定日)", "field_name": "freememo", "disp_format": "", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/03/12", "can_calc": "0", "data_code": "result_exam_date", "data_name": "検査日", "data_type": "DateTime", "conv_table": [], "data_class": "検査結果(指定日)", "field_name": "result_exam_date", "disp_format": "yyyy/mm/dd", "filter_type": "ExamNull", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "透析前", "can_calc": "0", "data_code": "reg_order_class", "data_name": "検査区分", "data_type": "string", "conv_table": [{"code": "0", "disp": "その他", "item": "その他"}, {"code": "1", "disp": "透析前", "item": "透析前"}, {"code": "2", "disp": "透析後", "item": "透析後"}], "data_class": "検査結果(指定日)", "field_name": "reg_order_class", "disp_format": "", "filter_type": "ExamNull", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "15.0", "can_calc": "0", "data_code": "upper", "data_name": "正常値上限", "data_type": "decimal", "conv_table": [], "data_class": "検査結果(指定日)", "field_name": "upper", "disp_format": "0.0", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10.0", "can_calc": "0", "data_code": "lower", "data_name": "正常値下限", "data_type": "decimal", "conv_table": [], "data_class": "検査結果(指定日)", "field_name": "lower", "disp_format": "0.0", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10.0～15.0", "can_calc": "0", "data_code": "normal_value", "data_name": "正常値範囲", "data_type": "string", "conv_table": [], "data_class": "検査結果(指定日)", "field_name": "normal_value", "disp_format": "", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [1, 2, 9, 10]}', '検査結果(指定日) 単型 @patId @facilityCd @date', '2020-03-25 18:00:00', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (246, 'WITH infection_order AS (
  select
    one_json ->> ''code'' as infection_cd
    , json_idx as infection_cd_order
from
    mst_selector
    cross join lateral jsonb_array_elements(order_settings -> ''items'') with ordinality as tmp(one_json, json_idx)
where
    facility_cd = @facilityCd
    and master_physical_name = ''mst_exam_item''
),

result_table AS (
    SELECT
        p.pat_id,
        p.facility_cd,
        p.exam_main_cd,
        p.result_exam_date,
        p.reg_exam_date,
        p.reg_order_class,
				case p.reg_order_class
        when ''0'' then ''9''
        else p.reg_order_class
        end as reg_order_class_sort,

        info->>''item_cd''   AS item_cd,
        info->>''item_name'' AS item_name,
        info->>''result''    AS result,
        info->>''unit''      AS unit,
        info->>''freememo''  AS freememo,

        CASE
            WHEN info->>''upper'' = ''null'' OR info->>''upper'' IS NULL THEN ''''
            ELSE info->>''upper''
        END AS upper,
        CASE
            WHEN info->>''lower'' = ''null'' OR info->>''lower'' IS NULL THEN ''''
            ELSE info->>''lower''
        END AS lower,

        item.in_hospital_cd1,
        item.in_hospital_cd2,
        item.in_hospital_cd3,
        item.sbt_cd1,
        item.sbt_cd2,
        item.sbt_cd3,

        inf.infection_cd_order
    FROM pat_exam_main p
    CROSS JOIN LATERAL json_array_elements(p.exam_result_info::json) info
    LEFT JOIN mst_exam_item item
        ON info->>''item_cd'' = item.exam_item_cd::text
       AND item.is_del = ''0''
       AND item.is_disp = ''1''
    LEFT JOIN infection_order inf
        ON info->>''item_cd'' = inf.infection_cd
    WHERE p.is_del = ''0''
      AND p.exam_status = ''1''
      AND p.pat_id IN (@patIds)
      AND p.facility_cd = @facilityCd
      AND p.result_exam_date BETWEEN
          date_trunc(''day'', @fromDate::timestamp)
          AND date_trunc(''day'', @toDate::timestamp)
              + INTERVAL ''1 day - 1 millisecond''
)

SELECT 
    rt.*,

    CASE
        WHEN rt.lower = '''' AND rt.upper = '''' THEN ''''
        ELSE rt.lower || ''~'' || rt.upper
    END AS normal_value,

    prev.result_before,
    prev.result_before_exam_date

FROM result_table rt

LEFT JOIN LATERAL (
    SELECT
        info2->>''result'' AS result_before,
        p2.result_exam_date AS result_before_exam_date
    FROM pat_exam_main p2
    CROSS JOIN LATERAL json_array_elements(p2.exam_result_info::json) info2
    WHERE p2.pat_id = rt.pat_id
      AND p2.facility_cd = rt.facility_cd
      AND p2.is_del = ''0''
      AND p2.exam_status = ''1''
      AND info2->>''item_cd'' = rt.item_cd
      AND p2.reg_order_class = rt.reg_order_class
      AND p2.result_exam_date < date_trunc(''day'', rt.result_exam_date)
			AND p2.result_exam_date >= date_trunc(''day'', rt.result_exam_date) - INTERVAL ''3 months''
    ORDER BY p2.result_exam_date DESC
    LIMIT 1
) prev ON TRUE

ORDER BY
    rt.pat_id,
    rt.item_cd,
    ARRAY_POSITION(ARRAY[''1'',''2'',''0''], rt.reg_order_class),
    rt.result_exam_date DESC,
    rt.infection_cd_order;
', 2, '[{"preview": "1234", "can_calc": "0", "data_code": "in_hospital_cd1", "data_name": "院内コード1", "data_type": "string", "conv_table": [], "data_class": "検査結果(指定日)", "field_name": "in_hospital_cd1", "disp_format": "", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "4567", "can_calc": "0", "data_code": "in_hospital_cd2", "data_name": "院内コード2", "data_type": "string", "conv_table": [], "data_class": "検査結果(指定日)", "field_name": "in_hospital_cd2", "disp_format": "", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "7890", "can_calc": "0", "data_code": "in_hospital_cd3", "data_name": "院内コード3", "data_type": "string", "conv_table": [], "data_class": "検査結果(指定日)", "field_name": "in_hospital_cd3", "disp_format": "", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0123", "can_calc": "0", "data_code": "sbt_cd1", "data_name": "属性コード1", "data_type": "string", "conv_table": [], "data_class": "検査結果(指定日)", "field_name": "sbt_cd1", "disp_format": "", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "3456", "can_calc": "0", "data_code": "sbt_cd2", "data_name": "属性コード2", "data_type": "string", "conv_table": [], "data_class": "検査結果(指定日)", "field_name": "sbt_cd2", "disp_format": "", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "6789", "can_calc": "0", "data_code": "sbt_cd3", "data_name": "属性コード3", "data_type": "string", "conv_table": [], "data_class": "検査結果(指定日)", "field_name": "sbt_cd3", "disp_format": "", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "検査項目テスト", "can_calc": "0", "data_code": "item_name", "data_name": "検査項目名", "data_type": "string", "conv_table": [], "data_class": "検査結果(指定日)", "field_name": "item_name", "disp_format": "", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "11.2", "can_calc": "0", "data_code": "result", "data_name": "検査結果", "data_type": "string", "conv_table": [], "data_class": "検査結果(指定日)", "field_name": "result", "disp_format": "", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "11.2", "can_calc": "0", "data_code": "result_before", "data_name": "検査結果(前回)", "data_type": "string", "conv_table": [], "data_class": "検査結果(指定日)", "field_name": "result_before", "disp_format": "", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "mg/dL", "can_calc": "0", "data_code": "unit", "data_name": "単位", "data_type": "string", "conv_table": [], "data_class": "検査結果(指定日)", "field_name": "unit", "disp_format": "", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "検査結果のテストです。", "can_calc": "0", "data_code": "freememo", "data_name": "検査コメント", "data_type": "string", "conv_table": [], "data_class": "検査結果(指定日)", "field_name": "freememo", "disp_format": "", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/03/12", "can_calc": "0", "data_code": "result_exam_date", "data_name": "検査日", "data_type": "DateTime", "conv_table": [], "data_class": "検査結果(指定日)", "field_name": "result_exam_date", "disp_format": "yyyy/mm/dd", "filter_type": "ExamNull", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "透析前", "can_calc": "0", "data_code": "reg_order_class", "data_name": "検査区分", "data_type": "string", "conv_table": [{"code": "0", "disp": "その他", "item": "その他"}, {"code": "1", "disp": "透析前", "item": "透析前"}, {"code": "2", "disp": "透析後", "item": "透析後"}], "data_class": "検査結果(指定日)", "field_name": "reg_order_class", "disp_format": "", "filter_type": "ExamNull", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "15.0", "can_calc": "0", "data_code": "upper", "data_name": "正常値上限", "data_type": "decimal", "conv_table": [], "data_class": "検査結果(指定日)", "field_name": "upper", "disp_format": "0.0", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10.0", "can_calc": "0", "data_code": "lower", "data_name": "正常値下限", "data_type": "decimal", "conv_table": [], "data_class": "検査結果(指定日)", "field_name": "lower", "disp_format": "0.0", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10.0～15.0", "can_calc": "0", "data_code": "normal_value", "data_name": "正常値範囲", "data_type": "string", "conv_table": [], "data_class": "検査結果(指定日)", "field_name": "normal_value", "disp_format": "", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [3]}', '検査結果(指定日) @patId @date 複数患者帳票使用', '2025-04-18 23:31:47.414', CURRENT_TIMESTAMP, NULL);
