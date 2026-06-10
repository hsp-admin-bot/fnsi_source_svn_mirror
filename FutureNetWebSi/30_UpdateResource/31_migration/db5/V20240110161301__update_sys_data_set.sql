DELETE FROM "ntss"."sys_data_set" WHERE sql_cd IN (-303003);
INSERT INTO ntss.sys_data_set (sql_cd,"sql",db_class,detail,can_repeat,use_application,report_class,memo,reg_date,up_date,pre_sql_info) VALUES
	 (-303003,'SELECT
  array_to_json(ARRAY_AGG(T.col)) AS addition_info
FROM
  ( 
    SELECT
       json_build_object(''cd'', A.addition_cd, ''reg_date'', A.reg_date + cast( ''-9 hours'' as INTERVAL ), ''is_enable'', ''1'') AS col
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
      AND NOT (
        A.addition_class = ''12'' AND A.addition_kind <> ''1''
      )
    ORDER BY
      ms.INDEX
  ) AS T',2,'[{}]'::jsonb,'0','{"applications": [4]}'::jsonb,NULL,'外部連携用の[患者基本情報→加算情報]デフォルト値の取得','2023-11-22 23:25:32.58',CURRENT_TIMESTAMP,NULL);
