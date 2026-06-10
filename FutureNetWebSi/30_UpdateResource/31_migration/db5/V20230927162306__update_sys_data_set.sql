DELETE FROM ntss.sys_data_set
WHERE sql_cd IN (-200000,-200001,-200006,-200010,-2400,-436,-437,-438,-439,-440,-441,-442,-443,-444,-445,-447,-448,-450,-451,-603001,-603002,-603101,-603201,-603202,-603204,-603205,-604104,-604108,-604153,-604157,-604161,-604165,-604166,-604167,-604168,-604169,-604170,-604171,-604901,-607001,-607003,-609201,-610001,-610003,-610901,-610902,-610903,-610904,1101,1201,1202,42025101,5102,5103,5201,5301)
;


INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-610904, 'WITH user_info AS(
  SELECT
    ind_user_id
  FROM
    pat_exam_main
  WHERE
    exam_main_cd = @ordNo
)
SELECT
  CASE
    WHEN user_settings -> ''authorized_authorities'' @> ''["073"]''::jsonb THEN ''3''
    ELSE ''0''
  END AS acl
FROM
  mst_user
WHERE
  user_id = (SELECT ind_user_id FROM user_info)', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'MIRAIs_exam_ord_ACL取得SQL', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-610903, 'select
    in_hospital_cd_1
from
    mst_bed
where
    facility_cd = @facilityCd
    and is_disp = ''1''
    and is_del = ''0''
    and in_hospital_cd_1 is not null', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'MIRAIs_exam_ord_BED_NO取得SQL', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-610902, 'select
    disp_user_id
from
    mst_user_authentication
where
    user_id = @userId', 1, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'MIRAIs_exam_ord_UPDATE_CODE取得SQL', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": -610901, "field_name": "user_id", "replace_var": "@userId"}]'::jsonb);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-610901, 'SELECT
  user_id,
  base_date
FROM
  sys_coop_journal
WHERE
  ctl_no = @ctlNo', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'MIRAIs_exam_ord_UPDATE_CODE取得事前SQL', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-610003, 'with job_info as (
select
    is_doctor
from
    mst_job
where
    job_cd = @jobCd
   )
SELECT
  coalesce((select is_doctor from job_info),''0'') as is_doctor', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'MIRAIs_exam_ord_医師フラグ取得SQL', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": -610002, "field_name": "job_cd", "replace_var": "@jobCd"}]'::jsonb);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-610001, 'with staff1 as (
select
    disp_user_id
from
    mst_user_authentication
where
    user_id = coalesce(NULLIF(@staffCd1::text, ''''),''-1'')::int
   ),
staff2 as (
select
    disp_user_id
from
    mst_user_authentication
where
    user_id = coalesce(NULLIF(@staffCd2::text, ''''),''-1'')::int
   ),
ind_user as (
select
    disp_user_id
from
    mst_user_authentication
where
    case 
    when NULLIF(@indUserId::text, '''') is null then false
    else user_id = @indUserId
    end
   ),
reg_staff as (
select
    disp_user_id
from
    mst_user_authentication
where
    case 
    when NULLIF(@regStaff::text, '''') is null then false
    else user_id = @regStaff
    end
   ),
up_staff as (
select
    disp_user_id
from
    mst_user_authentication
where
    case 
    when NULLIF(@upStaff::text, '''') is null then false
    else user_id = @upStaff
    end
   )
SELECT
coalesce((SELECT disp_user_id FROM staff1),'''') AS staff_cd1,
coalesce((SELECT disp_user_id FROM staff2),'''') AS staff_cd2,
coalesce((SELECT disp_user_id FROM ind_user),'''') AS ind_user_id,
coalesce((SELECT disp_user_id FROM reg_staff),'''') AS reg_staff,
coalesce((SELECT disp_user_id FROM up_staff),'''') AS up_staff', 1, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'MIRAIs_exam_ord_医師コード取得SQL', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": -442, "field_name": "staff_cd1", "replace_var": "@staffCd1"}, {"sql_cd": -442, "field_name": "staff_cd2", "replace_var": "@staffCd2"}, {"sql_cd": -442, "field_name": "ind_user_id", "replace_var": "@indUserId"}, {"sql_cd": -442, "field_name": "reg_staff", "replace_var": "@regStaff"}, {"sql_cd": -442, "field_name": "up_staff", "replace_var": "@upStaff"}]'::jsonb);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-609201, 'WITH
exam_item AS (
    SELECT
        COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS value
    FROM
        ntss.mst_coop_ini AS ini
        CROSS JOIN
            LATERAL json_array_elements(ini.coop_ini_info::json) info
    where
        facility_cd = ''@facilityCd''
    AND is_del = ''0''
    AND info ->> ''key0'' = ''CSI''
    AND info ->> ''key1'' = ''MST''
    AND info ->> ''key2'' = ''EXAM_ITEM''
),
json_info as(
SELECT 
       jsonb_agg(result || json_build_object(''item_cd'',item.exam_item_cd)::jsonb) AS result_json
     from
       jsonb_array_elements(''[{"com_cd":"@examResultInfo.comCd", "disp_order":"@nextDispOrder", "exam_class":"@examResultInfo.examClass", "freememo":"@examResultInfo.freememo", "hl":"@examResultInfo.hl", "item_cd":"@examResultInfo.itemCd", "item_name":"@examResultInfo.itemName", "jlac10_cd":"@examResultInfo.jlac10Cd", "lower":"@examResultInfo.lower", "result":"@examResultInfo.result", "result_date":"@examResultInfo.resultDate", "type":"@examResultInfo.type", "unit":"@examResultInfo.unit", "upper":"@examResultInfo.upper"}]'' :: jsonb) result
         left outer join ntss.mst_exam_item as item 
           on result ->> ''item_cd'' = CASE (SELECT value FROM exam_item)
       WHEN ''1'' THEN item.in_hospital_cd1::text
       WHEN ''2'' THEN item.in_hospital_cd2::text
       WHEN ''3'' THEN item.in_hospital_cd3::text
       ELSE ''''
       END
       AND item.facility_cd = ''@facilityCd''
       AND item.is_disp = ''1''
       AND item.is_del = ''0''
)

UPDATE pat_exam_main
SET exam_result_info =
CASE
    ''@examResultInfoFlg'' 
    WHEN '''' THEN ''@examResultInfoValue''
    ELSE exam_result_info || (select result_json from json_info)
    END
  WHERE
  is_del = ''0'' 
  AND pat_id = @patId 
  AND facility_cd = ''@facilityCd'' 
  AND reg_exam_date = to_timestamp( ''@regExamDate_Date'', ''yyyy-MM-dd hh24:mi:ss'' ) 
  AND reg_order_class = ''@regOrderClass'' 
  AND exam_main_cd = @examMainCd', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)CSIの検査結果', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-607003, 'with job_info as (
select
    is_doctor
from
    mst_job
where
    job_cd = @jobCd
   )
SELECT
  coalesce((select is_doctor from job_info),''0'') as is_doctor', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'MIRAIs_rst_dial_医師フラグ取得SQL', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": -607002, "field_name": "job_cd", "replace_var": "@jobCd"}]'::jsonb);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-607001, 'with staff1 as (
select
    disp_user_id
from
    mst_user_authentication
where
    user_id = coalesce(NULLIF(@staffCd1::text, ''''),''-1'')::int
   ),
staff2 as (
select
    disp_user_id
from
    mst_user_authentication
where
    user_id = coalesce(NULLIF(@staffCd2::text, ''''),''-1'')::int
   ),
up_ind_user as (
select
    disp_user_id
from
    mst_user_authentication
where
    user_id = @upIndUserId
   )
SELECT
coalesce((SELECT disp_user_id FROM staff1),'''') AS staff_cd1,
coalesce((SELECT disp_user_id FROM staff2),'''') AS staff_cd2,
coalesce((SELECT disp_user_id FROM up_ind_user),'''') AS up_ind_user_id', 1, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'MIRAIs_rst_dial_医師コード取得SQL', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": -444, "field_name": "staff_cd1", "replace_var": "@staffCd1"}, {"sql_cd": -444, "field_name": "staff_cd2", "replace_var": "@staffCd2"}, {"sql_cd": -444, "field_name": "up_ind_user_id", "replace_var": "@upIndUserId"}]'::jsonb);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-604901, 'WITH user_info AS(
  SELECT
    up_ind_user_id
  FROM
    ord_main
  WHERE
    ord_no = @ordNo
)
SELECT
  CASE
    WHEN user_settings -> ''authorized_authorities'' @> ''["053"]''::jsonb THEN ''3''
    ELSE ''0''
  END AS acl
FROM
  mst_user
WHERE
  user_id = (SELECT up_ind_user_id FROM user_info)', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'MIRAIs_ind_rst_dial_ACL取得SQL', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-604171, '-- 【SQL_CD=-604171】
WITH item_name AS (
  SELECT
    ''011'' AS fnw_cd,
    ''25'' AS ntss_cd,
    ''抗凝固剤'' AS fnw_name
  ORDER BY
    fnw_cd asc
),
rst_cond_info AS (
  SELECT
    jsonb_object_keys (ord.rst_cond_info) AS ntss_cd,
    ord.rst_cond_info -> jsonb_object_keys (ord.rst_cond_info) AS rst_cond_info,
    ord.rst_cond_info -> ''16'' ->> ''value'' AS value_16,
    ord.rst_cond_info -> ''20'' ->> ''value'' AS value_20,
    ord.rst_cond_info -> ''26'' ->> ''value'' AS value_26,
    ord.rst_cond_info -> ''28'' ->> ''value'' AS value_28
  FROM
    ord_main AS ord
  WHERE
    ord.ord_no = @ordNo
)
SELECT
  mix.med_in_hospital_cd as mix_med_in_hospital_cd,
  --薬剤院内コード
  mix.med_is_shot as mix_med_is_shot,
  --薬剤-注射  
  mix.amout as mix_amout
  --薬剤-数量  
FROM
  item_name,
  rst_cond_info as cond
  LEFT OUTER JOIN mst_equipment AS meqa -- 医療材料マスタ
  ON meqa.equipment_cd = TO_NUMBER(cond.rst_cond_info ->> ''value'', ''999999999999'')
  AND cond.ntss_cd in (''6'', ''7'', ''8'')
  LEFT OUTER JOIN mst_medicine AS med -- 薬剤マスタ
  ON med.medicine_cd = TO_NUMBER(cond.rst_cond_info ->> ''value'', ''999999999999'')
  AND cond.ntss_cd in (''25'')
  AND cond.rst_cond_info ->> ''medicine_type'' = ''1''
  LEFT OUTER JOIN mst_medicine_mix AS mmx -- 調製薬剤マスタ
  ON mmx.medicine_mix_cd = TO_NUMBER(cond.rst_cond_info ->> ''value'', ''999999999999'')
  AND cond.ntss_cd in (''25'')
  AND cond.rst_cond_info ->> ''medicine_type'' = ''2''
  LEFT OUTER JOIN mst_treatment AS mtt -- 治療方法マスタ
  ON mtt.treatment_cd = TO_NUMBER(cond.rst_cond_info ->> ''value'', ''999999999999'')
  AND cond.ntss_cd in (''-2'')
  LEFT OUTER JOIN mst_dialyzer AS mdr -- ダイアライザマスタ
  ON mdr.dialyzer_cd = TO_NUMBER(cond.rst_cond_info ->> ''value'', ''999999999999'')
  AND cond.ntss_cd in (''5'')
  LEFT OUTER JOIN mst_va AS mva -- VAマスタ
  ON mva.va_cd = TO_NUMBER(cond.rst_cond_info ->> ''value'', ''999999999999'')
  AND cond.ntss_cd in (''2'')

  CROSS JOIN (
    SELECT
      TRIM (med2.in_hospital_cd_1) as med_in_hospital_cd,
      --薬剤院内コード
      med2.is_shot as med_is_shot,
      --薬剤-注射  
      (mix_infoes ->> ''amount'') as amout
      --薬剤-数量  
    FROM
      item_name,
      rst_cond_info as cond
      LEFT OUTER JOIN mst_equipment AS meqa -- 医療材料マスタ
      ON meqa.equipment_cd = TO_NUMBER(cond.rst_cond_info ->> ''value'', ''999999999999'')
      AND cond.ntss_cd in (''6'', ''7'', ''8'')
      LEFT OUTER JOIN mst_medicine AS med -- 薬剤マスタ
      ON med.medicine_cd = TO_NUMBER(cond.rst_cond_info ->> ''value'', ''999999999999'')
      AND cond.ntss_cd in (''25'')
      AND cond.rst_cond_info ->> ''medicine_type'' = ''1''
      LEFT OUTER JOIN mst_medicine_mix AS mmx -- 調製薬剤マスタ
      ON mmx.medicine_mix_cd = TO_NUMBER(cond.rst_cond_info ->> ''value'', ''999999999999'')
      AND cond.ntss_cd in (''25'')
      AND cond.rst_cond_info ->> ''medicine_type'' = ''2''
      LEFT OUTER JOIN mst_treatment AS mtt -- 治療方法マスタ
      ON mtt.treatment_cd = TO_NUMBER(cond.rst_cond_info ->> ''value'', ''999999999999'')
      AND cond.ntss_cd in (''-2'')
      LEFT OUTER JOIN mst_dialyzer AS mdr -- ダイアライザマスタ
      ON mdr.dialyzer_cd = TO_NUMBER(cond.rst_cond_info ->> ''value'', ''999999999999'')
      AND cond.ntss_cd in (''5'')
      LEFT OUTER JOIN mst_va AS mva -- VAマスタ
      ON mva.va_cd = TO_NUMBER(cond.rst_cond_info ->> ''value'', ''999999999999'')
      AND cond.ntss_cd in (''2'')
      CROSS JOIN lateral json_array_elements (mmx.mix_info :: json) mix_infoes -- 調製薬剤分離
      LEFT OUTER JOIN mst_medicine AS med2 -- 調製薬剤_薬剤マスタ
      ON med2.medicine_cd = TO_NUMBER(mix_infoes ->> ''cd'', ''999999999999'')
    WHERE
      cond.ntss_cd = item_name.ntss_cd
      AND TO_NUMBER(item_name.fnw_cd, ''999'') > 0
      AND cond.ntss_cd in (''25'')
  ) AS mix
WHERE
  cond.ntss_cd = item_name.ntss_cd
  AND TO_NUMBER(item_name.fnw_cd, ''999'') > 0
  AND cond.ntss_cd in (''25'')

', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, '{"classes": []}'::jsonb, 'CSI透析実績(透析条件)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-604170, '-- 【SQL_CD=-604170】
WITH item_name AS (
  SELECT
    ''011'' AS fnw_cd,
    ''25'' AS ntss_cd,
    ''抗凝固剤'' AS fnw_name
  ORDER BY
    fnw_cd asc
),
rst_cond_info AS (
  SELECT
    jsonb_object_keys (ord.rst_cond_info) AS ntss_cd,
    ord.rst_cond_info -> jsonb_object_keys (ord.rst_cond_info) AS rst_cond_info,
    ord.rst_cond_info -> ''16'' ->> ''value'' AS value_16,
    ord.rst_cond_info -> ''20'' ->> ''value'' AS value_20,
    ord.rst_cond_info -> ''26'' ->> ''value'' AS value_26,
    ord.rst_cond_info -> ''28'' ->> ''value'' AS value_28
  FROM
    ord_main AS ord
  WHERE
    ord.ord_no = @ordNo
)
SELECT
  ''透析条件'' AS detail_id,
  item_name.fnw_cd as item_cd,
  cond.ntss_cd as ntss_cd,
  item_name.fnw_name as item_name,
  case
    when cond.rst_cond_info ->> ''medicine_type'' = ''1'' then ''0''
    when cond.rst_cond_info ->> ''medicine_type'' = ''2'' then ''1''
  end as item_value,
  cond.rst_cond_info ->> ''value_name_1'' as item_value_name,
  TRIM (meqa.in_hospital_cd_1) as meqa_in_hospital_cd,
  --医療材料院内コード
  TRIM (med.in_hospital_cd_1) as med_in_hospital_cd,
  --薬剤院内コード
  med.is_shot as med_is_shot,
  --薬剤-注射  
  TRIM (mtt.in_hospital_cd_a1) as mtt_in_hospital_cd,
  --治療方法院内コード
  TRIM (mtt.treatment_name) as mtt_treatment_name,
  --治療方法名
  TRIM (mdr.in_hospital_cd_1) as mdr_in_hospital_cd,
  --ダイアライザ院内コード
  TRIM (mva.in_hospital_cd_1) as mva_in_hospital_cd,
  --VA院内コード
  cond.rst_cond_info ->> ''unit'' as item_value_unit,
  cond.rst_cond_info ->> ''medicine_type'' as medicine_type,
  cond.rst_cond_info ->> ''ind_user_id'' as ind_user_id,
  cond.rst_cond_info ->> ''upd_user_id'' as upd_user_id
FROM
  item_name,
  rst_cond_info as cond
  LEFT OUTER JOIN mst_equipment AS meqa -- 医療材料マスタ
  ON meqa.equipment_cd = TO_NUMBER(cond.rst_cond_info ->> ''value'', ''999999999999'')
  AND cond.ntss_cd in (''6'', ''7'', ''8'')
  LEFT OUTER JOIN mst_medicine AS med -- 薬剤マスタ
  ON med.medicine_cd = TO_NUMBER(cond.rst_cond_info ->> ''value'', ''999999999999'')
  AND cond.ntss_cd in (''25'')
  AND cond.rst_cond_info ->> ''medicine_type'' = ''1''
  LEFT OUTER JOIN mst_medicine_mix AS mmx -- 調製薬剤マスタ
  ON mmx.medicine_mix_cd = TO_NUMBER(cond.rst_cond_info ->> ''value'', ''999999999999'')
  AND cond.ntss_cd in (''25'')
  AND cond.rst_cond_info ->> ''medicine_type'' = ''2''
  LEFT OUTER JOIN mst_treatment AS mtt -- 治療方法マスタ
  ON mtt.treatment_cd = TO_NUMBER(cond.rst_cond_info ->> ''value'', ''999999999999'')
  AND cond.ntss_cd in (''-2'')
  LEFT OUTER JOIN mst_dialyzer AS mdr -- ダイアライザマスタ
  ON mdr.dialyzer_cd = TO_NUMBER(cond.rst_cond_info ->> ''value'', ''999999999999'')
  AND cond.ntss_cd in (''5'')
  LEFT OUTER JOIN mst_va AS mva -- VAマスタ
  ON mva.va_cd = TO_NUMBER(cond.rst_cond_info ->> ''value'', ''999999999999'')
  AND cond.ntss_cd in (''2'')
WHERE
  cond.ntss_cd = item_name.ntss_cd
  AND TO_NUMBER(item_name.fnw_cd, ''999'') > 0
  AND cond.ntss_cd in (''25'')

', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, '{"classes": []}'::jsonb, 'CSI透析実績(透析条件)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-604169, '-- 【SQL_CD=-604169】
 WITH staff_info AS (
   SELECT ROW_NUMBER( ) OVER ( ORDER BY info ->> ''is_main'' DESC,  info ->> ''is_charge'' DESC,  info ->> ''is_puncture'' DESC, info ->> ''ctl_no'' ASC ) AS CNT,
     info ->> ''staff_cd'' AS staff_cd 
   FROM
     pat_main AS pat
     LEFT JOIN LATERAL json_array_elements ( pat.charge_staff_info :: json ) info ON info ->> ''ctl_no'' IS NOT NULL 
   WHERE
     pat.pat_id = @patId 
   )
 SELECT
    -- クールマスタ
    ord.rst_kur_cd AS kur_cd,
    mkr.kur_name AS kur_name,
    COALESCE(TRIM(mkr.in_hospital_cd_1), cast(mkr.kur_cd as VARCHAR)) AS kur_cd1,
    LEFT ( mkr.kur_standard_start_time, 4 ) AS kur_standard_start_time,
    -- ベッドマスタ
    ord.rst_bed_cd AS bed_cd,
    mbd.bed_name AS bed_name,
    COALESCE(TRIM(mbd.in_hospital_cd_1), cast(mbd.bed_cd as VARCHAR)) AS bed_cd1,
    -- 基本情報.診療科コード
    pat.medical_care_info ->> ''main_course_cd'' AS course_cd,
    course.course_name AS course_name,
    COALESCE(TRIM(course.in_hospital_cd_1), cast(course.course_cd as VARCHAR)) AS course_cd1,
    -- 実績：診療科コード
    ord.rst_ward_cd AS rst_ward_cd,
    mwd.in_hospital_cd_1 AS in_hospital_cd_1,
    rst_course.course_name AS rst_course_name,
    COALESCE(TRIM(rst_course.in_hospital_cd_1), cast(rst_course.course_cd as VARCHAR)) AS rst_course_cd1,

    -- 透析導入日
    pat.medical_care_info ->> ''dialysis_start_date'' AS dialysis_start_date,
    -- 透析番号
    ord.rst_fn_dialysis_no,
    -- 版番号
    ord.rst_edition,
    -- 治療開始日時
    to_char(cast(scj.base_date as date), ''yyyy/mm/dd hh24:mi:ss'') as rst_start_date,
    -- 治療終了日時
    to_char(cast(scj.base_date as date), ''yyyy/mm/dd hh24:mi:ss'') as rst_end_date,
    -- 透析時間
    ord.rst_running_time,
    -- 最終更新指示者ID
    ord.up_ind_user_id,
    -- 医師1
    staff1.staff_cd AS staff_cd1,
    -- 医師2
    staff2.staff_cd AS staff_cd2
 FROM
    (
      SELECT
        ord.ord_no,
        del_date
      FROM
        ord_main_restore AS ord,
        sys_coop_journal as journal
      WHERE
        ord.ord_no = @ordNo
        AND journal.ctl_no = @ctlNo
        AND ord.ord_no = journal.ord_no
        AND journal.reg_date >= ord.del_date
      ORDER BY
        del_date DESC
      LIMIT
        1
    ) as ord_main_max,
    ord_main_restore AS ord
    INNER JOIN pat_main AS pat ON pat.pat_id = ord.pat_id 
    LEFT JOIN staff_info AS staff1 ON staff1.CNT = 1
    LEFT JOIN staff_info AS staff2 ON staff2.CNT = 2
    LEFT JOIN mst_kur AS mkr ON mkr.kur_cd = ord.rst_kur_cd 
    LEFT JOIN mst_bed AS mbd ON mbd.bed_cd = ord.rst_bed_cd
    LEFT JOIN mst_course AS course ON course.course_cd ::TEXT = pat.medical_care_info ->> ''main_course_cd''
    LEFT JOIN mst_course AS rst_course ON rst_course.course_cd = ord.rst_ward_cd
    LEFT JOIN mst_ward AS mwd ON mwd.ward_cd = ord.rst_ward_cd
    LEFT JOIN sys_coop_journal AS scj ON  scj.ctl_no = @ctlNo
  WHERE
    pat.pat_id = @patId 
    AND ord_main_max.ord_no = ord.ord_no
    AND ord_main_max.del_date = ord.del_date', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, '{"classes": []}'::jsonb, 'CSI透析実績(透析条件)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-604168, '-- 【SQL_CD=-604168】
WITH rst_complaint_info AS (
  SELECT
    complaint
  FROM
    ord_main AS ord
    CROSS JOIN LATERAL json_array_elements(ord.rst_complaint_info :: json) complaint
  WHERE
    ord.ord_no = @ordNo
),
rst_treatment_info AS (
  SELECT
    ord.ord_no,
    tmedi
  FROM
    ord_main AS ord
    CROSS JOIN LATERAL json_array_elements(ord.rst_treatment_info :: json) tmedi
  WHERE
    ord.ord_no = @ordNo
)
SELECT
  CAST(info.tmedi ->> ''ctl_no'' AS TEXT) || ''_'' || CAST(info.tmedi ->> ''row_no'' AS TEXT) AS disp_no,
  CASE
    info.tmedi ->> ''treat_class''
    WHEN ''0'' THEN ''調製薬剤''
    WHEN ''1'' THEN ''薬剤''
    WHEN ''2'' THEN ''処置''
    WHEN ''3'' THEN ''酸素吸入''
    WHEN ''4'' THEN ''心電図''
    ELSE ''不明''
  END || (
    CASE
      WHEN comp_info.complaint ->> ''complaint'' IS NOT NULL THEN (
        ''-'' || CAST(comp_info.complaint ->> ''complaint'' AS TEXT)
      )
      ELSE ''''
    END
  ) || (
    CASE
      WHEN info.tmedi ->> ''treat_name'' IS NOT NULL THEN (''-'' || CAST(info.tmedi ->> ''treat_name'' AS TEXT))
      ELSE ''''
    END
  ) AS disp_name,
  CASE
    WHEN info.tmedi ->> ''treat_class'' = ''3'' THEN info.tmedi ->> ''treat_class''
    ELSE ''1''
  END AS treat_class,
  info.tmedi ->> ''treat_cd'' AS treat_cd,
  info.tmedi ->> ''treat_medicine_cd'' AS medicine_cd,
  info.tmedi ->> ''procedure_cd'' AS procedure_cd,
  (info.tmedi ->> ''amount'') :: numeric AS amount,
  info.tmedi ->> ''unit'' AS unit,
  info.ord_no AS result_no,
  CAST(
    CAST(info.tmedi ->> ''occur_date'' AS TIMESTAMP) AS TEXT
  ) AS occur_date_start,
  CAST(
    CAST(info.tmedi ->> ''occur_date'' AS TIMESTAMP) AS TEXT
  ) AS occur_date_end,
  info.tmedi ->> ''oxygen_amount'' AS oxygen_amount,
  CASE
    WHEN info.tmedi ->> ''linkStartDate'' is NULL THEN info.tmedi ->> ''oxygen_start''  
    ELSE link_source_info.tmedi ->> ''oxygen_start''  
  END AS oxygen_start,
  CAST(
    (
	  CASE
	    WHEN info.tmedi ->> ''linkStartDate'' is NULL THEN CAST(info.tmedi ->> ''oxygen_start'' AS TIMESTAMP) :: TIMESTAMP (0) + (info.tmedi ->> ''oxygen_time'' || '' min'') :: interval 
	    ELSE CAST(link_source_info.tmedi ->> ''oxygen_start'' AS TIMESTAMP) :: TIMESTAMP (0) + (link_source_info.tmedi ->> ''oxygen_time'' || '' min'') :: interval 
	  END
    ) AS TEXT
  ) AS oxygen_start_new,
  CASE
    WHEN info.tmedi ->> ''linkStartDate'' is NULL THEN info.tmedi ->> ''oxygen_time'' 
    ELSE link_source_info.tmedi ->> ''oxygen_time'' 
  END AS oxygen_time,
  CAST(
    (
      CASE
        WHEN info.tmedi ->> ''linkStartDate'' IS NULL THEN  CAST(link_info.tmedi ->> ''occur_date'' AS TIMESTAMP) - CAST(info.tmedi ->> ''occur_date'' AS TIMESTAMP)
        ELSE CAST(info.tmedi ->> ''occur_date'' AS TIMESTAMP) - CAST(link_source_info.tmedi ->> ''occur_date'' AS TIMESTAMP)
      END
    ) AS TEXT
  ) AS oxygen_time_new,
  case 
    when abs(to_number(coalesce(replace((date_trunc(''day'',now()) - date_trunc(''day'',mp.in_hosp_a_startdate )) ::text,''days'',''''),''99999''),''99999'')) < abs(to_number(coalesce(replace((date_trunc(''day'',now()) - date_trunc(''day'',mp.in_hosp_b_startdate)) ::text,''days'',''''),''99999''),''99999'')) then  mp.in_hospital_cd_a1 
    else mp.in_hospital_cd_b1 
  end as mp_in_hospital_cd_1,
  case 
  	when abs(to_number(coalesce(replace((date_trunc(''day'',now()) - date_trunc(''day'',mp.in_hosp_a_startdate )) ::text,''days'',''''),''99999''),''99999'')) < abs(to_number(coalesce(replace((date_trunc(''day'',now()) - date_trunc(''day'',mp.in_hosp_b_startdate)) ::text,''days'',''''),''99999''),''99999'')) then  mp.in_hospital_cd_a2 
    else mp.in_hospital_cd_b2 
  end as mp_in_hospital_cd_2,
  CASE
    WHEN mmd.class_cd IS NOT NULL THEN mmd.class_cd --薬剤
    ELSE mmx.class_cd -- 調製薬剤
  END AS mmd_class_cd,
  CASE
    WHEN mmd.medicine_cd IS NOT NULL THEN mmd.medicine_cd --薬剤
    ELSE mmx.medicine_mix_cd -- 調製薬剤
  END AS mmd_medicine_cd,
  CASE
    WHEN mmd.is_shot IS NOT NULL THEN mmd.is_shot --薬剤
    ELSE mmx.is_shot -- 調製薬剤
  END AS mmd_is_shot,
  CASE
    WHEN mmd.in_hospital_cd_1 IS NOT NULL THEN TRIM(mmd.in_hospital_cd_1) --薬剤
    ELSE TRIM(mmx.in_hospital_cd_1) -- 調製薬剤
  END AS mmd_in_hospital_cd_1,
  CASE
    WHEN mmd.in_hospital_cd_2 IS NOT NULL THEN TRIM(mmd.in_hospital_cd_2) --薬剤
    ELSE TRIM(mmx.in_hospital_cd_2) -- 調製薬剤
  END AS mmd_in_hospital_cd_2
FROM
  rst_treatment_info AS info
  LEFT JOIN rst_treatment_info AS link_info ON info.tmedi ->> ''ctl_no'' = link_info.tmedi ->> ''linkStartDate''
  LEFT JOIN rst_treatment_info AS link_source_info ON info.tmedi ->> ''linkStartDate'' = link_source_info.tmedi ->> ''ctl_no''
  LEFT JOIN rst_complaint_info AS comp_info ON info.tmedi ->> ''ctl_no'' = comp_info.complaint ->> ''ctl_no''
  AND comp_info.complaint ->> ''comp_cd'' IS NOT NULL
  LEFT OUTER JOIN mst_medicine AS mmd -- 薬剤マスタ
  ON mmd.medicine_cd = to_number(
    info.tmedi ->> ''treat_medicine_cd'',
    ''999999999999''
  )
--   AND ''1'' = info.tmedi ->> ''treat_class''
  LEFT OUTER JOIN mst_medicine_mix AS mmx --調製薬剤マスタ
  ON mmx.medicine_mix_cd = to_number(
    info.tmedi ->> ''treat_medicine_cd'',
    ''999999999999''
  )
--   AND ''0'' = info.tmedi ->> ''treat_class''
  LEFT OUTER JOIN mst_procedure AS mp -- 手技マスタ
  ON mp.procedure_cd = to_number(info.tmedi ->> ''procedure_cd'', ''999999999999'')
WHERE
  mmx.mix_info IS NULL
UNION
SELECT
  CAST(info.tmedi ->> ''ctl_no'' AS TEXT) || ''_'' || CAST(info.tmedi ->> ''row_no'' AS TEXT) AS disp_no,
  CASE
    info.tmedi ->> ''treat_class''
    WHEN ''0'' THEN ''調製薬剤''
    WHEN ''1'' THEN ''薬剤''
    WHEN ''2'' THEN ''処置''
    WHEN ''3'' THEN ''酸素吸入''
    WHEN ''4'' THEN ''心電図''
    ELSE ''不明''
  END || (
    CASE
      WHEN comp_info.complaint ->> ''complaint'' IS NOT NULL THEN (
        ''-'' || CAST(comp_info.complaint ->> ''complaint'' AS TEXT)
      )
      ELSE ''''
    END
  ) || (
    CASE
      WHEN info.tmedi ->> ''treat_name'' IS NOT NULL THEN (''-'' || CAST(info.tmedi ->> ''treat_name'' AS TEXT))
      ELSE ''''
    END
  ) AS disp_name,
  CASE
    WHEN info.tmedi ->> ''treat_class'' = ''3'' THEN info.tmedi ->> ''treat_class''
    ELSE ''1''
  END AS treat_class,
  info.tmedi ->> ''treat_cd'' AS treat_cd,
  mmd2.medicine_cd :: text AS medicine_cd,
  info.tmedi ->> ''procedure_cd'' AS procedure_cd,
  (info.tmedi ->> ''amount'') :: numeric * (mix_infoes ->> ''amount'') :: numeric AS amount,
  info.tmedi ->> ''unit'' AS unit,
  info.ord_no AS result_no,
  CAST(
    CAST(info.tmedi ->> ''occur_date'' AS TIMESTAMP) AS TEXT
  ) AS occur_date_start,
  CAST(
    CAST(info.tmedi ->> ''occur_date'' AS TIMESTAMP) AS TEXT
  ) AS occur_date_end,
  info.tmedi ->> ''oxygen_amount'' AS oxygen_amount,
  info.tmedi ->> ''oxygen_start'' AS oxygen_start,
  CAST(
    (
      CAST(info.tmedi ->> ''oxygen_start'' AS TIMESTAMP) :: TIMESTAMP (0) + (info.tmedi ->> ''oxygen_time'' || '' min'') :: INTERVAL
    ) AS TEXT
  ) AS oxygen_start_new,
  info.tmedi ->> ''oxygen_time'' AS oxygen_time,
  CAST(
    (
      CAST(info.tmedi ->> ''occur_date'' AS TIMESTAMP) - CAST(info.tmedi ->> ''occur_date'' AS TIMESTAMP)
    ) AS TEXT
  ) AS oxygen_time_new,
  case 
    when abs(to_number(coalesce(replace((date_trunc(''day'',now()) - date_trunc(''day'',mp.in_hosp_a_startdate )) ::text,''days'',''''),''99999''),''99999'')) < abs(to_number(coalesce(replace((date_trunc(''day'',now()) - date_trunc(''day'',mp.in_hosp_b_startdate)) ::text,''days'',''''),''99999''),''99999'')) then  mp.in_hospital_cd_a1 
    else mp.in_hospital_cd_b1 
  end as mp_in_hospital_cd_1,
  case 
  	when abs(to_number(coalesce(replace((date_trunc(''day'',now()) - date_trunc(''day'',mp.in_hosp_a_startdate )) ::text,''days'',''''),''99999''),''99999'')) < abs(to_number(coalesce(replace((date_trunc(''day'',now()) - date_trunc(''day'',mp.in_hosp_b_startdate)) ::text,''days'',''''),''99999''),''99999'')) then  mp.in_hospital_cd_a2 
    else mp.in_hospital_cd_b2 
  end as mp_in_hospital_cd_2,
  CASE
    WHEN mmd2.class_cd IS NOT NULL THEN mmd2.class_cd --薬剤
    ELSE mmx.class_cd -- 調製薬剤
  END AS mmd_class_cd,
  CASE
    WHEN mmd2.medicine_cd IS NOT NULL THEN mmd2.medicine_cd --薬剤
    ELSE mmx.medicine_mix_cd -- 調製薬剤
  END AS mmd_medicine_cd,
  CASE
    WHEN mmd2.is_shot IS NOT NULL THEN mmd2.is_shot --薬剤
    ELSE mmx.is_shot -- 調製薬剤
  END AS mmd_is_shot,
  CASE
    WHEN mmd2.in_hospital_cd_1 IS NOT NULL THEN TRIM(mmd2.in_hospital_cd_1) --薬剤
    ELSE TRIM(mmx.in_hospital_cd_1) -- 調製薬剤
  END AS mmd_in_hospital_cd_1,
  CASE
    WHEN mmd2.in_hospital_cd_2 IS NOT NULL THEN TRIM(mmd2.in_hospital_cd_2) --薬剤
    ELSE TRIM(mmx.in_hospital_cd_2) -- 調製薬剤
  END AS mmd_in_hospital_cd_2
FROM
  rst_treatment_info AS info
  LEFT JOIN rst_treatment_info AS link_info ON info.tmedi ->> ''ctl_no'' = link_info.tmedi ->> ''linkStartDate''
  LEFT JOIN rst_treatment_info AS link_source_info ON info.tmedi ->> ''linkStartDate'' = link_source_info.tmedi ->> ''ctl_no''
  LEFT JOIN rst_complaint_info AS comp_info ON info.tmedi ->> ''ctl_no'' = comp_info.complaint ->> ''ctl_no''
  AND comp_info.complaint ->> ''comp_cd'' IS NOT NULL
  LEFT OUTER JOIN mst_medicine AS mmd -- 薬剤マスタ
  ON mmd.medicine_cd = to_number(
    info.tmedi ->> ''treat_medicine_cd'',
    ''999999999999''
  )
--   AND ''1'' = info.tmedi ->> ''treat_class''
  LEFT OUTER JOIN mst_medicine_mix AS mmx --調製薬剤マスタ
  ON mmx.medicine_mix_cd = to_number(
    info.tmedi ->> ''treat_medicine_cd'',
    ''999999999999''
  )
--   AND ''0'' = info.tmedi ->> ''treat_class''
  LEFT OUTER JOIN mst_procedure AS mp -- 手技マスタ
  ON mp.procedure_cd = to_number(info.tmedi ->> ''procedure_cd'', ''999999999999'')
  CROSS JOIN lateral json_array_elements (mmx.mix_info :: json) mix_infoes -- 調製薬剤分離
  LEFT OUTER JOIN mst_medicine AS mmd2 -- 調製薬剤_薬剤マスタ
  ON mmd2.medicine_cd = TO_NUMBER(mix_infoes ->> ''cd'', ''999999999999'')
ORDER BY
  occur_date_start ASC,
  disp_no ASC', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, '{"classes": []}'::jsonb, 'CSI透析実績(透析条件)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-604167, '-- 【SQL_CD=-604167】
SELECT
  medi ->> ''no'' AS ctl_no,
  medi ->> ''effect_flg'' AS effect_flg,
  medi ->> ''cd'' AS medicine_cd,
  case
    when mmd.medicine_cd is not null then mmd.medicine_cd --薬剤
    else mmx.medicine_mix_cd -- 調製薬剤
  end AS mmd_medicine_cd,
  case
    when mmd.is_shot is not null then mmd.is_shot --薬剤
    else mmx.is_shot -- 調製薬剤
  end AS mmd_is_shot,
  case
    when mmd.in_hospital_cd_1 is not null then TRIM(mmd.in_hospital_cd_1) --薬剤
    else TRIM(mmx.in_hospital_cd_1) -- 調製薬剤
  end AS mmd_in_hospital_cd_1,
  case
    when mmd.in_hospital_cd_2 is not null then TRIM(mmd.in_hospital_cd_2) --薬剤
    else TRIM(mmx.in_hospital_cd_2) -- 調製薬剤
  end AS mmd_in_hospital_cd_2,
  medi ->> ''procedure_cd'' AS procedure_cd,
  medi ->> ''class_cd'' AS class_cd,
  medi ->> ''class_type'' AS class_type,
  cast(
    cast(medi ->> ''effect_date'' as timestamp) AS TEXT
  ) AS effect_date,
  ''0'' AS set_medicine_flg,
  (medi ->> ''amount'') :: numeric as amount,
  medi ->> ''unit'' AS unit,
  mp.pricedure_name AS pricedure_name,
  case 
    when abs(to_number(coalesce(replace((date_trunc(''day'',now()) - date_trunc(''day'',mp.in_hosp_a_startdate )) ::text,''days'',''''),''99999''),''99999'')) < abs(to_number(coalesce(replace((date_trunc(''day'',now()) - date_trunc(''day'',mp.in_hosp_b_startdate)) ::text,''days'',''''),''99999''),''99999'')) then  mp.in_hospital_cd_a1 
    else mp.in_hospital_cd_b1 
  end as mp_in_hospital_cd_1,
  case 
  	when abs(to_number(coalesce(replace((date_trunc(''day'',now()) - date_trunc(''day'',mp.in_hosp_a_startdate )) ::text,''days'',''''),''99999''),''99999'')) < abs(to_number(coalesce(replace((date_trunc(''day'',now()) - date_trunc(''day'',mp.in_hosp_b_startdate)) ::text,''days'',''''),''99999''),''99999'')) then  mp.in_hospital_cd_a2 
    else mp.in_hospital_cd_b2 
  end as mp_in_hospital_cd_2
FROM
  ord_main AS ord
  CROSS JOIN LATERAL json_array_elements (ord.rst_medi_info :: json) medi
  LEFT OUTER JOIN mst_medicine AS mmd -- 薬剤マスタ
  ON mmd.medicine_cd = TO_NUMBER(medi ->> ''cd'', ''999999999999'')
  AND ''1'' = medi ->> ''medicine_type''
  LEFT OUTER JOIN mst_medicine_mix AS mmx --調製薬剤マスタ
  ON mmx.medicine_mix_cd = TO_NUMBER(medi ->> ''cd'', ''999999999999'')
  AND ''2'' = medi ->> ''medicine_type''
  LEFT OUTER JOIN mst_procedure AS mp -- 手技マスタ 
  ON mp.procedure_cd = TO_NUMBER(medi ->> ''procedure_cd'', ''999999999999'')
WHERE
  medi ->> ''effect_flg'' = ''1''
  AND ord.ord_no = @ordNo
  AND mmx.mix_info IS NULL
UNION
SELECT
  medi ->> ''no'' AS ctl_no,
  medi ->> ''effect_flg'' AS effect_flg,
  medi ->> ''cd'' AS medicine_cd,
  case
    when mmd.medicine_cd is not null then mmd.medicine_cd --薬剤
    else mmx.medicine_mix_cd -- 調製薬剤
  end AS mmd_medicine_cd,
  case
    when mmd.is_shot is not null then mmd.is_shot --薬剤
    else mmx.is_shot -- 調製薬剤
  end AS mmd_is_shot,
  case
    when mmd.in_hospital_cd_1 is not null then TRIM(mmd.in_hospital_cd_1) --薬剤
    else TRIM(mmx.in_hospital_cd_1) -- 調製薬剤
  end AS mmd_in_hospital_cd_1,
  case
    when mmd.in_hospital_cd_2 is not null then TRIM(mmd.in_hospital_cd_2) --薬剤
    else TRIM(mmx.in_hospital_cd_2) -- 調製薬剤
  end AS mmd_in_hospital_cd_2,
  medi ->> ''procedure_cd'' AS procedure_cd,
  medi ->> ''class_cd'' AS class_cd,
  medi ->> ''class_type'' AS class_type,
  cast(
    cast(medi ->> ''effect_date'' as timestamp) AS TEXT
  ) AS effect_date,
  ''0'' AS set_medicine_flg,
  (medi ->> ''amount'') :: numeric * (mix_infoes ->> ''amount'') :: numeric as amount,
  medi ->> ''unit'' AS unit,
  mp.pricedure_name AS pricedure_name,
  case 
    when abs(to_number(coalesce(replace((date_trunc(''day'',now()) - date_trunc(''day'',mp.in_hosp_a_startdate )) ::text,''days'',''''),''99999''),''99999'')) < abs(to_number(coalesce(replace((date_trunc(''day'',now()) - date_trunc(''day'',mp.in_hosp_b_startdate)) ::text,''days'',''''),''99999''),''99999'')) then  mp.in_hospital_cd_a1 
    else mp.in_hospital_cd_b1 
  end as mp_in_hospital_cd_1,
  case 
  	when abs(to_number(coalesce(replace((date_trunc(''day'',now()) - date_trunc(''day'',mp.in_hosp_a_startdate )) ::text,''days'',''''),''99999''),''99999'')) < abs(to_number(coalesce(replace((date_trunc(''day'',now()) - date_trunc(''day'',mp.in_hosp_b_startdate)) ::text,''days'',''''),''99999''),''99999'')) then  mp.in_hospital_cd_a2 
    else mp.in_hospital_cd_b2 
  end as mp_in_hospital_cd_2
FROM
  ord_main AS ord
  CROSS JOIN LATERAL json_array_elements (ord.rst_medi_info :: json) medi
  LEFT OUTER JOIN mst_medicine AS mmd -- 薬剤マスタ
  ON mmd.medicine_cd = TO_NUMBER(medi ->> ''cd'', ''999999999999'')
  AND ''1'' = medi ->> ''medicine_type''
  LEFT OUTER JOIN mst_medicine_mix AS mmx --調製薬剤マスタ
  ON mmx.medicine_mix_cd = TO_NUMBER(medi ->> ''cd'', ''999999999999'')
  AND ''2'' = medi ->> ''medicine_type''
  LEFT OUTER JOIN mst_procedure AS mp -- 手技マスタ 
  ON mp.procedure_cd = TO_NUMBER(medi ->> ''procedure_cd'', ''999999999999'')
  CROSS JOIN lateral json_array_elements (mmx.mix_info :: json) mix_infoes -- 調製薬剤分離
  LEFT OUTER JOIN mst_medicine AS med2 -- 調製薬剤_薬剤マスタ
  ON med2.medicine_cd = TO_NUMBER(mix_infoes ->> ''cd'', ''999999999999'')
WHERE
  medi ->> ''effect_flg'' = ''1''
  AND ord.ord_no = @ordNo', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, '{"classes": []}'::jsonb, 'CSI透析実績(透析条件)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-604166, '-- 【SQL_CD=-604166】
WITH item_name AS (
  SELECT
    ''001'' AS fnw_cd,
    ''-1'' AS ntss_cd,
    ''透析開始時刻'' AS fnw_name
  UNION
  SELECT
    ''002'' AS fnw_cd,
    ''1'' AS ntss_cd,
    ''透析時間'' AS fnw_name
  UNION
  SELECT
    ''003'' AS fnw_cd,
    ''2'' AS ntss_cd,
    ''VA'' AS fnw_name
  UNION
  SELECT
    ''004'' AS fnw_cd,
    ''39'' AS ntss_cd,
    ''DW'' AS fnw_name
  UNION
  SELECT
    ''005'' AS fnw_cd,
    ''3'' AS ntss_cd,
    ''目標体重'' AS fnw_name
  UNION
  SELECT
    ''006'' AS fnw_cd,
    ''-2'' AS ntss_cd,
    ''治療方法'' AS fnw_name
  UNION
  SELECT
    ''007'' AS fnw_cd,
    ''4'' AS ntss_cd,
    ''除水量制限'' AS fnw_name
  UNION
  SELECT
    ''008'' AS fnw_cd,
    ''5'' AS ntss_cd,
    ''ダイアライザ'' AS fnw_name
  UNION
  SELECT
    ''009'' AS fnw_cd,
    ''6'' AS ntss_cd,
    ''吸着カラム'' AS fnw_name
  UNION
  SELECT
    ''010'' AS fnw_cd,
    ''14'' AS ntss_cd,
    ''血流量'' AS fnw_name
  UNION
  SELECT
    ''011'' AS fnw_cd,
    ''25'' AS ntss_cd,
    ''抗凝固剤'' AS fnw_name
  UNION
  SELECT
    ''012'' AS fnw_cd,
    ''26'' AS ntss_cd,
    ''抗凝固剤ワンショット量'' AS fnw_name
  UNION
  SELECT
    ''013'' AS fnw_cd,
    ''27'' AS ntss_cd,
    ''抗凝固剤持続速度'' AS fnw_name
  UNION
  SELECT
    ''014'' AS fnw_cd,
    ''28'' AS ntss_cd,
    ''抗凝固剤持続総量'' AS fnw_name
  UNION
  SELECT
    ''015'' AS fnw_cd,
    ''29'' AS ntss_cd,
    ''IP使用選択'' AS fnw_name
  UNION
  SELECT
    ''016'' AS fnw_cd,
    ''31'' AS ntss_cd,
    ''IPワンショット量'' AS fnw_name
  UNION
  SELECT
    ''017'' AS fnw_cd,
    ''32'' AS ntss_cd,
    ''IP速度'' AS fnw_name
  UNION
  SELECT
    ''018'' AS fnw_cd,
    ''15'' AS ntss_cd,
    ''透析液'' AS fnw_name
  UNION
  SELECT
    ''019'' AS fnw_cd,
    ''16'' AS ntss_cd,
    ''透析液流量'' AS fnw_name
  UNION
  SELECT
    ''020'' AS fnw_cd,
    ''17'' AS ntss_cd,
    ''透析液量'' AS fnw_name
  UNION
  SELECT
    ''021'' AS fnw_cd,
    ''18'' AS ntss_cd,
    ''透析液温度'' AS fnw_name
  UNION
  SELECT
    ''022'' AS fnw_cd,
    ''19'' AS ntss_cd,
    ''補液'' AS fnw_name
  UNION
  SELECT
    ''023'' AS fnw_cd,
    ''20'' AS ntss_cd,
    ''補液量'' AS fnw_name
  UNION
  SELECT
    ''024'' AS fnw_cd,
    ''21'' AS ntss_cd,
    ''補液選択'' AS fnw_name
  UNION
  SELECT
    ''025'' AS fnw_cd,
    ''23'' AS ntss_cd,
    ''補液温度'' AS fnw_name
  UNION
  SELECT
    ''026'' AS fnw_cd,
    ''-3'' AS ntss_cd,
    ''UFRプログラム'' AS fnw_name
  UNION
  SELECT
    ''027'' AS fnw_cd,
    ''-4'' AS ntss_cd,
    ''Na注入プログラム'' AS fnw_name
  UNION
  SELECT
    ''028'' AS fnw_cd,
    ''-5'' AS ntss_cd,
    ''透析液濃度プログラム'' AS fnw_name
  UNION
  SELECT
    ''029'' AS fnw_cd,
    ''12'' AS ntss_cd,
    ''シングルニードル使用'' AS fnw_name
  UNION
  SELECT
    ''030'' AS fnw_cd,
    ''22'' AS ntss_cd,
    ''補液使用数'' AS fnw_name
  UNION
  SELECT
    ''031'' AS fnw_cd,
    ''30'' AS ntss_cd,
    ''IPスタート'' AS fnw_name
  UNION
  SELECT
    ''032'' AS fnw_cd,
    ''34'' AS ntss_cd,
    ''自動ワンショット'' AS fnw_name
  UNION
  SELECT
    ''033'' AS fnw_cd,
    ''35'' AS ntss_cd,
    ''IP電源自動切り'' AS fnw_name
  UNION
  SELECT
    ''034'' AS fnw_cd,
    ''36'' AS ntss_cd,
    ''IP電源自動切り時間'' AS fnw_name
  UNION
  SELECT
    ''035'' AS fnw_cd,
    ''37'' AS ntss_cd,
    ''IP電源OKモニタ切り'' AS fnw_name
  UNION
  SELECT
    ''036'' AS fnw_cd,
    ''38'' AS ntss_cd,
    ''IP電源OKモニタ切り時間'' AS fnw_name
  UNION
  SELECT
    ''037'' AS fnw_cd,
    ''33'' AS ntss_cd,
    ''IP速度最大値'' AS fnw_name
  UNION
  SELECT
    ''038'' AS fnw_cd,
    ''24'' AS ntss_cd,
    ''補液速度'' AS fnw_name
  UNION
  SELECT
    ''039'' AS fnw_cd,
    ''7'' AS ntss_cd,
    ''1次膜'' AS fnw_name
  UNION
  SELECT
    ''040'' AS fnw_cd,
    ''8'' AS ntss_cd,
    ''2次膜'' AS fnw_name
  UNION
  SELECT
    ''-1'' AS fnw_cd,
    ''9'' AS ntss_cd,
    ''穿刺針(A針)'' AS fnw_name
  UNION
  SELECT
    ''-2'' AS fnw_cd,
    ''10'' AS ntss_cd,
    ''穿刺針(V針)'' AS fnw_name
  UNION
  SELECT
    ''-3'' AS fnw_cd,
    ''11'' AS ntss_cd,
    ''穿刺針(SN)'' AS fnw_name
  ORDER BY
    fnw_cd asc
),
rst_cond_info AS (
  SELECT
    jsonb_object_keys (ord.rst_cond_info) AS ntss_cd,
    ord.rst_cond_info -> jsonb_object_keys (ord.rst_cond_info) AS rst_cond_info,
    ord.rst_cond_info -> ''16'' ->> ''value'' AS value_16,
    ord.rst_cond_info -> ''20'' ->> ''value'' AS value_20,
    ord.rst_cond_info -> ''26'' ->> ''value'' AS value_26,
    ord.rst_cond_info -> ''28'' ->> ''value'' AS value_28
  FROM
    ord_main AS ord
  WHERE
    ord.ord_no = @ordNo
  UNION
  -- 006:治療方法（-2）
  SELECT
    ''-2'' as ntss_cd,
    (''{"value":'' || ord.rst_treatment_cd || ''}'') :: jsonb AS rst_cond_info,
    ''0'' AS value_16,
    ''0'' AS value_20,
    ''0'' AS value_26,
    ''0'' AS value_28
  FROM
    ord_main AS ord
  WHERE
    ord.ord_no = @ordNo
  UNION
  -- 001:透析開始時刻（-1）
  SELECT
    ''-1'' as ntss_cd,
    (
      ''{"value":"'' || to_char(ord.rst_start_date, ''HH24MI'') || ''"}''
    ) :: jsonb AS rst_cond_info,
    ''0'' AS value_16,
    ''0'' AS value_20,
    ''0'' AS value_26,
    ''0'' AS value_28
  FROM
    ord_main AS ord
  WHERE
    ord.ord_no = @ordNo
)
SELECT
  ''透析条件'' AS detail_id,
  item_name.fnw_cd as item_cd,
  cond.ntss_cd as ntss_cd,
  item_name.fnw_name as item_name,
  case
      when cond.ntss_cd = ''15'' then ''0''
      when cond.ntss_cd = ''19'' then ''0''
      else cond.rst_cond_info ->> ''value'' 
  end as item_value,
  cond.rst_cond_info ->> ''value_name_1'' as item_value_name,
  TRIM (meqa.in_hospital_cd_1) as meqa_in_hospital_cd,
  --医療材料院内コード
  TRIM (med.in_hospital_cd_1) as med_in_hospital_cd,
  --薬剤院内コード
  med.is_shot as med_is_shot,
  --薬剤-注射  
  TRIM (mtt.in_hospital_cd_a1) as mtt_in_hospital_cd,
  --治療方法院内コード
  TRIM (mtt.treatment_name) as mtt_treatment_name,
  --治療方法名
  TRIM (mdr.in_hospital_cd_1) as mdr_in_hospital_cd,
  --ダイアライザ院内コード
  TRIM (mva.in_hospital_cd_1) as mva_in_hospital_cd,
  --VA院内コード
  cond.rst_cond_info ->> ''unit'' as item_value_unit,
  cond.rst_cond_info ->> ''medicine_type'' as medicine_type,
  cond.rst_cond_info ->> ''ind_user_id'' as ind_user_id,
  cond.rst_cond_info ->> ''upd_user_id'' as upd_user_id
FROM
  item_name,
  rst_cond_info as cond
  LEFT OUTER JOIN mst_equipment AS meqa -- 医療材料マスタ
  ON meqa.equipment_cd = TO_NUMBER(cond.rst_cond_info ->> ''value'', ''999999999999'')
  AND cond.ntss_cd in (''6'', ''7'', ''8'')
  LEFT OUTER JOIN mst_medicine AS med -- 薬剤マスタ
  ON med.medicine_cd = TO_NUMBER(cond.rst_cond_info ->> ''value'', ''999999999999'')
  AND cond.ntss_cd in (''15'', ''19'')
  AND cond.rst_cond_info ->> ''medicine_type'' = ''1''
  LEFT OUTER JOIN mst_medicine_mix AS mmx -- 調製薬剤マスタ
  ON mmx.medicine_mix_cd = TO_NUMBER(cond.rst_cond_info ->> ''value'', ''999999999999'')
  AND cond.ntss_cd in (''15'', ''19'')
  AND cond.rst_cond_info ->> ''medicine_type'' = ''2''
  LEFT OUTER JOIN mst_treatment AS mtt -- 治療方法マスタ
  ON mtt.treatment_cd = TO_NUMBER(cond.rst_cond_info ->> ''value'', ''999999999999'')
  AND cond.ntss_cd in (''-2'')
  LEFT OUTER JOIN mst_dialyzer AS mdr -- ダイアライザマスタ
  ON mdr.dialyzer_cd = TO_NUMBER(cond.rst_cond_info ->> ''value'', ''999999999999'')
  AND cond.ntss_cd in (''5'')
  LEFT OUTER JOIN mst_va AS mva -- VAマスタ
  ON mva.va_cd = TO_NUMBER(cond.rst_cond_info ->> ''value'', ''999999999999'')
  AND cond.ntss_cd in (''2'')
WHERE
  cond.ntss_cd = item_name.ntss_cd
  AND TO_NUMBER(item_name.fnw_cd, ''999'') > 0
  AND mmx.mix_info IS NULL
  AND cond.ntss_cd not in (''25'')

UNION
SELECT
  ''透析条件'' AS detail_id,
  item_name.fnw_cd as item_cd,
  cond.ntss_cd as ntss_cd,
  item_name.fnw_name as item_name,
  case
    when cond.ntss_cd = ''15'' then ''0''
    when cond.ntss_cd = ''19'' then ''0''
    else cond.rst_cond_info ->> ''value''
  end as item_value,
  cond.rst_cond_info ->> ''value_name_1'' as item_value_name,
  TRIM (meqa.in_hospital_cd_1) as meqa_in_hospital_cd,
  --医療材料院内コード
  TRIM (med2.in_hospital_cd_1) as med_in_hospital_cd,
  --薬剤院内コード
  med2.is_shot as med_is_shot,
  --薬剤-注射  
  TRIM (mtt.in_hospital_cd_a1) as mtt_in_hospital_cd,
  --治療方法院内コード
  TRIM (mtt.treatment_name) as mtt_treatment_name,
  --治療方法名
  TRIM (mdr.in_hospital_cd_1) as mdr_in_hospital_cd,
  --ダイアライザ院内コード
  TRIM (mva.in_hospital_cd_1) as mva_in_hospital_cd,
  --VA院内コード
  cond.rst_cond_info ->> ''unit'' as item_value_unit,
  cond.rst_cond_info ->> ''medicine_type'' as medicine_type,
  cond.rst_cond_info ->> ''ind_user_id'' as ind_user_id,
  cond.rst_cond_info ->> ''upd_user_id'' as upd_user_id
FROM
  item_name,
  rst_cond_info as cond
  LEFT OUTER JOIN mst_equipment AS meqa -- 医療材料マスタ
  ON meqa.equipment_cd = TO_NUMBER(cond.rst_cond_info ->> ''value'', ''999999999999'')
  AND cond.ntss_cd in (''6'', ''7'', ''8'')
  LEFT OUTER JOIN mst_medicine AS med -- 薬剤マスタ
  ON med.medicine_cd = TO_NUMBER(cond.rst_cond_info ->> ''value'', ''999999999999'')
  AND cond.ntss_cd in (''15'', ''19'')
  AND cond.rst_cond_info ->> ''medicine_type'' = ''1''
  LEFT OUTER JOIN mst_medicine_mix AS mmx -- 調製薬剤マスタ
  ON mmx.medicine_mix_cd = TO_NUMBER(cond.rst_cond_info ->> ''value'', ''999999999999'')
  AND cond.ntss_cd in (''15'', ''19'')
  AND cond.rst_cond_info ->> ''medicine_type'' = ''2''
  LEFT OUTER JOIN mst_treatment AS mtt -- 治療方法マスタ
  ON mtt.treatment_cd = TO_NUMBER(cond.rst_cond_info ->> ''value'', ''999999999999'')
  AND cond.ntss_cd in (''-2'')
  LEFT OUTER JOIN mst_dialyzer AS mdr -- ダイアライザマスタ
  ON mdr.dialyzer_cd = TO_NUMBER(cond.rst_cond_info ->> ''value'', ''999999999999'')
  AND cond.ntss_cd in (''5'')
  LEFT OUTER JOIN mst_va AS mva -- VAマスタ
  ON mva.va_cd = TO_NUMBER(cond.rst_cond_info ->> ''value'', ''999999999999'')
  AND cond.ntss_cd in (''2'')
  CROSS JOIN lateral json_array_elements (mmx.mix_info :: json) mix_infoes -- 調製薬剤分離
  LEFT OUTER JOIN mst_medicine AS med2 -- 調製薬剤_薬剤マスタ
  ON med2.medicine_cd = TO_NUMBER(mix_infoes ->> ''cd'', ''999999999999'')
WHERE
  cond.ntss_cd = item_name.ntss_cd
  AND TO_NUMBER(item_name.fnw_cd, ''999'') > 0
  AND cond.ntss_cd not in (''25'')', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, '{"classes": []}'::jsonb, 'CSI透析実績(透析条件)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-604165, '-- 【SQL_CD=-604165】
SELECT
  coalesce(mst_user_authentication.disp_user_id, '''') AS user_id,
  split_part(journal_arr.journal_row, ''-@-'', 2) AS up_date,
  split_part(journal_arr.journal_row, ''-@-'', 4) AS is_doctor
FROM
  (
    SELECT
      REGEXP_SPLIT_TO_TABLE(@journalArrString, ''-@@@-'') as journal_row
  ) AS journal_arr
  LEFT JOIN mst_user_authentication ON split_part(journal_arr.journal_row, ''-@-'', 1) = mst_user_authentication.user_id :: text
', 1, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, '{"classes": []}'::jsonb, 'CSI透析予約(連携電文の条件詳細)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": -604164, "field_name": "journal_arr_string", "replace_var": "@journalArrString"}]'::jsonb);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-604161, '-- 【SQL_CD=-604161】
SELECT
  coalesce(ind_user.disp_user_id, '''') AS ind_user_id,
  coalesce(upd_user.disp_user_id, '''') AS upd_user_id,
  CASE 
  WHEN split_part(ind_arr.ind_row, ''-@-'', 3) = '''' THEN ''''
  ELSE to_char(split_part(ind_arr.ind_row, ''-@-'', 3)::Timestamp, ''YYYY/MM/DD HH24:MI:SS'')
  END AS up_date,
  split_part(ind_arr.ind_row, ''-@-'', 5) AS is_doctor
FROM
  (
    SELECT
      REGEXP_SPLIT_TO_TABLE(@indArrString, ''-@@@-'') as ind_row
  ) AS ind_arr
  LEFT JOIN mst_user_authentication as ind_user ON split_part(ind_arr.ind_row, ''-@-'', 1) = ind_user.user_id :: text
  LEFT JOIN mst_user_authentication as upd_user ON split_part(ind_arr.ind_row, ''-@-'', 2) = upd_user.user_id :: text', 1, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, '{"classes": []}'::jsonb, 'CSI透析予約(連携電文の条件詳細)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": -604160, "field_name": "ind_arr_string", "replace_var": "@indArrString"}]'::jsonb);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-604157, '-- 【SQL_CD=-604157】
SELECT
  coalesce(ind_user.disp_user_id, '''') AS ind_user_id,
  coalesce(upd_user.disp_user_id, '''') AS upd_user_id,
  to_char(split_part(equip_arr.equip_row, ''-@-'', 3)::Timestamp, ''YYYY/MM/DD HH24:MI:SS'') AS up_date,
  split_part(equip_arr.equip_row, ''-@-'', 5) AS is_doctor
FROM
  (
    SELECT
      REGEXP_SPLIT_TO_TABLE(@equipArrString, ''-@@@-'') as equip_row
  ) AS equip_arr
  LEFT JOIN mst_user_authentication as ind_user ON split_part(equip_arr.equip_row, ''-@-'', 1) = ind_user.user_id :: text
  LEFT JOIN mst_user_authentication as upd_user ON split_part(equip_arr.equip_row, ''-@-'', 2) = upd_user.user_id :: text', 1, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, '{"classes": []}'::jsonb, 'CSI透析予約(連携電文の条件詳細)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": -604156, "field_name": "equip_arr_string", "replace_var": "@equipArrString"}]'::jsonb);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-604153, '-- 【SQL_CD=-604153】
SELECT
  split_part(cond_arr.cond_row, ''-@-'', 1) AS item_cd,
  split_part(cond_arr.cond_row, ''-@-'', 2) AS item_name,
  split_part(cond_arr.cond_row, ''-@-'', 3) AS item_value,
  split_part(cond_arr.cond_row, ''-@-'', 4) AS item_value_name,
  split_part(cond_arr.cond_row, ''-@-'', 5) AS item_value_unit,
  coalesce(ind_user.disp_user_id, '''') AS ind_user_id,
  coalesce(upd_user.disp_user_id, '''') AS upd_user_id,
  to_char(split_part(cond_arr.cond_row, ''-@-'', 8)::Timestamp, ''YYYY/MM/DD HH24:MI:SS'') AS up_date,
  split_part(cond_arr.cond_row, ''-@-'', 9) AS add_item,
  split_part(cond_arr.cond_row, ''-@-'', 11) AS is_doctor
FROM
  (
    SELECT
      REGEXP_SPLIT_TO_TABLE(@condArrString, ''-@@@-'') as cond_row
  ) AS cond_arr
  LEFT JOIN mst_user_authentication as ind_user ON split_part(cond_arr.cond_row, ''-@-'', 6) = ind_user.user_id :: text
  LEFT JOIN mst_user_authentication as upd_user ON split_part(cond_arr.cond_row, ''-@-'', 7) = upd_user.user_id :: text', 1, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, '{"classes": []}'::jsonb, 'CSI透析予約(連携電文の条件詳細)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": -604152, "field_name": "cond_arr_string", "replace_var": "@condArrString"}]'::jsonb);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-604108, '-- 【SQL_CD=-604108】
SELECT
  coalesce(ind_user.disp_user_id, '''') AS ind_user_id,
  coalesce(upd_user.disp_user_id, '''') AS upd_user_id,
  to_char(
    split_part(schedule.schedule_row, ''-@-'', 3) :: Timestamp,
    ''YYYY/MM/DD HH24:MI:SS''
  ) AS up_date,
  split_part(schedule.schedule_row, ''-@-'', 5) AS is_doctor
FROM
  (
    SELECT
      @scheduleString as schedule_row
  ) AS schedule
  LEFT JOIN mst_user_authentication as ind_user ON split_part(schedule.schedule_row, ''-@-'', 1) = ind_user.user_id :: text
  LEFT JOIN mst_user_authentication as upd_user ON split_part(schedule.schedule_row, ''-@-'', 2) = upd_user.user_id :: text', 1, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, '{"classes": []}'::jsonb, 'CSI透析予約(連携電文の予約詳細)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": -604107, "field_name": "schedule_string", "replace_var": "@scheduleString"}]'::jsonb);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-604104, '-- 【SQL_CD=-604104】
SELECT
  coalesce(ind_user.disp_user_id, '''') AS ind_user_id,
  coalesce(upd_user.disp_user_id, '''') AS upd_user_id,
  to_char(split_part(medi_arr.medi_row, ''-@-'', 3)::Timestamp, ''YYYY/MM/DD HH24:MI:SS'') AS up_date,
  split_part(medi_arr.medi_row, ''-@-'', 5) AS is_doctor
FROM
  (
    SELECT
      REGEXP_SPLIT_TO_TABLE(@mediArrString, ''-@@@-'') as medi_row
  ) AS medi_arr
  LEFT JOIN mst_user_authentication as ind_user ON split_part(medi_arr.medi_row, ''-@-'', 1) = ind_user.user_id :: text
  LEFT JOIN mst_user_authentication as upd_user ON split_part(medi_arr.medi_row, ''-@-'', 2) = upd_user.user_id :: text', 1, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, '{"classes": []}'::jsonb, 'CSI透析予約(連携電文の投薬詳細)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": -604103, "field_name": "medi_arr_string", "replace_var": "@mediArrString"}]'::jsonb);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-603205, 'WITH new_name_info AS (
  SELECT
    substring(''@lastName'' ::TEXT from ''^(.*?)[\u3000\s]'') AS patLastName
    , substring(''@lastName'' ::TEXT from ''[\u3000\s](.*)'') AS patFirstName
) 
UPDATE
  ntss.pat_personal_main
SET
  other_contact_info = other_contact_info || json_build_object(''ctl_no'',null,''disp_order'',null,''is_key_person'',null,''pat_id'',null,''last_name'', (SELECT patLastName FROM new_name_info) ,''first_name'', (SELECT patFirstName FROM new_name_info) ,''last_name_kana'',null,''first_name_kana'',null,''relation_cd'', NULL ,''relation_name'', CASE WHEN ''@relationCd'' = ''0'' THEN ''その他(本人)'' WHEN ''@relationCd'' = ''99'' THEN ''その他'' ELSE null END ,''zip_cd'',''@zipCd'',''address'',''@address'',''e_mail'',null,''work_name'',null,''work_tel'',null,''tel1'',''@tel1'',''tel2'',null,''fax'',null,''memo1'', null,''memo2'',null)::jsonb
WHERE
  is_del = ''0''
  AND hosp_pat_id = ''@hospPatId''
  AND facility_cd = ''@facilityCd''', 3, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)患者個人情報の取得', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-603204, 'UPDATE ntss.pat_personal_main
SET other_contact_info = (
  SELECT jsonb_agg(
    CASE
      WHEN NULLIF(REPLACE(REPLACE(concat((elem ->> ''last_name'')::TEXT, (elem ->> ''first_name'')::TEXT), ''　'', ''''), '' '', ''''), '''') = NULLIF(REPLACE(REPLACE(''@lastName'', ''　'', ''''), '' '', ''''), '''')
        AND (elem ->> ''relation_name'')::TEXT = 
          CASE 
            WHEN ''@relationCd'' = ''0'' THEN ''その他(本人)''::TEXT 
            WHEN ''@relationCd'' = ''99'' THEN ''その他''::TEXT
            ELSE NULL
          END 
      THEN
        jsonb_set(
          jsonb_set(
            jsonb_set(elem, ''{zip_cd}'', ''"@zipCd"''::jsonb, false),
            ''{address}'', ''"@address"''::jsonb, false),
          ''{tel1}'', ''"@tel1"''::jsonb, false
        )
      ELSE elem
    END
  )
  FROM jsonb_array_elements(personal_info_decrypt_jsonb(other_contact_info)) AS elem
)
WHERE
  is_del = ''0''
  AND hosp_pat_id = ''@hospPatId''
  AND facility_cd = ''@facilityCd'';', 3, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)CSIの患者プロファイル', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-603202, '-- 【SQL_CD=-603202】
WITH mst_course_info AS (
  SELECT
    mst_course.course_cd :: text as course_cd
  , mst_course.in_hospital_cd_1
  FROM
    mst_course
  WHERE
    mst_course.facility_cd = ''@facilityCd''
    AND is_del = ''0''
),
mst_ward_info AS (
  SELECT
    mst_ward.ward_cd :: text as ward_cd
  , mst_ward.in_hospital_cd_1
  FROM
    mst_ward
  WHERE
    mst_ward.facility_cd = ''@facilityCd''
    AND is_del = ''0''
),
course_ward_info AS (
  SELECT
    (
      CASE ''@medicalCareInfo.mainCourseCd''
        WHEN ''''
        THEN pat_main.medical_care_info ->> ''main_course_cd''
        ELSE mst_course_info.course_cd
      END
    ) :: TEXT AS main_course_cd,
    (
      case
        ''@medicalCareInfo.wardCd''
        when '''' then pat_main.medical_care_info ->> ''ward_cd''
        else mst_ward_info.ward_cd
      end
    ) AS ward_cd
  FROM
    pat_main
  LEFT JOIN mst_course_info ON
    ''@medicalCareInfo.mainCourseCd'' = mst_course_info.in_hospital_cd_1
  LEFT JOIN mst_ward_info ON
    ''@medicalCareInfo.wardCd'' = mst_ward_info.in_hospital_cd_1
  WHERE
    is_del = ''0''
    AND pat_id = @patId
)
UPDATE
  pat_main
SET
  up_date = CURRENT_TIMESTAMP,
  in_out_current_state = (
    case
      ''@isDie''
      when ''1'' then ''11''
      else in_out_current_state
    end
  ),
  medical_care_info = json_build_object(
    ''main_course_cd'',
    TO_NUMBER(
      NULLIF(
        (
          SELECT
            main_course_cd
          FROM
            course_ward_info
        ),
        ''''
      ),
      ''FM999999999''
    ),
    ''dialysis_course_cd'',
    medical_care_info -> ''dialysis_course_cd'',
    ''ward_cd'',
    TO_NUMBER(
      NULLIF(
        (
          SELECT
            ward_cd
          FROM
            course_ward_info
        ),
        ''''
      ),
      ''FM999999999''
    ),
    ''dialysis_count'',
    medical_care_info -> ''dialysis_count'',
    ''purification_count'',
    medical_care_info -> ''purification_count'',
    ''other_dialysis_count'',
    medical_care_info -> ''other_dialysis_count'',
    ''pat_dialysis_count'',
    medical_care_info -> ''pat_dialysis_count'',
    ''facility_cd'',
    medical_care_info ->> ''facility_cd'',
    ''dialysis_start_date'',
    medical_care_info ->> ''dialysis_start_date'',
    ''hospital_start_date'',
    medical_care_info ->> ''hospital_start_date''
  )
WHERE
  is_del = ''0''
  AND pat_id = @patId', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)患者プロファイル_患者基本情報の修正', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-603201, 'WITH new_name_info AS (
  SELECT
    substring(''@patLastName'' ::TEXT from ''^(.*?)[\u3000\s]'') AS patLastName
    , substring(''@patLastName'' ::TEXT from ''[\u3000\s](.*)'') AS patFirstName
    , substring(''@patLastNmKana'' ::TEXT from ''^(.*?)[\u3000\s]'') AS patLastNmKana
    , substring(''@patLastNmKana'' ::TEXT from ''[\u3000\s](.*)'') AS patFirstNmKana
)
, new_name_check_info AS (
    SELECT CASE WHEN (pat_last_name = personal_info_encrypt(''ini_dial'') AND pat_first_name = personal_info_encrypt(''only'')) OR (pat_last_name IS NULL AND pat_first_name IS NULL) THEN ''new''
            WHEN (''ini_dial'' <> (SELECT patLastName FROM new_name_info) 
                AND ''only'' <> (SELECT patFirstName FROM new_name_info)) THEN ''new''
            ELSE ''old'' END AS name_falg
    FROM pat_personal_main
    WHERE
        is_del = ''0'' 
        AND hosp_pat_id = @hospPatId :: text
        AND facility_cd = ''@facilityCd''   
) 
, pat_contact_info_json AS (
SELECT
    CASE
        WHEN ''@patContactInfo.ctlNo'' = ''1''
  THEN jsonb_build_object( 
      ''zip_cd''
        , NULLIF(''@patContactInfo.zipCd'', '''')
        , ''address''
        , NULLIF(TRIM(TRIM(TRIM(''@patContactInfo.address'', ''　''), '' ''), ''　''), '''')
        , ''tel1''
        , NULLIF(''@patContactInfo.tel1'', '''')
        , ''tel2''
        , NULLIF(''@patContactInfo.tel2'', '''')
        , ''fax''
        , NULLIF(''@patContactInfo.fax'', '''')
        , ''e_mail''
        , NULLIF(''@patContactInfo.eMail'', '''')
        , ''work_name''
        , NULLIF(''@patContactInfo.workName'', '''')
        ,''work_address''
        , NULLIF(''@patContactInfo.workAddress'', '''')
        ,''work_tel''
        , NULLIF(''@patContactInfo.workTel'', '''')
        , ''memo1''
        , NULLIF(''@patContactInfo.memo1'', '''')
        , ''memo2''
        , NULLIF(''@patContactInfo.memo2'', '''')
    )
  ELSE jsonb_build_object( 
      ''zip_cd''
        , NULL
        , ''address''
        , NULL
        , ''tel1''
        , NULL
        , ''tel2''
        , NULL
        , ''fax''
        , NULL
        , ''e_mail''
        , NULL
        , ''work_name''
        , NULL
        , ''work_address''
        , NULL
        , ''work_tel''
        , NULL
        , ''memo1''
        , NULL
        , ''memo2''
        , NULL
    )
    END
)
UPDATE pat_personal_main 
SET
  pat_last_name = CASE WHEN ''new'' = (SELECT name_falg FROM new_name_check_info) THEN personal_info_encrypt((SELECT patLastName FROM new_name_info)) ELSE pat_last_name END 
  , pat_first_name = CASE WHEN ''new'' = (SELECT name_falg FROM new_name_check_info) THEN COALESCE(personal_info_encrypt(NULLIF((SELECT patFirstName FROM new_name_info), '''')), pat_first_name) ELSE pat_first_name END
  , pat_last_name_kana = personal_info_encrypt((SELECT patLastNmKana FROM new_name_info))
  , pat_first_name_kana = COALESCE(personal_info_encrypt(NULLIF((SELECT patFirstNmKana FROM new_name_info), '''')) , pat_first_name_kana) 
  , pat_last_name_alpha = NULLIF(''@patLastNmAlpha'', '''')
  , pat_first_name_alpha = NULLIF(''@patFirstNmAlpha'', '''')
  , pat_birth_name = NULLIF(''@patBirthName'', '''')
  , pat_birth_name_kana = NULLIF(''@patBirthNmKana'', '''')
  , pat_birth_name_alpha = NULLIF(''@patBirthNmAlpha'', '''')
  , pat_birthday = NULLIF(''@patBirthday'', '''')
  , pat_sex = CASE ''@patSex'' 
    WHEN '''' THEN NULL 
    ELSE TO_NUMBER(''@patSex'', ''FM9999999999999999'') 
    END
  , pat_blood_type_abo = CASE ''@patBloodTypeAbo'' 
    WHEN '''' THEN 0 
    ELSE TO_NUMBER(''@patBloodTypeAbo'', ''FM9999999999999999'') 
    END
  , pat_blood_type_rh = CASE ''@patBloodTypeRh'' 
    WHEN '''' THEN 0 
    ELSE TO_NUMBER(''@patBloodTypeRh'', ''FM9999999999999999'') 
    END
  , in_out_class = CASE  
    WHEN ''@inOutClass'' = ''0'' or ''@inOutClass'' = ''1'' THEN TO_NUMBER(''@inOutClass'', ''FM9999999999999999'')  
    ELSE 3
    END
  , is_die = NULLIF(''@isDie'', '''')
  , die_date = CASE ''@dieDate_Date'' 
    WHEN '''' THEN NULL 
    ELSE TO_TIMESTAMP(''@dieDate_Date'', ''YYYY-MM-DD HH24:MI:SS'') 
    END
  , pat_contact_info = CASE 
    WHEN ''@patContactInfoFlg''  = '''' THEN ''@patContactInfoValue''
    WHEN ''@patContactInfo.ctlNo'' = ''1'' THEN (SELECT * FROM pat_contact_info_json)
    ELSE pat_contact_info
    END
  , up_date = CURRENT_TIMESTAMP
WHERE
  is_del = ''0'' 
  AND hosp_pat_id = ''@hospPatId''  
  AND facility_cd = ''@facilityCd''', 3, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)患者個人情報の取得の修正', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-603101, 'WITH new_name_info AS (
  SELECT
    substring(''@patLastName'' ::TEXT from ''^(.*?)[\u3000\s]'') AS patLastName
    , substring(''@patLastName'' ::TEXT from ''[\u3000\s](.*)'') AS patFirstName
    , substring(''@patLastNmKana'' ::TEXT from ''^(.*?)[\u3000\s]'') AS patLastNmKana
    , substring(''@patLastNmKana'' ::TEXT from ''[\u3000\s](.*)'') AS patFirstNmKana
) 
, pat_contract_info_json AS (
SELECT
    CASE
        WHEN ''@patContactInfo.ctlNo'' = ''1''
  THEN json_build_object( 
      ''zip_cd''
        , NULLIF(''@patContactInfo.zipCd'', '''')
        , ''address''
        , NULLIF(TRIM(TRIM(TRIM(''@patContactInfo.address'', ''　''), '' ''), ''　''), '''')
        , ''tel1''
        , NULLIF(''@patContactInfo.tel1'', '''')
        , ''tel2''
        , NULLIF(''@patContactInfo.tel2'', '''')
        , ''fax''
        , NULLIF(''@patContactInfo.fax'', '''')
        , ''e_mail''
        , NULLIF(''@patContactInfo.eMail'', '''')
        , ''work_name''
        , NULLIF(''@patContactInfo.workName'', '''')
        ,''work_address''
        , NULLIF(''@patContactInfo.workAddress'', '''')
        ,''work_tel''
        , NULLIF(''@patContactInfo.workTel'', '''')
        , ''memo1''
        , NULLIF(''@patContactInfo.memo1'', '''')
        , ''memo2''
        , NULLIF(''@patContactInfo.memo2'', '''')
    )
  ELSE json_build_object( 
      ''zip_cd''
        , NULL
        , ''address''
        , NULL
        , ''tel1''
        , NULL
        , ''tel2''
        , NULL
        , ''fax''
        , NULL
        , ''e_mail''
        , NULL
        , ''work_name''
        , NULL
        , ''work_address''
        , NULL
        , ''work_tel''
        , NULL
        , ''memo1''
        , NULL
        , ''memo2''
        , NULL
    )
    END
)
INSERT 
INTO ntss.pat_personal_main( 
  fn_pat_id
  , hosp_pat_id
  , nkk_pat_id
  , facility_cd
  , pat_last_name
  , pat_first_name
  , pat_last_name_kana
  , pat_first_name_kana
  , pat_last_name_alpha
  , pat_first_name_alpha
  , pat_birth_name
  , pat_birth_name_kana
  , pat_birth_name_alpha
  , pat_birthday
  , pat_sex
  , nationality
  , pat_blood_type_abo
  , pat_blood_type_rh
  , pat_blood_type_serovar
  , in_out_class
  , is_die
  , die_cd
  , die_date
  , dial_diff_com_info
  , severity_cd
  , transport_cd
  , pat_contact_info
  , other_contact_info
  , vendor_contact_info
  , insurance_info
  , is_del
  , up_date
  , reg_date
  , primary_disease_cd
  , remote_monitor_service
  , remote_monitor_user_id
  , remote_monitor_user_pw
) 
VALUES ( 
  NULLIF(''@fnPatId'', '''')
  , NULLIF(''@hospPatId'', '''')
  , NULLIF(''@nkkPatId'', '''')
  , NULLIF(''@facilityCd'', '''')
  , personal_info_encrypt((SELECT patLastName FROM new_name_info)) 
  , personal_info_encrypt((SELECT patFirstName FROM new_name_info))
  , personal_info_encrypt((SELECT patLastNmKana FROM new_name_info))
  , personal_info_encrypt((SELECT patFirstNmKana FROM new_name_info))
  , NULLIF(''@patLastNmAlpha'', '''')
  , NULLIF(''@patFirstNmAlpha'', '''')
  , NULLIF(''@patBirthName'', '''')
  , NULLIF(''@patBirthNmKana'', '''')
  , NULLIF(''@patBirthNmAlpha'', '''')
  , NULLIF(''@patBirthday'', '''')
  , CASE ''@patSex'' 
    WHEN '''' THEN NULL 
    ELSE TO_NUMBER(''@patSex'', ''FM9999999999999999'') 
    END
  , NULLIF(''@nationality'', '''')
  , CASE ''@patBloodTypeAbo'' 
    WHEN '''' THEN 0 
    ELSE TO_NUMBER(''@patBloodTypeAbo'', ''FM9999999999999999'') 
    END
  , CASE ''@patBloodTypeRh'' 
    WHEN '''' THEN 0 
    ELSE TO_NUMBER(''@patBloodTypeRh'', ''FM9999999999999999'') 
    END
  , CASE ''@patBloodTypeSerovar'' 
    WHEN '''' THEN 0 
    ELSE TO_NUMBER(''@patBloodTypeSerovar'', ''FM9999999999999999'') 
    END
  , CASE ''@inOutClass'' 
    WHEN '''' THEN 3 
    ELSE TO_NUMBER(''@inOutClass'', ''FM9999999999999999'') 
    END
  , NULLIF(''@isDie'', '''')
  , CASE ''@dieCd'' 
    WHEN '''' THEN NULL 
    ELSE TO_NUMBER(''@dieCd'', ''FM99999999999999999999999999999999'') 
    END
  , CASE ''@dieDate_Date'' 
    WHEN '''' THEN NULL 
    ELSE TO_TIMESTAMP(''@dieDate_Date'', ''YYYY-MM-DD HH24:MI:SS'') 
    END
  , COALESCE(NULLIF(''@dialDiffComInfo'', ''''), ''[]'') ::JSONB
  , CASE ''@severityCd'' 
    WHEN '''' THEN NULL 
    ELSE TO_NUMBER(''@severityCd'', ''FM99999999999999999999999999999999'') 
    END
  , CASE ''@transportCd'' 
    WHEN '''' THEN NULL 
    ELSE TO_NUMBER(''@transportCd'', ''FM99999999999999999999999999999999'') 
    END
  , CASE ''@patContactInfoFlg'' 
    WHEN '''' THEN json_build_object( 
      ''zip_cd''
      , NULL
      , ''address''
      , NULL
      , ''tel1''
      , NULL
      , ''tel2''
      , NULL
      , ''fax''
      , NULL
      , ''e_mail''
      , NULL
      , ''work_name''
      , NULL
      , ''work_address''
      , NULL
      , ''work_tel''
      , NULL
      , ''memo1''
      , NULL
      , ''memo2''
      , NULL
    ) 
    ELSE (SELECT * FROM pat_contract_info_json)
    END
  , ''@otherContactInfoValue''
  , ''@vendorContactInfoValue''
  , ''@insuranceInfoValue''
  , ''0''
  , CURRENT_TIMESTAMP
  , CURRENT_TIMESTAMP
  , CASE ''@primaryDiseaseCd'' 
    WHEN '''' THEN NULL 
    ELSE TO_NUMBER(''@primaryDiseaseCd'', ''FM99999999999999999999999999999999'') 
    END
  , CASE ''@remoteMonitorService'' 
    WHEN '''' THEN NULL 
    ELSE TO_NUMBER(''@remoteMonitorService'', ''FM99999999999999999999999999999999'') 
    END
  , NULLIF(''@remoteMonitorUserId'', '''')
  , NULLIF(''@remoteMonitorUserPw'', '''')
)', 3, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)患者個人情報の取得の新規', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": 1001, "field_name": "dial_diff_com_info", "replace_var": "@dialDiffComInfo"}]'::jsonb);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-603002, 'WITH name_info AS ( 
SELECT
  REPLACE(REPLACE(substring(@lastName ::TEXT from ''^(.*?)[\u3000\s]''), ''　'', ''''), '' '', '''') AS patLastName,
  REPLACE(REPLACE(substring(@lastName ::TEXT from ''[\u3000\s](.*)''), ''　'', ''''), '' '', '''') AS patFirstName
),
where_cond AS (
SELECT ''[{"last_name": "'' || (SELECT patLastName FROM name_info) ||
 ''", "first_name": "'' || (SELECT patFirstName FROM name_info) ||
 ''", "relation_name": "'' || 
 CASE @relationCd
   WHEN ''0'' THEN ''その他(本人)''
   WHEN ''99'' THEN ''その他''
   ELSE ''''
   END ||
 ''"}]'' AS cond
)
select
  pat_id,
  fn_pat_id,
  hosp_pat_id,
  nkk_pat_id,
  facility_cd,
  personal_info_decrypt(pat_last_name) as pat_last_name,
  personal_info_decrypt(pat_first_name) as pat_first_name,
  personal_info_decrypt(pat_last_name_kana) as pat_last_name_kana,
  personal_info_decrypt(pat_first_name_kana) as pat_first_name_kana,
  personal_info_decrypt(pat_last_name_alpha) as pat_last_name_alpha,
  personal_info_decrypt(pat_first_name_alpha) as pat_first_name_alpha,
  personal_info_decrypt(pat_birth_name) as pat_birth_name,
  personal_info_decrypt(pat_birth_name_kana) as pat_birth_name_kana,
  personal_info_decrypt(pat_birth_name_alpha) as pat_birth_name_alpha,
  pat_birthday,
  pat_sex,
  nationality,
  pat_blood_type_abo,
  pat_blood_type_rh,
  pat_blood_type_serovar,
  in_out_class,
  is_die,
  die_cd,
  die_date,
  dial_diff_com_info,
  severity_cd,
  transport_cd,
  personal_info_decrypt_jsonb(pat_contact_info) as pat_contact_info,
  personal_info_decrypt_jsonb(other_contact_info) as other_contact_info,
  personal_info_decrypt_jsonb(vendor_contact_info) as vendor_contact_info,
  insurance_info,
  is_del,
  up_date,
  reg_date,
  primary_disease_cd,
  remote_monitor_service,
  personal_info_decrypt(remote_monitor_user_id) as remote_monitor_user_id,
  personal_info_decrypt(remote_monitor_user_pw) as remote_monitor_user_pw
from
  pat_personal_main
where
  is_del = ''0''
and
  hosp_pat_id = @hospPatId
and
  facility_cd = @facilityCd
and
  @contactCtlNo in (''2'', ''3'')
and
  NOT personal_info_decrypt_jsonb(other_contact_info) @> (SELECT cond FROM where_cond)::jsonb;', 3, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)MIRAIsの患者プロファイル', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-603001, 'WITH name_info AS ( 
SELECT
  REPLACE(REPLACE(substring(@lastName ::TEXT from ''^(.*?)[\u3000\s]''), ''　'', ''''), '' '', '''') AS patLastName,
  REPLACE(REPLACE(substring(@lastName ::TEXT from ''[\u3000\s](.*)''), ''　'', ''''), '' '', '''') AS patFirstName
),
where_cond AS (
SELECT ''[{"last_name": "'' || (SELECT patLastName FROM name_info) ||
 ''", "first_name": "'' || (SELECT patFirstName FROM name_info) ||
 ''", "relation_name": "'' || 
 CASE @relationCd
   WHEN ''0'' THEN ''その他(本人)''
   WHEN ''99'' THEN ''その他''
   ELSE ''''
   END ||
 ''"}]'' AS cond
)
select
  pat_id,
  fn_pat_id,
  hosp_pat_id,
  nkk_pat_id,
  facility_cd,
  personal_info_decrypt(pat_last_name) as pat_last_name,
  personal_info_decrypt(pat_first_name) as pat_first_name,
  personal_info_decrypt(pat_last_name_kana) as pat_last_name_kana,
  personal_info_decrypt(pat_first_name_kana) as pat_first_name_kana,
  personal_info_decrypt(pat_last_name_alpha) as pat_last_name_alpha,
  personal_info_decrypt(pat_first_name_alpha) as pat_first_name_alpha,
  personal_info_decrypt(pat_birth_name) as pat_birth_name,
  personal_info_decrypt(pat_birth_name_kana) as pat_birth_name_kana,
  personal_info_decrypt(pat_birth_name_alpha) as pat_birth_name_alpha,
  pat_birthday,
  pat_sex,
  nationality,
  pat_blood_type_abo,
  pat_blood_type_rh,
  pat_blood_type_serovar,
  in_out_class,
  is_die,
  die_cd,
  die_date,
  dial_diff_com_info,
  severity_cd,
  transport_cd,
  personal_info_decrypt_jsonb(pat_contact_info) as pat_contact_info,
  personal_info_decrypt_jsonb(other_contact_info) as other_contact_info,
  personal_info_decrypt_jsonb(vendor_contact_info) as vendor_contact_info,
  insurance_info,
  is_del,
  up_date,
  reg_date,
  primary_disease_cd,
  remote_monitor_service,
  personal_info_decrypt(remote_monitor_user_id) as remote_monitor_user_id,
  personal_info_decrypt(remote_monitor_user_pw) as remote_monitor_user_pw
from
  pat_personal_main
where
  is_del = ''0''
and
  hosp_pat_id = @hospPatId
and
  facility_cd = @facilityCd
and
  @contactCtlNo in (''2'', ''3'')
and
  personal_info_decrypt_jsonb(other_contact_info) @> (SELECT cond FROM where_cond)::jsonb;', 3, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)MIRAIsの患者プロファイル', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-200010, '-- 【SQL_CD=-200010】
SELECT 
1 AS order_no
,COALESCE( ( mcd.distribute_setting ->> ''protocolInfo'' ) :: json ->> ''hospPatIdLen'', ''0'' ) AS hosp_pat_id_len 
FROM
	mst_coop_distribute mcd 
WHERE
	mcd.facility_cd = @facilityCd 
-- add 2023-01-18 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
	AND mcd.coop_version = @coopVersion 
-- add 2023-01-18 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
	AND mcd.coop_cd = ''rep_dial'' 
	AND mcd.coop_cd_index like ''%listxml'' 
	AND mcd.direction = ''S''
	AND is_disp =''1''
	AND is_del =''0''
UNION
select 
 2 AS order_no ,
(''0'')::TEXT AS  hosp_pat_id_len
ORDER BY
    order_no ASC LIMIT 1', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, '{"classes": []}'::jsonb, 'CSI', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-200006, '-- 【SQL_CD=-200006】
select
  to_char(ord.rst_start_date,''YYYYMMDDHH24MISS'') as start_date14,--透析開始日時
  to_char(ord.rst_start_date,''YYYY/MM/DD HH24:MI:SS'') as start_date14a,--透析開始日時
  to_char(ord.rst_start_date,''YYYYMMDD'') as start_date8,--透析開始日時
  to_char(ord.rst_start_date,''YYYY/MM/DD'') as start_date8a,--透析開始日時
  to_char(ord.rst_start_date,''HH24MISS'') as start_date6,--透析開始日時
  to_char(ord.rst_start_date,''HH24:MI:SS'') as start_date6a,--透析開始日時
  to_char(ord.rst_end_date,''YYYYMMDDHH24MISS'') as end_date14,--透析終了日時
  to_char(ord.rst_end_date,''YYYYMMDD'') as end_date8,--透析終了日時
  to_char(ord.rst_end_date,''HH24MISS'') as end_date6,--透析終了日時
  to_char(ord.rst_end_date,''YYYY/MM/DD HH24:MI:SS'') as end_date14a,--透析終了日時
  to_char(ord.rst_end_date,''YYYY/MM/DD'') as end_date8a,--透析終了日時
  to_char(ord.rst_end_date,''HH24:MI:SS'') as end_date6a,--透析終了日時
  to_char(ord.rst_start_date,''HH24MI'') as start_time4,--透析開始時刻
  to_char(ord.rst_end_date,''HH24MI'') as end_time4,--透析終了時刻
  ord.rst_running_time as running_time,
  RIGHT(''00''||TRUNC(TO_NUMBER(ord.rst_cond_info->''1''->>''value'',''999999'')/60,0),2)||'':''||RIGHT(''00''||MOD(TO_NUMBER(ord.rst_cond_info->''1''->>''value'',''999999''),60),2) as treatment_time,
  to_char(timestamp ''now'',''YYYYMMDDHH24MISS'') as nowtime14,
  rst_bed_name as bed_name,
  ord_no as dialysis_no,
  rst_edition as edition,
  up_date as up_date
from
  ord_main as ord
where
  ord.ord_no = @ordNo', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, '{"classes": []}'::jsonb, 'CSI', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-200001, '-- 【SQL_CD=-200001】
 select
 hosp_pat_id,
 personal_info_decrypt(pat_last_name)||'' ''||personal_info_decrypt(pat_first_name) as pat_name,
 personal_info_decrypt(pat_last_name_kana)||'' ''||personal_info_decrypt(pat_first_name_kana) as pat_name_kana,
 personal_info_decrypt(pat_last_name_alpha)||'' ''||personal_info_decrypt(pat_first_name_alpha) as pat_name_alpha,
 to_char(to_date(pat_birthday, ''YYYYMMDD''), ''YYYY/MM/DD'') as pat_birthday,
 case when pat_birthday is null then null
 else date_part(''year'',age(''now'', to_date(pat_birthday, ''YYYYMMDD'')))
 end as pat_age,
 case when pat_sex = 1 then 0   when pat_sex = 2 then 1 else 2 end as pat_sex,
 pat_blood_type_abo,
 pat_blood_type_rh,
 pat_blood_type_abo * 10 +  pat_blood_type_rh as pat_blood_type_abo_rh,
 pat_blood_type_serovar as pat_blood_type_serovar,
 in_out_class,
 trim(both ''"'' from personal_info_decrypt(pat_contact_info->>''zip_cd'')) as pat_zip,
 trim(both ''"'' from personal_info_decrypt(pat_contact_info->>''address'')) as pat_address,
 trim(both ''"'' from personal_info_decrypt(pat_contact_info->>''tel1'')) as pat_tel1,
 trim(both ''"'' from personal_info_decrypt(pat_contact_info->>''tel2'')) as pat_tel2,
 trim(both ''"'' from personal_info_decrypt(pat_contact_info->>''fax'')) as pat_fax,
 trim(both ''"'' from personal_info_decrypt(pat_contact_info->>''e_mail'')) as pat_e_mail,
 trim(both ''"'' from personal_info_decrypt(pat_contact_info->>''work_name'')) as pat_work_name,
 trim(both ''"'' from personal_info_decrypt(pat_contact_info->>''work_tel'')) as pat_work_tel,
 trim(both ''"'' from personal_info_decrypt(pat_contact_info->>''memo1'')) as pat_memo1,
 trim(both ''"'' from personal_info_decrypt(pat_contact_info->>''memo2'')) as pat_memo2,
 nationality as nationality,
 severity_cd,
 transport_cd,
 is_die,
 die_date,
 die_cd,
 die_cd as die_cd1,
 -- 透析困難有無
 case when jsonb_array_length(dial_diff_com_info) > 0 then 1 else 0 end as dial_diff_com_info_flag,
 up_date
 from
 pat_personal_main
 where
 is_del = ''0''
 and
 pat_id = @patId', 3, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, '{"classes": []}'::jsonb, 'CSI', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-200000, '-- 【SQL_CD=-200000】
SELECT ''05'' AS detail_id', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, '{"classes": []}'::jsonb, 'CSI', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-2400, '-- 【SQL_CD=-2400】
select
 @pat_id as patid,
 @ord_no as ordno,
 hosp_pat_id as hosp_pat_id
from
  pat_personal_main
where
  is_del = ''0''
and pat_id = @pat_id', 3, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '定時一括送信機能（患者プロファイル用）', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": -2401, "field_name": "ord_no", "replace_var": "@ord_no"}, {"sql_cd": -2401, "field_name": "pat_id", "replace_var": "@pat_id"}]'::jsonb);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-451, '-- 【SQL_CD=-451】
WITH rst_complaint_info AS ( 
  SELECT
    complaint 
  FROM
    ord_main AS ord 
    CROSS JOIN LATERAL json_array_elements(ord.rst_complaint_info ::json) complaint 
  WHERE
    ord.ord_no = @ordNo 
) 
, rst_treatment_info AS ( 
  SELECT
    ord.ord_no
    , tmedi 
  FROM
    ord_main AS ord 
    CROSS JOIN LATERAL json_array_elements(ord.rst_treatment_info ::json) tmedi 
  WHERE
    ord.ord_no = @ordNo 
) 
SELECT
  CAST(info.tmedi ->> ''ctl_no'' AS TEXT) || ''_'' || CAST(info.tmedi ->> ''row_no'' AS TEXT) AS disp_no
  , CASE info.tmedi ->> ''treat_class'' 
    WHEN ''0'' THEN ''調製薬剤'' 
    WHEN ''1'' THEN ''薬剤'' 
    WHEN ''2'' THEN ''処置'' 
    WHEN ''3'' THEN ''酸素吸入'' 
    WHEN ''4'' THEN ''心電図'' 
    ELSE ''不明'' 
    END || ( 
    CASE 
      WHEN comp_info.complaint ->> ''complaint'' IS NOT NULL 
        THEN (''-'' || CAST(comp_info.complaint ->> ''complaint'' AS TEXT)) 
      ELSE '''' 
      END  ) || ( 
    CASE 
      WHEN info.tmedi ->> ''treat_name'' IS NOT NULL 
        THEN (''-'' || CAST(info.tmedi ->> ''treat_name'' AS TEXT)) 
      ELSE '''' 
      END
  ) AS disp_name 
  --   , comp_info.complaint ->> ''comp_cd'' AS comp_cd
  --   , comp_info.complaint ->> ''complaint'' AS complaint
  , info.tmedi ->> ''treat_class'' AS treat_class 
  --   , case info.tmedi ->> ''treat_class''
  --     when ''0'' then ''調製薬剤''
  --     when ''1'' then ''薬剤''
  --     when ''2'' then ''処置''
  --     when ''3'' then ''酸素吸入''
  --     when ''4'' then ''心電図''
  --     else ''不明''
  --     end AS treat_class_name
  , info.tmedi ->> ''treat_cd'' AS treat_cd 
  --   , info.tmedi ->> ''treat_name'' AS treat_name
  , info.tmedi ->> ''treat_medicine_cd'' AS medicine_cd 
  --  , info.tmedi ->> ''treat_medicine_name'' AS medicine_name
  , info.tmedi ->> ''procedure_cd'' AS procedure_cd 
  --  , info.tmedi ->> ''procedure_name'' AS procedure_name
  , info.tmedi ->> ''amount'' AS amount
  , info.tmedi ->> ''unit'' AS unit
  , info.ord_no AS result_no
  , CAST(CAST(info.tmedi ->> ''occur_date'' AS TIMESTAMP) AS TEXT) AS occur_date_start
  , CAST(CAST(link_info.tmedi ->> ''occur_date'' AS TIMESTAMP) AS TEXT)  AS occur_date_end
  , link_info.tmedi ->> ''oxygen_amount'' AS oxygen_amount
  , info.tmedi ->> ''oxygen_start'' AS oxygen_start
  , CAST((CAST(info.tmedi ->> ''oxygen_start'' AS TIMESTAMP) ::TIMESTAMP (0) + (info.tmedi ->> ''oxygen_time'' || '' min'')::INTERVAL) AS TEXT) AS oxygen_start_new
  , info.tmedi ->> ''oxygen_time'' AS oxygen_time
  , CAST((CAST(link_info.tmedi ->> ''occur_date'' AS TIMESTAMP) - CAST(info.tmedi ->> ''occur_date'' AS TIMESTAMP)) AS TEXT) AS oxygen_time_new 
  --  , CAST(EXTRACT( ''hour'' FROM (CAST(link_info.tmedi ->> ''occur_date'' AS TIMESTAMP) - CAST(info.tmedi ->> ''occur_date'' AS TIMESTAMP))) AS TEXT)AS oxygen_time_hour 
  --  , CAST(EXTRACT( ''minute'' FROM (CAST(link_info.tmedi ->> ''occur_date'' AS TIMESTAMP) - CAST(info.tmedi ->> ''occur_date'' AS TIMESTAMP))) AS TEXT)AS oxygen_time_minute 
  --  , CAST(EXTRACT( ''second'' FROM (CAST(link_info.tmedi ->> ''occur_date'' AS TIMESTAMP) - CAST(info.tmedi ->> ''occur_date'' AS TIMESTAMP))) AS TEXT)AS oxygen_time_second 
  --  , CAST(EXTRACT( ''epoch'' FROM (CAST(link_info.tmedi ->> ''occur_date'' AS TIMESTAMP) - CAST(info.tmedi ->> ''occur_date'' AS TIMESTAMP))) AS TEXT)AS oxygen_time_epoch 
  --  , info.tmedi ->> ''oxygen_speed'' AS oxygen_speed
  --  , info.tmedi ->> ''over_time'' AS over_time
  , mp.in_hospital_cd_a1 AS mp_in_hospital_cd_1
  , mp.in_hospital_cd_b1 AS mp_in_hospital_cd_2
  , CASE 
    WHEN mmd.class_cd IS NOT NULL 
      THEN mmd.class_cd     --薬剤
    ELSE mmx.class_cd       -- 調製薬剤
    END AS mmd_class_cd
  , CASE 
    WHEN mmd.medicine_cd IS NOT NULL 
      THEN mmd.medicine_cd       --薬剤
    ELSE mmx.medicine_mix_cd     -- 調製薬剤
    END AS mmd_medicine_cd
  , CASE 
    WHEN mmd.is_shot IS NOT NULL 
      THEN mmd.is_shot     --薬剤
    ELSE mmx.is_shot       -- 調製薬剤
    END AS mmd_is_shot
  , CASE 
    WHEN mmd.in_hospital_cd_1 IS NOT NULL 
      THEN TRIM(mmd.in_hospital_cd_1)     --薬剤
    ELSE TRIM(mmx.in_hospital_cd_1)       -- 調製薬剤
    END AS mmd_in_hospital_cd_1
  , CASE 
    WHEN mmd.in_hospital_cd_2 IS NOT NULL 
      THEN TRIM(mmd.in_hospital_cd_2)     --薬剤
    ELSE TRIM(mmx.in_hospital_cd_2)       -- 調製薬剤
    END AS mmd_in_hospital_cd_2 
FROM
  rst_treatment_info AS info 
  LEFT JOIN rst_treatment_info AS link_info 
    ON info.tmedi ->> ''ctl_no'' = link_info.tmedi ->> ''linkStartDate'' 
  LEFT JOIN rst_complaint_info AS comp_info 
    ON info.tmedi ->> ''ctl_no'' = comp_info.complaint ->> ''ctl_no'' AND comp_info.complaint ->> ''comp_cd'' IS NOT NULL 
  LEFT OUTER JOIN mst_medicine AS mmd   -- 薬剤マスタ
    ON mmd.medicine_cd = to_number(info.tmedi ->> ''treat_medicine_cd'', ''999999999999'') AND ''1'' = info.tmedi ->> ''treat_class'' 
  LEFT OUTER JOIN mst_medicine_mix AS mmx   --調製薬剤マスタ
    ON mmx.medicine_mix_cd = to_number(info.tmedi ->> ''treat_medicine_cd'', ''999999999999'') AND ''0'' = info.tmedi ->> ''treat_class'' 
  LEFT OUTER JOIN mst_procedure AS mp   -- 手技マスタ
    ON mp.procedure_cd = to_number(info.tmedi ->> ''procedure_cd'', ''999999999999'') 
WHERE
  info.tmedi ->> ''linkStartDate'' IS NULL 
ORDER BY
  info.tmedi ->> ''occur_date'' ASC
  , CAST(info.tmedi ->> ''ctl_no'' AS INT) ASC
  , CAST(info.tmedi ->> ''row_no'' AS INT) ASC', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, '{"classes": []}'::jsonb, 'CSI透析実績(愁訴処置)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-450, '-- 【SQL_CD=-450】
SELECT
  medi ->> ''no'' AS ctl_no,
  medi ->> ''effect_flg'' AS effect_flg,
  medi ->> ''cd'' AS medicine_cd,
  case when mmd.medicine_cd is not null then
    mmd.medicine_cd  --薬剤
  else
    mmx.medicine_mix_cd -- 調製薬剤
  end AS mmd_medicine_cd,
  case when mmd.is_shot is not null then
    mmd.is_shot  --薬剤
  else
    mmx.is_shot -- 調製薬剤
  end AS mmd_is_shot,
  case when mmd.in_hospital_cd_1 is not null then
    TRIM(mmd.in_hospital_cd_1)  --薬剤
  else
    TRIM(mmx.in_hospital_cd_1) -- 調製薬剤
  end AS mmd_in_hospital_cd_1,
  case when mmd.in_hospital_cd_2 is not null then
    TRIM(mmd.in_hospital_cd_2)  --薬剤
  else
    TRIM(mmx.in_hospital_cd_2) -- 調製薬剤
  end AS mmd_in_hospital_cd_2,
  medi ->> ''procedure_cd'' AS procedure_cd,
  medi ->> ''class_cd'' AS class_cd,
  medi ->> ''class_type'' AS class_type,
  cast(cast(medi ->> ''effect_date'' as timestamp) AS TEXT) AS effect_date,
  ''0'' AS set_medicine_flg,
  medi ->> ''amount'' AS amount,
  medi ->> ''unit'' AS unit,
  mp.pricedure_name AS pricedure_name,
  mp.in_hospital_cd_a1 AS mp_in_hospital_cd_1,
  mp.in_hospital_cd_b1 AS mp_in_hospital_cd_2  
FROM
  ord_main AS ord
  CROSS JOIN LATERAL json_array_elements ( ord.rst_medi_info :: json ) medi
  LEFT OUTER JOIN mst_medicine AS mmd -- 薬剤マスタ
    ON mmd.medicine_cd = TO_NUMBER(medi ->> ''cd'', ''999999999999'') AND ''1'' = medi ->> ''medicine_type''
  LEFT OUTER JOIN mst_medicine_mix AS mmx --調製薬剤マスタ
    ON mmx.medicine_mix_cd = TO_NUMBER(medi ->> ''cd'', ''999999999999'')  AND ''2'' = medi ->> ''medicine_type''
  LEFT OUTER JOIN mst_procedure AS mp -- 手技マスタ 
    ON mp.procedure_cd = TO_NUMBER(medi ->> ''procedure_cd'', ''999999999999'') 
WHERE
  medi ->> ''effect_flg'' = ''1''
  AND ord.ord_no = @ordNo 
', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, '{"classes": []}'::jsonb, 'CSI透析実績(投薬履歴)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-448, '-- 【SQL_CD=-448】
 SELECT
   ''透析困難コメント_詳細部分'' AS detail_id,
   info ->> ''ctl_no'' AS ctl_no,
   info ->> ''dial_diff_cd'' AS dial_diff_cd,
   info ->> ''is_main'' AS is_main,
   info ->> ''is_dial_diff'' AS is_dial_diff,
   info ->> ''reg_date'' AS reg_date,
   dialysis.dialysis_difficulty_name,
   dialysis.in_hospital_cd_1,
   dialysis.in_hospital_cd_2,
   dialysis.up_date 
 FROM
   json_array_elements ( @dialDiffComInfo :: json ) info
   LEFT JOIN mst_dialysis_difficulty AS dialysis ON info ->> ''dial_diff_cd'' = dialysis_difficulty_cd :: TEXT 
   AND dialysis.is_disp = ''1'' 
   AND dialysis.is_del = ''0'' 
 ORDER BY
   info ->> ''is_main'' DESC,
   info ->> ''ctl_no'' ASC', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, '{"classes": []}'::jsonb, 'CSI透析実績(透析困難コメント_詳細部分)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": -449, "field_name": "dial_diff_com_info", "replace_var": "@dialDiffComInfo"}]'::jsonb);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-447, '-- 【SQL_CD=-447】
WITH item_name AS (
  SELECT ''001'' AS fnw_cd, ''-1'' AS ntss_cd, ''透析開始時刻'' AS fnw_name UNION 
  SELECT ''002'' AS fnw_cd, ''1'' AS ntss_cd, ''透析時間'' AS fnw_name UNION 
  SELECT ''003'' AS fnw_cd, ''2'' AS ntss_cd, ''VA'' AS fnw_name UNION 
  SELECT ''004'' AS fnw_cd, ''39'' AS ntss_cd, ''DW'' AS fnw_name UNION 
  SELECT ''005'' AS fnw_cd, ''3'' AS ntss_cd, ''目標体重'' AS fnw_name UNION 
  SELECT ''006'' AS fnw_cd, ''-2'' AS ntss_cd, ''治療方法'' AS fnw_name UNION 
  SELECT ''007'' AS fnw_cd, ''4'' AS ntss_cd, ''除水量制限'' AS fnw_name UNION 
  SELECT ''008'' AS fnw_cd, ''5'' AS ntss_cd, ''ダイアライザ'' AS fnw_name UNION 
  SELECT ''009'' AS fnw_cd, ''6'' AS ntss_cd, ''吸着カラム'' AS fnw_name UNION 
  SELECT ''010'' AS fnw_cd, ''14'' AS ntss_cd, ''血流量'' AS fnw_name UNION 
  SELECT ''011'' AS fnw_cd, ''25'' AS ntss_cd, ''抗凝固剤'' AS fnw_name UNION 
  SELECT ''012'' AS fnw_cd, ''26'' AS ntss_cd, ''抗凝固剤ワンショット量'' AS fnw_name UNION 
  SELECT ''013'' AS fnw_cd, ''27'' AS ntss_cd, ''抗凝固剤持続速度'' AS fnw_name UNION 
  SELECT ''014'' AS fnw_cd, ''28'' AS ntss_cd, ''抗凝固剤持続総量'' AS fnw_name UNION 
  SELECT ''015'' AS fnw_cd, ''29'' AS ntss_cd, ''IP使用選択'' AS fnw_name UNION 
  SELECT ''016'' AS fnw_cd, ''31'' AS ntss_cd, ''IPワンショット量'' AS fnw_name UNION 
  SELECT ''017'' AS fnw_cd, ''32'' AS ntss_cd, ''IP速度'' AS fnw_name UNION 
  SELECT ''018'' AS fnw_cd, ''15'' AS ntss_cd, ''透析液'' AS fnw_name UNION 
  SELECT ''019'' AS fnw_cd, ''16'' AS ntss_cd, ''透析液流量'' AS fnw_name UNION 
  SELECT ''020'' AS fnw_cd, ''17'' AS ntss_cd, ''透析液量'' AS fnw_name UNION 
  SELECT ''021'' AS fnw_cd, ''18'' AS ntss_cd, ''透析液温度'' AS fnw_name UNION 
  SELECT ''022'' AS fnw_cd, ''19'' AS ntss_cd, ''補液'' AS fnw_name UNION 
  SELECT ''023'' AS fnw_cd, ''20'' AS ntss_cd, ''補液量'' AS fnw_name UNION 
  SELECT ''024'' AS fnw_cd, ''21'' AS ntss_cd, ''補液選択'' AS fnw_name UNION 
  SELECT ''025'' AS fnw_cd, ''23'' AS ntss_cd, ''補液温度'' AS fnw_name UNION 
  SELECT ''026'' AS fnw_cd, ''-3'' AS ntss_cd, ''UFRプログラム'' AS fnw_name UNION 
  SELECT ''027'' AS fnw_cd, ''-4'' AS ntss_cd, ''Na注入プログラム'' AS fnw_name UNION 
  SELECT ''028'' AS fnw_cd, ''-5'' AS ntss_cd, ''透析液濃度プログラム'' AS fnw_name UNION 
  SELECT ''029'' AS fnw_cd, ''12'' AS ntss_cd, ''シングルニードル使用'' AS fnw_name UNION 
  SELECT ''030'' AS fnw_cd, ''22'' AS ntss_cd, ''補液使用数'' AS fnw_name UNION 
  SELECT ''031'' AS fnw_cd, ''30'' AS ntss_cd, ''IPスタート'' AS fnw_name UNION 
  SELECT ''032'' AS fnw_cd, ''34'' AS ntss_cd, ''自動ワンショット'' AS fnw_name UNION 
  SELECT ''033'' AS fnw_cd, ''35'' AS ntss_cd, ''IP電源自動切り'' AS fnw_name UNION 
  SELECT ''034'' AS fnw_cd, ''36'' AS ntss_cd, ''IP電源自動切り時間'' AS fnw_name UNION 
  SELECT ''035'' AS fnw_cd, ''37'' AS ntss_cd, ''IP電源OKモニタ切り'' AS fnw_name UNION 
  SELECT ''036'' AS fnw_cd, ''38'' AS ntss_cd, ''IP電源OKモニタ切り時間'' AS fnw_name UNION 
  SELECT ''037'' AS fnw_cd, ''33'' AS ntss_cd, ''IP速度最大値'' AS fnw_name UNION 
  SELECT ''038'' AS fnw_cd, ''24'' AS ntss_cd, ''補液速度'' AS fnw_name UNION 
  SELECT ''039'' AS fnw_cd, ''7'' AS ntss_cd, ''1次膜'' AS fnw_name UNION 
  SELECT ''040'' AS fnw_cd, ''8'' AS ntss_cd, ''2次膜'' AS fnw_name UNION 
  SELECT ''-1'' AS fnw_cd, ''9'' AS ntss_cd, ''穿刺針(A針)'' AS fnw_name UNION 
  SELECT ''-2'' AS fnw_cd, ''10'' AS ntss_cd, ''穿刺針(V針)'' AS fnw_name UNION 
  SELECT ''-3'' AS fnw_cd, ''11'' AS ntss_cd, ''穿刺針(SN)'' AS fnw_name 
  ORDER BY fnw_cd asc),
rst_cond_info AS (
  SELECT
    jsonb_object_keys ( ord.rst_cond_info ) as ntss_cd,
    ord.rst_cond_info -> jsonb_object_keys ( ord.rst_cond_info ) AS rst_cond_info 
  FROM
    ord_main AS ord 
  WHERE
    ord.ord_no = @ordNo
  UNION 
  -- 006:治療方法（-2）
  SELECT
    ''-2'' as ntss_cd,
    (''{"value":'' || ord.rst_treatment_cd || ''}''):: jsonb AS rst_cond_info
  FROM
    ord_main AS ord 
  WHERE
    ord.ord_no = @ordNo
  UNION 
  -- 001:透析開始時刻（-1）
  SELECT
    ''-1'' as ntss_cd,
    (''{"value":"'' || to_char(ord.rst_start_date, ''HH24MI'') || ''"}''):: jsonb AS rst_cond_info
  FROM
    ord_main AS ord 
  WHERE
    ord.ord_no = @ordNo
)
SELECT
  ''透析条件'' AS detail_id,
  item_name.fnw_cd as item_cd,
  cond.ntss_cd as ntss_cd,
  item_name.fnw_name as item_name,
  cond.rst_cond_info->>''value'' as item_value,
  cond.rst_cond_info->>''value_name_1'' as item_value_name,
  TRIM ( meqa.in_hospital_cd_1 ) as meqa_in_hospital_cd, --医療材料院内コード
  case when med.in_hospital_cd_1 is not null then 
    TRIM ( med.in_hospital_cd_1 ) --薬剤院内コード
  else
      TRIM ( mmx.in_hospital_cd_1 ) --調製薬剤院内コード
  end as med_in_hospital_cd, --薬剤院内コード
  case when med.is_shot is not null then 
    med.is_shot --薬剤-注射
  else
      mmx.is_shot --調製薬剤-注射
  end as med_is_shot, --薬剤-注射  
  TRIM ( mtt.in_hospital_cd_a1 ) as mtt_in_hospital_cd, --治療方法院内コード
  TRIM ( mtt.treatment_name ) as mtt_treatment_name, --治療方法名
  TRIM ( mdr.in_hospital_cd_1 ) as mdr_in_hospital_cd, --ダイアライザ院内コード
  TRIM ( mva.in_hospital_cd_1 ) as mva_in_hospital_cd, --VA院内コード
  cond.rst_cond_info->>''unit'' as item_value_unit,
  cond.rst_cond_info->>''medicine_type'' as medicine_type,
  cond.rst_cond_info->>''ind_user_id'' as ind_user_id,
  cond.rst_cond_info->>''upd_user_id'' as upd_user_id
FROM
  item_name,
  rst_cond_info as cond
  -- 医療材料マスタ
  LEFT OUTER JOIN mst_equipment AS meqa ON meqa.equipment_cd = TO_NUMBER( cond.rst_cond_info ->> ''value'', ''999999999999'' ) AND cond.ntss_cd in (''6'',''7'',''8'') 
  -- 薬剤マスタ
  LEFT OUTER JOIN mst_medicine AS med ON med.medicine_cd = TO_NUMBER( cond.rst_cond_info ->> ''value'', ''999999999999'' ) AND cond.ntss_cd in (''15'',''19'',''25'') AND cond.rst_cond_info ->> ''medicine_type'' = ''1''
  -- 調製薬剤マスタ
  LEFT OUTER JOIN mst_medicine_mix AS mmx ON mmx.medicine_mix_cd = TO_NUMBER( cond.rst_cond_info ->> ''value'', ''999999999999'' ) AND cond.ntss_cd in (''15'',''19'',''25'') AND cond.rst_cond_info ->> ''medicine_type'' = ''2''
  -- 治療方法マスタ
  LEFT OUTER JOIN mst_treatment AS mtt ON mtt.treatment_cd = TO_NUMBER( cond.rst_cond_info ->> ''value'', ''999999999999'' )  AND cond.ntss_cd in (''-2'')
  -- ダイアライザマスタ
  LEFT OUTER JOIN mst_dialyzer AS mdr ON mdr.dialyzer_cd = TO_NUMBER( cond.rst_cond_info ->> ''value'', ''999999999999'' ) AND cond.ntss_cd in (''5'')
  -- VAマスタ
  LEFT OUTER JOIN mst_va AS mva ON mva.va_cd = TO_NUMBER( cond.rst_cond_info ->> ''value'', ''999999999999'' ) AND cond.ntss_cd in (''2'')
WHERE cond.ntss_cd = item_name.ntss_cd
  AND TO_NUMBER(item_name.fnw_cd, ''999'') > 0 
ORDER BY item_name.fnw_cd ASC', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, '{"classes": []}'::jsonb, 'CSI透析実績(透析条件)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-445, '-- 【SQL_CD=-445】
 SELECT
   ''透析困難コメント_基本情報部分'' AS detail_id,
   dialysis_difficulty_name,
   in_hospital_cd_1,
   in_hospital_cd_2,
   up_date 
 FROM
   mst_dialysis_difficulty 
 WHERE
   dialysis_difficulty_cd = @dialDiffCd 
   AND is_disp = ''1'' 
   AND is_del = ''0''', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, '{"classes": []}'::jsonb, 'CSI透析実績(透析困難コメント_基本情報部分)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": -446, "field_name": "dial_diff_cd", "replace_var": "@dialDiffCd"}]'::jsonb);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-444, '-- 【SQL_CD=-444】
 WITH staff_info AS (
   SELECT ROW_NUMBER( ) OVER ( ORDER BY info ->> ''is_main'' DESC,  info ->> ''is_charge'' DESC,  info ->> ''is_puncture'' DESC, info ->> ''ctl_no'' ASC ) AS CNT,
     info ->> ''staff_cd'' AS staff_cd 
   FROM
     pat_main AS pat
     LEFT JOIN LATERAL json_array_elements ( pat.charge_staff_info :: json ) info ON info ->> ''ctl_no'' IS NOT NULL 
   WHERE
     pat.pat_id = @patId 
   )
 SELECT
    -- クールマスタ
    ord.rst_kur_cd AS kur_cd,
    mkr.kur_name AS kur_name,
    COALESCE(TRIM(mkr.in_hospital_cd_1), cast(mkr.kur_cd as VARCHAR)) AS kur_cd1,
    LEFT ( mkr.kur_standard_start_time, 4 ) AS kur_standard_start_time,
    -- ベッドマスタ
    ord.rst_bed_cd AS bed_cd,
    mbd.bed_name AS bed_name,
    COALESCE(TRIM(mbd.in_hospital_cd_1), cast(mbd.bed_cd as VARCHAR)) AS bed_cd1,
    -- 基本情報.診療科コード
    pat.medical_care_info ->> ''main_course_cd'' AS course_cd,
    course.course_name AS course_name,
    COALESCE(TRIM(course.in_hospital_cd_1), cast(course.course_cd as VARCHAR)) AS course_cd1,
    -- 実績：診療科コード
    ord.rst_ward_cd AS rst_ward_cd,
    mwd.in_hospital_cd_1 AS in_hospital_cd_1,
    rst_course.course_name AS rst_course_name,
    COALESCE(TRIM(rst_course.in_hospital_cd_1), cast(rst_course.course_cd as VARCHAR)) AS rst_course_cd1,

    -- 透析導入日
    pat.medical_care_info ->> ''dialysis_start_date'' AS dialysis_start_date,
    -- 透析番号
    ord.rst_fn_dialysis_no,
    -- 版番号
    ord.rst_edition,
    -- 治療開始日時
    to_char(ord.rst_start_date, ''yyyy/mm/dd hh24:mi:ss'') as rst_start_date,
    -- 治療終了日時
    to_char(ord.rst_end_date, ''yyyy/mm/dd hh24:mi:ss'') as rst_end_date,
    -- 透析時間
    ord.rst_running_time,
    -- 最終更新指示者ID
    ord.up_ind_user_id,
    -- 医師1
    staff1.staff_cd AS staff_cd1,
    -- 医師2
    staff2.staff_cd AS staff_cd2
 FROM
    ord_main AS ord
    INNER JOIN pat_main AS pat ON pat.pat_id = ord.pat_id 
    LEFT JOIN staff_info AS staff1 ON staff1.CNT = 1
    LEFT JOIN staff_info AS staff2 ON staff2.CNT = 2
    LEFT JOIN mst_kur AS mkr ON mkr.kur_cd = ord.rst_kur_cd 
    LEFT JOIN mst_bed AS mbd ON mbd.bed_cd = ord.rst_bed_cd
    LEFT JOIN mst_course AS course ON course.course_cd ::TEXT = pat.medical_care_info ->> ''main_course_cd''
    LEFT JOIN mst_course AS rst_course ON rst_course.course_cd = ord.rst_ward_cd
    LEFT JOIN mst_ward AS mwd ON mwd.ward_cd = ord.rst_ward_cd


  WHERE
    ord.ord_no = @ordNo 
  AND pat.pat_id = @patId ', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, '{"classes": []}'::jsonb, 'CSI透析実績(透析実績履歴)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-443, '-- 【SQL_CD=-443】
SELECT

	''検査項目'' AS detail_id,

	info ->> ''item_cd'' AS item_cd,

	info ->> ''item_name'' AS item_name,

	item.exam_item_name AS exam_item_name,

	P.reg_exam_date AS reg_exam_date,

	item.in_hospital_cd1 AS in_hospital_cd1,

	COALESCE ( item.sbt_cd1, ''ET1'' ) AS sbt_cd1,

	item.in_hospital_cd2 AS in_hospital_cd2,

	item.sbt_cd2 AS sbt_cd2,

	item.in_hospital_cd3 AS in_hospital_cd3,

	item.sbt_cd3 AS sbt_cd3,

	item.unit AS unit,

	TRIM ( to_char( item.spitz_cd, ''999999999'' ) ) AS spitz_cd,

	spitz.spitz_name AS spitz_name

FROM

	(

	SELECT M

		.* 

	FROM

		pat_exam_main AS M 

	WHERE

		M.is_del = ''0'' 

		AND M.exam_status = ''0''

		AND jsonb_array_length ( M.order_exam_set_info ) > 0 

		AND M.exam_main_cd = @ordNo  

	)

	P CROSS JOIN LATERAL json_array_elements ( P.exam_order_info :: json ) info

	LEFT OUTER JOIN mst_exam_item AS item ON info ->> ''item_cd'' = ( item.exam_item_cd || '''' )

	LEFT OUTER JOIN mst_spitz AS spitz ON item.spitz_cd = spitz.spitz_cd 

WHERE

	COALESCE ( item.in_hospital_cd1, ''no_cd'' ) <> ''no_cd''', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, '{"classes": []}'::jsonb, 'CSI検査オーダ(連携電文の検査項目)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-442, '-- 【SQL_CD=-442】
 WITH staff_info AS (
   SELECT ROW_NUMBER( ) OVER ( ORDER BY info ->> ''is_main'' DESC,  info ->> ''is_charge'' DESC,  info ->> ''is_puncture'' DESC, info ->> ''ctl_no'' ASC ) AS CNT,
     info ->> ''staff_cd'' AS staff_cd 
   FROM
     pat_main AS pat
     LEFT JOIN LATERAL json_array_elements ( pat.charge_staff_info :: json ) info ON info ->> ''ctl_no'' IS NOT NULL 
   WHERE
     pat.pat_id = @patId 
   )
 SELECT
   CASE M1.reg_order_class
   WHEN ''1'' THEN ''0''
   WHEN ''2'' THEN ''1''
   ELSE ''2''
   END reg_order_class,
   TO_CHAR( M1.reg_exam_date, ''YYYYMMDD'' ) AS reg_exam_date,
   M1.ind_user_id,
   M1.reg_staff,
   M1.up_staff,
   TO_CHAR( M1.up_date, ''YYYY/MM/DD HH24:MI:SS'' ) AS up_date,
   -- 診療科マスタ
   pat.medical_care_info ->> ''main_course_cd'' AS course_cd,
   course.course_name AS course_name,
   COALESCE ( TRIM ( course.in_hospital_cd_1 ), CAST ( course.course_cd AS VARCHAR ) ) AS course_cd1,
   -- 透析前/透析後開始時刻
   TO_CHAR( M1.reg_exam_date, ''HH24MISS'' ) AS standard_start_time,
   -- 透析後予定透析時間
   TO_CHAR( M1.reg_exam_date, ''HH24MI'' ) AS ind_dialysis_time,
   -- その他開始時刻
   TO_CHAR( M1.reg_exam_date, ''HH24MI'' ) AS other_exam_time,
   -- 血液検査セットコード
   info ->> ''set_cd'' AS exam_set_cd,
   -- 医師1
   staff1.staff_cd AS staff_cd1,
   -- 医師2
    staff2.staff_cd AS staff_cd2 
 FROM
   pat_exam_main AS M1
   LEFT JOIN LATERAL json_array_elements ( M1.order_exam_set_info :: json ) info ON info ->> ''set_name'' LIKE''%血液%''
   INNER JOIN pat_main AS pat ON pat.pat_id = M1.pat_id
   LEFT JOIN staff_info AS staff1 ON staff1.CNT = 1
   LEFT JOIN staff_info AS staff2 ON staff2.CNT = 2
   LEFT JOIN mst_course AS course ON course.course_cd :: TEXT = pat.medical_care_info ->> ''main_course_cd'' 
 WHERE
   M1.is_del = ''0'' 
   AND M1.exam_status = ''0'' 
   AND M1.exam_main_cd = @ordNo
   LIMIT 1', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, '{"classes": []}'::jsonb, 'CSI検査オーダ(連携電文の検査スケジュール)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-441, '-- 【SQL_CD=-441】
 SELECT

   ''指示簿指示'' AS detail_id,

   info->>''no'' as no,

   info->>''content'' as content,



   info->>''ind_user_id'' as ind_user_id,

   TRIM ( COALESCE ( info ->> ''ind_user_last_name'', '''' ) || ''　'' || COALESCE ( info ->> ''ind_user_first_name'', '''' ), ''　'' ) AS ind_user_name,

   info->>''upd_user_id'' as upd_user_id,

   TRIM ( COALESCE ( info ->> ''upd_user_last_name'', '''' ) || ''　'' || COALESCE ( info ->> ''upd_user_first_name'', '''' ), ''　'' ) AS upd_user_name,

   info->>''input_class'' as input_class,

   info->>''is_editable'' as is_editable,

   info->>''cop_order_no'' as cop_order_no,

   ind_treat_start_time as treat_date_start,

   null as treat_date_end,

   up_date AS up_date

 FROM

   ord_main

     cross join lateral

       json_array_elements (ord_main.ind_ind_comment_info :: json) info

 WHERE

   ord_no = @ordNo

', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, '{"classes": []}'::jsonb, 'CSI透析予約(連携電文の指示簿詳細)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-440, '-- 【SQL_CD=-440】
 SELECT

   ''材料指示'' AS detail_id,

   info ->> ''class_cd'' AS class_cd,

   info ->> ''class_type'' AS class_type,

   info ->> ''equip_type'' AS equip_type,

   info ->> ''cd'' AS cd,

   info ->> ''amount'' AS amount,

   info ->> ''ind_user_id'' AS ind_user_id,

   TRIM ( COALESCE ( info ->> ''ind_user_last_name'', '''' ) || ''　'' || COALESCE ( info ->> ''ind_user_first_name'', '''' ), ''　'' ) AS ind_user_name,

   info ->> ''upd_user_id'' AS upd_user_id,

   TRIM ( COALESCE ( info ->> ''upd_user_last_name'', '''' ) || ''　'' || COALESCE ( info ->> ''upd_user_first_name'', '''' ), ''　'' ) AS upd_user_name,

   info ->> ''input_class'' AS input_class,

   info ->> ''is_editable'' AS is_editable,

   info ->> ''needle_type'' AS needle_type,

   info ->> ''cop_order_no'' AS cop_order_no,

   up_date AS up_date

 FROM

   ord_main

   CROSS JOIN LATERAL json_array_elements ( ord_main.ind_equip_info :: json ) info 

 WHERE

   ord_no = @ordNo', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, '{"classes": []}'::jsonb, 'CSI透析予約(連携電文の材料詳細)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-439, '-- 【SQL_CD=-439】
 SELECT

   ''投薬指示'' AS detail_id,

   info ->> ''no'' AS NO,

   info ->> ''medicine_type'' AS medicine_type,

   info ->> ''cd'' AS cd,

   info ->> ''amount'' AS amount,

   to_date( info ->> ''init_date'', ''yyyymmdd'' ) AS init_date,

   info ->> ''date_interval'' AS date_interval,

   info ->> ''timing_cd'' AS timing_cd,

   info ->> ''procedure_cd'' AS procedure_cd,

   info ->> ''comment'' AS COMMENT,

   info ->> ''ind_user_id'' AS ind_user_id,

   TRIM ( COALESCE ( info ->> ''ind_user_last_name'', '''' ) || ''　'' || COALESCE ( info ->> ''ind_user_first_name'', '''' ), ''　'' ) AS ind_user_name,

   info ->> ''upd_user_id'' AS upd_user_id,

   TRIM ( COALESCE ( info ->> ''upd_user_last_name'', '''' ) || ''　'' || COALESCE ( info ->> ''upd_user_first_name'', '''' ), ''　'' ) AS upd_user_name,

   info ->> ''input_class'' AS input_class,

   info ->> ''is_editable'' AS is_editable,

   info ->> ''cop_order_no'' AS cop_order_no,

   up_date AS up_date

 FROM

   ord_main

   CROSS JOIN LATERAL json_array_elements ( ord_main.ind_medi_info :: json ) info 

 WHERE

   ord_no = @ordNo', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, '{"classes": []}'::jsonb, 'CSI透析予約(連携電文の投薬詳細)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-438, '-- 【SQL_CD=-438】
 SELECT

   ''予約指示'' AS detail_id,

   ord.ind_schedule_user_info -> ''ind_user_id'' AS ind_user_id,

   TRIM (

     COALESCE ( ( ord.ind_schedule_user_info ->> ''ind_user_last_name'' ), '''' ) || ''　'' || COALESCE ( ord.ind_schedule_user_info ->> ''ind_user_first_name'', '''' ),

     ''　'' 

   ) AS ind_user_name,

   ord.ind_schedule_user_info -> ''upd_user_id'' AS upd_user_id,

   TRIM (

     COALESCE ( ( ord.ind_schedule_user_info ->> ''upd_user_last_name'' ), '''' ) || ''　'' || COALESCE ( ( ord.ind_schedule_user_info ->> ''upd_user_first_name'' ), '''' ),

     ''　'' 

   ) AS upd_user_name,

   up_date AS up_date 

 FROM

   ord_main AS ord 

 WHERE

   ord.ord_no = @ordNo', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, '{"classes": []}'::jsonb, 'CSI透析予約(連携電文の予約詳細)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-437, '-- 【SQL_CD=-437】
 SELECT

   ''条件指示'' AS detail_id,

   split_part( cond_arr.cond_row, ''-@-'', 1 ) AS item_cd,

   split_part( cond_arr.cond_row, ''-@-'', 2 ) AS item_name,

   split_part( cond_arr.cond_row, ''-@-'', 3 ) AS item_value,

   split_part( cond_arr.cond_row, ''-@-'', 4 ) AS item_value_name,

   split_part( cond_arr.cond_row, ''-@-'', 5 ) AS item_value_unit, 

   split_part( cond_arr.cond_row, ''-@-'', 6 ) AS ind_user_id, 

   split_part( cond_arr.cond_row, ''-@-'', 7 ) AS upd_user_id, 

   split_part( cond_arr.cond_row, ''-@-'', 8 ) AS up_date, 

   split_part( cond_arr.cond_row, ''-@-'', 9 ) AS add_item  

 FROM

   (

   SELECT

     regexp_split_to_table(

       array_to_string(

         ARRAY [ concat ( ''001-@-透析開始時刻-@-'', ord.ind_treat_start_time, ''-@--@-'', ''-@--@-'' ),

         concat ( ''002-@-透析時間-@-'', ord.ind_cond_info -> ''1'' ->> ''value'', ''-@--@-分'', ''-@-'', ord.ind_cond_info -> ''1'' ->> ''ind_user_id'', ''-@-'', ord.ind_cond_info -> ''1'' ->> ''upd_user_id'' ),

         concat ( ''003-@-VA-@-'', TRIM ( mva.in_hospital_cd_1 ), ''-@-'', ord.ind_cond_info -> ''2'' ->> ''value_name_1'', ''-@-'', ''-@-'', ord.ind_cond_info -> ''2'' ->> ''ind_user_id'', ''-@-'', ord.ind_cond_info -> ''2'' ->> ''upd_user_id'' ),

         concat ( ''004-@-DW-@-'', physical ->> ''dw'', ''-@-'', ''-@-'', ''kg'', ''-@--@-'' ),

         concat ( ''005-@-目標体重-@-'', ord.ind_cond_info -> ''3'' ->> ''value'', ''-@-'', ''-@-'', ''kg'', ''-@-'', ord.ind_cond_info -> ''3'' ->> ''ind_user_id'', ''-@-'', ord.ind_cond_info -> ''3'' ->> ''upd_user_id'' ),

         concat ( ''006-@-治療方法-@-'', mtt.in_hospital_cd_a1, ''-@-'', mtt.treatment_name, ''-@-'', ''-@--@--@--@-'', mtt.device_mode ),

         concat ( ''007-@-除水量制限-@-'', to_char( to_number( ord.ind_cond_info -> ''4'' ->> ''value'', ''99.99'' ), ''FM90.99'' ), ''-@-'', ''-@-'', ''L'', ''-@-'', ord.ind_cond_info -> ''4'' ->> ''ind_user_id'', ''-@-'', ord.ind_cond_info -> ''4'' ->> ''upd_user_id'' ),

         concat ( ''008-@-ダイアライザー-@-'', TRIM ( mdr.in_hospital_cd_1 ), ''-@-'', ord.ind_cond_info -> ''5'' ->> ''value_name_1'', ''-@-'', ''-@-'', ord.ind_cond_info -> ''5'' ->> ''ind_user_id'', ''-@-'', ord.ind_cond_info -> ''5'' ->> ''upd_user_id'' ),

         concat ( ''009-@-吸着カラム-@-'', TRIM ( meqad.in_hospital_cd_1 ), ''-@-'', ord.ind_cond_info -> ''6'' ->> ''value_name_1'', ''-@-'', ''-@-'', ord.ind_cond_info -> ''6'' ->> ''ind_user_id'', ''-@-'', ord.ind_cond_info -> ''6'' ->> ''upd_user_id'' ),

         concat ( ''010-@-血流量-@-'', ord.ind_cond_info -> ''14'' ->> ''value'', ''-@-'', ''-@-'', ''mL/min'', ''-@-'', ord.ind_cond_info -> ''14'' ->> ''ind_user_id'', ''-@-'', ord.ind_cond_info -> ''14'' ->> ''upd_user_id'' ),

         concat (

           ''011-@-抗凝固剤-@-'',

           ( CASE ord.ind_cond_info -> ''25'' ->> ''medicine_type'' WHEN ''1'' THEN med25.in_hospital_cd_1 WHEN ''2'' THEN mmx.in_hospital_cd_1 END ),

           ''-@-'',

           ord.ind_cond_info -> ''25'' ->> ''value_name_1'',

           ''-@-'', 

           ''-@-'', ord.ind_cond_info -> ''25'' ->> ''ind_user_id'', ''-@-'', ord.ind_cond_info -> ''25'' ->> ''upd_user_id'' ),

         concat ( ''012-@-抗凝固剤ワンショット量-@-'', ord.ind_cond_info -> ''26'' ->> ''value'', ''-@-'', ''-@-'', ord.ind_cond_info -> ''26'' ->> ''unit'', ''-@-'', ord.ind_cond_info -> ''26'' ->> ''ind_user_id'', ''-@-'', ord.ind_cond_info -> ''26'' ->> ''upd_user_id'' ),

         concat ( ''013-@-抗凝固剤持続速度-@-'', ord.ind_cond_info -> ''27'' ->> ''value'', ''-@-'', ''-@-'', ord.ind_cond_info -> ''27'' ->> ''unit'', ''-@-'', ord.ind_cond_info -> ''27'' ->> ''ind_user_id'', ''-@-'', ord.ind_cond_info -> ''27'' ->> ''upd_user_id'' ),

         concat ( ''014-@-抗凝固剤持続総量-@-'', ord.ind_cond_info -> ''28'' ->> ''value'', ''-@-'', ''-@-'', ord.ind_cond_info -> ''28'' ->> ''unit'', ''-@-'', ord.ind_cond_info -> ''28'' ->> ''ind_user_id'', ''-@-'', ord.ind_cond_info -> ''28'' ->> ''upd_user_id'' ),

         concat (

           ''015-@-IP使用選択-@-'',

           ord.ind_cond_info -> ''29'' ->> ''value'',

           ''-@-'',

           ( CASE ord.ind_cond_info -> ''29'' ->> ''value'' WHEN ''1'' THEN ''使用する'' WHEN ''0'' THEN ''使用しない'' ELSE NULL END ),

           ''-@-'', 

           ''-@-'', ord.ind_cond_info -> ''29'' ->> ''ind_user_id'', ''-@-'', ord.ind_cond_info -> ''29'' ->> ''upd_user_id'' ),

         concat ( ''016-@-IPワンショット量-@-'', ord.ind_cond_info -> ''31'' ->> ''value'', ''-@-'', ''-@-'', ''mL'', ''-@-'', ord.ind_cond_info -> ''31'' ->> ''ind_user_id'', ''-@-'', ord.ind_cond_info -> ''31'' ->> ''upd_user_id'' ),

         concat ( ''017-@-IP速度-@-'', ord.ind_cond_info -> ''32'' ->> ''value'', ''-@-'', ''-@-'', ''“mL/h'', ''-@-'', ord.ind_cond_info -> ''32'' ->> ''ind_user_id'', ''-@-'', ord.ind_cond_info -> ''32'' ->> ''upd_user_id'' ),

         concat (

           ''018-@-透析液-@-'',

           (

           CASE

               ord.ind_cond_info -> ''15'' ->> ''medicine_type'' 

               WHEN ''1'' THEN

               TRIM ( med15.in_hospital_cd_1 ) 

               WHEN ''2'' THEN

               TRIM ( mmmx.in_hospital_cd_1 ) 

             END 

             ),

             ''-@-'',

             ord.ind_cond_info -> ''15'' ->> ''value_name_1'',

             ''-@-'', 

             ''-@-'', ord.ind_cond_info -> ''15'' ->> ''ind_user_id'', ''-@-'', ord.ind_cond_info -> ''15'' ->> ''upd_user_id'' ),

           concat ( ''019-@-透析液流量-@-'', ord.ind_cond_info -> ''16'' ->> ''value'', ''-@-'', ''-@-'', ''mL/min'', ''-@-'', ord.ind_cond_info -> ''16'' ->> ''ind_user_id'', ''-@-'', ord.ind_cond_info -> ''16'' ->> ''upd_user_id'' ),

           concat ( ''020-@-透析液量-@-'', ord.ind_cond_info -> ''17'' ->> ''value'', ''-@-'', ''-@-'', ord.ind_cond_info -> ''17'' ->> ''unit'', ''-@-'', ord.ind_cond_info -> ''17'' ->> ''ind_user_id'', ''-@-'', ord.ind_cond_info -> ''17'' ->> ''upd_user_id'' ),

           concat ( ''021-@-透析液温度-@-'', ord.ind_cond_info -> ''18'' ->> ''value'', ''-@-'', ''-@-'', ''℃'', ''-@-'', ord.ind_cond_info -> ''18'' ->> ''ind_user_id'', ''-@-'', ord.ind_cond_info -> ''18'' ->> ''upd_user_id'' ),

           concat (

             ''022-@-補液-@-'',

             ( CASE ord.ind_cond_info -> ''19'' ->> ''medicine_type'' WHEN ''1'' THEN med19.in_hospital_cd_1 WHEN ''2'' THEN mmmmx.in_hospital_cd_1 END ),

             ''-@-'',

             ord.ind_cond_info -> ''19'' ->> ''value_name_1'',

             ''-@-'', 

             ''-@-'', ord.ind_cond_info -> ''19'' ->> ''ind_user_id'', ''-@-'', ord.ind_cond_info -> ''19'' ->> ''upd_user_id'' ),

           concat ( ''023-@-補液量-@-'', ord.ind_cond_info -> ''20'' ->> ''value'', ''-@-'', ''-@-'', ''L'', ''-@--@-'' ),

           concat (

             ''024-@-補液選択-@-'',

             ord.ind_cond_info -> ''21'' ->> ''value'',

             ''-@-'',

             ( CASE ord.ind_cond_info -> ''21'' ->> ''value'' WHEN ''1'' THEN ''前補液'' WHEN ''0'' THEN ''後補液'' ELSE NULL END ),

             ''-@-'', 

             ''-@-'', ord.ind_cond_info -> ''21'' ->> ''ind_user_id'', ''-@-'', ord.ind_cond_info -> ''21'' ->> ''upd_user_id'' ),

           concat ( ''025-@-補液温度-@-'', ord.ind_cond_info -> ''23'' ->> ''value'', ''-@-'', ''-@-'', ''℃'', ''-@-'', ord.ind_cond_info -> ''23'' ->> ''ind_user_id'', ''-@-'', ord.ind_cond_info -> ''23'' ->> ''upd_user_id'' ),

           concat (

             ''029-@-シングルニードル電源-@-'',

             ord.ind_cond_info -> ''12'' ->> ''value'',

             ''-@-'',

             ( CASE ord.ind_cond_info -> ''12'' ->> ''value'' WHEN ''1'' THEN ''使用する'' WHEN ''0'' THEN ''使用しない'' ELSE NULL END ),

             ''-@-'', 

             ''-@-'', ord.ind_cond_info -> ''12'' ->> ''ind_user_id'', ''-@-'', ord.ind_cond_info -> ''12'' ->> ''upd_user_id'' ),

           concat ( ''030-@-補液使用数-@-'', ord.ind_cond_info -> ''22'' ->> ''value'', ''-@-'', ''-@-'', ord.ind_cond_info -> ''22'' ->> ''unit'', ''-@-'', ord.ind_cond_info -> ''22'' ->> ''ind_user_id'', ''-@-'', ord.ind_cond_info -> ''22'' ->> ''upd_user_id'' ),

           concat (

             ''031-@-IPスタート-@-'',

             ord.ind_cond_info -> ''30'' ->> ''value'',

             ''-@-'',

             ( CASE ord.ind_cond_info -> ''30'' ->> ''value'' WHEN ''0'' THEN ''手動'' WHEN ''1'' THEN ''自動'' ELSE NULL END ),

             ''-@-'', 

             ''-@-'', ord.ind_cond_info -> ''30'' ->> ''ind_user_id'', ''-@-'', ord.ind_cond_info -> ''30'' ->> ''upd_user_id'' ),

           concat (

             ''032-@-自動ワンショット-@-'',

             ord.ind_cond_info -> ''34'' ->> ''value'',

             ''-@-'',

             ( CASE ord.ind_cond_info -> ''34'' ->> ''value'' WHEN ''1'' THEN ''使用する'' WHEN ''0'' THEN ''使用しない'' ELSE NULL END ),

             ''-@-'', 

             ''-@-'', ord.ind_cond_info -> ''34'' ->> ''ind_user_id'', ''-@-'', ord.ind_cond_info -> ''34'' ->> ''upd_user_id'' ),

           concat (

             ''033-@-IP電源自動切り-@-'',

             ord.ind_cond_info -> ''35'' ->> ''value'',

             ''-@-'',

             ( CASE ord.ind_cond_info -> ''35'' ->> ''value'' WHEN ''1'' THEN ''入り'' WHEN ''0'' THEN ''切り'' ELSE NULL END ),

             ''-@-'', 

             ''-@-'', ord.ind_cond_info -> ''35'' ->> ''ind_user_id'', ''-@-'', ord.ind_cond_info -> ''35'' ->> ''upd_user_id'' ),

           concat ( ''034-@-IP電源自動切り時間-@-'', ord.ind_cond_info -> ''36'' ->> ''value'', ''-@-'', ''-@-'', ''分'', ''-@-'', ord.ind_cond_info -> ''36'' ->> ''ind_user_id'', ''-@-'', ord.ind_cond_info -> ''36'' ->> ''upd_user_id'' ),

           concat (

             ''035-@-IP電源OKモニタ切り-@-'',

             ord.ind_cond_info -> ''37'' ->> ''value'',

             ''-@-'',

             ( CASE ord.ind_cond_info -> ''37'' ->> ''value'' WHEN ''1'' THEN ''入り'' WHEN ''0'' THEN ''切り'' ELSE NULL END ),

             ''-@-'', 

             ''-@-'', ord.ind_cond_info -> ''37'' ->> ''ind_user_id'', ''-@-'', ord.ind_cond_info -> ''37'' ->> ''upd_user_id'' ),

           concat ( ''036-@-IP電源OKモニタ切り時間-@-'', ord.ind_cond_info -> ''38'' ->> ''value'', ''-@-'', ''-@-'', ''分'', ''-@-'', ord.ind_cond_info -> ''38'' ->> ''ind_user_id'', ''-@-'', ord.ind_cond_info -> ''1'' ->> ''upd_user_id'' ),

           concat ( ''037-@-IP速度最大値-@-'', ord.ind_cond_info -> ''33'' ->> ''value'', ''-@-'', ''-@-'', ''mL/h'', ''-@-'', ord.ind_cond_info -> ''33'' ->> ''ind_user_id'', ''-@-'', ord.ind_cond_info -> ''33'' ->> ''upd_user_id'' ),

           concat ( ''038-@-補液速度-@-'', ord.ind_cond_info -> ''24'' ->> ''value'', ''-@-'', ''-@-'', ''L/h'', ''-@-'', ord.ind_cond_info -> ''24'' ->> ''ind_user_id'', ''-@-'', ord.ind_cond_info -> ''24'' ->> ''upd_user_id'' ),

           concat ( ''039-@-1次膜-@-'', meqpr.in_hospital_cd_1, ''-@-'', ord.ind_cond_info -> ''7'' ->> ''value_name_1'', ''-@-'', ''-@-'', ord.ind_cond_info -> ''7'' ->> ''ind_user_id'', ''-@-'', ord.ind_cond_info -> ''7'' ->> ''upd_user_id'' ),

           concat ( ''040-@-2次膜-@-'', meqse.in_hospital_cd_1, ''-@-'', ord.ind_cond_info -> ''8'' ->> ''value_name_1'', ''-@-'', ''-@-'', ord.ind_cond_info -> ''8'' ->> ''ind_user_id'', ''-@-'', ord.ind_cond_info -> ''8'' ->> ''upd_user_id'' ) ],

           ''-@@-'' 

         ),

         ''-@@-'' 

       ) AS cond_row 

     FROM

       ord_main AS ord

       LEFT OUTER JOIN mst_equipment AS meqad ON meqad.equipment_cd = TO_NUMBER( ord.ind_cond_info -> ''6'' ->> ''value'', ''999999999999'' )

       LEFT OUTER JOIN mst_equipment AS meqpr ON meqpr.equipment_cd = TO_NUMBER( ord.ind_cond_info -> ''7'' ->> ''value'', ''999999999999'' )

       LEFT OUTER JOIN mst_equipment AS meqse ON meqse.equipment_cd = TO_NUMBER( ord.ind_cond_info -> ''8'' ->> ''value'', ''999999999999'' )

       LEFT OUTER JOIN mst_medicine AS med15 ON med15.medicine_cd = TO_NUMBER( ord.ind_cond_info -> ''15'' ->> ''value'', ''999999999999'' )

       LEFT OUTER JOIN mst_medicine AS med19 ON med19.medicine_cd = TO_NUMBER( ord.ind_cond_info -> ''19'' ->> ''value'', ''999999999999'' )

       LEFT OUTER JOIN mst_medicine AS med25 ON med25.medicine_cd = TO_NUMBER( ord.ind_cond_info -> ''25'' ->> ''value'', ''999999999999'' )

       LEFT OUTER JOIN mst_treatment AS mtt ON mtt.treatment_cd = ord.ind_treatment_cd

       LEFT OUTER JOIN mst_dialyzer AS mdr ON mdr.dialyzer_cd = TO_NUMBER( ord.ind_cond_info -> ''5'' ->> ''value'', ''999999999999'' )

       LEFT OUTER JOIN mst_va AS mva ON mva.va_cd = TO_NUMBER( ord.ind_cond_info -> ''2'' ->> ''value'', ''999999999999'' )

       LEFT OUTER JOIN mst_medicine_mix AS mmx ON mmx.medicine_mix_cd = TO_NUMBER( ord.ind_cond_info -> ''25'' ->> ''value'', ''999999999999'' )

       LEFT OUTER JOIN mst_medicine_mix AS mmmx ON mmmx.medicine_mix_cd = TO_NUMBER( ord.ind_cond_info -> ''15'' ->> ''value'', ''999999999999'' )

       LEFT OUTER JOIN mst_medicine_mix AS mmmmx ON mmmmx.medicine_mix_cd = TO_NUMBER( ord.ind_cond_info -> ''19'' ->> ''value'', ''999999999999'' )

       LEFT OUTER JOIN pat_unique AS puq ON puq.pat_id = ord.pat_id

       CROSS JOIN LATERAL json_array_elements ( puq.physical_info :: json ) physical 

     WHERE

       physical ->> ''exam_date'' = (

       SELECT MAX

         ( physical2 ->> ''exam_date'' ) 

       FROM

         ord_main ord2,

         pat_unique puq2

         CROSS JOIN LATERAL json_array_elements ( puq2.physical_info :: json ) physical2 

       WHERE

         physical2 ->> ''exam_date'' <= ord.treat_date 

         AND COALESCE ( physical2 ->> ''dw'', ''ZERO'' ) <> ''ZERO'' 

         AND ord.pat_id = puq2.pat_id 

       ) 

       AND ord.ord_no = @ordNo

     ) cond_arr 

 WHERE

   (LENGTH ( split_part( cond_arr.cond_row, ''-@-'', 3 ) ) > 0 OR LENGTH ( split_part( cond_arr.cond_row, ''-@-'', 9 ) ) > 0) 

 AND split_part( cond_arr.cond_row, ''-@-'', 1 ) IN (''001'', ''002'', ''003'', ''004'', ''005'', ''006'')', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, '{"classes": []}'::jsonb, 'CSI透析予約(連携電文の条件詳細)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-436, '-- 【SQL_CD=-436】
 WITH staff_info AS (
   SELECT ROW_NUMBER( ) OVER ( ORDER BY info ->> ''is_main'' DESC,  info ->> ''is_charge'' DESC,  info ->> ''is_puncture'' DESC, info ->> ''ctl_no'' ASC ) AS CNT,
     info ->> ''staff_cd'' AS staff_cd 
   FROM
     pat_main AS pat
     LEFT JOIN LATERAL json_array_elements ( pat.charge_staff_info :: json ) info ON info ->> ''ctl_no'' IS NOT NULL 
   WHERE
     pat.pat_id = @patId 
   )
 SELECT
    ord.treat_date AS treat_date,
    ord.ind_treat_start_time AS start_time,
    -- クールマスタ
    ord.ind_kur_cd AS kur_cd,
    mkr.kur_name AS kur_name,
    COALESCE(TRIM(mkr.in_hospital_cd_1), cast(mkr.kur_cd as VARCHAR)) AS kur_cd1,
    LEFT ( mkr.kur_standard_start_time, 4 ) AS kur_standard_start_time,
    mkr.kur_standard_start_time AS kur_standard_start_time_6,
    -- ベッドマスタ
    ord.ind_bed_cd AS bed_cd,
    mbd.bed_name AS bed_name,
    COALESCE(TRIM(mbd.in_hospital_cd_1), cast(mbd.bed_cd as VARCHAR)) AS bed_cd1,
    -- 診療科マスタ
    pat.medical_care_info ->> ''main_course_cd'' AS course_cd,
    course.course_name AS course_name,
    COALESCE(TRIM(course.in_hospital_cd_1), cast(course.course_cd as VARCHAR)) AS course_cd1,
    -- 医師1
    staff1.staff_cd AS staff_cd1,
    -- 医師2
    staff2.staff_cd AS staff_cd2 
 FROM
    pat_main AS pat
    LEFT JOIN ord_main AS ord ON pat.pat_id = ord.pat_id AND ord.ord_no = @ordNo
    LEFT JOIN staff_info AS staff1 ON staff1.CNT = 1
    LEFT JOIN staff_info AS staff2 ON staff2.CNT = 2
    LEFT JOIN mst_kur AS mkr ON mkr.kur_cd = ord.ind_kur_cd 
    LEFT JOIN mst_bed AS mbd ON mbd.bed_cd = ord.ind_bed_cd
    LEFT JOIN mst_course AS course ON course.course_cd ::TEXT = pat.medical_care_info ->> ''main_course_cd''
  WHERE
    pat.pat_id = @patId ', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, '{"classes": []}'::jsonb, 'CSI透析予約(連携電文の透析スケジュール)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(1101, '-- 【SQL_CD=1101】
select
  pat_id,
  fn_pat_id,
  hosp_pat_id,
  nkk_pat_id,
  facility_cd,
  personal_info_decrypt(pat_last_name) as pat_last_name,
  personal_info_decrypt(pat_first_name) as pat_first_name,
  personal_info_decrypt(pat_last_name_kana) as pat_last_name_kana,
  personal_info_decrypt(pat_first_name_kana) as pat_first_name_kana,
  personal_info_decrypt(pat_last_name_alpha) as pat_last_name_alpha,
  personal_info_decrypt(pat_first_name_alpha) as pat_first_name_alpha,
  personal_info_decrypt(pat_birth_name) as pat_birth_name,
  personal_info_decrypt(pat_birth_name_kana) as pat_birth_name_kana,
  personal_info_decrypt(pat_birth_name_alpha) as pat_birth_name_alpha,
  pat_birthday,
  pat_sex,
  nationality,
  pat_blood_type_abo,
  pat_blood_type_rh,
  pat_blood_type_serovar,
  in_out_class,
  is_die,
  die_cd,
  die_date,
  dial_diff_com_info,
  severity_cd,
  transport_cd,
  personal_info_decrypt_jsonb(pat_contact_info) as pat_contact_info,
  personal_info_decrypt_jsonb(other_contact_info) as other_contact_info,
  personal_info_decrypt_jsonb(vendor_contact_info) as vendor_contact_info,
  insurance_info,
  is_del,
  up_date,
  reg_date,
  primary_disease_cd,
  remote_monitor_service,
  personal_info_decrypt(remote_monitor_user_id) as remote_monitor_user_id,
  personal_info_decrypt(remote_monitor_user_pw) as remote_monitor_user_pw
from
  pat_personal_main
where
  is_del = ''0''
and
  hosp_pat_id = @hospPatId
and
  facility_cd = @facilityCd', 3, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)患者個人情報の取得', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(1201, '-- 【SQL_CD=1201】
SELECT
    pat_id,
    facility_cd,
    is_same,
    is_implant,
    is_infect,
    is_diabetes,
    is_blood_suger_exam,
    in_out_current_state,
    in_out_plan_state,
    in_out_plan_date,
    pat_memo_info,
    addition_info,
    charge_staff_info,
    pat_group_info,
    taboo_allergy_info,
    infect_info,
    implant_info,
    tare_info,
    off_water_info,
    device_set_info,
    acceptance_status_info,
    is_del,
    up_date,
    reg_date,
    is_wheel_chair,
    medical_care_info,
    sch_ext_end_date,
    sch_ext_status,
    card_idm,
    old_up_date,
    host_notification_info,
    (
    SELECT
        (
            COALESCE ( MAX ( TO_NUMBER( COALESCE ( NULLIF ( RESULT ->> ''ctl_no'', '''' ), ''0'' ), ''99999'' ) ), 0 ) + 1 
        ) AS ctl_no 
    FROM
        pat_main tbl1
        CROSS JOIN LATERAL json_array_elements ( tbl1.pat_memo_info :: json ) RESULT 
    WHERE
        tbl1.pat_id = @patId 
    ) AS next_ctl_no_1,
    (
    SELECT
        (
            COALESCE ( MAX ( TO_NUMBER( COALESCE ( NULLIF ( RESULT ->> ''ctl_no'', '''' ), ''0'' ), ''99999'' ) ), 0 ) + 1 
        ) AS ctl_no 
    FROM
        pat_main tbl2
        CROSS JOIN LATERAL json_array_elements ( tbl2.charge_staff_info :: json ) RESULT 
    WHERE
        tbl2.pat_id = @patId 
    ) AS next_ctl_no_2,
    (
    SELECT
        (
            COALESCE ( MAX ( TO_NUMBER( COALESCE ( NULLIF ( RESULT ->> ''ctl_no'', '''' ), ''0'' ), ''99999'' ) ), 0 ) + 1 
        ) AS ctl_no 
    FROM
        pat_main tbl3
        CROSS JOIN LATERAL json_array_elements ( tbl3.taboo_allergy_info :: json ) RESULT 
    WHERE
        tbl3.pat_id = @patId 
    ) AS next_ctl_no_3,
    (
    SELECT
        (
            COALESCE ( MAX ( TO_NUMBER( COALESCE ( NULLIF ( RESULT ->> ''ctl_no'', '''' ), ''0'' ), ''99999'' ) ), 0 ) + 1 
        ) AS ctl_no 
    FROM
        pat_main tbl4
        CROSS JOIN LATERAL json_array_elements ( tbl4.infect_info :: json ) RESULT 
    WHERE
        tbl4.pat_id = @patId 
    ) AS next_ctl_no_4,
    (
    SELECT
        (
            COALESCE ( MAX ( TO_NUMBER( COALESCE ( NULLIF ( RESULT ->> ''ctl_no'', '''' ), ''0'' ), ''99999'' ) ), 0 ) + 1 
        ) AS ctl_no 
    FROM
        pat_main tbl5
        CROSS JOIN LATERAL json_array_elements ( tbl5.implant_info :: json ) RESULT 
    WHERE
        tbl5.pat_id = @patId 
    ) AS next_ctl_no_5 
FROM
    pat_main 
WHERE
    is_del = ''0'' 
    AND pat_id = @patId', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)患者基本情報の取得', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(1202, '-- 【SQL_CD=1202】
WITH take_cource_info AS ( 
  SELECT
    1 AS order_no
    , CASE TRIM(ini_info ->> ''value'') 
      WHEN '''' THEN COALESCE(NULLIF(TRIM(ini_info ->> ''default_v''), ''''), ''1'') 
      ELSE TRIM(ini_info ->> ''value'') 
      END AS take_cource_flg 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) AS ini_info 
  WHERE
    ini.is_del = ''0'' 
    AND ini.facility_cd = ''@facilityCd'' 
		AND COALESCE(ini_info ->> ''key0'','''') = ''@key0''
    AND TRIM(ini_info ->> ''key1'') = ''PATIENT_SEND'' 
    AND TRIM(ini_info ->> ''key2'') = ''IS_TAKE_COURCE_FLG'' 
  UNION 
  SELECT
    2 AS order_no
    , ''1'' AS take_cource_flg 
  ORDER BY order_no ASC LIMIT 1
)
, cource_ward_info AS (
  SELECT 
    CASE WHEN (SELECT take_cource_flg FROM take_cource_info) = ''1'' AND (''@inOutClass'') = ''1'' -- ''1''：入院
      THEN (''@medicalCareInfo.mainCourseCd'' :: TEXT) 
      ELSE ('''' :: TEXT) END AS main_course_cd
    , (''@medicalCareInfo.wardCd'' :: TEXT) AS ward_cd
)
INSERT 
INTO pat_main( 
  pat_id
  , facility_cd
  , is_same
  , is_implant
  , is_infect
  , is_diabetes
  , is_blood_suger_exam
  , in_out_current_state
  , in_out_plan_state
  , in_out_plan_date
  , pat_memo_info
  , addition_info
  , charge_staff_info
  , pat_group_info
  , taboo_allergy_info
  , infect_info
  , implant_info
  , tare_info
  , off_water_info
  , device_set_info
  , acceptance_status_info
  , is_del
  , up_date
  , reg_date
  , is_wheel_chair
  , medical_care_info
  , sch_ext_end_date
  , sch_ext_status
  , card_idm
  , old_up_date
  , host_notification_info
) 
VALUES ( 
  @patId
  , ''@facilityCd''
  , NULLIF(''@isSame'', '''')
  , NULLIF(''@isImplant'', '''')
  , NULLIF(''@isInfect'', '''')
  , NULLIF(''@isDiabetes'', '''')
  , NULLIF(''@isBloodSugerExam'', '''')
  , NULLIF(''@inOutCurrentState'', '''')
  , NULLIF(''@inOutPlanState'', '''')
  , CASE ''@inOutPlanDate_Date'' 
    WHEN '''' THEN NULL 
    ELSE to_timestamp(''@inOutPlanDate_Date'', ''yyyy-MM-dd hh24:mi:ss'') 
    END
  , COALESCE(NULLIF(''@patMemoInfo'', ''''), ''[]'') ::JSONB
  , COALESCE(NULLIF(''@additioninfo'', ''''), ''[]'') ::JSONB
  , ''@chargeStaffInfoValue''
  , ''@patGroupInfoValue''
  , ''@tabooAllergyInfoValue''
  , COALESCE(NULLIF(''@infectInfo'', ''''), ''[]'') ::JSONB
  , ''@implantInfoValue''
  , ''@tareInfoValue''
  , ''@offWaterInfoValue''
  , ''@deviceSetInfoValue''
  , ''@acceptanceStatusInfoValue''
  , ''0''
  , CURRENT_TIMESTAMP
  , CURRENT_TIMESTAMP
  , NULLIF(''@isWheelChair'', '''')
  , json_build_object( 
      ''main_course_cd''
      , TO_NUMBER(NULLIF((SELECT main_course_cd FROM cource_ward_info), ''''), ''FM999999999'')
      , ''dialysis_course_cd''
      , TO_NUMBER(NULLIF(''@medicalCareInfo.dialysisCourseCd'', ''''), ''FM999999999'')
      , ''ward_cd''
      , TO_NUMBER(NULLIF((SELECT ward_cd FROM cource_ward_info), ''''), ''FM999999999'')
      , ''dialysis_count''
      , TO_NUMBER(NULLIF(''@medicalCareInfo.dialysisCount'', ''''), ''FM999999999'')
      , ''purification_count''
      , TO_NUMBER(NULLIF(''@medicalCareInfo.purificationCount'', ''''), ''FM999999999'')
      , ''other_dialysis_count''
      , TO_NUMBER(NULLIF(''@medicalCareInfo.otherDialysisCount'', ''''), ''FM999999999'')
      , ''pat_dialysis_count''
      , TO_NUMBER(NULLIF(''@medicalCareInfo.patDialysisCount'', ''''), ''FM999999999'')
      , ''facility_cd''
      , NULLIF(''@medicalCareInfo.facilityCd'', '''')
      , ''dialysis_start_date''
      , NULLIF(''@medicalCareInfo.dialysisStartDate'', '''')
      , ''hospital_start_date''
      , NULLIF(''@medicalCareInfo.hospitalStartDate'', '''')
    )
  , NULLIF(''@schExtEndDate'', '''')
  , NULLIF(''@schExtStatus'', '''')
  , NULLIF(''@cardIdm'', '''')
  , CASE ''@oldUpDate_Date'' 
    WHEN '''' THEN NULL 
    ELSE to_timestamp(''@oldUpDate_Date'', ''yyyy-MM-dd hh24:mi:ss'') 
    END
  , NULL
)', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)富士通の患者プロファイル_患者基本情報の新規', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": 1002, "field_name": "pat_memo_info", "replace_var": "@patMemoInfo"}, {"sql_cd": 1003, "field_name": "infect_info", "replace_var": "@infectInfo"}, {"sql_cd": 1004, "field_name": "addition_info", "replace_var": "@additioninfo"}]'::jsonb);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(5102, '-- 【SQL_CD=5102】
INSERT INTO pat_exam_main (

  pat_id,

  facility_cd,

  ord_no,

  fn_pat_id,

  reg_exam_date,

  reg_order_class,

  exam_status,

  order_comment,

  order_exam_set_info,

  exam_order_info,

  order_label_info,

  data_gen_class,

  result_exam_date,

  result_comment,

  exam_result_info,

  cop_order_no1,

  cop_order_no2,

  is_lock,

  ind_user_id,

  is_del,

  reg_date,

  reg_staff,

  up_date,

  up_staff,

  is_order,

  exam_week,

  exam_from,

  exam_to,

  exam_pattern 

)

VALUES

  (

    @patId,

    ''@facilityCd'',

  CASE

      ''@ordNo'' 

      WHEN '''' THEN

      NULL ELSE to_number( ''@ordNo'', ''9999999999999999999999999999999999999999999999999999999999999999'' ) 

    END,

    NULLIF ( ''@fnPatId'', '''' ),

  CASE

      ''@regExamDate'' 

      WHEN '''' THEN

      CURRENT_TIMESTAMP ELSE to_timestamp( ''@regExamDate_Date'', ''yyyy-MM-dd hh24:mi:ss'' ) 

    END,

  CASE

      ''@regOrderClass'' 

      WHEN '''' THEN

      NULL ELSE''@regOrderClass'' 

      END,

    NULLIF ( ''@examStatus'', '''' ),

    NULLIF ( ''@orderComment'', '''' ),

    ''@orderExamSetInfoValue'',

    ''@examOrderInfoValue'',

    ''@orderLabelInfoValue'',

    NULLIF ( ''@dataGenClass'', '''' ),

  CASE

      ''@resultExamDate'' 

      WHEN '''' THEN

      NULL ELSE to_timestamp( ''@resultExamDate_Date'', ''yyyy-MM-dd hh24:mi:ss'' ) 

    END,

    NULLIF ( ''@resultComment'', '''' ),

   ''@examResultInfoValue'',

  CASE

      ''@copOrderNo1'' 

      WHEN '''' THEN

      NULL ELSE to_number( ''@copOrderNo1'', ''9999999999999999999999999999999999999999999999999999999999999999'' ) 

    END,

  CASE

      ''@copOrderNo2'' 

      WHEN '''' THEN

      NULL ELSE to_number( ''@copOrderNo2'', ''9999999999999999999999999999999999999999999999999999999999999999'' ) 

      END,

    NULLIF ( ''@isLock'', '''' ),

  CASE

      ''@indUserId'' 

      WHEN '''' THEN

      NULL ELSE to_number( ''@indUserId'', ''9999999999999999999999999999999999999999999999999999999999999999'' ) 

    END,

    ''0'',

    CURRENT_TIMESTAMP,

  CASE

      ''@regStaff'' 

      WHEN '''' THEN

      NULL ELSE to_number( ''@regStaff'', ''9999999999999999999999999999999999999999999999999999999999999999'' ) 

    END,

    CURRENT_TIMESTAMP,

  CASE

      ''@upStaff'' 

      WHEN '''' THEN

      NULL ELSE to_number( ''@upStaff'', ''9999999999999999999999999999999999999999999999999999999999999999'' ) 

    END,

    NULLIF ( ''@isOrder'', '''' ),

  CASE

      ''@examWeek'' 

      WHEN '''' THEN

      NULL ELSE to_number( ''@examWeek'', ''9999999999999999'' ) 

    END,

  CASE

      ''@examFrom'' 

      WHEN '''' THEN

      NULL ELSE to_timestamp( ''@examFrom'', ''yyyymmddhh24miss'' ) 

      END,

  CASE

      ''@examTo'' 

      WHEN '''' THEN

      NULL ELSE to_timestamp( ''@examTo'', ''yyyymmddhh24miss'' ) 

      END,

  CASE

      ''@examPattern'' 

      WHEN '''' THEN

      NULL ELSE to_number( ''@examPattern'', ''9999999999999999'' ) 

    END 

  )', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)CSIの検査結果', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(5103, '-- 【SQL_CD=5103】
UPDATE pat_exam_main 

SET result_exam_date =

CASE

    ''@resultExamDate'' 

    WHEN '''' THEN

    NULL ELSE to_timestamp( ''@resultExamDate_Date'', ''yyyy-MM-dd hh24:mi:ss'' ) 

    END,

    up_date = CURRENT_TIMESTAMP 

WHERE

    is_del = ''0'' 

    AND pat_id = @patId 

    AND facility_cd = ''@facilityCd''

    AND reg_exam_date = to_timestamp(''@regExamDate_Date'', ''yyyy-MM-dd hh24:mi:ss'')

    AND reg_order_class = ''@regOrderClass'' 

    AND exam_main_cd = @examMainCd', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)CSIの検査結果', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(5201, '-- 【SQL_CD=5201】
UPDATE pat_exam_main 

SET is_del = ''1'',

up_date = CURRENT_TIMESTAMP 

WHERE

  is_del = ''0'' 

  AND pat_id = @patId 

  AND facility_cd = ''@facilityCd'' 

  AND reg_exam_date = to_timestamp(''@regExamDate_Date'', ''yyyy-MM-dd hh24:mi:ss'')

  AND reg_order_class = ''@regOrderClass'' 

  AND exam_main_cd = @examMainCd', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)CSIの検査結果', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(5301, '-- 【SQL_CD=5301】
UPDATE pat_exam_main 

SET exam_result_info = ''[]'' 

WHERE

  is_del = ''0'' 

  AND pat_id = @patId 

  AND facility_cd = ''@facilityCd'' 

  AND reg_exam_date = to_timestamp(''@regExamDate_Date'', ''yyyy-MM-dd hh24:mi:ss'')

  AND reg_order_class = ''@regOrderClass'' 

  AND exam_main_cd = @examMainCd', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)CSIの検査結果', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);