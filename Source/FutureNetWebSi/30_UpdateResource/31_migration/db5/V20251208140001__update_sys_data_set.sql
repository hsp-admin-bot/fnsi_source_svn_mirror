delete from sys_data_set where sql_cd in (-1000007);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1000007, '-- 【SQL_CD=-1000007】
SELECT
    p.pat_id AS PATID,
    COALESCE(NULLIF(mf2.facility_name, ''''), NULLIF(sf2.facility_name, ''''), NULLIF(p.medical_care_info ->> ''facility_cd'', '''')) AS INSTITUTION_CD,
    TO_CHAR(
        TO_DATE(REPLACE(p.medical_care_info ->> ''dialysis_start_date'', ''/'', ''''), ''YYYYMMDD''),
        ''YYYYMMDD''
    ) AS DIAL_START_DATE,
    p.is_diabetes AS DIABETES
FROM
    pat_main p
    LEFT JOIN mst_facility mf2 ON TRIM(p.medical_care_info ->> ''facility_cd'') = TRIM(mf2.facility_cd)
    LEFT JOIN sys_facility sf2 ON TRIM(p.medical_care_info ->> ''facility_cd'') = TRIM(sf2.medical_institution_cd)
WHERE
    p.pat_id = @patId
AND
    p.facility_cd = @facilityCd
AND
    p.is_del = ''0''',2,'[{}]','0','{"applications": [4]}',NULL,'統計調査（患者基本情報取得）',CURRENT_TIMESTAMP,CURRENT_TIMESTAMP,NULL);