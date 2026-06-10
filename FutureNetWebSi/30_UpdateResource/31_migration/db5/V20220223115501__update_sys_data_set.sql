delete from "sys_data_set" where "sql_cd" in (1901,1902,1903,1904,3102);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (1901, 'SELECT
  coop_save_no,
  facility_cd,
  pat_id,
  save_1,
  save_2,
  save_3,
  save_4,
  save_5,
  save_6,
  save_7,
  save_8,
  save_9,
  save_10,
  is_disp,
  is_del,
  user_id,
  up_date,
  reg_date
FROM
  pat_coop_detail 
WHERE
  facility_cd = @facilityCd 
  AND pat_id = @patId
  AND is_del = ''0''
  AND save_2->>''ord_no''::TEXT = @save2.ordNo', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)富士通の患者連携情報取得', '2022-01-07 18:21:46', CURRENT_TIMESTAMP, NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (1902, 'WITH pkg_info AS(
  SELECT
    1 AS order_no
    , CASE TRIM(ini_info ->> ''value'') 
      WHEN '''' THEN COALESCE(NULLIF(TRIM(ini_info ->> ''default_v''), ''''), ''GX'') 
      ELSE TRIM(ini_info ->> ''value'') 
      END AS pkg_name 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) AS ini_info 
  WHERE
    ini.is_del = ''0'' 
    AND ini.facility_cd = ''@facilityCd ''
    AND TRIM(ini_info ->> ''key1'') = ''FJI_COM_INFO'' 
    AND TRIM(ini_info ->> ''key2'') = ''PKG'' 
  UNION
  SELECT
    2 AS order_no
    , ''GX'' AS pkg_name
  ORDER BY order_no ASC LIMIT 1
)
INSERT INTO pat_coop_detail 
(
  facility_cd,
  pat_id,
  save_1,
  save_2,
  save_3,
  save_4,
  save_5,
  save_6,
  save_7,
  save_8,
  save_9,
  save_10,
  is_disp,
  is_del,
  user_id,
  up_date,
  reg_date
)
VALUES ( 
  ''@facilityCd''
  , @patId
  , json_build_object(''pkg'', (SELECT pkg_name FROM pkg_info))
  , json_build_object(''ord_no'', NULLIF(''@save2.ordNo'', '''')
      , ''insu_no'', NULLIF(''@save2.insuNo'', '''')
      , ''dr_id'', NULLIF(''@save2.drId'', '''')
      , ''coop_pat_id'', NULLIF(''@save2.coopPatId'', '''')
    )
  , json_build_object(''des_cd'', NULLIF(''@save3.desCd'', '''')
      , ''diff_cd'', NULLIF(''@save3.diffCd'', '''')
      , ''add_cd'', NULLIF(''@save3.addCd'', '''')
      , ''treat_cd'', NULLIF(''@save3.treatCd'', '''')
      , ''comment'', NULLIF(''@save3.comment'', '''')
      , ''dw'', NULLIF(''@save3.dw'', '''')
      , ''ind_dr'', NULLIF(''@save3.indDr'', '''')
      , ''start_date'', NULLIF(''@save3.startDate'', '''')
    )
  , NULL
  , NULL
  , NULL
  , NULL
  , NULL
  , NULL
  , NULL
  , ''1''
  , ''0''
  , ''-1''
  , CURRENT_TIMESTAMP
  , CURRENT_TIMESTAMP
)', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)富士通の患者連携情報登録', '2022-01-07 18:21:46', CURRENT_TIMESTAMP, NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (1903, 'UPDATE pat_coop_detail 
SET
  save_2 = json_build_object(''ord_no'', NULLIF(''@save2.ordNo'', '''')
      , ''insu_no'', NULLIF(''@save2.insuNo'', '''')
      , ''dr_id'', NULLIF(''@save2.drId'', '''')
      , ''coop_pat_id'', NULLIF(''@save2.coopPatId'', '''')
    )
  , save_3 = json_build_object(''des_cd'', NULLIF(''@save3.desCd'', '''')
      , ''diff_cd'', NULLIF(''@save3.diffCd'', '''')
      , ''add_cd'', NULLIF(''@save3.addCd'', '''')
      , ''treat_cd'', NULLIF(''@save3.treatCd'', '''')
      , ''comment'', NULLIF(''@save3.comment'', '''')
      , ''dw'', NULLIF(''@save3.dw'', '''')
      , ''ind_dr'', NULLIF(''@save3.indDr'', '''')
      , ''start_date'', NULLIF(''@save3.startDate'', '''')
    )
  , up_date = CURRENT_TIMESTAMP
WHERE
  facility_cd = ''@facilityCd'' 
  AND pat_id = @patId
  AND is_del = ''0''
  AND coop_save_no = @coopSaveNo
  AND save_2->>''ord_no''::TEXT = ''@save2.ordNo''', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)富士通の患者連携情報更新', '2022-01-07 18:21:46', CURRENT_TIMESTAMP, NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (1904, 'UPDATE pat_coop_detail 
SET
  is_del = ''1'' 
WHERE
  facility_cd = ''@facilityCd'' 
  AND pat_id = @patId
  AND is_del = ''0''
  AND save_2->>''ord_no''::TEXT = ''@save2.ordNo''', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)富士通の患者連携情報削除(論理:削除フラグ=''1'')', '2022-01-07 18:21:46', CURRENT_TIMESTAMP, NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (3102, 'WITH new_data_idx AS(
  SELECT
    info.idx
  FROM
    pat_main AS pat 
    CROSS JOIN LATERAL json_array_elements(pat.charge_staff_info :: json)  WITH ORDINALITY AS info(staff_info, idx)
  WHERE    
    pat.is_del = ''0'' 
    AND pat.pat_id = @patId
    AND pat.facility_cd = ''@facilityCd'' 
    AND (staff_info->>''staff_cd'' :: TEXT) = ''@chargeStaffInfo.staffCd''  
  ORDER BY idx ASC LIMIT 1
)
, new_data AS(
  SELECT
    CASE WHEN new.idx > 0 THEN -1 ELSE info.idx END AS idx
    , staff_info->>''ctl_no'' AS ctl_no 
    , staff_info->>''disp_order'' AS disp_order 
    , staff_info->>''staff_cd'' AS staff_cd 
    , CASE WHEN new.idx > 0 THEN ''1'' ELSE staff_info->>''is_main'' END AS is_main  
    , staff_info->>''is_charge'' AS is_charge 
    , staff_info->>''is_puncture'' AS is_puncture 
  FROM
    pat_main AS pat 
    CROSS JOIN LATERAL json_array_elements(pat.charge_staff_info :: json)  WITH ORDINALITY AS info(staff_info, idx)
    LEFT JOIN new_data_idx AS new ON info.idx = new.idx
  WHERE
    pat.is_del = ''0'' 
    AND pat.pat_id = @patId
    AND pat.facility_cd = ''@facilityCd'' 
  UNION
  SELECT
    -1 AS idx
    , COALESCE(NULLIF(''@nextCtlNo2'', ''''), ''1'') AS ctl_no 
    , ''0'' AS disp_order 
    , ''@chargeStaffInfo.staffCd'' AS staff_cd 
    , COALESCE(NULLIF(''@chargeStaffInfo.isMain'', ''''), ''1'') AS is_main 
    , COALESCE(NULLIF(''@chargeStaffInfo.isCharge'', ''''), ''0'') AS is_charge 
    , COALESCE(NULLIF(''@chargeStaffInfo.isPuncture'', ''''), ''0'') AS is_puncture 
  WHERE
    (SELECT idx FROM new_data_idx) IS NULL
  ORDER BY idx ASC
)
, json_data AS (
  SELECT json_build_object(''ctl_no'', row_number() over(order by idx ASC, ctl_no ASC),
    ''disp_order'', row_number() over(order by idx ASC, ctl_no ASC),
    ''staff_cd'', TO_NUMBER(staff_cd, ''FM9999999999999999''),
    ''is_main'', is_main,
    ''is_charge'', is_charge,
    ''is_puncture'', is_puncture) AS new_data
  FROM new_data
)
UPDATE pat_main 
SET
  charge_staff_info = (SELECT array_to_json(ARRAY_AGG(new_data)) FROM json_data)
  , up_date = CURRENT_TIMESTAMP
WHERE
  is_del = ''0'' 
  AND pat_id = @patId 
  AND facility_cd = ''@facilityCd''', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)富士通の初回申し込み→担当スタッフ情報', '2020-05-25 18:21:40.841', CURRENT_TIMESTAMP, NULL);
