delete from "sys_data_set" where "sql_cd" in (-108);
INSERT INTO "sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-108, 'WITH A AS (
    SELECT COALESCE
               (NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS setting_value
    FROM mst_coop_ini AS ini
             CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info :: json) info
    WHERE facility_cd = @facilityCd
      AND is_del = ''0''
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 start
			AND COALESCE(info->>''key0'','''') = @key0
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 end
      AND info ->> ''key1'' = ''DIALYSISSEND''
      AND info ->> ''key2'' = ''DERECT_ACID_FLG''
)
SELECT A.setting_value,
             (
                 SELECT (save_2 ->> ''ord_no'')
                 FROM (
                          SELECT (save_1 :: json) save_1,
                                 (save_2 :: json) save_2,
                                 reg_date
                          FROM pat_coop_detail
                          WHERE pat_id = @patId
-- add 2023-01-19 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
                            AND facility_cd = @facilityCd
                            AND coop_version = @coopVersion
-- add 2023-01-19 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
                            AND is_del = ''0''
                      ) s
                 WHERE save_1 ->> ''pkg'' = ''GX''
                   AND reg_date < (SELECT rst_start_date FROM ord_main WHERE ord_no = @ordNo)
                 ORDER BY reg_date DESC
                 LIMIT 1
             ) AS ord_no
      FROM A
', 2, '[]', '0', '{"applications": [4]}', '{"classes": []}', 'NKK)透析実績：指示診療No取得', '2022-06-07 03:24:08.677', CURRENT_TIMESTAMP, NULL);
