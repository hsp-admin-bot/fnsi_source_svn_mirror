DELETE FROM sys_data_set WHERE sql_cd IN 
(-1202007);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1202007, 'WITH coop_ini_info AS (
    SELECT
        COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS value
        , info ->> ''key1'' AS key1
        , info ->> ''key2'' AS key2
    FROM
        mst_coop_ini AS ini
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
    WHERE
        facility_cd = @facilityCd
        AND is_del = ''0''
        AND COALESCE(info ->> ''key0'', '''') = @key0
)
, exam_inhosp AS ( --検査項目マスタの使用院内コード番号
    SELECT *
    FROM coop_ini_info
    WHERE key1 = ''SX_EXAM_SCHE_INFO''
        AND key2 = ''EXAM_INHOSP''
)
, exam_set_inhosp AS ( --検査セットマスタの使用院内コード番号
    SELECT *
    FROM coop_ini_info
    WHERE key1 = ''SX_EXAM_SCHE_INFO''
        AND key2 = ''EXAM_SET_INHOSP''
)
, output_setting AS ( --院外院内フラグ(0:両方, 1:院内のみ,2:院外のみ)
    SELECT *
    FROM coop_ini_info
    WHERE key1 = ''SX_EXAM_SCHE_INFO''
        AND key2 = ''EXAM_OUTPUT''
)
, do_pat_exam_main AS (
    SELECT
        exam_order_info
        , 0 AS idx
        , up_date
    FROM pat_exam_main_hst
    WHERE exam_main_cd = @ordNo
    UNION
    SELECT
        exam_order_info
        , 1 AS idx
        , up_date
    FROM pat_exam_main
    WHERE exam_main_cd = @ordNo
    ORDER BY
        idx ASC
        , up_date DESC
    LIMIT 1
)
SELECT lpad(RIGHT(TO_CHAR(COUNT(DISTINCT mes.exam_set_cd), ''FM999999999''), 3), 3, '' '') AS count
FROM do_pat_exam_main pem
CROSS JOIN LATERAL jsonb_array_elements(pem.exam_order_info) info
LEFT JOIN mst_exam_set mes ON info ->> ''set_cd'' = mes.exam_set_cd ::text
LEFT JOIN mst_exam_item mei ON info ->> ''item_cd'' = mei.exam_item_cd ::text
WHERE
  mes.facility_cd = @facilityCd
  AND mes.is_del = ''0''
  AND mes.is_disp = ''1''
  AND coalesce(
    (
      CASE (SELECT value FROM exam_set_inhosp)
      WHEN ''1'' THEN mes.in_hospital_cd1
      WHEN ''2'' THEN mes.in_hospital_cd2
      WHEN ''3'' THEN mes.in_hospital_cd3
      ELSE mes.in_hospital_cd1
      END
    ), '''') <> ''''
  AND mei.facility_cd = @facilityCd
  AND mei.is_del = ''0''
  AND mei.is_disp = ''1''
  AND coalesce(
    (
      CASE (SELECT value FROM exam_inhosp)
      WHEN ''1'' THEN mei.in_hospital_cd1
      WHEN ''2'' THEN mei.in_hospital_cd2
      WHEN ''3'' THEN mei.in_hospital_cd3
      ELSE mei.in_hospital_cd1
      END
    ), '''') <> ''''
  AND CASE (SELECT value FROM output_setting)
    WHEN ''1'' THEN mei.is_in_hospital = ''1'' --院内のみ
    WHEN ''2'' THEN mei.is_in_hospital = ''0'' --院外のみ
    ELSE true
    END', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'SX_血液検査依頼項目数', '2025-06-19 11:08:22.806', CURRENT_TIMESTAMP, NULL);
