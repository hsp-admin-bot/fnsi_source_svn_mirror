DELETE FROM ntss.sys_data_set
WHERE sql_cd IN (-603102,-604172,-610004,-604101,-604102,-604103,-604105,-604106,-604107,-604150,-604151,-604152,-604154,-604155,-604156,-604158,-604159,-604160,-604162,-604163,-604164,-607002,-610002)
;


INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-610002, 'SELECT
  personal_info_decrypt(job_cd) as job_cd
  FROM mst_personal_user
  WHERE user_id = @indUserId', 3, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'MIRAIs_exam_ord_医師フラグ取得事前SQL', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": -442, "field_name": "ind_user_id", "replace_var": "@indUserId"}]'::jsonb);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-604172, '-- 【SQL_CD=-604172】
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
  WHERE
    ord_main_max.ord_no = ord.ord_no
    AND ord_main_max.del_date = ord.del_date
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
  WHERE
    ord_main_max.ord_no = ord.ord_no
    AND ord_main_max.del_date = ord.del_date
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
  WHERE
    ord_main_max.ord_no = ord.ord_no
    AND ord_main_max.del_date = ord.del_date
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
VALUES(-604155, '-- 【SQL_CD=-604155】
with ind_dialysis_equip as (
  SELECT
    equip_arr.equip_row,
    personal_info_decrypt(mst_personal_user.job_cd) as job_cd
  FROM
    (
      SELECT
        REGEXP_SPLIT_TO_TABLE(@equipArrString, ''-@@@-'') as equip_row
    ) as equip_arr
    LEFT JOIN mst_personal_user ON split_part(equip_arr.equip_row, ''-@-'', 1) = mst_personal_user.user_id :: text
)
SELECT
  STRING_AGG(
    array_to_string(
      ARRAY [
        equip_row,
        job_cd
      ],
      ''-@-''
    ),
    ''-@@@-''
  ) AS equip_arr_string
FROM
  ind_dialysis_equip', 3, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, '{"classes": []}'::jsonb, 'CSI透析予約(連携電文の条件詳細)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": -604154, "field_name": "equip_arr_string", "replace_var": "@equipArrString"}]'::jsonb);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-610004, '-- 【SQL_CD=-610004】
SELECT 
  info ->> ''key1'' AS ini_section
  , info ->> ''key2'' AS ini_key
  , COALESCE(info ->> ''value'', info ->> ''default_v'', '''') AS ini_value
FROM 
  ntss.mst_coop_ini mci 
CROSS JOIN LATERAL json_array_elements ( mci.coop_ini_info  :: json ) info 
WHERE
  facility_cd = @facilityCd
  AND is_disp = ''1''
  AND is_del = ''0''', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '連携設定マスタ取得', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-604156, '-- 【SQL_CD=-604156】
with ind_dialysis_equip as (
  SELECT
    equip_arr.equip_row,
    coalesce(mst_job.is_doctor, '''') AS is_doctor
  FROM
    (
      SELECT
        REGEXP_SPLIT_TO_TABLE(@equipArrString, ''-@@@-'') as equip_row
    ) as equip_arr
    LEFT JOIN mst_job ON split_part(equip_arr.equip_row, ''-@-'', 4) = mst_job.job_cd :: text
)
SELECT
  STRING_AGG(
    array_to_string(
      ARRAY [
        equip_row,
        is_doctor
      ],
      ''-@-''
    ),
    ''-@@@-''
  ) AS equip_arr_string
FROM
  ind_dialysis_equip', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, '{"classes": []}'::jsonb, 'CSI透析予約(連携電文の条件詳細)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": -604155, "field_name": "equip_arr_string", "replace_var": "@equipArrString"}]'::jsonb);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-604106, '-- 【SQL_CD=-604106】
with ind_dialysis_schedule AS (
  SELECT
    schedule.schedule_row,
    personal_info_decrypt(mst_personal_user.job_cd) AS job_cd
  FROM
    (
      SELECT
        @scheduleString AS schedule_row
    ) as schedule
    LEFT JOIN mst_personal_user ON split_part(schedule.schedule_row :: text, ''-@-'', 1) = mst_personal_user.user_id :: text
)
SELECT
  array_to_string(
    ARRAY [
        schedule_row,
        job_cd
      ],
    ''-@-''
  ) AS schedule_string
FROM
  ind_dialysis_schedule', 3, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, '{"classes": []}'::jsonb, 'CSI透析予約(連携電文の予約詳細)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": -604105, "field_name": "schedule_string", "replace_var": "@scheduleString"}]'::jsonb);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-604158, '-- 【SQL_CD=-604158】
SELECT
  STRING_AGG(ind_arr.ind_row :: text, ''-@@@-'') as ind_arr_string
FROM
  (
    SELECT
       concat ( info ->> ''ind_user_id'', ''-@-'', info ->> ''upd_user_id'', ''-@-'', ord_main.up_date) AS ind_row
    FROM
      ord_main
      CROSS JOIN LATERAL json_array_elements (ord_main.ind_ind_comment_info :: json) info
    WHERE
      ord_no = @ordNo
  ) ind_arr', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, '{"classes": []}'::jsonb, 'CSI透析予約(連携電文の条件詳細)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-604160, '-- 【SQL_CD=-604160】
with ind_dialysis_ind as (
  SELECT
    ind_arr.ind_row,
    coalesce(mst_job.is_doctor, '''') AS is_doctor
  FROM
    (
      SELECT
        REGEXP_SPLIT_TO_TABLE(@indArrString, ''-@@@-'') as ind_row
    ) as ind_arr
    LEFT JOIN mst_job ON split_part(ind_arr.ind_row, ''-@-'', 4) = mst_job.job_cd :: text
)
SELECT
  STRING_AGG(
    array_to_string(
      ARRAY [
        ind_row,
        is_doctor
      ],
      ''-@-''
    ),
    ''-@@@-''
  ) AS ind_arr_string
FROM
  ind_dialysis_ind', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, '{"classes": []}'::jsonb, 'CSI透析予約(連携電文の条件詳細)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": -604159, "field_name": "ind_arr_string", "replace_var": "@indArrString"}]'::jsonb);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-604154, '-- 【SQL_CD=-604154】
SELECT
  STRING_AGG(equip_arr.equip_row :: text, ''-@@@-'') as equip_arr_string
FROM
  (
    SELECT
       concat ( info ->> ''ind_user_id'', ''-@-'', info ->> ''upd_user_id'', ''-@-'', ord_main.up_date) AS equip_row
    FROM
      ord_main
      CROSS JOIN LATERAL json_array_elements (ord_main.ind_equip_info :: json) info
    WHERE
      ord_no = @ordNo
  ) equip_arr', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, '{"classes": []}'::jsonb, 'CSI透析予約(連携電文の条件詳細)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-604163, '-- 【SQL_CD=-604163】
with journal_dialysis_journal as (
  SELECT
    journal_arr.journal_row,
    personal_info_decrypt(mst_personal_user.job_cd) as job_cd
  FROM
    (
      SELECT
        REGEXP_SPLIT_TO_TABLE(@journalArrString, ''-@@@-'') as journal_row
    ) as journal_arr
    LEFT JOIN mst_personal_user ON split_part(journal_arr.journal_row, ''-@-'', 1) = mst_personal_user.user_id :: text
)
SELECT
  STRING_AGG(
    array_to_string(
      ARRAY [
        journal_row,
        job_cd
      ],
      ''-@-''
    ),
    ''-@@@-''
  ) AS journal_arr_string
FROM
  journal_dialysis_journal', 3, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, '{"classes": []}'::jsonb, 'CSI透析予約(連携電文の条件詳細)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": -604162, "field_name": "journal_arr_string", "replace_var": "@journalArrString"}]'::jsonb);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-604162, '-- 【SQL_CD=-604162】
SELECT
  STRING_AGG(journal_arr.journal_row :: text, ''-@@@-'') as journal_arr_string,
  @ctlNo as ctl_no
FROM
  (
    SELECT
       concat ( user_id, ''-@-'', up_date) AS journal_row
    FROM
      sys_coop_journal
    WHERE
      ctl_no = @ctlNo
  ) journal_arr', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, '{"classes": []}'::jsonb, 'CSI透析予約(連携電文の条件詳細)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-604164, '-- 【SQL_CD=-604164】
with journal_dialysis_journal as (
  SELECT
    journal_arr.journal_row,
    coalesce(mst_job.is_doctor, '''') AS is_doctor
  FROM
    (
      SELECT
        REGEXP_SPLIT_TO_TABLE(@journalArrString, ''-@@@-'') as journal_row
    ) as journal_arr
    LEFT JOIN mst_job ON split_part(journal_arr.journal_row, ''-@-'', 3) = mst_job.job_cd :: text
)
SELECT
  STRING_AGG(
    array_to_string(
      ARRAY [
        journal_row,
        is_doctor
      ],
      ''-@-''
    ),
    ''-@@@-''
  ) AS journal_arr_string
FROM
  journal_dialysis_journal', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, '{"classes": []}'::jsonb, 'CSI透析予約(連携電文の条件詳細)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": -604163, "field_name": "journal_arr_string", "replace_var": "@journalArrString"}]'::jsonb);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-604159, '-- 【SQL_CD=-604159】
with ind_dialysis_ind as (
  SELECT
    ind_arr.ind_row,
    personal_info_decrypt(mst_personal_user.job_cd) as job_cd
  FROM
    (
      SELECT
        REGEXP_SPLIT_TO_TABLE(@indArrString, ''-@@@-'') as ind_row
    ) as ind_arr
    LEFT JOIN mst_personal_user ON split_part(ind_arr.ind_row, ''-@-'', 1) = mst_personal_user.user_id :: text
)
SELECT
  STRING_AGG(
    array_to_string(
      ARRAY [
        ind_row,
        job_cd
      ],
      ''-@-''
    ),
    ''-@@@-''
  ) AS ind_arr_string
FROM
  ind_dialysis_ind', 3, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, '{"classes": []}'::jsonb, 'CSI透析予約(連携電文の条件詳細)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": -604158, "field_name": "ind_arr_string", "replace_var": "@indArrString"}]'::jsonb);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-604102, '-- 【SQL_CD=-604102】
with ind_dialysis_medi as (
  SELECT
    medi_arr.medi_row,
    personal_info_decrypt(mst_personal_user.job_cd) as job_cd
  FROM
    (
      SELECT
        REGEXP_SPLIT_TO_TABLE(@mediArrString, ''-@@@-'') as medi_row
    ) as medi_arr
    LEFT JOIN mst_personal_user ON split_part(medi_arr.medi_row, ''-@-'', 1) = mst_personal_user.user_id :: text
)
SELECT
  STRING_AGG(
    array_to_string(
      ARRAY [
        medi_row,
        job_cd
      ],
      ''-@-''
    ),
    ''-@@@-''
  ) AS medi_arr_string
FROM
  ind_dialysis_medi', 3, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, '{"classes": []}'::jsonb, 'CSI透析予約(連携電文の投薬詳細)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": -604101, "field_name": "medi_arr_string", "replace_var": "@mediArrString"}]'::jsonb);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-604101, '-- 【SQL_CD=-604101】
SELECT
  STRING_AGG(medi_arr.medi_row :: text, ''-@@@-'') as medi_arr_string
FROM
  (
    SELECT
       concat ( info ->> ''ind_user_id'', ''-@-'', info ->> ''upd_user_id'', ''-@-'', ord_main.up_date) AS medi_row
    FROM
      ord_main
      CROSS JOIN LATERAL json_array_elements (ord_main.ind_medi_info :: json) info
    WHERE
      ord_no = @ordNo
  ) medi_arr', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, '{"classes": []}'::jsonb, 'CSI透析予約(連携電文の投薬詳細)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-604103, '-- 【SQL_CD=-604103】
with ind_dialysis_medi as (
  SELECT
    medi_arr.medi_row,
    coalesce(mst_job.is_doctor, '''') AS is_doctor
  FROM
    (
      SELECT
        REGEXP_SPLIT_TO_TABLE(@mediArrString, ''-@@@-'') as medi_row
    ) as medi_arr
    LEFT JOIN mst_job ON split_part(medi_arr.medi_row, ''-@-'', 4) = mst_job.job_cd :: text
)
SELECT
  STRING_AGG(
    array_to_string(
      ARRAY [
        medi_row,
        is_doctor
      ],
      ''-@-''
    ),
    ''-@@@-''
  ) AS medi_arr_string
FROM
  ind_dialysis_medi', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, '{"classes": []}'::jsonb, 'CSI透析予約(連携電文の投薬詳細)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": -604102, "field_name": "medi_arr_string", "replace_var": "@mediArrString"}]'::jsonb);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-604150, '-- 【SQL_CD=-604150】
SELECT
  STRING_AGG(cond_arr.cond_row :: text, ''-@@@-'') as cond_arr_string
FROM
  (
    SELECT
      regexp_split_to_table(
        array_to_string(
          ARRAY [ concat ( ''001-@-透析開始時刻-@-'', ord.ind_treat_start_time, ''-@--@-'', ''-@-'', ord.up_ind_user_id, ''-@-'', ord.up_user_id, ''-@-'', ord.up_date , ''-@-'' ),

         concat ( ''002-@-透析時間-@-'', ord.ind_cond_info -> ''1'' ->> ''value'', ''-@--@-分'', ''-@-'', ord.ind_cond_info -> ''1'' ->> ''ind_user_id'', ''-@-'', ord.ind_cond_info -> ''1'' ->> ''upd_user_id'', ''-@-'', ord.up_date , ''-@-'' ),

         concat ( ''003-@-VA-@-'', TRIM ( mva.in_hospital_cd_1 ), ''-@-'', ord.ind_cond_info -> ''2'' ->> ''value_name_1'', ''-@-'', ''-@-'', ord.ind_cond_info -> ''2'' ->> ''ind_user_id'', ''-@-'', ord.ind_cond_info -> ''2'' ->> ''upd_user_id'', ''-@-'', ord.up_date , ''-@-'' ),

         concat ( ''004-@-DW-@-'', physical ->> ''dw'', ''-@-'', ''-@-'', ''kg'', ''-@-'', ord.up_ind_user_id, ''-@-'', ord.up_user_id, ''-@-'', ord.up_date , ''-@-'' ),

         concat ( ''005-@-目標体重-@-'', ord.ind_cond_info -> ''3'' ->> ''value'', ''-@-'', ''-@-'', ''kg'', ''-@-'', ord.ind_cond_info -> ''3'' ->> ''ind_user_id'', ''-@-'', ord.ind_cond_info -> ''3'' ->> ''upd_user_id'', ''-@-'', ord.up_date , ''-@-'' ),

         concat ( ''006-@-治療方法-@-'', mtt.in_hospital_cd_a1, ''-@-'', mtt.treatment_name, ''-@-'', ''-@-'', ord.up_ind_user_id, ''-@-'', ord.up_user_id, ''-@-'', ord.up_date , ''-@-'', mtt.device_mode ) ],
          ''-@@-''
        ),
        ''-@@-''
      ) AS cond_row
    FROM
      ord_main AS ord
      LEFT OUTER JOIN mst_treatment AS mtt ON mtt.treatment_cd = ord.ind_treatment_cd
      LEFT OUTER JOIN mst_va AS mva ON mva.va_cd = TO_NUMBER(
        ord.ind_cond_info -> ''2'' ->> ''value'',
        ''999999999999''
      )
      LEFT OUTER JOIN pat_unique AS puq ON puq.pat_id = ord.pat_id
      CROSS JOIN LATERAL json_array_elements (puq.physical_info :: json) physical
    WHERE
      physical ->> ''exam_date'' = (
        SELECT
          MAX (physical2 ->> ''exam_date'')
        FROM
          pat_unique puq2
          CROSS JOIN LATERAL json_array_elements (puq2.physical_info :: json) physical2
        WHERE
          physical2 ->> ''exam_date'' <= ord.treat_date
          AND ord.pat_id = puq2.pat_id
      )
      AND ord.ord_no = @ordNo
  ) cond_arr
WHERE
  (
    LENGTH (split_part(cond_arr.cond_row, ''-@-'', 3)) > 0
    OR LENGTH (split_part(cond_arr.cond_row, ''-@-'', 9)) > 0
  )
  AND split_part(cond_arr.cond_row, ''-@-'', 1) IN (''001'', ''002'', ''003'', ''004'', ''005'', ''006'')', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, '{"classes": []}'::jsonb, 'CSI透析予約(連携電文の条件詳細)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-604151, '-- 【SQL_CD=-604151】
with ind_dialysis_cond as (
  SELECT
    cond_arr.cond_row,
    personal_info_decrypt(mst_personal_user.job_cd) as job_cd
  FROM
    (
      SELECT
        REGEXP_SPLIT_TO_TABLE(@condArrString, ''-@@@-'') as cond_row
    ) as cond_arr
    LEFT JOIN mst_personal_user ON split_part(cond_arr.cond_row, ''-@-'', 6) = mst_personal_user.user_id :: text
)
SELECT
  STRING_AGG(
    array_to_string(
      ARRAY [
        cond_row,
        job_cd
      ],
      ''-@-''
    ),
    ''-@@@-''
  ) AS cond_arr_string
FROM
  ind_dialysis_cond', 3, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, '{"classes": []}'::jsonb, 'CSI透析予約(連携電文の条件詳細)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": -604150, "field_name": "cond_arr_string", "replace_var": "@condArrString"}]'::jsonb);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-604152, '-- 【SQL_CD=-604152】
with ind_dialysis_cond as (
  SELECT
    cond_arr.cond_row,
    coalesce(mst_job.is_doctor, '''') AS is_doctor
  FROM
    (
      SELECT
        REGEXP_SPLIT_TO_TABLE(@condArrString, ''-@@@-'') as cond_row
    ) as cond_arr
    LEFT JOIN mst_job ON split_part(cond_arr.cond_row, ''-@-'', 10) = mst_job.job_cd :: text
)
SELECT
  STRING_AGG(
    array_to_string(
      ARRAY [
        cond_row,
        is_doctor
      ],
      ''-@-''
    ),
    ''-@@@-''
  ) AS cond_arr_string
FROM
  ind_dialysis_cond', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, '{"classes": []}'::jsonb, 'CSI透析予約(連携電文の条件詳細)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": -604151, "field_name": "cond_arr_string", "replace_var": "@condArrString"}]'::jsonb);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-604107, '-- 【SQL_CD=-604107】
with ind_dialysis_schedule AS (
  SELECT
    schedule.schedule_row,
    coalesce(mst_job.is_doctor, '''') AS is_doctor
  FROM
    (
      SELECT
        @scheduleString AS schedule_row
    ) AS schedule
    LEFT JOIN mst_job ON split_part(schedule.schedule_row, ''-@-'', 4) = mst_job.job_cd :: text
)
SELECT
  array_to_string(
    ARRAY [
        schedule_row,
        is_doctor
      ],
    ''-@-''
  ) AS schedule_string
FROM
  ind_dialysis_schedule', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, '{"classes": []}'::jsonb, 'CSI透析予約(連携電文の予約詳細)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": -604106, "field_name": "schedule_string", "replace_var": "@scheduleString"}]'::jsonb);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-604105, '-- 【SQL_CD=-604105】
SELECT
  concat (
    ind_schedule_user_info ->> ''ind_user_id'',
    ''-@-'',
    ind_schedule_user_info ->> ''upd_user_id'',
    ''-@-'',
    up_date
  ) AS schedule_string
FROM
  ord_main
WHERE
  ord_no = @ordNo', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, '{"classes": []}'::jsonb, 'CSI透析予約(連携電文の予約詳細)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-607002, 'SELECT
  personal_info_decrypt(job_cd) as job_cd
  FROM mst_personal_user
  WHERE user_id = @upIndUserId', 3, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'MIRAIs_rst_dial_医師フラグ取得事前SQL', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": -444, "field_name": "up_ind_user_id", "replace_var": "@upIndUserId"}]'::jsonb);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-603102, '-- 【SQL_CD=-603102】
WITH mst_course_info AS (
  SELECT
    mst_course.course_cd :: text as main_course_cd
  , mst_course.in_hospital_cd_1
  FROM
    mst_course
  WHERE
    mst_course.facility_cd = ''@facilityCd''
    AND is_del = ''0''
    AND ''@medicalCareInfo.mainCourseCd'' = mst_course.in_hospital_cd_1
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
    AND ''@medicalCareInfo.wardCd'' = mst_ward.in_hospital_cd_1
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
      , TO_NUMBER(NULLIF((SELECT main_course_cd FROM mst_course_info), ''''), ''FM999999999'')
      , ''dialysis_course_cd''
      , TO_NUMBER(NULLIF(''@medicalCareInfo.dialysisCourseCd'', ''''), ''FM999999999'')
      , ''ward_cd''
      , TO_NUMBER(NULLIF((SELECT ward_cd FROM mst_ward_info), ''''), ''FM999999999'')
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
)', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)患者プロファイル_患者基本情報の新規', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": 1002, "field_name": "pat_memo_info", "replace_var": "@patMemoInfo"}, {"sql_cd": 1003, "field_name": "infect_info", "replace_var": "@infectInfo"}, {"sql_cd": 1004, "field_name": "addition_info", "replace_var": "@additioninfo"}]'::jsonb);