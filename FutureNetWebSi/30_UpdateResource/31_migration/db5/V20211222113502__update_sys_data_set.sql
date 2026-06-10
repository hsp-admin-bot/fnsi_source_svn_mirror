UPDATE "ntss"."sys_data_set" SET "sql" = 'WITH pre_dat AS ( 
  SELECT
    ord.ord_no
    , SUBSTR( ( CASE WHEN ord.ind_treat_start_time IS NULL OR ord.ind_treat_start_time = '''' THEN COALESCE( NULLIF(mkr.kur_standard_start_time, ''''), ''000000'') ELSE ord.ind_treat_start_time END) || ''000000'', 1, 6) AS start_time
    , TO_TIMESTAMP( ord.treat_date || SUBSTR( ( CASE WHEN ord.ind_treat_start_time IS NULL OR ord.ind_treat_start_time = '''' THEN COALESCE( NULLIF(mkr.kur_standard_start_time, ''''), ''000000'') ELSE ord.ind_treat_start_time END) || ''000000'', 1, 6), ''YYYYMMDDHH24MISS'') AS start_date_time
    , TO_NUMBER( COALESCE( NULLIF(ord.ind_cond_info -> ''1'' ->> ''value'', ''''), ''0'') , ''999999'') AS dialysis_time 
  FROM
    ord_main AS ord 
    LEFT OUTER JOIN mst_kur AS mkr ON mkr.kur_cd = ord.ind_kur_cd
  WHERE
    ord.ord_no = @ordNo
) 
SELECT
  ord.treat_date AS start_date
  , pre.start_time
  , TO_CHAR( ( pre.start_date_time + (dialysis_time * INTERVAL ''1 minute'')) , ''YYYYMMDD'') AS end_date
  , TO_CHAR( ( pre.start_date_time + (dialysis_time * INTERVAL ''1 minute'')) , ''HH24MISS'') AS end_time 
  , COALESCE ( pat.medical_care_info ->> ''dialysis_start_date'', '''' ) AS dialysis_start_date 
  , COALESCE ( ord.ind_bed_cd, 0 ) AS ind_bed_cd
  , COALESCE ( mbd.in_hospital_cd_1, ''0'' ) AS hospital_bed_cd
  , TO_CHAR(ord.up_date, ''YYYYMMDD'') AS update_date
  , TO_CHAR(ord.up_date, ''HH24MISS'') AS update_time
  , COALESCE ( ord.ind_treatment_cd, 0 ) AS ind_treatment_cd
  , COALESCE ( mtt.in_hospital_cd_a1, '''' ) AS hospital_treatment_cd
  , CASE WHEN ord.up_ind_user_id IS NOT NULL THEN ord.up_ind_user_id
      WHEN ord.ind_schedule_user_info->>''upd_user_id'' IS NOT NULL AND ord.ind_schedule_user_info->>''upd_user_id'' != '''' THEN CAST(ord.ind_schedule_user_info->>''upd_user_id'' AS INTEGER)
      ELSE ord.up_user_id END AS up_ind_user_id
FROM
  ord_main AS ord
  INNER JOIN pre_dat AS pre ON ord.ord_no = pre.ord_no 
  INNER JOIN pat_main AS pat ON ord.pat_id = pat.pat_id AND pat.is_del = ''0''
  LEFT OUTER JOIN mst_bed AS mbd ON mbd.bed_cd = ord.ind_bed_cd
  LEFT OUTER JOIN mst_treatment AS mtt ON mtt.treatment_cd = ord.ind_treatment_cd
WHERE
  ord.ord_no = @ordNo', "up_date" = CURRENT_TIMESTAMP WHERE "sql_cd" = -207;
UPDATE "ntss"."sys_data_set" SET "sql" = 'WITH department_source_info AS ( 
  -- 依頼科取得先:0：患者基本情報の診療科、1：連携設定（※）の依頼科コード
  SELECT
    CASE TRIM(ini_info ->> ''value'') 
      WHEN '''' THEN TRIM(ini_info ->> ''default_v'') 
      WHEN ''NULL'' THEN TRIM(ini_info ->> ''default_v'') 
      ELSE TRIM(ini_info ->> ''value'') 
      END AS department_source 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) AS ini_info 
  WHERE
    ini.is_del = ''0'' 
    AND ini.facility_cd = @facilityCd
    AND TRIM(ini_info ->> ''key1'') = ''NECIS_COMMON'' 
    AND TRIM(ini_info ->> ''key2'') = ''DEPARTMENT_SOURCE''
) 
, indicate_staff_source_info AS ( 
  -- 依頼医取得先:0：患者基本情報の担当医１・２、1：透析予定(透析条件)の指示者、2：連携設定（※）の指示医のコード
  SELECT
    CASE TRIM(ini_info ->> ''value'') 
      WHEN '''' THEN TRIM(ini_info ->> ''default_v'') 
      WHEN ''NULL'' THEN TRIM(ini_info ->> ''default_v'') 
      ELSE TRIM(ini_info ->> ''value'') 
      END AS indicate_staff_source 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) AS ini_info 
  WHERE
    ini.is_del = ''0'' 
    AND ini.facility_cd = @facilityCd 
    AND TRIM(ini_info ->> ''key1'') = ''NECIS_COMMON'' 
    AND TRIM(ini_info ->> ''key2'') = ''INDICATE_STAFF_SOURCE''
) 
, department_code_info AS ( 
  -- 依頼科コード:連携設定
  SELECT
    CASE TRIM(ini_info ->> ''value'') 
      WHEN '''' THEN TRIM(ini_info ->> ''default_v'') 
      WHEN ''NULL'' THEN TRIM(ini_info ->> ''default_v'') 
      ELSE TRIM(ini_info ->> ''value'') 
      END AS department_code 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) AS ini_info 
  WHERE
    ini.is_del = ''0'' 
    AND ini.facility_cd = @facilityCd
    AND TRIM(ini_info ->> ''key1'') = ''NECIS_SCHE_DIAL'' 
    AND TRIM(ini_info ->> ''key2'') = ''DEPARTMENT_CODE''
) 
, indicate_staff_code_info AS ( 
  -- 依頼医コード:連携設定
  SELECT
    CASE TRIM(ini_info ->> ''value'') 
      WHEN '''' THEN TRIM(ini_info ->> ''default_v'') 
      WHEN ''NULL'' THEN TRIM(ini_info ->> ''default_v'') 
      ELSE TRIM(ini_info ->> ''value'') 
      END AS indicate_staff_code 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) AS ini_info 
  WHERE
    ini.is_del = ''0'' 
    AND ini.facility_cd = @facilityCd
    AND TRIM(ini_info ->> ''key1'') = ''NECIS_SCHE_DIAL'' 
    AND TRIM(ini_info ->> ''key2'') = ''INDICATE_STAFF_CODE''
) 
, staff_info AS ( 
  SELECT
    pat.pat_id
    , CAST(info ->> ''staff_cd'' AS TEXT) AS staff_cd 
  FROM
    pat_main AS pat 
    LEFT JOIN LATERAL json_array_elements(pat.charge_staff_info ::json) info ON info ->> ''ctl_no'' IS NOT NULL 
  WHERE
    pat.pat_id = @patId 
  ORDER BY
    info ->> ''is_main'' DESC, info ->> ''is_charge'' DESC, info ->> ''is_puncture'' DESC, info ->> ''ctl_no'' ASC 
  LIMIT 1
) 
, DepartmentStaffInfoSrc AS ( 
  SELECT
    -- 診療科マスタ
    pat.medical_care_info ->> ''main_course_cd'' AS course_cd
    , COALESCE(NULLIF(TRIM(course.in_hospital_cd_1), ''''), '''') AS hospital_course_cd 
    -- 医師
    , staff.staff_cd AS staff_cd 
    -- 指示者
    , CASE 
      WHEN ord.up_ind_user_id IS NOT NULL 
        THEN ord.up_ind_user_id ::TEXT 
      WHEN ord.ind_schedule_user_info ->> ''upd_user_id'' IS NOT NULL AND ord.ind_schedule_user_info ->> ''upd_user_id'' != '''' 
        THEN ord.ind_schedule_user_info ->> ''upd_user_id'' ::TEXT 
      ELSE ord.up_user_id ::TEXT 
      END AS up_ind_user_id 
  FROM
    ord_main AS ord 
    LEFT OUTER JOIN pat_main AS pat ON pat.pat_id = ord.pat_id AND pat.pat_id = @patId
    LEFT OUTER JOIN staff_info AS staff ON pat.pat_id = staff.pat_id 
    LEFT OUTER JOIN mst_course AS course ON course.course_cd ::TEXT = pat.medical_care_info ->> ''main_course_cd'' 
  WHERE
    ord.ord_no = @ordNo
) 
, DepartmentStaffInfoNoDefault AS (
  SELECT
    CASE COALESCE( NULLIF( ( SELECT department_source FROM department_source_info) , '''') , ''NULL'') 
      WHEN ''0'' THEN info.hospital_course_cd  --院内コード
      WHEN ''1'' THEN ( SELECT department_code FROM department_code_info)  --連携設定「依頼科コード」
      ELSE info.hospital_course_cd 
      END AS DepartmentCode
    , CASE COALESCE( NULLIF( ( SELECT indicate_staff_source FROM indicate_staff_source_info) , '''') , ''NULL'') 
      WHEN ''0'' THEN info.staff_cd  -- 担当医
      WHEN ''1'' THEN info.up_ind_user_id  -- 指示者
      WHEN ''2'' THEN ( SELECT indicate_staff_code FROM indicate_staff_code_info) --連携設定「依頼医コード」
      ELSE COALESCE(NULLIF(info.staff_cd, ''''), info.up_ind_user_id) 
      END AS IndicateStaffCode 
  FROM
    DepartmentStaffInfoSrc AS info
) 
SELECT
  COALESCE(NULLIF(info.DepartmentCode, ''''), (SELECT department_source FROM department_source_info)) AS department_code
  , COALESCE(NULLIF(info.IndicateStaffCode, ''''), (SELECT indicate_staff_source FROM indicate_staff_source_info)) AS indicate_staff_code
FROM
  DepartmentStaffInfoNoDefault AS info', "up_date" = CURRENT_TIMESTAMP WHERE "sql_cd" = -208;
UPDATE "ntss"."sys_data_set" SET "sql" = 'WITH ini_data AS ( 
  SELECT
    TRIM(ini_info ->> ''key2'') ::TEXT AS key2
    , ( 
      CASE TRIM(ini_info ->> ''value'') 
        WHEN '''' THEN TRIM(ini_info ->> ''default_v'') 
        WHEN ''NULL'' THEN TRIM(ini_info ->> ''default_v'') 
        ELSE TRIM(ini_info ->> ''value'') 
        END
    ) ::TEXT AS ini_value 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) AS ini_info 
  WHERE
    ini.is_del = ''0'' 
    AND ini.facility_cd = @facilityCd 
    AND TRIM(ini_info ->> ''key1'') = ''NECIS_SCHE_DIAL''
) 
, ini_unit AS ( 
  SELECT
    TRIM(ini_info ->> ''key2'') ::TEXT AS key2
    , ( 
      CASE TRIM(ini_info ->> ''value'') 
        WHEN '''' THEN TRIM(ini_info ->> ''default_v'') 
        WHEN ''NULL'' THEN TRIM(ini_info ->> ''default_v'') 
        ELSE TRIM(ini_info ->> ''value'') 
        END
    ) ::TEXT AS ini_value 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) AS ini_info 
  WHERE
    ini.is_del = ''0'' 
    AND ini.facility_cd = @facilityCd 
    AND TRIM(ini_info ->> ''key1'') = ''NECIS_CONV_UNIT''
) 
, dialysis_detail AS ( 
  -- (1) DW
  SELECT
    (SELECT ini_value FROM ini_data WHERE key2 = ''DW_FUNCTION_ID'') AS function_id
    , (SELECT ini_value FROM ini_data WHERE key2 = ''DW_ITEM_CODE'') AS item_code
    , (physical ->> ''dw'') ::TEXT AS quantity
    , (SELECT ini_value FROM ini_data WHERE key2 = ''WEIGHT_UNIT'') AS unit_code 
  FROM
    ord_main AS ord 
    LEFT OUTER JOIN pat_unique AS puq ON puq.pat_id = ord.pat_id AND puq.is_del = ''0''
    CROSS JOIN LATERAL json_array_elements(puq.physical_info ::json) physical 
  WHERE
    ord.ord_no = @ordNo 
    AND physical ->> ''exam_date'' = ( 
      SELECT
        MAX(physical2 ->> ''exam_date'') 
      FROM
        ord_main ord2
        , pat_unique puq2 
        CROSS JOIN LATERAL json_array_elements(puq2.physical_info ::json) physical2 
      WHERE
        ord2.ord_no = @ordNo 
        AND puq2.pat_id = @patId 
        AND TO_CHAR(CAST(physical2 ->> ''exam_date'' AS TIMESTAMP), ''YYYYMMDD'') <= ord.treat_date 
        AND COALESCE(physical2 ->> ''dw'', ''ZERO'') <> ''ZERO'' 
        AND ord.pat_id = puq2.pat_id
        AND puq2.is_del = ''0''
    ) 
  -- (2) 前体重:無し
  -- (3) 後体重:無し
  -- (4) VA
  UNION 
  SELECT
    COALESCE(NULLIF(TRIM(mva.in_hospital_cd_2), ''''), ((SELECT ini_value FROM ini_data WHERE key2 = ''VA_FUNCTION_ID''))) AS function_id
    , TRIM(mva.in_hospital_cd_1) AS item_code
    , '''' AS quantity
    , '''' AS unit_code 
  FROM
    ord_main AS ord 
    LEFT OUTER JOIN mst_va AS mva ON mva.va_cd = TO_NUMBER(NULLIF(ord.ind_cond_info -> ''2'' ->> ''value'', ''0''), ''FM999999999999'')
  WHERE
    ord.ord_no = @ordNo
    AND ord.ind_cond_info -> ''2'' ->> ''value'' IS NOT NULL 
  -- (5) ダイアライザ
  UNION 
  SELECT
    COALESCE(NULLIF(TRIM(mdr.in_hospital_cd_2), ''''), ((SELECT ini_value FROM ini_data WHERE key2 = ''DIALYZER_FUNCTION_ID''))) AS function_id
    , TRIM(mdr.in_hospital_cd_1) AS item_code
    , ''1'' AS quantity
    , (SELECT ini_value FROM ini_data WHERE key2 = ''DIALYZER_UNIT'') AS unit_code 
  FROM
    ord_main AS ord 
    LEFT OUTER JOIN mst_dialyzer AS mdr ON mdr.dialyzer_cd = TO_NUMBER(ord.ind_cond_info -> ''5'' ->> ''value'', ''FM999999999999'')  
  WHERE
    ord.ord_no = @ordNo 
    AND ord.ind_cond_info -> ''5'' ->> ''value'' IS NOT NULL 
  -- (6) 抗凝固剤(単体薬剤時)
  UNION 
  SELECT
    COALESCE(NULLIF(TRIM(med25.in_hospital_cd_2), ''''), (( SELECT ini_value FROM ini_data WHERE key2 = ''ANTICOAGULANT_FUNCTION_ID''))) AS function_id
    , TRIM(med25.in_hospital_cd_1) AS item_code
    , TO_CHAR(TO_NUMBER( NULLIF(ord.ind_cond_info -> ''26'' ->> ''value'', ''0''), ''FM999999999999'') + TO_NUMBER(NULLIF(ord.ind_cond_info -> ''28'' ->> ''value'', ''0''), ''FM999999999999'') , ''FM999999999999.00'') AS quantity
    , (SELECT ini_value FROM ini_unit WHERE key2 = med25.unit) AS unit_code 
  FROM
    ord_main AS ord 
    LEFT OUTER JOIN mst_medicine AS med25 ON med25.medicine_cd = TO_NUMBER(ord.ind_cond_info -> ''25'' ->> ''value'', ''FM999999999999'') 
  WHERE
    ord.ord_no = @ordNo 
    AND ord.ind_cond_info -> ''25'' ->> ''medicine_type'' ::TEXT = ''1'' 
    AND ord.ind_cond_info -> ''15'' ->> ''value'' IS NOT NULL 
  -- (7) 抗凝固剤(セット薬剤時)
  UNION 
  SELECT
    COALESCE(NULLIF(TRIM(mmx.in_hospital_cd_2), ''''), ((SELECT ini_value FROM ini_data WHERE key2 = ''ANTICOAGULANT_FUNCTION_ID''))) AS function_id
    , TRIM(mmx.in_hospital_cd_1) AS item_code
    , NULLIF(jsonb_array_length(mmx.mix_info), 0) ::TEXT AS quantity
    , (SELECT ini_value FROM ini_unit WHERE key2 = mmx.unit) AS unit_code 
  FROM
    ord_main AS ord 
    LEFT OUTER JOIN mst_medicine_mix AS mmx ON mmx.medicine_mix_cd = TO_NUMBER(ord.ind_cond_info -> ''25'' ->> ''value'', ''FM999999999999'') 
  WHERE
    ord.ord_no = @ordNo 
    AND ord.ind_cond_info -> ''25'' ->> ''medicine_type'' ::TEXT = ''2'' 
    AND ord.ind_cond_info -> ''15'' ->> ''value'' IS NOT NULL 
  -- (8) 薬剤(単体薬剤時) ：投与薬剤
  UNION 
  SELECT
    COALESCE(NULLIF(TRIM(mmd.in_hospital_cd_2), ''''), ((SELECT ini_value FROM ini_data WHERE key2 = ''MEDICINE_FUNCTION_ID''))) AS function_id
    , TRIM(mmd.in_hospital_cd_1) AS item_code
    , TO_CHAR( 
      TO_NUMBER(medi ->> ''amount'', ''FM999999999999.99''), ''FM999999999999.00'') AS quantity
    , (SELECT ini_value FROM ini_unit WHERE  key2 = mmd.unit) AS unit_code 
  FROM
    ord_main AS ord 
    CROSS JOIN LATERAL json_array_elements(ord.ind_medi_info ::json) medi 
    LEFT OUTER JOIN mst_medicine AS mmd ON mmd.medicine_cd = TO_NUMBER(medi ->> ''cd'', ''FM999999999999'') 
  WHERE
    ord.ord_no = @ordNo 
    AND medi ->> ''medicine_type'' = ''1'' 
  --AND COALESCE(mmd.in_hospital_cd_1, ''ZERO'') <> ''ZERO''
  -- (8) 薬剤(単体薬剤時) ：透析条件の透析液
  UNION 
  SELECT
    COALESCE(NULLIF(TRIM(med15.in_hospital_cd_2), ''''), ((SELECT ini_value FROM ini_data WHERE key2 = ''MEDICINE_FUNCTION_ID''))) AS function_id
    , TRIM(med15.in_hospital_cd_1) AS item_code
    , TO_CHAR(TO_NUMBER(NULLIF(ord.ind_cond_info -> ''17'' ->> ''value'', ''0''), ''FM999999999999'') , ''FM999999999999.00'') AS quantity
    , ( SELECT ini_value FROM ini_unit WHERE key2 = med15.unit) AS unit_code 
  FROM
    ord_main AS ord 
    LEFT OUTER JOIN mst_medicine AS med15 ON med15.medicine_cd = TO_NUMBER(ord.ind_cond_info -> ''15'' ->> ''value'', ''FM999999999999'') 
  WHERE
    ord.ord_no = @ordNo 
    AND ord.ind_cond_info -> ''15'' ->> ''medicine_type'' ::TEXT = ''1'' 
    AND ord.ind_cond_info -> ''15'' ->> ''value'' IS NOT NULL 
  -- (8) 薬剤(単体薬剤時) ：透析条件の補液
  UNION 
  SELECT
    COALESCE(NULLIF(TRIM(med19.in_hospital_cd_2), ''''), ((SELECT ini_value FROM ini_data WHERE key2 = ''MEDICINE_FUNCTION_ID''))) AS function_id
    , TRIM(med19.in_hospital_cd_1) AS item_code
    , TO_CHAR(TO_NUMBER(NULLIF(ord.ind_cond_info -> ''22'' ->> ''value'', ''0''), ''FM999999999999'') , ''FM999999999999.00'') AS quantity
    , (SELECT ini_value FROM ini_unit WHERE key2 = med19.unit) AS unit_code 
  FROM
    ord_main AS ord 
    LEFT OUTER JOIN mst_medicine AS med19 ON med19.medicine_cd = TO_NUMBER( ord.ind_cond_info -> ''19'' ->> ''value'', ''FM999999999999'') 
  WHERE
    ord.ord_no = @ordNo 
    AND ord.ind_cond_info -> ''19'' ->> ''medicine_type'' ::TEXT = ''1'' 
    AND ord.ind_cond_info -> ''19'' ->> ''value'' IS NOT NULL 
  -- (9) 薬剤(セット薬剤時)  ：投与薬剤
  UNION
  SELECT
    COALESCE(NULLIF(TRIM(mmx.in_hospital_cd_2), ''''), ((SELECT ini_value FROM ini_data WHERE key2 = ''MEDICINE_FUNCTION_ID''))) AS function_id
    , TRIM(mmx.in_hospital_cd_1) AS item_code
    , NULLIF(jsonb_array_length(mmx.mix_info), 0) ::TEXT AS quantity
    , (SELECT ini_value FROM ini_unit WHERE key2 = mmx.unit) AS unit_code 
  FROM
    ord_main AS ord 
    CROSS JOIN LATERAL json_array_elements(ord.ind_medi_info ::json) medi 
    LEFT OUTER JOIN mst_medicine_mix AS mmx ON mmx.medicine_mix_cd = TO_NUMBER(medi ->> ''cd'', ''FM999999999999'')
  WHERE
    ord.ord_no = @ordNo 
    AND medi ->> ''medicine_type'' = ''2'' 
  --AND COALESCE(mmd.in_hospital_cd_1, ''ZERO'') <> ''ZERO''
  -- (9) 薬剤(セット薬剤時)  ：透析条件の透析液
  UNION 
  SELECT
    COALESCE(NULLIF(TRIM(mmmx.in_hospital_cd_2), ''''), ((SELECT ini_value FROM ini_data WHERE key2 = ''MEDICINE_FUNCTION_ID''))) AS function_id
    , TRIM(mmmx.in_hospital_cd_1) AS item_code
    , TO_CHAR(TO_NUMBER(NULLIF(ord.ind_cond_info -> ''17'' ->> ''value'', ''0''), ''FM999999999999'') , ''FM999999999999.00'') AS quantity
    , (SELECT ini_value FROM ini_unit WHERE key2 = mmmx.unit) AS unit_code 
  FROM
    ord_main AS ord 
    LEFT OUTER JOIN mst_medicine_mix AS mmmx ON mmmx.medicine_mix_cd = TO_NUMBER( ord.ind_cond_info -> ''15'' ->> ''value'', ''FM999999999999'')  
  WHERE
    ord.ord_no = @ordNo 
    AND ord.ind_cond_info -> ''15'' ->> ''medicine_type'' ::TEXT = ''2'' 
    AND ord.ind_cond_info -> ''15'' ->> ''value'' IS NOT NULL 
  -- (9) 薬剤(セット薬剤時)  ：透析条件の補液
  UNION 
  SELECT
    COALESCE(NULLIF(TRIM(mmmmx.in_hospital_cd_2), ''''), ((SELECT ini_value FROM ini_data WHERE key2 = ''MEDICINE_FUNCTION_ID''))) AS function_id
    , TRIM(mmmmx.in_hospital_cd_1) AS item_code
    , TO_CHAR(TO_NUMBER(NULLIF(ord.ind_cond_info -> ''22'' ->> ''value'', ''0''), ''FM999999999999'') , ''FM999999999999.00'') AS quantity
    , (SELECT ini_value FROM ini_unit WHERE key2 = mmmmx.unit) AS unit_code 
  FROM
    ord_main AS ord 
    LEFT OUTER JOIN mst_medicine_mix AS mmmmx ON mmmmx.medicine_mix_cd = TO_NUMBER( ord.ind_cond_info -> ''19'' ->> ''value'', ''FM999999999999'') 
  WHERE
    ord.ord_no = @ordNo 
    AND ord.ind_cond_info -> ''19'' ->> ''medicine_type'' ::TEXT = ''2'' 
    AND ord.ind_cond_info -> ''19'' ->> ''value'' IS NOT NULL 
  -- (10) 穿刺針:透析条件のA針
  UNION 
  SELECT
    COALESCE(NULLIF(TRIM(meq.in_hospital_cd_2), ''''), ((SELECT ini_value FROM ini_data WHERE key2 = ''NEEDLE_FUNCTION_ID''))) AS function_id
    , TRIM(meq.in_hospital_cd_1) AS item_code
    , ''1.00'' AS quantity
    , (SELECT ini_value FROM ini_unit WHERE key2 = meq.unit) AS unit_code 
  FROM
    ord_main AS ord 
    LEFT OUTER JOIN mst_equipment AS meq ON meq.equipment_cd = TO_NUMBER( ord.ind_cond_info -> ''9'' ->> ''value'', ''FM999999999999'')  
  WHERE
    ord.ord_no = @ordNo 
    AND ord.ind_cond_info -> ''9'' ->> ''value'' IS NOT NULL 
  -- (10) 穿刺針:透析条件のV針
  UNION 
  SELECT
    COALESCE(NULLIF(TRIM(meq.in_hospital_cd_2), ''''), ((SELECT ini_value FROM ini_data WHERE key2 = ''NEEDLE_FUNCTION_ID''))) AS function_id
    , TRIM(meq.in_hospital_cd_1) AS item_code
    , ''1.00'' AS quantity
    , (SELECT ini_value FROM ini_unit WHERE key2 = meq.unit) AS unit_code 
  FROM
    ord_main AS ord 
    LEFT OUTER JOIN mst_equipment AS meq ON meq.equipment_cd = TO_NUMBER( ord.ind_cond_info -> ''10'' ->> ''value'', ''FM999999999999'') 
  WHERE
    ord.ord_no = @ordNo 
    AND ord.ind_cond_info -> ''10'' ->> ''value'' IS NOT NULL 
  -- (10) 穿刺針:透析条件のSN針
  UNION 
  SELECT
    COALESCE( NULLIF(TRIM(meq.in_hospital_cd_2), ''''), ((SELECT ini_value FROM ini_data WHERE key2 = ''NEEDLE_FUNCTION_ID''))) AS function_id
    , TRIM(meq.in_hospital_cd_1) AS item_code
    , ''1.00'' AS quantity
    , (SELECT ini_value FROM ini_unit WHERE key2 = meq.unit) AS unit_code 
  FROM
    ord_main AS ord 
    LEFT OUTER JOIN mst_equipment AS meq ON meq.equipment_cd = TO_NUMBER( ord.ind_cond_info -> ''11'' ->> ''value'', ''FM999999999999'') 
  WHERE
    ord.ord_no = @ordNo 
    AND ord.ind_cond_info -> ''11'' ->> ''value'' IS NOT NULL 
  -- (10) 穿刺針:医材内の穿刺針
  UNION 
  SELECT
    COALESCE(NULLIF(TRIM(meq.in_hospital_cd_2), ''''), ((SELECT ini_value FROM ini_data WHERE key2 = ''MEDICINE_FUNCTION_ID''))) AS function_id
    , TRIM(meq.in_hospital_cd_1) AS item_code
    , (equip ->> ''amount'') ::TEXT AS quantity
    , (SELECT ini_value FROM ini_unit WHERE key2 = meq.unit) AS unit_code 
  FROM
    ord_main AS ord 
    CROSS JOIN LATERAL json_array_elements(ord.ind_equip_info ::json) equip 
    LEFT OUTER JOIN mst_equipment AS meq ON meq.equipment_cd = TO_NUMBER(equip ->> ''cd'', ''FM999999999999'') 
  WHERE
    ord.ord_no = @ordNo 
    AND equip ->> ''class_type'' IN (''2'', ''3'') 
  -- (11) 使用材料:医材内の穿刺針を除く
  UNION 
  SELECT
    COALESCE( NULLIF(TRIM(meq.in_hospital_cd_2), ''''), ((SELECT ini_value FROM ini_data WHERE key2 = ''EQUIP_FUNCTION_ID''))) AS function_id
    , TRIM(meq.in_hospital_cd_1) AS item_code
    , (equip ->> ''amount'') ::TEXT AS quantity
    , (SELECT ini_value FROM ini_unit WHERE key2 = meq.unit) AS unit_code 
  FROM
    ord_main AS ord 
    CROSS JOIN LATERAL json_array_elements(ord.ind_equip_info ::json) equip 
    LEFT OUTER JOIN mst_equipment AS meq ON meq.equipment_cd = TO_NUMBER(equip ->> ''cd'', ''FM999999999999'') 
  WHERE
    ord.ord_no = @ordNo 
    AND equip ->> ''class_type'' NOT IN (''2'', ''3'') 
  -- (12) 使用材料(透析条件の吸着カラム)
  UNION 
  SELECT
    COALESCE(NULLIF(TRIM(meq.in_hospital_cd_2), ''''), ((SELECT ini_value FROM ini_data WHERE key2 = ''EQUIP_FUNCTION_ID''))) AS function_id
    , TRIM(meq.in_hospital_cd_1) AS item_code
    , ''1'' AS quantity
    , (SELECT ini_value FROM ini_unit WHERE key2 = meq.unit) AS unit_code 
  FROM
    ord_main AS ord 
    LEFT OUTER JOIN mst_equipment AS meq ON meq.equipment_cd = TO_NUMBER( ord.ind_cond_info -> ''6'' ->> ''value'', ''FM999999999999'')  
  WHERE
    ord.ord_no = @ordNo 
    AND ord.ind_cond_info -> ''6'' ->> ''value'' IS NOT NULL 
  -- (12) 使用材料(透析条件の1次膜)
  UNION 
  SELECT
    COALESCE(NULLIF(TRIM(meq.in_hospital_cd_2), ''''), ((SELECT ini_value FROM ini_data WHERE key2 = ''EQUIP_FUNCTION_ID''))) AS function_id
    , TRIM(meq.in_hospital_cd_1) AS item_code
    , ''1'' AS quantity
    , (SELECT ini_value FROM ini_unit WHERE key2 = meq.unit) AS unit_code 
  FROM
    ord_main AS ord 
    LEFT OUTER JOIN mst_equipment AS meq ON meq.equipment_cd = TO_NUMBER( ord.ind_cond_info -> ''7'' ->> ''value'', ''FM999999999999'') 
  WHERE
    ord.ord_no = @ordNo 
    AND ord.ind_cond_info -> ''7'' ->> ''value'' IS NOT NULL 
  -- (12) 使用材料(透析条件の2次膜)
  UNION 
  SELECT
    COALESCE(NULLIF(TRIM(meq.in_hospital_cd_2), ''''), ((SELECT ini_value FROM ini_data WHERE key2 = ''EQUIP_FUNCTION_ID''))) AS function_id
    , TRIM(meq.in_hospital_cd_1) AS item_code
    , ''1'' AS quantity
    , (SELECT ini_value FROM ini_unit WHERE key2 = meq.unit) AS unit_code 
  FROM
    ord_main AS ord 
    LEFT OUTER JOIN mst_equipment AS meq ON meq.equipment_cd = TO_NUMBER( ord.ind_cond_info -> ''8'' ->> ''value'', ''FM999999999999'') 
  WHERE
    ord.ord_no = @ordNo 
    AND ord.ind_cond_info -> ''8'' ->> ''value'' IS NOT NULL 
  -- (13) 加算(システム設定(ID=134：レセプトメモ表示切替)が存在しない、または「0：透析困難理由」の場合):無し
  -- (14) 加算(システム設定(ID=134：レセプトメモ表示切替)が「1：レセプトメモ」の場合):無し
  -- (15) その他項目(除水量):無し
  ORDER BY
    function_id ASC, item_code ASC
) 
SELECT
  ROW_NUMBER() OVER (ORDER BY function_id) AS seq_no
  , dialysis_detail.* 
FROM
  dialysis_detail 
ORDER BY
  function_id ASC, item_code ASC', "up_date" = CURRENT_TIMESTAMP WHERE "sql_cd" = -209;
