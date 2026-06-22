delete from sys_data_set where sql_cd in (-1000029);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1000029, '-- 【SQL_CD=-1000029】
SELECT
    j.period_start AS REG_DATE,
    COALESCE(NULLIF(mf.facility_name, ''''), NULLIF(sf.facility_name, ''''), NULLIF(j.from_facility, '''')) AS FROM_FACILITY
FROM
    pat_unique p
    CROSS JOIN jsonb_to_recordset(p.in_out_visit_history_info)
        AS j(ctl_no int, move_in_out text, period_start text, from_facility text)
    LEFT JOIN mst_facility mf
        ON j.from_facility = mf.facility_cd
    LEFT JOIN sys_facility sf
        ON j.from_facility = sf.medical_institution_cd
WHERE
    p.is_del = ''0''
    AND j.move_in_out = ''1''
    AND p.pat_id = @patId
    AND p.facility_cd = @facilityCd
    AND to_date(j.period_start, ''YYYYMMDD'') >= to_date(@fromDate, ''YYYY/MM/DD'')
    AND to_date(j.period_start, ''YYYYMMDD'') < to_date(@toDate, ''YYYY/MM/DD'')
ORDER BY
    to_date(j.period_start, ''YYYYMMDD'') ASC',2,'[{}]','0','{"applications": [4]}',NULL,'統計調査（透析導入日）',CURRENT_TIMESTAMP,CURRENT_TIMESTAMP,NULL);
