DELETE FROM ntss.sys_data_set
WHERE sql_cd IN (-604167, -604168, -604176, -604179, -604189, -604193);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-604167, '-- 【SQL_CD=-604167】
SELECT
  medi ->> ''no'' AS ctl_no,
  medi ->> ''effect_flg'' AS effect_flg,
  case
    when mmd.in_hospital_cd_1 is not null then TRIM(mmd.in_hospital_cd_1) --薬剤
    else TRIM(mmx.in_hospital_cd_1) -- 調製薬剤
  end AS medicine_cd,
  case
    when mmd.in_hospital_cd_1 is not null then TRIM(mmd.in_hospital_cd_1) --薬剤
    else TRIM(mmx.in_hospital_cd_1) -- 調製薬剤
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
  mmc.in_hospital_cd_1 AS mmc_in_hospital_cd_1,
  medi ->> ''class_type'' AS class_type,
  cast(
    cast(medi ->> ''effect_date'' as timestamp) AS TEXT
  ) AS effect_date,
  case 
    when mmx.mix_info IS NULL then ''0''
    else ''1''
  end AS set_medicine_flg,
  case
    when mmd.medicine_cd is not null then (medi ->> ''amount'') :: numeric  --薬剤
    else 1 -- 調製薬剤
  end as amount,
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
  LEFT OUTER JOIN mst_medicine_class AS mmc --薬剤分類マスタ
  ON mmc.class_cd = COALESCE(mmd.class_cd, mmx.class_cd)
WHERE
  medi ->> ''effect_flg'' = ''1''
  AND ord.ord_no = @ordNo
  AND medi ->> ''no'' = @ctlNo', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, '{"classes": []}'::jsonb, 'CSI透析実績(透析条件)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);

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
  CASE
    WHEN mmd.in_hospital_cd_1 IS NOT NULL THEN TRIM(mmd.in_hospital_cd_1) --薬剤
    ELSE TRIM(mmx.in_hospital_cd_1) -- 調製薬剤
  END AS medicine_cd,
  info.tmedi ->> ''procedure_cd'' AS procedure_cd,
  CASE
    WHEN mmx.medicine_mix_cd IS NOT NULL THEN 1 --調整薬剤使用量
    ELSE (info.tmedi ->> ''amount'') :: numeric
  END AS amount,
  info.tmedi ->> ''unit'' AS unit,
  CONCAT(LPAD(info.tmedi ->> ''ctl_no'', 3, ''0''), LPAD(info.tmedi ->> ''row_no'', 3, ''0'')) AS result_no,
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
        WHEN info.tmedi ->> ''linkStartDate'' IS NULL THEN  COALESCE(CAST(link_info.tmedi ->> ''occur_date'' AS TIMESTAMP), CAST(info.tmedi ->> ''occur_date'' AS TIMESTAMP)) - CAST(info.tmedi ->> ''occur_date'' AS TIMESTAMP)
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
  mmc.in_hospital_cd_1 AS mmc_in_hospital_cd_1,
  CASE
    WHEN mmd.in_hospital_cd_1 IS NOT NULL THEN TRIM(mmd.in_hospital_cd_1) --薬剤
    ELSE TRIM(mmx.in_hospital_cd_1) -- 調製薬剤
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
  and info.tmedi ->> ''row_no'' = comp_info.complaint ->> ''row_no''
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
  LEFT OUTER JOIN mst_medicine_class AS mmc --薬剤分類マスタ
  ON mmc.class_cd = COALESCE(mmd.class_cd, mmx.class_cd)
WHERE
  CAST(info.tmedi ->> ''ctl_no'' AS TEXT) || ''_'' || CAST(info.tmedi ->> ''row_no'' AS TEXT) = @dispNo', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, '{"classes": []}'::jsonb, 'CSI透析実績(透析条件)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-604176, '-- 【SQL_CD=-604176】
SELECT
  med2.medicine_cd AS mmd_medicine_cd,
  med2.is_shot AS mmd_is_shot,
  TRIM(med2.in_hospital_cd_1) AS mmd_in_hospital_cd_1,
  TRIM(med2.in_hospital_cd_2) AS mmd_in_hospital_cd_2,
  @amount AS amount,
  mmc.in_hospital_cd_1 AS mmc_in_hospital_cd_1
FROM
  mst_medicine AS med2 -- 調製薬剤_薬剤マスタ
  LEFT JOIN mst_medicine_class AS mmc
  ON mmc.class_cd = med2.class_cd
WHERE
  med2.medicine_cd  = TO_NUMBER(@medicineCd, ''999999999999'')', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, '{"classes": []}'::jsonb, 'CSI透析実績(医療材料)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-604179, '-- 【SQL_CD=-604179】
SELECT
  med2.medicine_cd AS mmd_medicine_cd,
  med2.is_shot AS mmd_is_shot,
  TRIM(med2.in_hospital_cd_1) AS mmd_in_hospital_cd_1,
  TRIM(med2.in_hospital_cd_2) AS mmd_in_hospital_cd_2,
  @amount AS amount,
  mmc.in_hospital_cd_1 AS mmc_in_hospital_cd_1
FROM
  mst_medicine AS med2 -- 調製薬剤_薬剤マスタ
  LEFT JOIN mst_medicine_class AS mmc
  ON mmc.class_cd = med2.class_cd
WHERE
  med2.medicine_cd  = TO_NUMBER(@medicineCd, ''999999999999'')', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, '{"classes": []}'::jsonb, 'CSI透析実績(医療材料)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-604189, '-- 【SQL_CD=-604189】
WITH latest_journal AS (
    SELECT convert_from(dump, ''SJIS'')::xml AS dump_xml
    FROM sys_coop_journal
    WHERE facility_cd = @facilityCd
        AND ord_no = @ordNo
        AND pat_id = @patId
        AND coop_cd = ''rst_dial''
        AND crud in (''C'', ''U'')
        AND ana_result = ''9''
        AND coop_result = ''9''
        AND ctl_no < @ctlNo
    ORDER BY ctl_no DESC
    LIMIT 1
),
treatment_nodes AS (
    SELECT
        row_number() OVER () AS seq,
        treat_node
    FROM (
        SELECT unnest(xpath(''//RST_DIALYSIS_TREATMENT_HST'', dump_xml)) AS treat_node
        FROM latest_journal
    ) expanded
)
SELECT
    ''10''                                                                                                AS detail_id,
    seq,
    @ctlNo                                                                                              AS journal_ctl_no,
    @ordNo                                                                                              AS ord_no,
    @facilityCd                                                                                         AS facility_cd,
    @patId                                                                                              AS pat_id,
    (xpath(''/RST_DIALYSIS_TREATMENT_HST/@CTL_NO'', treat_node))[1]::text                                AS disp_no,
    (xpath(''/RST_DIALYSIS_TREATMENT_HST/@NAME'', treat_node))[1]::text                                  AS disp_name,
    (xpath(''/RST_DIALYSIS_TREATMENT_HST/TREAT_MEDICINE_CD/text()'', treat_node))[1]::text               AS medicine_cd,
    (xpath(''/RST_DIALYSIS_TREATMENT_HST/PROCEDURE_CD/text()'', treat_node))[1]::text                    AS procedure_cd,
    (xpath(''/RST_DIALYSIS_TREATMENT_HST/AMOUNT/text()'', treat_node))[1]::text                          AS amount,
    (xpath(''/RST_DIALYSIS_TREATMENT_HST/TREAT_CLASS/text()'', treat_node))[1]::text                     AS treat_class,
    (xpath(''/RST_DIALYSIS_TREATMENT_HST/RESULT_NO/text()'', treat_node))[1]::text                       AS result_no,
    (xpath(''/RST_DIALYSIS_TREATMENT_HST/OCCUR_DATE/text()'', treat_node))[1]::text                      AS occur_date_start,
    (xpath(''/RST_DIALYSIS_TREATMENT_HST/OXYGEN_AMOUNT/text()'', treat_node))[1]::text                   AS oxygen_amount,
    (xpath(''/RST_DIALYSIS_TREATMENT_HST/OXYGEN_START/text()'', treat_node))[1]::text                    AS oxygen_start_new,
    (xpath(''/RST_DIALYSIS_TREATMENT_HST/OXYGEN_TIME/text()'', treat_node))[1]::text                     AS oxygen_time_new,
    (xpath(''/RST_DIALYSIS_TREATMENT_HST/MST_MEDICINE/SHOT/text()'', treat_node))[1]::text               AS mmd_is_shot,
    (xpath(''/RST_DIALYSIS_TREATMENT_HST/MST_MEDICINE/IN_HOSPITAL_CD/text()'', treat_node))[1]::text     AS mmd_in_hospital_cd_1,
    (xpath(''/RST_DIALYSIS_TREATMENT_HST/MST_MEDICINE/IN_HOSPITAL_CD2/text()'', treat_node))[1]::text    AS mmd_in_hospital_cd_2,
    (xpath(''/RST_DIALYSIS_TREATMENT_HST/MST_MEDICINE/MEDICINE_CD/text()'', treat_node))[1]::text        AS mmd_medicine_cd,
    (xpath(''/RST_DIALYSIS_TREATMENT_HST/MST_MEDICINE/MEDICINE_GROUP_CD/text()'', treat_node))[1]::text  AS mmd_class_cd,
    (xpath(''/RST_DIALYSIS_TREATMENT_HST/MST_PROCEDURE/IN_HOSPITAL_CD1/text()'', treat_node))[1]::text   AS mp_in_hospital_cd_1,
    (xpath(''/RST_DIALYSIS_TREATMENT_HST/MST_PROCEDURE/IN_HOSPITAL_CD2/text()'', treat_node))[1]::text   AS mp_in_hospital_cd_2,
    (xpath(''/RST_DIALYSIS_TREATMENT_HST/MST_SET_MEDI_NAME/IN_HOSPITAL_CD2/text()'', treat_node))[1]::text AS mix_med_in_hospital_cd2
FROM treatment_nodes
ORDER BY seq;', 2, '[]'::jsonb, '1', '{"applications": [4]}'::jsonb, '{"classes": []}'::jsonb, 'CSI透析実績 最新新規電文のdumpタグ取得(RST_DIALYSIS_TREATMENT_HST)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-604193, '-- 【SQL_CD=-604193】
SELECT
    @e01 AS e01,
    @e02 AS e02,
    @e03 AS e03,
    @e04 AS e04,
    @e05 AS e05,
    @e06 AS e06,
    @e07 AS e07,
    @e08 AS e08,
    @e09 AS e09,
    @e10 AS e10,
    @e11 AS e11,
    @e12 AS e12,
    @e13 AS e13,
    @e14 AS e14,
    @e15 AS e15,
    @e16 AS e16,
    @e17 AS e17', 2, '[]'::jsonb, '1', '{"applications": [4]}'::jsonb, '{"classes": []}'::jsonb, 'CSI透析実績 最新新規電文のdumpタグ取得(RST_DIALYSIS_MEDICATION_HST/RST_DIALYSIS_TREATMENT_HST 明細)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);