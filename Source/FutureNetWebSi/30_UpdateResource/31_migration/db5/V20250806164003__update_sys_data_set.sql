DELETE FROM sys_data_set
WHERE sql_cd IN (6202);

INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(6202, 'WITH exam_item AS(
    SELECT
        COALESCE(
            NULLIF(info ->> ''value'', ''''),
            info ->> ''default_v''
        ) AS value
    FROM
        ntss.mst_coop_ini AS ini
        CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info :: json) info
    where
        facility_cd = ''@facilityCd''
        AND is_del = ''0''
        AND COALESCE(info ->> ''key0'', '''') = ''@key0''
        AND info ->> ''key1'' = ''MST''
        AND info ->> ''key2'' = ''EXAM_ITEM''
),
item_cd AS (
    SELECT
        exam_item_cd,
        exam_item_name
    FROM
        mst_exam_item
    WHERE
        facility_cd = ''@facilityCd''
        AND CASE WHEN (
            SELECT
                value
            FROM
                exam_item
        ) = ''1'' THEN mst_exam_item.in_hospital_cd1 WHEN (
            SELECT
                value
            FROM
                exam_item
        ) = ''2'' THEN mst_exam_item.in_hospital_cd2 WHEN (
            SELECT
                value
            FROM
                exam_item
        ) = ''3'' THEN mst_exam_item.in_hospital_cd3 END = ''@examResultInfo.itemCd''
        LIMIT 1
),
chg_cnt AS (
    SELECT
        count(exam_result_info) AS chgCnt
    FROM
        pat_exam_main
        CROSS JOIN jsonb_array_elements(exam_result_info) exam_result_infoj
    WHERE
        facility_cd = ''@facilityCd''
        AND pat_id = @patId 
        AND (exam_result_infoj ->> ''item_cd'')::INTEGER = (SELECT exam_item_cd FROM item_cd)
        AND is_del = ''0''
),
keep_cnt AS (
    SELECT
        count(exam_result_infoj) AS keepcnt
    FROM
        pat_exam_main
        CROSS JOIN jsonb_array_elements(exam_result_info) exam_result_infoj
    WHERE
        facility_cd = ''@facilityCd''
        AND pat_id = @patId
        AND (exam_result_infoj ->> ''item_cd'')::INTEGER != (SELECT exam_item_cd FROM item_cd)
        AND is_del = ''0''
),
rst_comment AS (
    SELECT
        COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS comCd1
    FROM
        ntss.mst_coop_ini AS ini
        CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info::json) info
    WHERE
        facility_cd = ''@facilityCd''
        AND is_del = ''0''
        AND COALESCE(info ->> ''key0'', '''') = ''@key0''
        AND info ->> ''key1'' = ''EXAM_RST_COMMENT''
        AND info ->> ''key2'' = ''@examResultInfo.comCd1''
), 
rst_comment2 AS (
    SELECT
        COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS comCd2
    FROM
        ntss.mst_coop_ini AS ini
        CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info::json) info
    WHERE
        facility_cd = ''@facilityCd''
        AND is_del = ''0''
        AND COALESCE(info ->> ''key0'', '''') = ''@key0''
        AND info ->> ''key1'' = ''EXAM_RST_COMMENT''
        AND info ->> ''key2'' = ''@examResultInfo.comCd2''
),
jsonb_tbl AS (
    SELECT jsonb_build_array(
        jsonb_build_object(
            ''com_cd'',
            null,
            ''exam_class'',
            ''0'',
            ''freememo'',
            CASE 
                WHEN (select comCd1 from rst_comment) <> '''' AND (select comCd2 from rst_comment2) <> ''''
                    THEN concat_ws('', '',NULLIF((SELECT comCd1 FROM rst_comment), ''''), NULLIF((SELECT comCd2 FROM rst_comment2), ''''))
                    ELSE concat_ws('''',(select comCd1 from rst_comment),(select comCd2 from rst_comment2))
            END,
            ''hl'',
            ''@examResultInfo.hl'',
            ''item_cd'',
            (SELECT exam_item_cd FROM item_cd),
            ''item_name'',
            (SELECT exam_item_name FROM item_cd),
            ''lower'',
            null,
            ''result'',
            ''@examResultInfo.result'',
            ''result_date'',
            TO_CHAR(TO_TIMESTAMP(''@regExamDate_Date'', ''YYYY-MM-DD HH24:MI:SS''), ''YYYY/MM/DD HH24:MI:SS''),
            ''unit'',
            null,
            ''upper'',
            null
        ) 
    ) AS newJsonb
)
UPDATE pat_exam_main
SET
    exam_result_info = 
    CASE 
        WHEN exam_result_info IS NULL OR exam_result_info = ''[]'' THEN 
            newJsonb
        ELSE 
            CASE 
                WHEN chgCnt = 0 THEN 
                    exam_result_info || newJsonb
                ELSE 
                    CASE 
                        WHEN keepCnt = 0 THEN 
                            newJsonb 
                        ELSE 
                            (
                                SELECT jsonb_agg(exam_result_info_j)
                                FROM pat_exam_main
                                CROSS JOIN LATERAL jsonb_array_elements(exam_result_info) exam_result_info_j
                                WHERE facility_cd = ''@facilityCd''
                                  AND pat_id = @patId
                                  AND (exam_result_info_j ->> ''item_cd'')::INTEGER != (SELECT exam_item_cd FROM item_cd)
                                  AND exam_main_cd = @examMainCd
                            ) || newJsonb
                    END 
            END 
    END
FROM
	chg_cnt,
	jsonb_tbl,
	keep_cnt
WHERE
    is_del = ''0''
    AND pat_id = @patId
    AND facility_cd = ''@facilityCd''
    AND reg_exam_date = TO_TIMESTAMP(''@regExamDate_Date'', ''YYYY-MM-DD HH24:MI:SS'')
    AND reg_order_class = 
    CASE 
        WHEN ''@regOrderClass'' IN (''1'', ''2'') THEN ''@regOrderClass''
        ELSE ''0'' 
    END
    AND exam_main_cd = @examMainCd
    AND COALESCE(CAST((SELECT exam_item_cd FROM item_cd) AS TEXT), '''') <> ''''', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)Medicomの検査結果', '2020-05-25 18:21:40.841', CURRENT_TIMESTAMP, NULL);