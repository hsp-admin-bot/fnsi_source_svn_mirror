delete from ntss.sys_data_set where ntss.sys_data_set.sql_cd in (-604172, -604169);


INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-604172, '-- 【SQL_CD=-604172】
WITH  ord_main_max AS (
  (
    SELECT
      ord.ord_no,
      del_date,
      ord.del_date as up_date,
      ord.rst_cond_info,
      ord.rst_treatment_cd,
      ord.rst_start_date
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
  )
  UNION
  (
    SELECT
      ord.ord_no,
      null AS del_date,
      ord.rst_edition_date as up_date,
      ord.rst_cond_info,
      ord.rst_treatment_cd,
      ord.rst_start_date
    FROM
      ord_main AS ord,
      sys_coop_journal as journal
    WHERE
      ord.ord_no = @ordNo
      AND journal.ctl_no = @ctlNo
      AND ord.ord_no = journal.ord_no
  )
  ORDER BY
    up_date DESC
  LIMIT
    1
),
item_name AS (
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
    ord_main_max AS ord
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
    ord_main_max AS ord
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
    ord_main_max AS ord
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
  AND mmx.mix_info IS NULL

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
  cond.ntss_cd = item_name.ntss_cd', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, '{"classes": []}'::jsonb, 'CSI透析実績(透析条件)', '2023-10-05 22:41:33.168', CURRENT_TIMESTAMP, NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-604169, '  -- 【SQL_CD=-604169】
  WITH  ord_main_max AS (
    (
      SELECT
        ord.ord_no,
        del_date,
        ord.del_date as up_date,
        ord.rst_kur_cd,
        ord.rst_bed_cd, 
        ord.rst_ward_cd,
        ord.rst_fn_dialysis_no,
        ord.rst_edition,
        ord.rst_running_time,
        ord.up_ind_user_id,
        ord.pat_id 
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
    )
    UNION
    (
      SELECT
        ord.ord_no,
        null AS del_date,
        ord.rst_edition_date as up_date,
        ord.rst_kur_cd,
        ord.rst_bed_cd,
        ord.rst_ward_cd,
        ord.rst_fn_dialysis_no,
        ord.rst_edition,
        ord.rst_running_time,
        ord.up_ind_user_id,
        ord.pat_id 
      FROM
        ord_main AS ord,
        sys_coop_journal as journal
      WHERE
        ord.ord_no = @ordNo
        AND journal.ctl_no = @ctlNo
        AND ord.ord_no = journal.ord_no
    )
    ORDER BY
      up_date DESC
    LIMIT
      1
  ),
  staff_info AS (
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
      ord_main_max AS ord
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
      pat.pat_id = @patId ', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, '{"classes": []}'::jsonb, 'CSI透析実績(透析条件)', '2023-12-21 19:53:52.709', CURRENT_TIMESTAMP, NULL);
