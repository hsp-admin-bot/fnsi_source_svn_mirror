delete from sys_data_set where sql_cd in (-1000028);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1000028, '-- 【SQL_CD=-1000028】
WITH filtered_ord_main AS (
    SELECT DISTINCT
        (rst_cond_info -> @ctlNo ->> ''value'')::bigint AS value
    FROM ord_main
    WHERE facility_cd = @facilityCd
      AND is_del = ''0''
      AND to_date( @fromDate, ''YYYY/MM/DD'') <= rst_start_date
      AND rst_start_date < to_date( @toDate, ''YYYY/MM/DD'')
)
SELECT
    mst.va_cd   AS COL_FNW_CODE,
    mst.va_name AS COL_FNW_NAME
FROM filtered_ord_main AS c
JOIN mst_va AS mst
      ON mst.va_cd = c.value
     AND mst.facility_cd = @facilityCd
ORDER BY
    mst.va_cd IS NOT NULL',2,'[{}]','0','{"applications": [4]}',NULL,'統計調査（バスキュラーアクセス）',CURRENT_TIMESTAMP,CURRENT_TIMESTAMP,NULL);
