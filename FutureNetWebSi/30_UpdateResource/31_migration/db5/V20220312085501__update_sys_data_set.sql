delete from "sys_data_set" where "sql_cd" = 1004;
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (1004, 'SELECT
  array_to_json(ARRAY_AGG(T.col)) AS addition_info
FROM
  ( 
    SELECT
       json_build_object(''is_enable'', ''1'', ''reg_date'', CURRENT_TIMESTAMP, ''cd'', A.addition_cd) AS col
    FROM
      mst_addition A 
      , ( 
        SELECT
          mss.facility_cd
          , ms.*
          , ROW_NUMBER() OVER () AS INDEX 
        FROM
          mst_selector mss 
          CROSS JOIN LATERAL jsonb_to_recordset(mss.order_settings -> ''items'') AS ms(code BIGINT, NAME TEXT) 
        WHERE
          facility_cd = @facilityCd 
          AND master_physical_name = ''mst_addition'' 
      ) ms 
    WHERE
      A.facility_cd = ms.facility_cd 
      AND A.addition_cd = ms.code 
      AND A.is_del = ''0'' 
      AND A.is_disp = ''1'' 
      AND (A.addition_class != ''12'' OR (A.addition_class = ''12'' AND A.addition_kind = ''1''))
    ORDER BY
      ms.INDEX
  ) AS T', 2, '[{}]', '0', '{"applications": [4]}', NULL, '外部連携用の[患者基本情報→加算情報]デフォルト値の取得', '2020-05-25 18:21:40.841', CURRENT_TIMESTAMP, NULL);
