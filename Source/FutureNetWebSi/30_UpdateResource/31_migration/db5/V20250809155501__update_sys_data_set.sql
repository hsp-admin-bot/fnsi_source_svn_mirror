DELETE FROM ntss.sys_data_set
WHERE sql_cd=-1103000;

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1103000, '-- SQL: -1103000 begin
WITH RECURSIVE coop_ini_info AS (
--連携設定から取得
SELECT
  COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS value,
  info ->> ''key1'' AS key1,
  info ->> ''key2'' AS key2
FROM
  mst_coop_ini AS ini
CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
WHERE
  ini.facility_cd = @facilityCd
  AND ini.is_del = ''0''
  AND COALESCE(info ->> ''key0'', '''') = @key0
  AND info ->> ''key1'' IN(
            ''SCM_DIALYSISSEND'',
            ''SCM_COMMON'',
            ''SCM_DIALYSISSEND_KARTE_NOTE''
        )
)
, ini_value AS(
--連携設定取得値
SELECT
    (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_DIALYSISSEND'' AND key2 = ''TREAT_IDX_TITLE'') AS treat_title,
    (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_DIALYSISSEND_KARTE_NOTE'' AND key2 = ''FREE_WORD'') AS free_word,
    (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_DIALYSISSEND_KARTE_NOTE'' AND key2 = ''WEIGHT_BEFORE'') AS weight_before,
    (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_DIALYSISSEND_KARTE_NOTE'' AND key2 = ''WEIGHT_AFTER'') AS weight_after,
    (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_DIALYSISSEND_KARTE_NOTE'' AND key2 = ''VITAL_BEFORE'') AS vital_before,
    (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_DIALYSISSEND_KARTE_NOTE'' AND key2 = ''VITAL_AFTER'') AS vital_after,
    (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_DIALYSISSEND_KARTE_NOTE'' AND key2 = ''START_DATE'') AS start_date,
    (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_DIALYSISSEND_KARTE_NOTE'' AND key2 = ''END_DATE'') AS end_date,
    (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_DIALYSISSEND_KARTE_NOTE'' AND key2 = ''ADD_TOTAL'') AS add_total,
    (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_DIALYSISSEND_KARTE_NOTE'' AND key2 = ''DIALYSIS_TIME'') AS dialysis_time,
    (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_DIALYSISSEND_KARTE_NOTE'' AND key2 = ''VA'') AS va,
    (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_DIALYSISSEND_KARTE_NOTE'' AND key2 = ''TARGET_WEIGHT'') AS target_weight,
    (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_DIALYSISSEND_KARTE_NOTE'' AND key2 = ''BLOOD_FLOW'') AS blood_flow,
    (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_DIALYSISSEND_KARTE_NOTE'' AND key2 = ''SOLUTION_RESOLVE_FLUX'') AS solution_resolve_flux,
    (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_DIALYSISSEND_KARTE_NOTE'' AND key2 = ''REPLACE_RESOLVE_MEASURE'') AS replace_resolve_measure,
    (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_DIALYSISSEND_KARTE_NOTE'' AND key2 = ''KOU_COAG_RESOLVE_ONE_SHOT'') AS kou_one_shot,
    (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_DIALYSISSEND_KARTE_NOTE'' AND key2 = ''KOU_COAG_RESOLVE_SPEED'') AS kou_speed,
    (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_DIALYSISSEND_KARTE_NOTE'' AND key2 = ''KOU_COAG_RESOLVE_TOTAL'') AS kou_total,
    (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_DIALYSISSEND_KARTE_NOTE'' AND key2 = ''ADDITION'') AS addition,
    (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_DIALYSISSEND_KARTE_NOTE'' AND key2 = ''PAT_LIFE'') AS pat_life
)
, staff_cd_list AS (
--担当医の取得
SELECT
  users ->> ''disp_user_id'' AS disp_user_id,
  ROW_NUMBER() OVER(ORDER BY staff_info ->> ''disp_order'') AS row_no
FROM
  pat_main pm
CROSS JOIN jsonb_array_elements(pm.charge_staff_info) AS staff_info
LEFT JOIN jsonb_array_elements(@userList) AS users ON
  staff_info ->> ''staff_cd'' = users ->> ''user_id''
WHERE
  pm.facility_cd = @facilityCd
  AND pm.pat_id = @patId
  AND pm.is_del = ''0''
  AND staff_info ->> ''is_main'' = ''1''
)
, journal_staff_cd AS (
--版確定者の取得
SELECT
  users ->> ''disp_user_id'' AS disp_user_id
FROM
  sys_coop_journal AS journal
LEFT JOIN jsonb_array_elements(@userList) AS users ON
  journal.user_id = (users ->> ''user_id'')::NUMERIC
WHERE
  journal.ctl_no = @ctlNo
  AND journal.facility_cd = @facilityCd
)
, ord_main_info AS (
-- 治療情報
SELECT
  to_char(om.rst_start_date, ''YYYY-MM-DD'') AS rst_start_date,
  to_char(om.rst_start_date, ''HH24:MI:SS'') AS rst_start_time,
  to_char(om.rst_end_date, ''HH24:MI:SS'') AS rst_end_time,
  to_char(
    TRUNC(EXTRACT(EPOCH FROM (rst_end_date - rst_start_date)) / 60),
    ''FM9990''
) AS treat_time,
  to_char(om.treat_date::timestamp, ''YYYY-MM-DD'') AS treat_date,
  to_char(mk.kur_standard_start_time::time, ''HH24:MI:SS'') AS kur_standard_start_time,
  ROUND((om.rst_weight_info ->> ''weight_before'')::NUMERIC, 2) AS weight_before,
  ROUND((om.rst_weight_info ->> ''weight_after'')::NUMERIC, 2) AS weight_after,
  ROUND((om.rst_weight_info ->> ''water_removal_rst'')::NUMERIC, 2) AS add_total,
  mv.va_name AS va_name,
  ROUND((om.rst_cond_info ->''3''->>''value'')::NUMERIC, 2) AS target_weight,
  ROUND((om.rst_cond_info ->''14''->>''value'')::NUMERIC) AS blood_flow,
  ROUND((om.rst_cond_info ->''16''->>''value'')::NUMERIC) AS alqd_flood_vol,
  CASE WHEN mt.device_mode not in (10) THEN ROUND((om.rst_cond_info ->''20''->>''value'')::NUMERIC, 1) ELSE NULL END AS repl_amount,
  ROUND((om.rst_cond_info ->''26''->>''value'')::NUMERIC, 2) AS anti_oneshot,
  ROUND((om.rst_cond_info ->''27''->>''value'')::NUMERIC, 2) AS anti_speed,
  ROUND((om.rst_cond_info ->''28''->>''value'')::NUMERIC, 2) AS anti_amount,
  om.rst_running_time AS rst_running_time,
  (SELECT
    string_agg(elem ->> ''content'', E''\r\n'')
  FROM
    jsonb_array_elements(om.rst_ind_comment_info) AS elem
    ) AS addition,
  COALESCE(mm.unit, mmx.unit) AS kou_unit,
  -- 透析液に値が存在する場合TRUEを返却する       
  CASE 
    WHEN (om.rst_cond_info -> ''15'' ->> ''value'') IS NOT NULL THEN TRUE 
    ELSE FALSE 
  END as is_dialysate_present,
  -- 補液に値が存在する場合TRUEを返却する       
  CASE 
    WHEN (om.rst_cond_info -> ''19'' ->> ''value'') IS NOT NULL THEN TRUE 
    ELSE FALSE 
  END as is_infusion_present,
  -- 抗凝固剤に値が存在する場合TRUEを返却する       
  CASE 
    WHEN (om.rst_cond_info -> ''25'' ->> ''value'') IS NOT NULL THEN TRUE 
    ELSE FALSE 
  END as is_anticoagulant_present
FROM
  ord_main om
LEFT JOIN mst_va mv ON om.rst_cond_info ->''2''->>''value'' = mv.va_cd::text
LEFT JOIN mst_kur mk ON om.ind_kur_cd = mk.kur_cd AND mk.facility_cd = @facilityCd
LEFT JOIN mst_treatment mt on om.rst_treatment_cd = mt.treatment_cd AND mt.facility_cd = @facilityCd
LEFT JOIN mst_medicine mm ON om.rst_cond_info ->''25''->>''medicine_type'' = ''1''
  AND om.rst_cond_info ->''25''->>''value'' = mm.medicine_cd::text
  AND mm.facility_cd = @facilityCd
LEFT JOIN mst_medicine_mix mmx ON om.rst_cond_info ->''25''->>''medicine_type'' = ''2''
  AND om.rst_cond_info ->''25''->>''value'' = mmx.medicine_mix_cd::text
  AND mmx.facility_cd = @facilityCd
WHERE
  om.ord_no = @ordNo
  AND om.facility_cd = @facilityCd
  AND om.is_del = ''0''
  AND om.pat_id = @patId
)
, mni_monitor_info AS (
--装置モニタデータから取得
SELECT
  mm.data_type,
  mm.monitor_data ->> ''90'' AS b_max,
  mm.monitor_data ->> ''91'' AS b_min,
  mm.monitor_data ->> ''92'' AS b_ave,
  mm.monitor_data ->> ''93'' AS pulse
FROM
  mni_monitor mm
WHERE
  data_type IN (''5'', ''6'')
    AND mm.ord_no = @ordNo
    AND mm.pat_id = @patId
    AND mm.is_del = ''0''
)
, send_his_memo AS (
-- 送信履歴メモ
SELECT
  save_2 ->> ''injection_send_day'' AS req_date,
  save_2 ->> ''injection_seq_no'' AS req_seq_no,
  save_2 ->> ''injection_user_id'' AS req_user_id,
  save_2 ->> ''treatment_send_day'' AS tre_send_day,
  save_2 ->> ''treatment_seq_no'' AS tre_seq_no,
  save_2 ->> ''treatment_user_id'' AS tre_user_id
FROM
  pat_coop_detail
WHERE
  facility_cd = @facilityCd
  AND pat_id = @patId
  AND save_2 ->> ''ord_no'' = @ordNo::TEXT
  AND save_2 ->> ''coop_cd'' = ''ind_dial''
ORDER BY
  up_date DESC
LIMIT 1
)
, coop_detail AS (
SELECT
  sh.req_date AS req_date,
  sh.req_seq_no AS req_seq_no,
  sh.req_user_id AS req_user_id,
  sh.tre_send_day AS tre_send_day,
  sh.tre_seq_no AS tre_seq_no,
  sh.tre_user_id AS tre_user_id
FROM
  send_his_memo sh
UNION ALL
SELECT
  '''',
  '''',
  '''',
  '''',
  '''',
  ''''
WHERE
  NOT EXISTS (SELECT 1 FROM send_his_memo)
)
, pat_event_category_order AS (
-- 患者イベントカテゴリマスタ表示順
SELECT
  index_no ::int AS category_code_order,
  TO_NUMBER(order_cd ->> ''code'', ''999999999999'') AS category_code
FROM
  mst_selector
CROSS JOIN LATERAL jsonb_array_elements(order_settings -> ''items'') WITH ORDINALITY AS tmp(order_cd, index_no)
WHERE
  facility_cd = @facilityCd
  AND master_physical_name = ''mst_pat_event_category''
)
, pat_event_sub_category_order AS (
-- 患者イベントサブカテゴリマスタ表示順
SELECT
  index_no ::int AS sub_category_code_order,
  TO_NUMBER(order_cd ->> ''code'', ''999999999999'') AS sub_category_code
FROM
  mst_selector
CROSS JOIN LATERAL jsonb_array_elements(order_settings -> ''items'') WITH ORDINALITY AS tmp(order_cd, index_no)
WHERE
  facility_cd = @facilityCd
  AND master_physical_name = ''mst_pat_event_sub_category''
)
, pat_event_info AS (
--観察記録情報
SELECT
  pe.event_start_date::date AS rec_date,
  pe.category_cd AS category_cd,
  pe.sub_category_cd AS sub_category_cd,
  coalesce(pe.event_start_time, ''0000'') AS event_start_time,
  pe.sub_category_name::text AS label_name,
  STRING_AGG(
    CASE pe.sub_category_name
      WHEN ''SOAP'' THEN
        COALESCE((input.params ->> ''field_name''), '''') || '':''
        || unescape_html(REPLACE(REGEXP_REPLACE(REGEXP_REPLACE(REGEXP_REPLACE(REGEXP_REPLACE(substring(REGEXP_REPLACE(COALESCE(NULLIF(result.params ->> ''result_value'', ''''), COALESCE(input.params -> ''item_json'' ->> ''default_value'', '''')) , ''</[p^>]*>'', E''\r\n'', ''g'') from 1 for length(REGEXP_REPLACE(COALESCE(NULLIF(result.params ->> ''result_value'', ''''), COALESCE(input.params -> ''item_json'' ->> ''default_value'', '''')) , ''</[p^>]*>'', E''\r\n'', ''g''))), ''<[^>]*>'', '''', ''g''), E''^\r\n'', '''', ''''), E''\r\n$'', '''', ''''), E''(\\r?\\n)+'', E''\r\n   '', ''g''),E''\uFEFF'' ,''''))
      ELSE
        unescape_html(REPLACE(REGEXP_REPLACE(REGEXP_REPLACE(REGEXP_REPLACE(substring(REGEXP_REPLACE(COALESCE(NULLIF(result.params ->> ''result_value'', ''''), COALESCE(input.params -> ''item_json'' ->> ''default_value'', '''')) , ''</[p^>]*>'', E''\r\n'', ''g'') from 1 for length(REGEXP_REPLACE(COALESCE(NULLIF(result.params ->> ''result_value'', ''''), COALESCE(input.params -> ''item_json'' ->> ''default_value'', '''')) , ''</[p^>]*>'', E''\r\n'', ''g''))), ''<[^>]*>'', '''', ''g''), E''^\r\n'', '''', ''''), E''\r\n$'', '''', ''''),E''\uFEFF'' ,''''))
    END,
    E''\r\n''
  ) AS content
FROM
  pat_event pe
CROSS JOIN LATERAL json_array_elements(pe.input_params ::json) WITH ORDINALITY AS input(params, idx)
CROSS JOIN LATERAL json_array_elements(pe.result_params ::json) WITH ORDINALITY AS result(params, idx)
WHERE
  pe.facility_cd = @facilityCd
  AND pe.pat_id = @patId
  AND pe.ord_no = @ordNo
  AND pe.is_del = ''0''
  AND pe.use_type = 2
  AND pe.event_start_date IS NOT NULL
  AND input.idx = result.idx
  AND pe.sub_category_name IS NOT null
GROUP BY
  pe.pat_event_cd
)
, merged_pat_event_category as (
-- サブカテゴリ毎にマージした観察記録情報
  SELECT
    rec_date,
    label_name || '':'' || E''\r\n'' ||
      STRING_AGG(
      content,
      E''\r\n''
      ORDER BY label_name, event_start_time
    ) AS merged_content,
    category_code_order,
    sub_category_code_order
  FROM pat_event_info pei
  left join pat_event_category_order peco on pei.category_cd = peco.category_code
  left join pat_event_sub_category_order pesco on pei.sub_category_cd = pesco.sub_category_code
  GROUP BY rec_date, label_name,category_code_order,sub_category_code_order
  ORDER BY rec_date
)
, merged_pat_event_contents as (
-- 日付毎にマージした観察記録情報
  SELECT
    rec_date,
    STRING_AGG(
      merged_content,
      E''\r\n''
      ORDER BY category_code_order, sub_category_code_order
    ) AS merged_content
  FROM merged_pat_event_category
  GROUP BY rec_date
  ORDER BY rec_date
)
, karute_txt AS (
-- カルテ記録テキスト
SELECT
  COALESCE(ini.free_word) AS free_word,
  CASE
    WHEN ini.weight_before <> '''' AND om.weight_before IS NOT NULL THEN
        ini.weight_before || '':'' || om.weight_before || '' Kg''
      ELSE NULL
  END AS weight_before,
  CASE
    WHEN ini.weight_after <> '''' AND om.weight_after IS NOT NULL THEN
    ini.weight_after || '':'' || om.weight_after || '' Kg''
    ELSE NULL
  END AS weight_after,
  CASE
    WHEN ini.vital_before <> '''' THEN
    ini.vital_before || '':'' ||
     array_to_string(ARRAY[
     COALESCE(vbefore.b_max, ''-''), COALESCE(vbefore.b_min, ''-''), 
     COALESCE(vbefore.b_ave, ''-''), ''('' || COALESCE(vbefore.pulse, ''-'') || '')''], ''/'')
    ELSE NULL
  END AS vital_before,
  CASE
    WHEN ini.vital_after <> '''' THEN
    ini.vital_after || '':'' ||
    array_to_string(ARRAY[
    COALESCE(vafter.b_max, ''-''), COALESCE(vafter.b_min, ''-''), 
    COALESCE(vafter.b_ave, ''-''), ''('' || COALESCE(vafter.pulse, ''-'') || '')''], ''/'')
      ELSE NULL
  END AS vital_after,
  CASE
    WHEN ini.start_date <> '''' AND om.rst_start_time IS NOT NULL THEN
      ini.start_date || '':'' || om.rst_start_time::text
    ELSE NULL
  END AS start_date,
  CASE
    WHEN ini.end_date <> '''' AND om.rst_end_time IS NOT NULL THEN
      ini.end_date || '':'' || om.rst_end_time
    ELSE NULL
  END AS end_date,
  CASE
    WHEN ini.add_total <> '''' AND om.add_total IS NOT NULL THEN
      ini.add_total || '':'' || om.add_total || '' L''
    ELSE NULL
  END AS add_total,
  CASE
    WHEN ini.dialysis_time <> '''' AND om.treat_time IS NOT NULL THEN
      ini.dialysis_time || '':'' || om.treat_time || '' 分''
    ELSE NULL
  END AS dialysis_time,
  CASE
    WHEN ini.va <> '''' AND om.va_name IS NOT NULL THEN
      ini.va || '':'' || om.va_name
    ELSE NULL
  END AS va,
  CASE
    WHEN ini.target_weight <> '''' AND om.target_weight IS NOT NULL THEN
      ini.target_weight || '':'' || om.target_weight || '' Kg''
    ELSE NULL
  END AS target_weight,
  CASE
    WHEN ini.blood_flow <> '''' AND om.blood_flow IS NOT NULL THEN
      ini.blood_flow || '':'' || om.blood_flow || '' mL/min''
    ELSE NULL
  END AS blood_flow,
  -- 透析液が設定されている時のみ出力
  CASE
    WHEN ini.solution_resolve_flux <> '''' AND om.alqd_flood_vol IS NOT NULL AND om.is_dialysate_present THEN
      ini.solution_resolve_flux || '':'' || om.alqd_flood_vol || '' mL/min''
    ELSE NULL
  END AS solution_resolve_flux,
  -- 補液が設定されている時のみ出力
  CASE
    WHEN ini.replace_resolve_measure <> '''' AND om.repl_amount IS NOT NULL AND om.is_infusion_present THEN
      ini.replace_resolve_measure || '':'' || om.repl_amount || '' L''
    ELSE NULL
  END AS replace_resolve_measure,
  -- 抗凝固剤が設定されている時のみ出力
  CASE
    WHEN ini.kou_one_shot <> '''' AND om.anti_oneshot IS NOT NULL AND om.is_anticoagulant_present THEN
      ini.kou_one_shot || '':'' || om.anti_oneshot || COALESCE('' '' || om.kou_unit, '''')
    ELSE NULL
  END AS kou_one_shot,
  -- 抗凝固剤が設定されている時のみ出力
  CASE
    WHEN ini.kou_speed <> '''' AND om.anti_speed IS NOT NULL  AND om.is_anticoagulant_present THEN
      ini.kou_speed || '':'' || om.anti_speed || COALESCE('' '' || om.kou_unit || ''/h'', '''')
    ELSE NULL
  END AS kou_speed,
  -- 抗凝固剤が設定されている時のみ出力
  CASE
    WHEN ini.kou_total <> '''' AND om.anti_amount IS NOT NULL AND om.is_anticoagulant_present THEN
      ini.kou_total || '':'' || om.anti_amount || COALESCE('' '' || om.kou_unit, '''')
    ELSE NULL
  END AS kou_total,
  CASE
    WHEN ini.addition <> '''' AND om.addition IS NOT NULL THEN
      ini.addition || '':'' || om.addition
    ELSE NULL
  END AS ind_comment,
  CASE
    WHEN ini.pat_life = ''1'' THEN
     merged_content
    ELSE NULL
  END AS obs_record
FROM
  ord_main_info om
CROSS JOIN ini_value ini
LEFT JOIN merged_pat_event_contents pe ON pe.rec_date::date = om.treat_date::date
FULL OUTER JOIN (SELECT b_max, b_min, b_ave, pulse FROM mni_monitor_info WHERE data_type = ''5'' ) AS vbefore ON TRUE
FULL OUTER JOIN (SELECT b_max, b_min, b_ave, pulse FROM mni_monitor_info WHERE data_type = ''6'') AS vafter ON TRUE
)
, cut_positions AS (
SELECT
  ini.treat_title AS value,
  octet_length(ini.treat_title) AS byte_len,
  char_length(ini.treat_title) AS char_len,
  CASE
    WHEN octet_length(ini.treat_title) <= 56 THEN char_length(ini.treat_title)
    ELSE 
    (SELECT
      MAX(i)
    FROM
      generate_series(1, char_length(ini.treat_title)) AS i
    WHERE
      octet_length(substring(ini.treat_title FROM 1 FOR i)) <= 60
    )
  END AS cut_index
FROM
  ini_value ini
)
, title_limited AS (
SELECT
  substring(value FROM 1 FOR cut_index) AS limited_title
FROM
  cut_positions
)
, user_list AS (
    --mst_user_authenticationのuser_idとdisp_user_idを取得(pre_sqlにて取得)
    SELECT
        users ->> ''user_id'' AS user_id,
        users ->> ''disp_user_id'' AS disp_user_id
    FROM
        jsonb_array_elements(@userList) AS users
)
, personal_list AS (
    --mst_personal_userのuser_idとin_hospital_cd_1とin_hospital_cd_2を取得(pre_sqlにて取得)
    SELECT
        personal ->> ''user_id'' AS user_id,
        personal ->> ''in_hospital_cd_1'' AS in_hospital_cd_1,
        personal ->> ''in_hospital_cd_2'' AS in_hospital_cd_2
    FROM
        jsonb_array_elements(@personalList) AS personal
)
, default_doctor AS (
    --デフォルト医師の院内コードと表示用利用者IDを取得
    SELECT
        users.disp_user_id AS defalut_disp_user_id,
        CASE
      (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_COMMON'' AND key2 = ''IN_HOSP_CD'')
      WHEN ''1'' THEN personal.in_hospital_cd_1
      WHEN ''2'' THEN personal.in_hospital_cd_2
    END as defalut_in_hospital_cd
    FROM
        coop_ini_info cii
        LEFT JOIN user_list AS users ON 
            cii.value = users.disp_user_id
        LEFT JOIN personal_list AS personal ON
            users.user_id = personal.user_id
    WHERE
        cii.key1 = ''SCM_COMMON''
        AND cii.key2 = ''DEFAULT_DOCTOR''
)
SELECT
  RIGHT(
        CASE (SELECT value::NUMERIC FROM coop_ini_info WHERE key1 = ''SCM_DIALYSISSEND'' AND key2 = ''USER_ID_FLAG'')
        WHEN ''0'' THEN 
            (SELECT disp_user_id FROM journal_staff_cd)
        WHEN ''1'' THEN 
            COALESCE(
            (SELECT disp_user_id FROM staff_cd_list WHERE row_no = 1),
            (SELECT disp_user_id FROM staff_cd_list WHERE row_no = 2),
            (SELECT defalut_disp_user_id FROM default_doctor),
            ''''
            )
        END
    , 6) AS user_id,
  (SELECT
    limited_title
  FROM
    title_limited) AS treat_title,
  omi.treat_date AS treat_date,
  omi.rst_start_date AS rst_start_date,
  omi.rst_start_time AS rst_start_time,
  TO_CHAR(TO_DATE(cd.tre_send_day, ''YYYYMMDD''), ''YYYY-MM-DD'') AS treatment_req_date,
  TO_CHAR(TO_TIMESTAMP(cd.tre_seq_no, ''HH24MISS''), ''HH24:MI:SS'') AS treatment_req_seq_no,
  cd.tre_user_id AS treatment_req_user_id,
  TO_CHAR(TO_DATE(cd.req_date, ''YYYYMMDD''), ''YYYY-MM-DD'') AS injection_req_date,
  TO_CHAR(TO_TIMESTAMP(cd.req_seq_no::TEXT, ''HH24MISS''), ''HH24:MI:SS'') AS injection_req_seq_no,
  cd.req_user_id AS injection_req_user_id,
  omi.kur_standard_start_time AS kur_standard_start_time,
  array_to_string(array_remove(ARRAY[
      kt.free_word,
      kt.weight_before,
      kt.weight_after,
      kt.vital_before,
      kt.vital_after,
      kt.start_date,
      kt.end_date,
      kt.add_total,
      kt.dialysis_time,
      kt.va,
      kt.target_weight,
      kt.blood_flow,
      kt.solution_resolve_flux,
      kt.replace_resolve_measure,
      kt.kou_one_shot,
      kt.kou_speed,
      kt.kou_total,
      kt.ind_comment,
      kt.obs_record
    ], NULL),
    E''\r\n''
  ) AS medical_record_text
FROM
  ord_main_info omi,
  karute_txt kt,
  coop_detail cd
-- SQL: -1103000 end', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(送信用)セコムの透析実績連携', '2025-06-03 08:56:02.129', CURRENT_TIMESTAMP, '[{"sql_cd": -1100003, "field_name": "user_list", "replace_var": "@userList"}, {"sql_cd": -1102001, "field_name": "personal_list", "replace_var": "@personalList"}]'::jsonb);
