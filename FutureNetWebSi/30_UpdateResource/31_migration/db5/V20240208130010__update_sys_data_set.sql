DELETE FROM ntss.sys_data_set
WHERE sql_cd IN (-604172,-604173,-604166)
;

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
  cond.ntss_cd = item_name.ntss_cd
', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, '{"classes": []}'::jsonb, 'CSI透析実績(透析条件)', '2023-09-28 13:12:38.000', CURRENT_TIMESTAMP, NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-604173, '-- 【SQL_CD=-604173】
with rst_cond_info AS (
  SELECT
    jsonb_object_keys (ord.rst_cond_info) AS ntss_cd,
    ord.rst_cond_info -> jsonb_object_keys (ord.rst_cond_info) AS rst_cond_info
  FROM
    ord_main AS ord
  WHERE
    ord.ord_no = @ordNo
)
SELECT
  info ->> ''cd'' as equip_cd,
  info ->> ''name'' as equip_name,
  info ->> ''class_type'' as class_type,
  info ->> ''class_cd'' as class_cd,
  info ->> ''class_name'' as class_name,
  info ->> ''amount'' as amount,
  info ->> ''unit'' as unit,
  info ->> ''cop_order_no'' as cop_order_no,
  info ->> ''is_editable'' as is_editable,
  meqa.reg_date,
  meqa.in_hospital_cd_1,
  meqa.in_hospital_cd_2
FROM
  ord_main as ord
  cross join lateral json_array_elements (ord.rst_equip_info :: json) info
  LEFT OUTER JOIN mst_equipment AS meqa -- 医療材料マスタ
  ON meqa.equipment_cd = TO_NUMBER(info ->> ''cd'', ''999999999999'')
WHERE
  ord.ord_no = @ordNo
UNION ALL
SELECT
  cond.rst_cond_info ->> ''value'' as equip_cd,
  cond.rst_cond_info ->> ''value_name_1'' as equip_name,
  cond.rst_cond_info ->> ''input_class'' as class_type,
  meqa.class_cd::text as class_cd,
  meqc.class_name,
  ''1'' as amount,
  meqa.unit,
  cond.rst_cond_info ->> ''cop_order_no'' as cop_order_no,
  cond.rst_cond_info ->> ''is_editable'' as is_editable,
  meqa.reg_date,
  meqa.in_hospital_cd_1,
  meqa.in_hospital_cd_2
FROM 
  rst_cond_info as cond
  INNER JOIN mst_equipment AS meqa -- 医療材料マスタ
  ON meqa.equipment_cd = TO_NUMBER(cond.rst_cond_info ->> ''value'', ''999999999999'')
  AND cond.ntss_cd in (''9'',''10'',''11'',''13'')
  INNER JOIN mst_equipment_class AS meqc -- 医療材料クラスマスタ
  ON meqa.class_cd = meqc.class_cd 
', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, '{"classes": []}'::jsonb, 'CSI透析実績(医療材料)', '2023-12-07 14:03:17.031', CURRENT_TIMESTAMP, NULL);
