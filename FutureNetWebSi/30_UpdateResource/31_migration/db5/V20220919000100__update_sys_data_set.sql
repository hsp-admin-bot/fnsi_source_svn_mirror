DELETE  FROM "ntss"."sys_data_set" WHERE sql_cd IN ('-515','-516','-518','-517','-108','-105','-510','-511');
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-516, 'with coop_ini as (SELECT COALESCE
                             ( NULLIF( info ->> ''value'', '''' ), info ->> ''default_v'' ) AS header_mode
                  FROM
                      mst_coop_ini AS ini
                          CROSS JOIN LATERAL json_array_elements ( ini.coop_ini_info :: json ) info
                  WHERE
                          facility_cd = @facilityCd

                    AND is_del = ''0''
                    AND info ->> ''key1'' = ''DIALYSISSEND''
                    AND info ->> ''key2'' = ''HEADER_MODE''
)
select
    case when coop_ini.header_mode=  ''1'' then  ''1'' else '' ''
        end as type_cd
from coop_ini', 2, '[]', '0', '{"applications": [4]}', '{"classes": []}', 'NKK)  透析実績：ヘッダ切り替え-処理区分
', '2022-06-07 03:24:08.677', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-517, 'with coop_ini as (SELECT COALESCE
                             ( NULLIF( info ->> ''value'', '''' ), info ->> ''default_v'' ) AS header_mode
                  FROM
                      mst_coop_ini AS ini
                          CROSS JOIN LATERAL json_array_elements ( ini.coop_ini_info :: json ) info
                  WHERE
                          facility_cd = @facilityCd

                    AND is_del = ''0''
                    AND info ->> ''key1'' = ''DIALYSISSEND''
                    AND info ->> ''key2'' = ''HEADER_MODE''
)
select
    case when coop_ini.header_mode=  ''1'' then  ''2'' else '' ''
        end as type_cd
from coop_ini', 2, '[]', '0', '{"applications": [4]}', '{"classes": []}', 'NKK)  透析実績：ヘッダ切り替え-処理区分（削除）
', '2022-06-07 03:24:08.677', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-518, 'with coop_ini as (SELECT COALESCE
                             (NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS header_mode
                  FROM mst_coop_ini AS ini
                           CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info :: json) info
                  WHERE facility_cd = @facilityCd

                    AND is_del = ''0''
                    AND info ->> ''key1'' = ''DIALYSISSEND''
                    AND info ->> ''key2'' = ''HEADER_MODE''
)
select case
           when coop_ini.header_mode = ''1''
               then coop_ord_no
           else ''            ''
           end
           AS coop_ord_no
FROM sys_coop_journal,
     coop_ini
WHERE ctl_no = @ctlNo', 2, '[]', '0', '{"applications": [4]}', '{"classes": []}', 'NKK)  透析実績：ヘッダ切り替え-透析番号
', '2022-06-07 03:24:08.677', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-515, 'with coop_ini as (SELECT COALESCE
                             (NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS header_mode
                  FROM mst_coop_ini AS ini
                           CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info :: json) info
                  WHERE facility_cd = @facilityCd

                    AND is_del = ''0''
                    AND info ->> ''key1'' = ''DIALYSISSEND''
                    AND info ->> ''key2'' = ''HEADER_MODE''
)
select case
           when coop_ini.header_mode = ''1''
					 then to_char(CURRENT_TIMESTAMP, ''YYYYMMDDHH12MISS'') else ''              ''
           end sys_date
from coop_ini

', 2, '[]', '0', '{"applications": [4]}', '{"classes": []}', 'NKK)  透析実績：ヘッダ切り替え-処理日時
', '2022-06-07 03:24:08.677', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-510, 'WITH ord_main_restore_info AS (
		SELECT * FROM ord_main_restore as ord_i
		WHERE ord_i.ord_no = @ordNo AND ord_i.facility_cd = @facilityCd
		ORDER BY del_date DESC LIMIT 1
	)
	, A AS (
SELECT COALESCE
	( NULLIF( info ->> ''value'', '''' ), info ->> ''default_v'' ) AS default_in_hospital_cd
FROM
	mst_coop_ini AS ini
	CROSS JOIN LATERAL json_array_elements ( ini.coop_ini_info :: json ) info
WHERE
	facility_cd = @facilityCd

	AND is_del = ''0''
	AND info ->> ''key1'' = ''DIALYSISSEND''
	AND info ->> ''key2'' = ''DEPARTMENT_DEF''
	)	,
 coop_ini as (SELECT COALESCE
	( NULLIF( info ->> ''value'', '''' ), info ->> ''default_v'' ) AS header_mode
FROM
	mst_coop_ini AS ini
	CROSS JOIN LATERAL json_array_elements ( ini.coop_ini_info :: json ) info
WHERE
	facility_cd = @facilityCd

	AND is_del = ''0''
	AND info ->> ''key1'' = ''DIALYSISSEND''
	AND info ->> ''key2'' = ''HEADER_MODE''
)
SELECT
case when coop_ini.header_mode=  ''0'' then ''''
		 when coop_ini.header_mode=''1'' then
(
SELECT
	(
CASE
	WHEN ( SELECT rst_course_cd FROM ord_main_restore_info WHERE ord_no = @ordNo LIMIT 1 ) IS NOT NULL THEN
		CASE
			WHEN (SELECT in_hospital_cd_1 FROM mst_course WHERE course_cd = (SELECT rst_course_cd FROM ord_main_restore_info WHERE ord_no = @ordNo)) IS NULL THEN
				A.default_in_hospital_cd
			ELSE
				(SELECT in_hospital_cd_1 FROM mst_course WHERE course_cd = (SELECT rst_course_cd FROM ord_main_restore_info WHERE ord_no = @ordNo))
			END
	ELSE
		A.default_in_hospital_cd
END
	) AS in_hospital_cd_1
FROM
A)
end AS in_hospital_cd_1
FROM coop_ini', 2, '[{}]', '0', '{"applications": [4]}', '{"classes": []}', 'NKK)  透析実績：診療科コード取得（削除）', '2022-09-05 08:14:41.911', '2022-09-05 08:14:41.911', NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-108, 'WITH A AS (
    SELECT COALESCE
               (NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS setting_value
    FROM mst_coop_ini AS ini
             CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info :: json) info
    WHERE facility_cd = @facilityCd
      AND is_del = ''0''
      AND info ->> ''key1'' = ''DIALYSISSEND''
      AND info ->> ''key2'' = ''DERECT_ACID_FLG''
),
     coop_ini as (SELECT COALESCE
                             (NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS header_mode
                  FROM mst_coop_ini AS ini
                           CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info :: json) info
                  WHERE facility_cd = @facilityCd

                    AND is_del = ''0''
                    AND info ->> ''key1'' = ''DIALYSISSEND''
                    AND info ->> ''key2'' = ''HEADER_MODE''
     )
select case when coop_ini.header_mode = ''1'' then d.setting_value else '''' end    setting_value,
       case when coop_ini.header_mode = ''1'' then d.ord_no else ''          '' end ord_no
from (SELECT A.setting_value,
             (
                 SELECT (save_2 ->> ''ord_no'')
                 FROM (
                          SELECT (save_1 :: json) save_1,
                                 (save_2 :: json) save_2,
                                 reg_date
                          FROM pat_coop_detail
                          WHERE pat_id = @patId
                            AND is_del = ''0''
                      ) s
                 WHERE save_1 ->> ''pkg'' = ''GX''
                   AND reg_date < (SELECT rst_start_date FROM ord_main WHERE ord_no = @ordNo)
                 ORDER BY reg_date DESC
                 LIMIT 1
             ) AS ord_no
      FROM A) d,
     coop_ini
', 2, '[]', '0', '{"applications": [4]}', '{"classes": []}', 'NKK)透析実績：指示診療No取得', '2022-06-07 03:24:08.677', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-105, 'WITH A AS (
SELECT COALESCE
	( NULLIF( info ->> ''value'', '''' ), info ->> ''default_v'' ) AS default_in_hospital_cd
FROM
	mst_coop_ini AS ini
	CROSS JOIN LATERAL json_array_elements ( ini.coop_ini_info :: json ) info
WHERE
	facility_cd = @facilityCd

	AND is_del = ''0''
	AND info ->> ''key1'' = ''DIALYSISSEND''
	AND info ->> ''key2'' = ''DEPARTMENT_DEF''
	) ,
 coop_ini as (SELECT COALESCE
	( NULLIF( info ->> ''value'', '''' ), info ->> ''default_v'' ) AS header_mode
FROM
	mst_coop_ini AS ini
	CROSS JOIN LATERAL json_array_elements ( ini.coop_ini_info :: json ) info
WHERE
	facility_cd = @facilityCd

	AND is_del = ''0''
	AND info ->> ''key1'' = ''DIALYSISSEND''
	AND info ->> ''key2'' = ''HEADER_MODE''
)
SELECT
case when coop_ini.header_mode=  ''0'' then ''''
		 when coop_ini.header_mode=''1'' then
(SELECT
	(
CASE
	WHEN ( SELECT rst_course_cd FROM ord_main WHERE ord_no = @ordNo LIMIT 1 ) IS NOT NULL THEN
		CASE
			WHEN (SELECT in_hospital_cd_1 FROM mst_course WHERE course_cd = (SELECT rst_course_cd FROM ord_main WHERE ord_no = @ordNo)) IS NULL THEN
				A.default_in_hospital_cd
			ELSE
				(SELECT in_hospital_cd_1 FROM mst_course WHERE course_cd = (SELECT rst_course_cd FROM ord_main WHERE ord_no = @ordNo))
			END
	ELSE
		A.default_in_hospital_cd
END
	) AS in_hospital_cd_1
FROM
A)
end AS in_hospital_cd_1
FROM coop_ini', 2, '[{}]', '0', '{"applications": [4]}', '{"classes": []}', '実績（治療中）：診療科コード @ordNo 使用', '2022-05-27 15:57:30', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-511, 'with coop_ini as (SELECT COALESCE
                             (NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS header_mode
                  FROM mst_coop_ini AS ini
                           CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info :: json) info
                  WHERE facility_cd = @facilityCd

                    AND is_del = ''0''
                    AND info ->> ''key1'' = ''DIALYSISSEND''
                    AND info ->> ''key2'' = ''HEADER_MODE''
),
     journal as (
         SELECT coop_ord_no
         from sys_coop_journal
         WHERE facility_cd = @facilityCd
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
