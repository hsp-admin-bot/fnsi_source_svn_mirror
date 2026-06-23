delete from "sys_data_set" where "sql_cd" in (1901,1902,1904,9111,9112);
INSERT INTO "sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (1901, 'SELECT
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
-- add 2023-01-16 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
  coop_version,
-- add 2023-01-16 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
  up_date,
  reg_date
FROM
  pat_coop_detail 
WHERE
  facility_cd = @facilityCd 
-- add 2023-01-16 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
  AND coop_version = @coopVersion
-- add 2023-01-16 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
  AND pat_id = @patId
  AND is_del = ''0''
  AND save_2->>''ord_no''::TEXT = @save2.ordNo', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)富士通の患者連携情報取得', '2022-01-07 18:21:46', CURRENT_TIMESTAMP, NULL);
INSERT INTO "sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (1902, 'WITH pkg_info AS(
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
-- add 2022-12-07 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
    AND COALESCE(ini_info->>''key0'', '''') = ''@key0''
-- add 2022-12-07 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
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
-- add 2023-01-16 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
  coop_version,
-- add 2023-01-16 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
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
-- add 2023-01-16 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
  , ''@coopVersion''
-- add 2023-01-16 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
  , CURRENT_TIMESTAMP
  , CURRENT_TIMESTAMP
)', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)富士通の患者連携情報登録', '2022-01-07 18:21:46', CURRENT_TIMESTAMP, NULL);
INSERT INTO "sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (1904, 'UPDATE pat_coop_detail 
SET
  is_del = ''1'' 
WHERE
  facility_cd = ''@facilityCd'' 
-- add 2023-01-16 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
  AND coop_version = ''@coopVersion''
-- add 2023-01-16 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
  AND pat_id = @patId
  AND is_del = ''0''
  AND save_2->>''ord_no''::TEXT = ''@save2.ordNo''', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)富士通の患者連携情報削除(論理:削除フラグ=''1'')', '2022-01-07 18:21:46', CURRENT_TIMESTAMP, NULL);
INSERT INTO "sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (9111, 'SELECT
    coop_save_no
  , facility_cd
  , pat_id
  , save_1
  , save_2
  , save_3
  , save_4
  , save_5
  , save_6
  , save_7
  , save_8
  , save_9
  , save_10
  , is_disp
  , is_del
  , user_id
-- add 2023-01-16 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
  , coop_version
-- add 2023-01-16 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
  , up_date
  , reg_date
FROM
  pat_coop_detail 
WHERE
  is_del = ''0'' 
  AND pat_id = @patId 
  AND facility_cd = @facilityCd 
-- add 2023-01-16 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
  AND coop_version = @coopVersion
-- add 2023-01-16 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)NECの患者連携情報の取得', '2021-11-23 12:12:12', CURRENT_TIMESTAMP, NULL);
INSERT INTO "sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (9112, 'INSERT INTO pat_coop_detail( 
  facility_cd
  , pat_id
  , save_1
  , save_2
  , save_3
  , save_4
  , save_5
  , save_6
  , save_7
  , save_8
  , save_9
  , save_10
  , is_disp
  , is_del
  , user_id
-- add 2023-01-16 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
  , coop_version
-- add 2023-01-16 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
  , up_date
  , reg_date
) 
VALUES (
  ''@facilityCd''
  , @patId
  , jsonb_build_object(''key_01'',NULLIF(''@save1.key01'', ''''), ''key_02'',NULLIF(''@save1.key02'', ''''), ''key_03'',NULLIF(''@save1.key03'', ''''), ''key_04'',NULLIF(''@save1.key04'', ''''), ''key_05'',NULLIF(''@save1.key05'', ''''), ''key_06'',NULLIF(''@save1.key06'', ''''), ''key_07'',NULLIF(''@save1.key07'', ''''), ''key_08'',NULLIF(''@save1.key08'', ''''), ''key_09'',NULLIF(''@save1.key09'', ''''), ''key_10'',NULLIF(''@save1.key10'', ''''))
  , NULL
  , NULL
  , NULL
  , NULL
  , NULL
  , NULL
  , NULL
  , NULL
  , NULL
  , ''1''
  , ''0''
  , @userId
-- add 2023-01-16 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
  , ''@coopVersion''
-- add 2023-01-16 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
  , CURRENT_TIMESTAMP
  , CURRENT_TIMESTAMP
)', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)NECの患者連携情報の登録', '2021-11-23 12:12:12', CURRENT_TIMESTAMP, NULL);
