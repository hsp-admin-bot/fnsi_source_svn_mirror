delete from "sys_data_set" where "sql_cd" in (-200001, -444, -445, -446, -447, -448, -449, -450, -451);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-444, ' WITH staff_info AS (
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
  WHERE
    ord.ord_no = @ordNo 
  AND pat.pat_id = @patId ', 2, '[]', '0', '{"applications": [4]}', '{"classes": []}', 'CSI透析実績(透析実績履歴)', '2020-07-31 18:29:49', '2020-07-31 18:29:49', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-445, ' SELECT
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
   AND is_del = ''0''', 2, '[]', '0', '{"applications": [4]}', '{"classes": []}', 'CSI透析実績(透析困難コメント_基本情報部分)', '2020-07-31 18:29:49', '2020-07-31 18:29:49', '[{"sql_cd": -446, "field_name": "dial_diff_cd", "replace_var": "@dialDiffCd"}]');
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-446, ' SELECT
   info->>''ctl_no'' as ctl_no,
   info->>''dial_diff_cd'' as dial_diff_cd,
   info->>''is_main'' as is_main,
   info->>''is_dial_diff'' as is_dial_diff,
   info->>''reg_date'' as reg_date
 FROM
   pat_personal_main
   CROSS JOIN LATERAL json_array_elements ( pat_personal_main.dial_diff_com_info :: json ) info 
 WHERE
   is_del = ''0'' 
   AND pat_id = @patId
   order by info->>''is_main'' desc
   limit 1', 3, '[]', '0', '{"applications": [4]}', '{"classes": []}', 'CSI透析実績(透析困難コメント_事前取得_基本情報部分)', '2020-07-31 18:29:49', '2020-07-31 18:29:49', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-447, 'WITH item_name AS (
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
ORDER BY item_name.fnw_cd ASC', 2, '[]', '0', '{"applications": [4]}', '{"classes": []}', 'CSI透析実績(透析条件)', '2020-07-31 18:29:49', '2020-07-31 18:29:49', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-448, ' SELECT
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
   info ->> ''ctl_no'' ASC', 2, '[]', '0', '{"applications": [4]}', '{"classes": []}', 'CSI透析実績(透析困難コメント_詳細部分)', '2020-07-31 18:29:49', '2020-07-31 18:29:49', '[{"sql_cd": -449, "field_name": "dial_diff_com_info", "replace_var": "@dialDiffComInfo"}]');
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-449, ' SELECT
  dial_diff_com_info ::TEXT as dial_diff_com_info
 FROM
   pat_personal_main
 WHERE
   is_del = ''0'' 
   AND pat_id = @patId', 3, '[]', '0', '{"applications": [4]}', '{"classes": []}', 'CSI透析実績(透析困難コメント_事前取得_詳細部分)', '2020-07-31 18:29:49', '2020-07-31 18:29:49', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-450, 'SELECT
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
', 2, '[]', '0', '{"applications": [4]}', '{"classes": []}', 'CSI透析実績(投薬履歴)', '2020-07-31 18:29:49', '2020-07-31 18:29:49', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-451, 'WITH rst_complaint_info AS ( 
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
  , CAST(info.tmedi ->> ''row_no'' AS INT) ASC', 2, '[]', '0', '{"applications": [4]}', '{"classes": []}', 'CSI透析実績(愁訴処置)', '2020-07-31 18:29:49', '2020-07-31 18:29:49', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-200001, ' select
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
 pat_id = @patId', 3, '[]', '0', '{"applications": [4]}', '{"classes": []}', 'CSI', '2020-07-31 18:29:49', '2020-07-31 18:29:49', NULL);
