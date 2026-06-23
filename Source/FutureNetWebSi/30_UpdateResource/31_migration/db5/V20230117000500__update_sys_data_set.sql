delete from "sys_data_set" where "sql_cd" in (-99995,-99990,-511);
INSERT INTO "sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-99990, 'WITH journal AS ( 
  SELECT
    COUNT(1) AS CNT 
  FROM
    sys_coop_journal AS coop1 
  WHERE
    EXISTS ( 
      SELECT
        1 
      FROM
        sys_coop_journal AS coop2 
      WHERE
        coop2.ctl_no = @ctlNo
        AND TO_CHAR(coop2.reg_date, ''YYYYMMDD'') = TO_CHAR(coop1.reg_date, ''YYYYMMDD'') 
        AND coop2.coop_cd = coop1.coop_cd
-- add 2023-01-17 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
        AND coop2.coop_version = coop1.coop_version
-- add 2023-01-17 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
    )
) 
SELECT ''Dialysis'' || to_char(CURRENT_TIMESTAMP, ''YYYYMMDDHH24MISS'') || TO_CHAR((journal.CNT - 1)%1000, ''FM099'') || ''.txt'' AS filename FROM journal', 2, '[]', '0', '{"applications": [4]}', NULL, '日機装 透析実績[送信]ファイル名取得(拡張)', '2021-04-20 09:19:08.001', CURRENT_TIMESTAMP, NULL);
INSERT INTO "sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-511, 'with coop_ini as (SELECT COALESCE
                             (NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS header_mode
                  FROM mst_coop_ini AS ini
                           CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info :: json) info
                  WHERE facility_cd = @facilityCd
                    AND is_del = ''0''
                    -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 start
                    AND COALESCE(info->>''key0'','''') = @key0
                    -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 end
                    AND info ->> ''key1'' = ''DIALYSISSEND''
                    AND info ->> ''key2'' = ''HEADER_MODE''
),
     journal as (
         SELECT coop_ord_no
         from sys_coop_journal
         WHERE facility_cd = @facilityCd
-- add 2023-01-17 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
           AND coop_version = @coopVersion
-- add 2023-01-17 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
           AND ord_no = @ordNo
           AND coop_cd = ''rst_dial''
           AND coop_ord_no IS NOT NULL
         union
         select ''0'' as coop_ord_no
         order by coop_ord_no DESC
         LIMIT 1 )
select case
           when journal.coop_ord_no = ''0'' then ''            ''
           else
               (case
                   when coop_ini.header_mode = ''1''
                       then journal.coop_ord_no
                   else ''            ''
                   end)
           end coop_ord_no
FROM coop_ini,
     journal
', 2, '[{}]', '0', '{"applications": [4]}', '{"classes": []}', 'NKK)  透析実績：透析番号取得（削除）', '2022-09-05 08:14:41.911', CURRENT_TIMESTAMP, NULL);
INSERT INTO "sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-99995, 'WITH journal AS ( 
  SELECT
    COUNT(1) AS CNT 
  FROM
    sys_coop_journal AS coop1 
  WHERE
    EXISTS ( 
      SELECT
        1 
      FROM
        sys_coop_journal AS coop2 
      WHERE
        coop2.ctl_no = @ctlNo
        AND TO_CHAR(coop2.reg_date, ''YYYYMMDD'') = TO_CHAR(coop1.reg_date, ''YYYYMMDD'') 
        AND coop2.coop_cd = coop1.coop_cd
-- add 2023-01-17 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
        AND coop2.coop_version = coop1.coop_version
-- add 2023-01-17 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
    )
) 
SELECT to_char(CURRENT_TIMESTAMP, ''YYMMDD'') || ''_'' || TO_CHAR((journal.CNT - 1)%100, ''FM09'') || ''.txt'' AS filename FROM journal', 2, '[]', '0', '{"applications": [4]}', NULL, 'Medicom検査オーダファイル名取得', '2021-04-20 09:19:08.001', CURRENT_TIMESTAMP, NULL);
