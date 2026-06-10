delete from "sys_data_set" where "sql_cd" in (-99994,-408,-410,-417,-418,-419,-420,-421,-422,-423,-424,-425,-426,-427,-428);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-99994, 'SELECT
  TO_CHAR(CURRENT_TIMESTAMP, ''YYYYMMDDHH24MISS_'') ||
  ''_'' || 
  CASE WHEN ppm.in_out_class IS NULL THEN ''3'' ELSE CAST(ppm.in_out_class AS TEXT) END || 
  ''_'' ||
  ''FUTURENET''
  || ''.xml'' AS filename 
FROM
  ntss.pat_personal_main AS ppm 
WHERE
  pat_id = @patId', 3, '[]', '0', '{"applications": [4]}', NULL, 'Medicom透析実績ファイル名取得', '2021-04-20 09:19:08.001', '2021-04-20 09:19:12', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-428, 'select 
	''抗凝固剤'' as detail_id,
	ord.rst_cond_info->''25''->>''value_name_1''  as e01,
	trim(to_char(to_number(ord.rst_cond_info->''26''->>''value'',''9999.99''),''99990.99''))  as e02,
	trim(to_char(to_number(ord.rst_cond_info->''27''->>''value'',''9999.99''),''99990.99'')) as e03,
	trim(to_char(to_number(ord.rst_cond_info->''28''->>''value'',''9999.99''),''99990.99'')) as e04
from 
	ord_main ord
where
	ord.ord_no = @ordNo
', 2, '[{}]', '0', '{"applications": [4]}', NULL, 'Medicom)経過情報（抗凝固剤）', '2020-05-27 10:00:13', '2020-05-27 10:00:18.001', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-427, 'select 
	''除水'' as detail_id,
	trim(to_char(TO_NUMBER(COALESCE(ord.rst_weight_info->>''water_removal_target'',''0''),''9999.99''),''9990.99'')) as e01,
	trim(to_char(TO_NUMBER(COALESCE(ord.rst_weight_info->>''water_removal_target'',''0''),''999999'') / TRUNC(TO_NUMBER(ord.rst_cond_info->''1''->>''value'',''999999'')/60,0),''9990.99'')) as e02,
	trim(to_char(TO_NUMBER(COALESCE(ord.rst_weight_info->>''add_total'',''0''),''9999.99''),''9990.99'')) as e03
from 
	ord_main ord
where
	ord.ord_no = @ordNo
', 2, '[{}]', '0', '{"applications": [4]}', NULL, 'Medicom)経過情報（除水）', '2020-05-27 10:00:13', '2020-05-27 10:00:18.001', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-426, 'with hist_ord_nos as (
  select
    ord_main.ord_no
    ,ord_main.rst_start_date
  from
    ord_main
  where
    ord_main.pat_id = (select pat_id from ord_main where ord_no = 36301 and is_del = ''0'')
    and rst_dialysis_state > ''4''
    and ord_main.ord_no <> @ordNo
    and rst_start_date <= (select rst_start_date from ord_main where ord_no = @ordNo and is_del = ''0'')
    and is_del = ''0''
  order by rst_start_date desc limit 2
), ord_key_tbl as (
  select
    ord_no ,treat_date
  from
    ord_main
  where
    ord_no = @ordNo and is_del = ''0''
)
, ord_hist_tbl as (
  select
    ord_no
    ,rst_start_date
    ,to_number(rst_weight_info->>''weight_before'', ''999.99'') as weight_before
    ,(rst_weight_info->>''weight_before_date'')::timestamp as weight_before_date
    ,to_number(rst_weight_info->>''weight_after'', ''999.99'') as weight_after
    ,(rst_weight_info->>''weight_after_date'')::timestamp as weight_after_date
    ,to_number(rst_weight_info->>''water_removal_rst'', ''999.99'') as water_removal_rst
  from
    ord_main
  where
    ord_no in (select ord_no from hist_ord_nos)
), ord_array_tbl as (
  select
    array_agg(ord_no order by rst_start_date desc) as array_ord_no
    ,array_agg(rst_start_date order by rst_start_date desc) as array_rst_start_date
    ,array_agg(weight_before order by rst_start_date desc) as array_weight_before
    ,array_agg(weight_before_date order by rst_start_date desc) as array_weight_before_date
    ,array_agg(weight_after order by rst_start_date desc) as array_weight_after
    ,array_agg(weight_after_date order by rst_start_date desc) as array_weight_after_date
    ,array_agg(water_removal_rst order by rst_start_date desc) as array_water_removal_rst
  from
    ord_hist_tbl
)

select
  ''体重管理'' as detail_id,
  trim(to_char(to_number(ord.rst_weight_info->>''weight_before'',''999.99''),''990.99'')) as e01,
  trim(to_char(to_number(ord.rst_weight_info->>''weight_after'',''999.99''),''990.99'')) as e02,
  ord.rst_dw as e03,
  trim(to_char(COALESCE(array_weight_after[1],''0''),''990.99'')) as e04,
  trim(to_char(to_number(COALESCE(ord.rst_cond_info->''3''->>''value'',''0''),''999.99''),''990.99'')) as e05,
  trim(to_char(to_number(ord.rst_weight_info->>''weight_before'',''999.99'')-to_number(ord.rst_weight_info->>''weight_after'',''999.99''),''990.99'')) as e06,
  trim(to_char(to_number(ord.rst_weight_info->>''weight_before'',''999.99'')- COALESCE(array_weight_after[1],''0''),''990.99'')) as e07,
  array_ord_no[1] as ord_no_prev
  ,array_rst_start_date[1] as rst_start_date_prev
  ,array_weight_before[1] as weight_before_prev
  ,array_weight_before_date[1] as weight_before_date_prev
  ,array_weight_after_date[1] as weight_after_date_prev
  ,array_water_removal_rst[1] as water_removal_rst_prev

  ,array_ord_no[2] as ord_no_prev_prev
  ,array_rst_start_date[2] as rst_start_date_prev_prev
  ,array_weight_before[2] as weight_before_prev_prev
  ,array_weight_before_date[2] as weight_before_date_prev_prev
  ,array_weight_after[2] as weight_after_prev_prev
  ,array_weight_after_date[2] as weight_after_date_prev_prev
  ,array_water_removal_rst[2] as water_removal_rst_prev_prev
from
  ord_array_tbl,
  ord_main as ord
 where
  ord.ord_no = @ordNo
;
', 2, '[{}]', '0', '{"applications": [4]}', NULL, 'Medicom)経過情報（体重管理）', '2020-05-27 10:00:13', '2020-05-27 10:00:18.001', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-425, 'select
  ''担当Ｎｓ''as detail_id,
  concat(ord.rst_charge_user_info->>''user_last_name_1'' , ord.rst_charge_user_info->>''user_first_name_1'') as e01,--担当者1
  concat(ord.rst_charge_user_info->>''user_last_name_2'' , ord.rst_charge_user_info->>''user_first_name_2'') as e02--担当者2
from 
	ord_main ord
where
	ord.ord_no = @ordNo', 2, '[{}]', '1', '{"applications": [4]}', NULL, 'Medicom)経過情報（担当Ｎｓ）', '2020-05-27 10:00:13', '2020-05-27 10:00:18.001', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-424, 'select
  ''Ｄｒ''as detail_id,
  concat(ord.rst_charge_user_info->>''user_last_name_1'' , ord.rst_charge_user_info->>''user_first_name_1'') as e01,--担当者1
  concat(ord.rst_charge_user_info->>''user_last_name_2'' , ord.rst_charge_user_info->>''user_first_name_2'') as e02--担当者2
from 
	ord_main ord
where
	ord.ord_no = @ordNo', 2, '[{}]', '1', '{"applications": [4]}', NULL, 'Medicom)経過情報（Ｄｒ）', '2020-05-27 10:00:13', '2020-05-27 10:00:18.001', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-423, '--観察記録情報 看護メモ 
WITH T01 AS ( 
  SELECT
    pev.pat_event_cd
    , params ->> ''field_name'' AS field_name 
    , pev.up_date AS up_date
    , pev.reg_staff_info ->> ''reg_staff_cd'' AS reg_staff_cd
    , pev.reg_staff_info ->> ''reg_staff_name'' AS reg_staff_name 
  FROM
    pat_event AS pev
    , ord_main AS ord 
    CROSS JOIN LATERAL json_array_elements(pev.input_params ::json) params 
  WHERE
    pev.event_start_date = ord.treat_date 
    AND ord.pat_id = pev.pat_id 
    AND pev.use_type = 2 
    AND pev.is_del = ''0'' 
    AND json_array_length(pev.input_params ::json) = 1 
    AND ord.ord_no = @ordNo 
    ORDER BY pev.up_date DESC 
    LIMIT 1
) 
SELECT
  -- 看護メモ コメント
  ''看護メモ'' AS detail_id
  , ''1'' AS order_item
  , ''1'' AS tag_no
  , split_part(split_part(soap ->> ''result_value'', ''>'', 2), ''<'', 1) AS e01 
FROM
  pat_event AS pev 
  CROSS JOIN LATERAL json_array_elements(pev.result_params ::json) soap
  , T01 
WHERE
  pev.pat_event_cd = T01.pat_event_cd 
  AND soap ->> ''result_value'' IS NOT NULL
UNION 
SELECT
  -- 記録者名
  ''看護メモ'' AS detail_id
  , ''2'' AS order_item
  , ''2'' AS tag_no
  , T01.reg_staff_name AS e01 
FROM T01 
UNION 
SELECT
  -- 更新日時
  ''看護メモ'' AS detail_id
  , ''3'' AS order_item
  , ''3'' AS tag_no
  , TO_CHAR(T01.up_date, ''YYYY-MM-DD HH24:MI:SS'') AS e01 
FROM T01 
ORDER BY order_item ASC, tag_no ASC', 2, '[{}]', '1', '{"applications": [4]}', NULL, 'Medicom)経過情報（看護メモ）', '2020-05-27 10:00:13', '2020-05-27 10:00:18.001', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-422, '--観察記録情報SOAP 
WITH T01 AS ( 
  SELECT
    pev.pat_event_cd
    , params ->> ''field_name'' AS field_name 
  FROM
    pat_event AS pev
    , ord_main AS ord 
    CROSS JOIN LATERAL json_array_elements(pev.input_params ::json) params 
  WHERE
    pev.event_start_date = ord.treat_date 
    AND ord.pat_id = pev.pat_id 
    AND pev.use_type = 2 
    AND pev.is_del = ''0'' 
    AND json_array_length(pev.input_params ::json) >= 4 
    AND ord.ord_no = @ordNo 
    AND params ->> ''field_name'' IN (''S'', ''O'', ''A'', ''P'')
) 
, T02 AS ( 
  SELECT
    pev.pat_event_cd
    , pev.up_date AS up_date
    , pev.reg_staff_info ->> ''reg_staff_cd'' AS reg_staff_cd
    , pev.reg_staff_info ->> ''reg_staff_name'' AS reg_staff_name 
  FROM
    pat_event AS pev 
  WHERE
        EXISTS (SELECT 1 FROM T01 WHERE T01.pat_event_cd = pev.pat_event_cd AND T01.field_name = ''S'') 
    AND EXISTS (SELECT 1 FROM T01 WHERE T01.pat_event_cd = pev.pat_event_cd AND T01.field_name = ''O'') 
    AND EXISTS (SELECT 1 FROM T01 WHERE T01.pat_event_cd = pev.pat_event_cd AND T01.field_name = ''A'') 
    AND EXISTS (SELECT 1 FROM T01 WHERE T01.pat_event_cd = pev.pat_event_cd AND T01.field_name = ''P'') 
  ORDER BY pev.up_date DESC 
  LIMIT 1
) 
, T03 AS ( 
  SELECT
    (CASE ROW_NUMBER() OVER () % 5 
        WHEN 1 THEN ''1'' 
        WHEN 2 THEN ''2'' 
        WHEN 3 THEN ''3'' 
        WHEN 4 THEN ''4'' 
        ELSE ''5'' 
        END
    ) AS tag_no
    , split_part(split_part(soap ->> ''result_value'', ''>'', 2), ''<'', 1) AS e01 
  FROM
    pat_event AS pev 
    CROSS JOIN LATERAL json_array_elements(pev.result_params ::json) soap
    , T02 
  WHERE
    pev.pat_event_cd = T02.pat_event_cd 
  LIMIT 4
) 
SELECT
  -- SOAPコメント
  ''SOAP'' AS detail_id
  , ''1'' AS order_item
  , T03.tag_no
  , T03.e01 
FROM T03 
UNION 
SELECT
  -- 記録者名
  ''SOAP'' AS detail_id
  , ''2'' AS order_item
  , ''5'' AS tag_no
  , T02.reg_staff_name AS e01 
FROM T02 
UNION 
SELECT
  -- 更新日時
  ''SOAP'' AS detail_id
  , ''3'' AS order_item
  , ''6'' AS tag_no
  , TO_CHAR(T02.up_date, ''YYYY-MM-DD HH24:MI:SS'') AS e01 
FROM T02 
ORDER BY order_item ASC, tag_no ASC', 2, '[{}]', '1', '{"applications": [4]}', NULL, 'Medicom)経過情報（SOAP）', '2020-05-27 10:00:13', '2020-05-27 10:00:18.001', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-421, 'select
	''透析困難コメント'' as detail_id,
	 ''理由（'' || mdd.dialysis_difficulty_name || ''）'' as e01
from 
	mst_dialysis_difficulty as mdd
where
	mdd.dialysis_difficulty_cd =  @diff_cd', 2, '[{}]', '1', '{"applications": [4]}', NULL, 'Medicom)経過情報（透析困難コメント）patid', '2020-05-27 10:00:13', '2020-05-27 10:00:18.001', '[{"sql_cd": -420, "field_name": "diff_cd", "replace_var": "@diff_cd"}]');
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-420, 'WITH diff_info AS (select
	--''透析困難コメント'' as detail_id,
	 diff_com->>''dial_diff_cd'' as diff_cd
from 
	pat_personal_main as ppm
	cross join lateral
      json_array_elements (ppm.dial_diff_com_info :: json) diff_com
where
	diff_com->>''is_main'' = ''1'' and
	ppm.pat_id =  @patId),
diff_cnt AS (select count(diff_info.diff_cd) AS cnt FROM diff_info)
select  case when diff_cnt.cnt = 0 then ''-1'' else (SELECT  diff_info.diff_cd AS cnt FROM diff_info) end AS diff_cd from diff_cnt', 3, '[{}]', '0', '{"applications": [4]}', NULL, 'Medicom)経過情報（透析困難コメント取得用）patid', '2020-05-27 10:00:13', '2020-05-27 10:00:18.001', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-419, 'select
	''血液'' as detail_id,
	case ppm.pat_blood_type_abo when ''1'' then ''A'' when ''2'' then ''B'' when ''4'' then ''AB'' when ''3'' then ''O'' else ''不明'' end as ABO,
	case ppm.pat_blood_type_rh when ''1'' then ''RH+'' when ''2'' then ''RH1'' else  ''不明'' end as RH
from 
	pat_personal_main as ppm
where
	ppm.pat_id =  @patId', 3, '[{}]', '1', '{"applications": [4]}', NULL, 'Medicom)経過情報（血液）patid', '2020-05-27 10:00:13', '2020-05-27 10:00:18.001', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-418, 'select
	''感染症情報'' as detail_id,
	ARRAY_TO_STRING(ARRAY_AGG(min.infection_name),'','') as e01
from 
	pat_main as pm
	cross join lateral
      json_array_elements (pm.infect_info :: json) infect
	left outer join
	  mst_infection as min
	on
	  min.infection_cd = TO_NUMBER( infect->>''infection_cd'',''999999999999'')
where
	infect->>''infect'' = ''2'' and
	pm.pat_id = @patId', 2, '[{}]', '1', '{"applications": [4]}', NULL, 'Medicom)経過情報（感染症情報）patid', '2020-05-27 10:00:13', '2020-05-27 10:00:18.001', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-417, 'select
	''透析導入日'' as detail_id,
	to_char(to_date(pm.medical_care_info ->> ''dialysis_start_date'',''YYYYMMDD''), ''YYYY/MM/DD'') AS e01
from 
	pat_main as pm
where
	pm.pat_id = @patId
and pm.medical_care_info ->> ''dialysis_start_date'' is not null
', 2, '[{}]', '1', '{"applications": [4]}', NULL, 'Medicom)経過情報（透析導入日）patid', '2020-05-27 10:00:13', '2020-05-27 10:00:18.001', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-410, 'select
	''CTR'' as detail_id,
--	physical->>''ctr'' as e01
	ord.rst_weight_info->>''ctr'' as e01
from 
	ord_main as ord --,
--	pat_unique as puq
--	cross join lateral
--      json_array_elements (puq.physical_info :: json) physical
where
--	ord.pat_id = puq.pat_id and
--	physical->>''exam_date'' = to_char(ord.rst_start_date,''YYYY-MM-DD'') and
	ord.ord_no = @ordNo', 2, '[{}]', '1', '{"applications": [4]}', NULL, 'Medicom)経過情報（CTR）', '2020-05-27 10:00:13', '2020-05-27 10:00:18.001', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-408, 'select
	''透析回数'' as detail_id,
	case when ord.rst_dialysis_cnt is null then ord.rst_purification_cnt else ord.rst_dialysis_cnt end as e01
from 
	ord_main ord
where
	ord.ord_no = @ordNo', 2, '[{}]', '1', '{"applications": [4]}', NULL, 'Medicom)経過情報（透析回数）', '2020-05-27 10:00:13', '2020-05-27 10:00:18.001', NULL);
