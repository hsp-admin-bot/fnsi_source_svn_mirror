DELETE FROM ntss.sys_data_set
WHERE sql_cd IN (-604167,-604168,-604174,-604175,-604176,-604177,-604178,-604179)
;

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
  end as mp_in_hospital_cd_2,
  null AS medicine_mix_cd
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
  AND medi ->> ''no'' = @ctlNo
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
  ''1'' AS set_medicine_flg,
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
  end as mp_in_hospital_cd_2,
  mmx.medicine_mix_cd
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
  AND medi ->> ''no'' = @ctlNo
  AND mmx.mix_info IS NOT NULL', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, '{"classes": []}'::jsonb, 'CSI透析実績(透析条件)', '2023-09-28 13:12:38.000', CURRENT_TIMESTAMP, NULL);
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
  AND
    complaint ->> ''ctl_no'' = @ctlNo

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
  AND
    tmedi ->> ''ctl_no'' = @ctlNo
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
  info.tmedi ->> ''treat_class'' AS treat_class,
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
  AND ''1'' = info.tmedi ->> ''treat_class''
  LEFT OUTER JOIN mst_medicine_mix AS mmx --調製薬剤マスタ
  ON mmx.medicine_mix_cd = to_number(
    info.tmedi ->> ''treat_medicine_cd'',
    ''999999999999''
  )
  AND ''0'' = info.tmedi ->> ''treat_class''
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
  info.tmedi ->> ''treat_class'' AS treat_class,
  info.tmedi ->> ''treat_cd'' AS treat_cd,
  mmd.medicine_cd :: text AS medicine_cd,
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
  AND ''1'' = info.tmedi ->> ''treat_class''
  LEFT OUTER JOIN mst_medicine_mix AS mmx --調製薬剤マスタ
  ON mmx.medicine_mix_cd = to_number(
    info.tmedi ->> ''treat_medicine_cd'',
    ''999999999999''
  )
  AND ''0'' = info.tmedi ->> ''treat_class''
  LEFT OUTER JOIN mst_procedure AS mp -- 手技マスタ
  ON mp.procedure_cd = to_number(info.tmedi ->> ''procedure_cd'', ''999999999999'')
ORDER BY
  occur_date_start ASC,
  disp_no ASC', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, '{"classes": []}'::jsonb, 'CSI透析実績(透析条件)', '2023-09-28 13:12:38.000', CURRENT_TIMESTAMP, NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-604174, '-- 【SQL_CD=-604174】
SELECT
  ord.ord_no,
  medi ->> ''no'' AS ctl_no,
  ''05'' AS detail_id
FROM
  ord_main AS ord
  CROSS JOIN LATERAL json_array_elements (ord.rst_medi_info :: json) medi
WHERE
  medi ->> ''effect_flg'' = ''1''
  AND ord.ord_no = @ordNo', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, '{"classes": []}'::jsonb, 'CSI透析実績(医療材料)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-604175, '-- 【SQL_CD=-604175】
SELECT
  med2.medicine_cd AS medicine_cd,
  (mix_infoes ->> ''amount'') :: numeric as amount,
  ''06'' AS detail_id
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
  AND ord.ord_no = @ordNo
  AND medi ->> ''no'' = @ctlNo
  AND mmx.mix_info IS NOT NULL', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, '{"classes": []}'::jsonb, 'CSI透析実績(医療材料)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-604176, '-- 【SQL_CD=-604176】
SELECT
  med2.medicine_cd AS mmd_medicine_cd,
  med2.is_shot AS mmd_is_shot,
  TRIM(med2.in_hospital_cd_1) AS mmd_in_hospital_cd_1,
  TRIM(med2.in_hospital_cd_2) AS mmd_in_hospital_cd_2,
  @amount AS amount
FROM
  mst_medicine AS med2 -- 調製薬剤_薬剤マスタ
WHERE
  med2.medicine_cd  = TO_NUMBER(@medicineCd, ''999999999999'')', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, '{"classes": []}'::jsonb, 'CSI透析実績(医療材料)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-604177, '-- 【SQL_CD=-604177】
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
  info.ord_no,
  info.tmedi ->> ''ctl_no'' AS ctl_no,
  ''07'' AS detail_id,
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
  ) AS disp_name
FROM
  rst_treatment_info AS info
  LEFT JOIN rst_treatment_info AS link_info ON info.tmedi ->> ''ctl_no'' = link_info.tmedi ->> ''linkStartDate''
  LEFT JOIN rst_treatment_info AS link_source_info ON info.tmedi ->> ''linkStartDate'' = link_source_info.tmedi ->> ''ctl_no''
  LEFT JOIN rst_complaint_info AS comp_info ON info.tmedi ->> ''ctl_no'' = comp_info.complaint ->> ''ctl_no''
  AND comp_info.complaint ->> ''comp_cd'' IS NOT NULL', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, '{"classes": []}'::jsonb, 'CSI透析実績(医療材料)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-604178, '-- 【SQL_CD=-604178】
WITH rst_complaint_info AS (
  SELECT
    complaint
  FROM
    ord_main AS ord
    CROSS JOIN LATERAL json_array_elements(ord.rst_complaint_info :: json) complaint
  WHERE
    ord.ord_no = @ordNo
  AND
    complaint ->> ''ctl_no'' = @ctlNo

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
  AND
    tmedi ->> ''ctl_no'' = @ctlNo
)
SELECT
  mmd2.medicine_cd AS medicine_cd,
  (mix_infoes ->> ''amount'') :: numeric as amount,
  ''08'' AS detail_id
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
  AND ''1'' = info.tmedi ->> ''treat_class''
  LEFT OUTER JOIN mst_medicine_mix AS mmx --調製薬剤マスタ
  ON mmx.medicine_mix_cd = to_number(
    info.tmedi ->> ''treat_medicine_cd'',
    ''999999999999''
  )
  AND ''0'' = info.tmedi ->> ''treat_class''
  LEFT OUTER JOIN mst_procedure AS mp -- 手技マスタ
  ON mp.procedure_cd = to_number(info.tmedi ->> ''procedure_cd'', ''999999999999'')
  CROSS JOIN lateral json_array_elements (mmx.mix_info :: json) mix_infoes -- 調製薬剤分離
  LEFT OUTER JOIN mst_medicine AS mmd2 -- 調製薬剤_薬剤マスタ
  ON mmd2.medicine_cd = TO_NUMBER(mix_infoes ->> ''cd'', ''999999999999'')', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, '{"classes": []}'::jsonb, 'CSI透析実績(医療材料)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-604179, '-- 【SQL_CD=-604179】
SELECT
  med2.medicine_cd AS mmd_medicine_cd,
  med2.is_shot AS mmd_is_shot,
  TRIM(med2.in_hospital_cd_1) AS mmd_in_hospital_cd_1,
  TRIM(med2.in_hospital_cd_2) AS mmd_in_hospital_cd_2,
  @amount AS amount
FROM
  mst_medicine AS med2 -- 調製薬剤_薬剤マスタ
WHERE
  med2.medicine_cd  = TO_NUMBER(@medicineCd, ''999999999999'')', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, '{"classes": []}'::jsonb, 'CSI透析実績(医療材料)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
