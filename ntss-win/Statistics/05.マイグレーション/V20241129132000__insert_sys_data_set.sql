delete from sys_data_set where sql_cd in (-1000001,-1000002,-1000003,-1000004,-1000005);
delete from sys_data_set where sql_cd in (-1000006,-1000007,-1000008,-1000009,-1000010);
delete from sys_data_set where sql_cd in (-1000011,-1000012,-1000013,-1000014,-1000015);
delete from sys_data_set where sql_cd in (-1000016,-1000017,-1000018,-1000019,-1000020);
delete from sys_data_set where sql_cd in (-1000021,-1000022,-1000023,-1000024,-1000025);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1000001, '-- 【SQL_CD=-1000001】
SELECT 
    disease_cd AS COL_FNW_CODE,
    disease_name AS COL_FNW_NAME
FROM 
    mst_disease
WHERE
    facility_cd = @facilityCd 
ORDER BY
    disease_cd',2,'[{}]','0','{"applications": [4]}',NULL,'統計調査（原疾患、死因）',CURRENT_TIMESTAMP,CURRENT_TIMESTAMP,NULL);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1000002, '-- 【SQL_CD=-1000002】
WITH filtered_ord_main AS (
    SELECT DISTINCT rst_treatment_cd
    FROM  ord_main
    WHERE facility_cd = @facilityCd
    AND   is_del = ''0''
    AND   to_date( @fromDate, ''YYYY/MM/DD'') <= rst_start_date
    AND   rst_start_date < to_date( @toDate, ''YYYY/MM/DD'')
)
SELECT
    mst.treatment_cd AS COL_FNW_CODE,
    mst.treatment_name AS COL_FNW_NAME
FROM
    filtered_ord_main c
JOIN
    mst_treatment mst ON mst.treatment_cd = c.rst_treatment_cd
WHERE
    mst.device_mode IS NOT NULL 
    AND mst.device_mode NOT IN (9, 5)
ORDER BY
    mst.treatment_cd',2,'[{}]','0','{"applications": [4]}',NULL,'統計調査（患者治療項目）',CURRENT_TIMESTAMP,CURRENT_TIMESTAMP,NULL);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1000003, '-- 【SQL_CD=-1000003】
WITH facility_names AS (
    SELECT 
        p.facility_cd,
        j.move_in_out,
        j.from_facility,
        j.to_facility,
        j.facility_is_free,
        -- Get facility names for from_facility
        COALESCE(NULLIF(mf.facility_name, ''''), NULLIF(sf.facility_name, ''''), NULLIF(j.from_facility, '''')) AS from_facility_name,
        -- Get facility names for to_facility
        COALESCE(NULLIF(mf2.facility_name, ''''), NULLIF(sf2.facility_name, ''''), NULLIF(j.to_facility, '''')) AS to_facility_name
    FROM
        pat_unique p
    JOIN jsonb_to_recordset(p.in_out_visit_history_info) AS j(
        move_in_out TEXT, 
        from_facility TEXT, 
        to_facility TEXT,
        facility_is_free TEXT
    ) ON p.is_del = ''0''
    -- Join sys_facility for from_facility name
    LEFT JOIN sys_facility sf ON TRIM(j.from_facility) = TRIM(sf.medical_institution_cd)
    -- Join mst_facility for from_facility name if not found in sys_facility
    LEFT JOIN mst_facility mf ON TRIM(j.from_facility) = TRIM(mf.facility_cd)
    -- Join mst_facility for to_facility name
    LEFT JOIN mst_facility mf2 ON TRIM(j.to_facility) = TRIM(mf2.facility_cd)
    -- Join sys_facility for to_facility name if not found in mst_facility
    LEFT JOIN sys_facility sf2 ON TRIM(j.to_facility) = TRIM(sf2.medical_institution_cd)
)
-- Now use the facility_names CTE to combine facility names, displaying each facility name on a separate row
SELECT DISTINCT
    combined_facility_name AS COL_FNW_CODE,
    combined_facility_name AS COL_FNW_NAME
FROM (
    -- First part: from_facility_name
    SELECT
        from_facility_name AS combined_facility_name
    FROM
        facility_names
    WHERE
        facility_cd = @facilityCd
        AND from_facility_name IS NOT NULL
    
    UNION ALL

    -- Second part: to_facility_name
    SELECT
        to_facility_name AS combined_facility_name
    FROM
        facility_names
    WHERE
        facility_cd = @facilityCd
        AND to_facility_name IS NOT NULL
) AS combined_names
ORDER BY combined_facility_name',2,'[{}]','0','{"applications": [4]}',NULL,'統計調査（施設）',CURRENT_TIMESTAMP,CURRENT_TIMESTAMP,NULL);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1000004, '-- 【SQL_CD=-1000004】
SELECT
        exam_item_cd AS COL_FNW_CODE,
        exam_item_name AS COL_FNW_NAME
FROM
        mst_exam_item
WHERE
    facility_cd = @facilityCd
AND
    is_del = ''0''
AND
    is_disp = ''1''
ORDER BY
        exam_item_cd',2,'[{}]','0','{"applications": [4]}',NULL,'統計調査（検査項目）',CURRENT_TIMESTAMP,CURRENT_TIMESTAMP,NULL);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1000005, '-- 【SQL_CD=-1000005】
SELECT DISTINCT
    hst->>''disease_cd'' AS COL_FNW_CODE,
    mst.disease_name AS COL_FNW_NAME
FROM
    pat_unique pat
JOIN
    LATERAL JSONB_ARRAY_ELEMENTS(pat.medical_hst_info) AS hst ON true
JOIN
    mst_disease mst ON (hst->>''disease_cd'')::int = mst.disease_cd
JOIN (
    SELECT DISTINCT pat_id
    FROM ord_main
    WHERE
        facility_cd = @facilityCd
        AND is_del = ''0''
        AND to_date( @fromDate, ''YYYY/MM/DD'') <= rst_start_date
        AND rst_start_date < to_date( @toDate, ''YYYY/MM/DD'')
) AS ord ON pat.pat_id = ord.pat_id
WHERE
    pat.is_del = ''0''
ORDER BY
    hst->>''disease_cd''',2,'[{}]','0','{"applications": [4]}',NULL,'統計調査（指定期間内に透析を行った全ての患者の病歴を取得する）',CURRENT_TIMESTAMP,CURRENT_TIMESTAMP,NULL);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1000006, '-- 【SQL_CD=-1000006】
SELECT
    r.pat_id AS PATID,
    p.dial_start_date AS DIAL_START_DATE,
    p.institution_cd AS INSTITUTION_CD
FROM
    (
        SELECT DISTINCT
            pat_id
        FROM
            ord_main
        WHERE
            is_del = ''0''
            AND facility_cd = @facilityCd
            AND to_date( @fromDate, ''YYYY/MM/DD'') <= rst_start_date
            AND rst_start_date < to_date( @toDate, ''YYYY/MM/DD'')
            AND rst_treatment_cd IN (
                SELECT
                    mst.treatment_cd
                FROM
                    mst_treatment mst
                WHERE
                    mst.device_mode IS NOT NULL 
                AND mst.device_mode NOT IN (5, 9)
                AND mst.facility_cd = @facilityCd
            )
    ) r,
    (
        SELECT
            pat_id,
            medical_care_info ->> ''dialysis_start_date'' AS dial_start_date,
            medical_care_info ->> ''facility_cd'' AS institution_cd
        FROM
            pat_main p
        WHERE
            p.is_del = ''0''
            AND p.facility_cd = @facilityCd
    ) p
WHERE
    r.pat_id = p.pat_id',2,'[{}]','0','{"applications": [4]}',NULL,'統計調査（登録済み患者以外の患者）',CURRENT_TIMESTAMP,CURRENT_TIMESTAMP,NULL);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1000007, '-- 【SQL_CD=-1000007】
SELECT
    p.pat_id AS PATID,
    -- Get facility names for to_facility
    COALESCE(NULLIF(mf2.facility_name, ''''), NULLIF(sf2.facility_name, ''''), NULLIF(p.medical_care_info ->> ''facility_cd'', '''')) AS INSTITUTION_CD,
    p.medical_care_info ->> ''dialysis_start_date'' AS DIAL_START_DATE,
    p.is_diabetes AS DIABETES
FROM
    pat_main p
    -- Join mst_facility for to_facility name
    LEFT JOIN mst_facility mf2 ON TRIM(p.medical_care_info ->> ''facility_cd'') = TRIM(mf2.facility_cd)
    -- Join sys_facility for to_facility name if not found in mst_facility
    LEFT JOIN sys_facility sf2 ON TRIM(p.medical_care_info ->> ''facility_cd'') = TRIM(sf2.medical_institution_cd)
WHERE
    p.pat_id = @patId

AND
    p.facility_cd = @facilityCd

AND
    p.is_del = ''0''',2,'[{}]','0','{"applications": [4]}',NULL,'統計調査（患者基本情報取得）',CURRENT_TIMESTAMP,CURRENT_TIMESTAMP,NULL);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1000008, '-- 【SQL_CD=-1000008】
SELECT
    ord_no AS DIALYSIS_NO
FROM
    ord_main
WHERE
    is_del = ''0''
    AND facility_cd = @facilityCd
    AND pat_id = @patId
    AND to_date( @fromDate, ''YYYY/MM/DD'') <= rst_start_date
    AND rst_start_date < to_date( @toDate, ''YYYY/MM/DD'')
    AND rst_treatment_cd IN (
        SELECT
            treatment_cd
        FROM
            mst_treatment mst
        WHERE
            mst.device_mode IS NOT NULL 
        AND mst.device_mode NOT IN (9, 5)
        AND mst.facility_cd = @facilityCd)
ORDER BY 
    treat_date DESC,
    ord_no DESC
LIMIT 1',2,'[{}]','0','{"applications": [4]}',NULL,'統計調査（期間内の最後の透析番号を取得）',CURRENT_TIMESTAMP,CURRENT_TIMESTAMP,NULL);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1000009, '-- 【SQL_CD=-1000009】
SELECT
    j.period_start AS REG_DATE,
    -- Get facility names for to_facility
    COALESCE(NULLIF(mf2.facility_name, ''''), NULLIF(sf2.facility_name, ''''), NULLIF(j.to_facility, '''')) AS FACILITY_NAME,
    j.move_in_out AS INOUT_CD
FROM
    pat_unique p,
    jsonb_to_recordset(p.in_out_visit_history_info) as j(
        move_in_out text, 
        period_start text, 
        ctl_no int,
        from_facility text, 
        to_facility text
    )
    -- Join mst_facility for to_facility name
    LEFT JOIN mst_facility mf2 ON TRIM(j.to_facility) = TRIM(mf2.facility_cd)
    -- Join sys_facility for to_facility name if not found in mst_facility
    LEFT JOIN sys_facility sf2 ON TRIM(j.to_facility) = TRIM(sf2.medical_institution_cd)
WHERE
    p.pat_id = @patId
AND 
    p.facility_cd = @facilityCd
AND 
        j.move_in_out in (''3'',''11'',''7'',''8'')
AND 
    p.is_del = ''0''
AND 
        to_date( @fromDate, ''YYYY/MM/DD'') <=  to_date(j.period_start, ''YYYYMMDD'')
AND 
        to_date(j.period_start, ''YYYYMMDD'') < to_date( @toDate, ''YYYY/MM/DD'')
ORDER BY
        j.period_start DESC,
        j.ctl_no DESC',2,'[{}]','0','{"applications": [4]}',NULL,'統計調査（転出情報取得）',CURRENT_TIMESTAMP,CURRENT_TIMESTAMP,NULL);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1000010, '-- 【SQL_CD=-1000010】
SELECT
        rst_treatment_cd AS VALUE
FROM
        ord_main
WHERE
        facility_cd = @facilityCd
AND
        ord_no = @ordNo',2,'[{}]','0','{"applications": [4]}',NULL,'統計調査（ 治療方法コード取得）',CURRENT_TIMESTAMP,CURRENT_TIMESTAMP,NULL);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1000011, '-- 【SQL_CD=-1000011】
SELECT
    COUNT(r.ord_no)
FROM
    ord_main r,
    (
        SELECT
            pat_id,
            facility_cd,
            rst_start_date
        FROM
            ord_main
        WHERE
            @ordNo = ord_no
    ) s
WHERE
    r.is_del = ''0''
    AND r.facility_cd = s.facility_cd
    AND r.pat_id = s.pat_id
    AND s.rst_start_date + CAST(@days || ''days'' AS INTERVAL) - INTERVAL ''7 days'' < r.rst_start_date
    AND r.rst_start_date <= s.rst_start_date + CAST(@days || ''days'' AS INTERVAL)
    AND r.rst_treatment_cd IN (
        SELECT
            treatment_cd
        FROM
            mst_treatment mst
        WHERE
            mst.device_mode IS NOT NULL 
        AND mst.device_mode NOT IN (5, 9)
        AND mst.facility_cd = @facilityCd
    )',2,'[{}]','0','{"applications": [4]}',NULL,'統計調査（週透析回数取得）',CURRENT_TIMESTAMP,CURRENT_TIMESTAMP,NULL);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1000012, '-- 【SQL_CD=-1000012】
SELECT
    ROUND(EXTRACT(epoch FROM (rst_end_date - rst_start_date)) / 60) AS DIALYSIS_TIME
FROM
    ord_main
WHERE
    @ordNo = ord_no
AND
    facility_cd = @facilityCd',2,'[{}]','0','{"applications": [4]}',NULL,'統計調査（透析時間取得）',CURRENT_TIMESTAMP,CURRENT_TIMESTAMP,NULL);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1000013, '-- 【SQL_CD=-1000013】
SELECT
    p.ind_cond_info-> @ctlNo ->>''value'' AS VALUE
FROM
    ntss.ord_main p
WHERE
    p.ord_no = @ordNo
AND
    p.facility_cd = @facilityCd
AND
    p.ind_cond_info-> @ctlNo ->>''value'' IS NOT NULL',2,'[{}]','0','{"applications": [4]}',NULL,'統計調査（条件指示展開データ取得）',CURRENT_TIMESTAMP,CURRENT_TIMESTAMP,NULL);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1000014, '-- 【SQL_CD=-1000014】
SELECT
    p.rst_cond_info-> @ctlNo ->>''value'' AS VALUE
FROM
    ord_main p
WHERE
    p.ord_no = @ordNo
AND
    p.facility_cd = @facilityCd
AND
    p.rst_cond_info-> @ctlNo ->>''value'' IS NOT NULL',2,'[{}]','0','{"applications": [4]}',NULL,'統計調査（透析実績透析条件データ取得）',CURRENT_TIMESTAMP,CURRENT_TIMESTAMP,NULL);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1000015, '-- 【SQL_CD=-1000015】
SELECT
    j.height AS STATURE
FROM
    pat_unique p,
    jsonb_to_recordset(p.physical_info) as j(height numeric, exam_date text)
WHERE
    p.pat_id = @patId
AND
    p.is_del = ''0''
AND
    p.facility_cd = @facilityCd
AND
    j.height IS NOT NULL
AND
    to_date(j.exam_date, ''YYYY/MM/DD'') < to_date( @toDate, ''YYYY/MM/DD'') 
AND
    to_date(j.exam_date, ''YYYY/MM/DD'') >= to_date( @fromDate, ''YYYY/MM/DD'')
ORDER BY
    to_date(j.exam_date, ''YYYY/MM/DD'') desc',2,'[{}]','0','{"applications": [4]}',NULL,'統計調査（身長の取得）',CURRENT_TIMESTAMP,CURRENT_TIMESTAMP,NULL);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1000016, '-- 【SQL_CD=-1000016】
SELECT DISTINCT
    	to_char(rst_start_date, ''yyyymmdd'') DIALYSIS_DATE
FROM
(
SELECT
    r.rst_start_date,
    rank() OVER (
        PARTITION BY
            to_char(r.rst_start_date, ''IYYY''),
            to_char(r.rst_start_date, ''IW'')
        ORDER BY
            to_char(r.rst_start_date, ''D'')
    ) AS rank
FROM
    ord_main r
WHERE
    r.is_del = ''0''
    AND r.facility_cd = @facilityCd
    AND r.pat_id = @patId
    AND date_trunc(''week'', to_date( @fromDate, ''YYYY/MM/DD'')::date - interval ''1 day'') + interval ''1 day'' <= r.rst_start_date
    AND r.rst_start_date < to_date( @toDate, ''YYYY/MM/DD'')
    AND r.rst_treatment_cd IN (
        SELECT
            treatment_cd
        FROM
            mst_treatment mst
        WHERE
            mst.device_mode IS NOT NULL 
        AND mst.device_mode NOT IN (5, 9)
        AND mst.facility_cd = @facilityCd)
)  as sub  
    where
        RANK = 1',2,'[{}]','0','{"applications": [4]}',NULL,'統計調査（第１透析日のみを取得）',CURRENT_TIMESTAMP,CURRENT_TIMESTAMP,NULL);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1000017, '-- 【SQL_CD=-1000017】
SELECT DISTINCT
    hst->>''disease_cd'' AS DISEASE_CD
FROM
    pat_unique pat,
    LATERAL JSONB_ARRAY_ELEMENTS(pat.medical_hst_info) AS hst
WHERE
    pat.is_del = ''0''
AND
    pat.pat_id = @patId
AND
    pat.facility_cd = @facilityCd
ORDER BY
    hst->>''disease_cd''',2,'[{}]','0','{"applications": [4]}',NULL,'統計調査（患者病歴に糖尿病に該当する病名）',CURRENT_TIMESTAMP,CURRENT_TIMESTAMP,NULL);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1000018, '-- 【SQL_CD=-1000018】
SELECT
    COUNT(p.pat_id)
FROM
    pat_unique p,
    jsonb_to_recordset(p.in_out_visit_history_info) as j(
        move_in_out text, 
        period_start text, 
        ctl_no int
    )
WHERE
    p.is_del = ''0''
AND
    p.facility_cd = @facilityCd
AND
    (
        (p.pat_id, j.ctl_no, to_date(j.period_start, ''YYYYMMDD'')) 
    IN 
        (
            SELECT 
                p2.pat_id, 
                j2.ctl_no, 
                max(to_date(j2.period_start, ''YYYYMMDD''))
            FROM 
                pat_unique p2,
                jsonb_to_recordset(p2.in_out_visit_history_info) as j2(
                    move_in_out text, 
                    period_start text, 
                    ctl_no int,
                    from_facility text, 
                    to_facility text
                )
            WHERE 
                p2.pat_id = @patId
            AND
                p2.facility_cd = @facilityCd
            AND
                to_date(j2.period_start, ''YYYYMMDD'') < to_date( @toDate, ''YYYY/MM/DD'')
            GROUP BY
                p2.pat_id, j2.ctl_no
        )
    )
AND
    j.move_in_out in (''2'')',2,'[{}]','0','{"applications": [4]}',NULL,'統計調査（患者が転入患者であるか）',CURRENT_TIMESTAMP,CURRENT_TIMESTAMP,NULL);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1000019, '-- 【SQL_CD=-1000019】
WITH filtered_data AS (
    SELECT 
        (monitor_data ->> ''90'')::int AS value_90,
        (monitor_data ->> ''91'')::int AS value_91,
        (monitor_data ->> ''93'')::int AS value_93
    FROM
        mni_monitor
    WHERE 
        ord_no = @ordNo
    AND
        data_type = 5
    AND
        facility_cd = @facilityCd
)
SELECT
    MIN(value_90) AS BP_BEFORE,
    MAX(value_91) AS BP_AFTER,
    MAX(value_93) AS PULSE
FROM filtered_data',2,'[{}]','0','{"applications": [4]}',NULL,'統計調査（透析前収縮期血圧、透析前拡張期血圧、透析前脈拍の取得）',CURRENT_TIMESTAMP,CURRENT_TIMESTAMP,NULL);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1000020, '-- 【SQL_CD=-1000020】
SELECT
    p.pat_id AS PATID,
    j.move_in_out AS INOUT_CD,
    j.period_start AS REG_DATE,
    CASE
        WHEN j.move_in_out = ''2'' then j.from_facility
        ELSE j.to_facility
    END AS FACILITY_NAME,
    j.ctl_no AS CTL_NO
FROM
    pat_unique p,
    jsonb_to_recordset(p.in_out_visit_history_info) as j(
        move_in_out text, 
        period_start text, 
        ctl_no int,
        from_facility text, 
        to_facility text
    )
WHERE
    p.is_del = ''0''
AND
    (
        (p.pat_id, j.ctl_no, to_date(j.period_start, ''YYYYMMDD'')) 
    IN 
        (
            SELECT 
                p2.pat_id, 
                j2.ctl_no, 
                max(to_date(j2.period_start, ''YYYYMMDD''))
            FROM 
                pat_unique p2,
                jsonb_to_recordset(p2.in_out_visit_history_info) as j2(
                    move_in_out text, 
                    period_start text, 
                    ctl_no int,
                    from_facility text, 
                    to_facility text
                )
            WHERE 
                p2.pat_id = @patId
            AND
                p2.facility_cd = @facilityCd
            AND
                to_date(j2.period_start, ''YYYYMMDD'') < to_date( @toDate, ''YYYY/MM/DD'')
            AND
                to_date(j2.period_start, ''YYYYMMDD'') >= to_date( @fromDate, ''YYYY/MM/DD'')
            AND
                j2.move_in_out in (''2'', ''3'', ''11'', ''7'', ''8'')
            GROUP BY
                p2.pat_id, j2.ctl_no
        )
    )
AND
    j.move_in_out in (''2'', ''3'', ''11'', ''7'', ''8'')
AND 
    p.facility_cd = @facilityCd
ORDER BY
    j.period_start ASC,
    j.ctl_no ASC',2,'[{}]','0','{"applications": [4]}',NULL,'統計調査（転入・転帰パターン）',CURRENT_TIMESTAMP,CURRENT_TIMESTAMP,NULL);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1000021, '-- 【SQL_CD=-1000021】
SELECT
    p.pat_id AS PATID,
    j.move_in_out AS INOUT_CD,
    j.period_start AS REG_DATE
FROM
    pat_unique p,
    jsonb_to_recordset(p.in_out_visit_history_info) as j(ctl_no int, move_in_out text, period_start text)
WHERE
    p.pat_id = @patId
AND
    p.is_del = ''0''
AND
    p.facility_cd = @facilityCd
AND
    to_date(j.period_start, ''YYYYMMDD'') < to_date( @toDate, ''YYYY/MM/DD'') 
AND
    to_date(j.period_start, ''YYYYMMDD'') >= to_date( @fromDate, ''YYYY/MM/DD'')
AND
    j.move_in_out <> ''11''
ORDER BY
    ctl_no DESC,
    to_date(j.period_start, ''YYYYMMDD'') DESC',2,'[{}]','0','{"applications": [4]}',NULL,'統計調査（最新のinout_cdが対象年に指定であれば取得）',CURRENT_TIMESTAMP,CURRENT_TIMESTAMP,NULL);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1000022, '-- 【SQL_CD=-1000022】
WITH v_exam AS (
    SELECT
        ex.pat_id AS PATID,
        ex.reg_exam_date AS EXAM_DATE,
        TO_CHAR(ex.reg_exam_date, ''yyyymmdd'') AS EXAM_DAY,
        ex.reg_order_class AS ORDER_CLASS,
        ed.result AS EXAM_RST,
        ed.item_cd AS EXAM_ITEM_CODE,
        ed.result_date AS RESULT_DATE,
        ROW_NUMBER() OVER (
            PARTITION BY
                TO_CHAR(ex.reg_exam_date, ''yyyymmdd''),
                ex.reg_order_class,
                ed.item_cd
            ORDER BY
                ex.reg_order_class
        ) AS num
    FROM
        pat_exam_main ex
        JOIN jsonb_to_recordset(ex.exam_result_info) AS ed(
            item_cd INTEGER,
            result_date TIMESTAMP,
            result TEXT
        ) ON ed.item_cd IS NOT NULL
    WHERE
        ex.is_del = ''0''
        AND ex.facility_cd = @facilityCd
        AND ex.pat_id = @patId
        AND ex.up_date = (
            SELECT MAX(up_date)
            FROM pat_exam_main ex_sub
            WHERE
                ex.pat_id = ex_sub.pat_id
                AND ex.reg_exam_date = ex_sub.reg_exam_date
                AND ex.reg_order_class = ex_sub.reg_order_class
        )
        AND ed.result_date = (
            SELECT MAX(result_date)
            FROM jsonb_to_recordset(ex.exam_result_info) AS ed_sub(
                item_cd INTEGER,
                result TEXT,
                result_date TIMESTAMP
            )
            WHERE
                ed.item_cd = ed_sub.item_cd
        )
),
exam_info AS (
    SELECT *
    FROM v_exam
    WHERE num = 1
),
dialysis_info AS (
    SELECT
        ord_no AS DIALYSIS_NO,
        pat_id AS PATID,
        rst_start_date AS START_DATE,
        treat_type AS TREAT_TYPE,
        rst_treatment_cd AS TREAT_ITEM_CD,
        ROW_NUMBER() OVER (
            PARTITION BY
                TO_CHAR(rst_start_date, ''YYYYMMDD''),
                pat_id
            ORDER BY
                rst_start_date
        ) AS NUM
    FROM
        ord_main
    WHERE
        is_del = ''0''
    AND facility_cd = @facilityCd
),
weight_info AS (
    SELECT
        p.ord_no AS DIALYSIS_NO,
        p.rst_weight_info->>''weight_before'' AS WEIGHT_BEFORE, 
        p.rst_weight_info->>''weight_after'' AS WEIGHT_AFTER
    FROM
        ord_main p
    WHERE
        p.is_del = ''0''
        AND p.pat_id = @patId
        AND p.facility_cd = @facilityCd
)
SELECT
    w.WEIGHT_BEFORE,
    w.WEIGHT_AFTER,
    e2.EXAM_RST AS RST_BUN_BEFORE,
    e3.EXAM_RST AS RST_BUN_AFTER,
    e4.EXAM_RST AS RST_CRE_BEFORE,
    e5.EXAM_RST AS RST_CRE_AFTER,
    e1.EXAM_DAY,
    e1.EXAM_DATE,
    r.DIALYSIS_NO
FROM
    exam_info e1
    LEFT JOIN exam_info e2 
        ON e1.PATID = e2.PATID 
        AND e1.EXAM_DAY = e2.EXAM_DAY 
        AND e2.EXAM_ITEM_CODE = @cdBun  -- BUN BEFORE
        AND (
            @orderClass = ''2''  
            OR e2.ORDER_CLASS = ''1'' 
        )
    LEFT JOIN exam_info e3 
        ON e1.PATID = e3.PATID 
        AND e1.EXAM_DAY = e3.EXAM_DAY 
        AND e3.EXAM_ITEM_CODE = @bunAfter  -- BUN AFTER  
        AND (
            @orderClass = ''2''  
            OR e3.ORDER_CLASS = ''2'' 
        )
    LEFT JOIN exam_info e4 
        ON e1.PATID = e4.PATID 
        AND e1.EXAM_DAY = e4.EXAM_DAY 
        AND e4.EXAM_ITEM_CODE = @cdCre  -- CRE BEFORE 
        AND (
            @orderClass = ''2''  
            OR e4.ORDER_CLASS = ''1'' 
        )
    LEFT JOIN exam_info e5 
        ON e1.PATID = e5.PATID   
        AND e1.EXAM_DAY = e5.EXAM_DAY 
        AND e5.EXAM_ITEM_CODE = @creAfter  -- CRE AFTER 
        AND (
            @orderClass = ''2''  
            OR e5.ORDER_CLASS = ''2'' 
        )
    LEFT JOIN dialysis_info r 
        ON e1.PATID = r.PATID 
        AND e1.EXAM_DAY = TO_CHAR(r.START_DATE, ''yyyymmdd'') 
        AND r.NUM = 1
    LEFT JOIN weight_info w 
        ON r.DIALYSIS_NO = w.DIALYSIS_NO
WHERE
    to_date(@fromDate, ''YYYY/MM/DD'') <= r.START_DATE
    AND r.START_DATE < to_date(@toDate, ''YYYY/MM/DD'')
    AND r.TREAT_ITEM_CD IN (
        SELECT
            treatment_cd
        FROM
            mst_treatment mst
        WHERE   
            mst.device_mode IS NOT NULL 
            AND mst.device_mode NOT IN (9, 5)
            AND mst.facility_cd = @facilityCd
    )
ORDER BY
    e1.EXAM_DATE DESC,
    e1.RESULT_DATE DESC',2,'[{}]','0','{"applications": [4]}',NULL,'統計調査（体重情報格納(BUN,クレアチニン格納)）',CURRENT_TIMESTAMP,CURRENT_TIMESTAMP,NULL);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1000023, '-- 【SQL_CD=-1000023】
SELECT
    ed.result AS EXAM_RST,
    ex.reg_exam_date AS EXAM_DATE
FROM
    pat_exam_main ex
    JOIN jsonb_to_recordset(ex.exam_result_info) AS ed(
        item_cd INTEGER,
        result_date TIMESTAMP,
        result TEXT
    ) ON ed.item_cd IS NOT NULL
WHERE
    ex.is_del = ''0''
AND
    facility_cd = @facilityCd
AND
    ex.pat_id = @patId
AND
    ed.item_cd = @examCd
AND
    to_date( @fromDate, ''YYYY/MM/DD'') <= ex.reg_exam_date
AND
    ex.reg_exam_date < to_date( @toDate, ''YYYY/MM/DD'')

AND (
    @orderClass = ''9''
    OR @orderClass = ex.reg_order_class
)
AND ex.up_date = (
    SELECT MAX(up_date)
    FROM pat_exam_main ex_sub
    WHERE
        ex.pat_id = ex_sub.pat_id
        AND ex.reg_exam_date = ex_sub.reg_exam_date
        AND ex.reg_order_class = ex_sub.reg_order_class
)
AND ed.result_date = (
    SELECT MAX(result_date)
    FROM jsonb_to_recordset(ex.exam_result_info) AS ed_sub(
        item_cd INTEGER,
        result TEXT,
        result_date TIMESTAMP
    )
    WHERE
        ed.item_cd = ed_sub.item_cd
    )
ORDER BY
    ex.reg_exam_date desc',2,'[{}]','0','{"applications": [4]}',NULL,'統計調査（検査1件分の結果）',CURRENT_TIMESTAMP,CURRENT_TIMESTAMP,NULL);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1000024, '-- 【SQL_CD=-1000024】
SELECT
    ed.result AS EXAM_RST,
    ex.reg_exam_date AS EXAM_DATE
FROM
    pat_exam_main ex
    JOIN jsonb_to_recordset(ex.exam_result_info) AS ed(
        item_cd INTEGER,
        result_date TIMESTAMP,
        result TEXT
    ) ON ed.item_cd IS NOT NULL
WHERE
    ex.is_del = ''0''
AND
    facility_cd = @facilityCd
AND
    ex.pat_id = @patId
AND
    ed.item_cd = @examCd
AND
    to_date( @fromDate, ''YYYY/MM/DD'') = ex.reg_exam_date
AND (
    @orderClass = ''9''
    OR @orderClass = ex.reg_order_class
)
AND ex.up_date = (
    SELECT MAX(up_date)
    FROM pat_exam_main ex_sub
    WHERE
        ex.pat_id = ex_sub.pat_id
        AND ex.reg_exam_date = ex_sub.reg_exam_date
        AND ex.reg_order_class = ex_sub.reg_order_class
)
AND ed.result_date = (
    SELECT MAX(result_date)
    FROM jsonb_to_recordset(ex.exam_result_info) AS ed_sub(
        item_cd INTEGER,
        result TEXT,
        result_date TIMESTAMP
    )
    WHERE
        ed.item_cd = ed_sub.item_cd
    )
ORDER BY
    ex.reg_exam_date desc',2,'[{}]','0','{"applications": [4]}',NULL,'統計調査（検査1件分の結果を検査日指定で格納）',CURRENT_TIMESTAMP,CURRENT_TIMESTAMP,NULL);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1000025, '-- 【SQL_CD=-1000025】
SELECT
    j.period_start AS REG_DATE,
    -- Get facility names for from_facility
    COALESCE(NULLIF(mf.facility_name, ''''), NULLIF(sf.facility_name, ''''), NULLIF(j.from_facility, '''')) AS FROM_FACILITY_NAME,
    -- Get facility names for to_facility
    COALESCE(NULLIF(mf2.facility_name, ''''), NULLIF(sf2.facility_name, ''''), NULLIF(j.to_facility, '''')) AS TO_FACILITY_NAME
FROM
    pat_unique p,
    jsonb_to_recordset(p.in_out_visit_history_info) AS j(ctl_no int, move_in_out text, period_start text, from_facility text, to_facility text)
    -- Join sys_facility for from_facility name
    LEFT JOIN sys_facility sf ON TRIM(j.from_facility) = TRIM(sf.medical_institution_cd)
    -- Join mst_facility for from_facility name if not found in sys_facility
    LEFT JOIN mst_facility mf ON TRIM(j.from_facility) = TRIM(mf.facility_cd)
    -- Join mst_facility for to_facility name
    LEFT JOIN mst_facility mf2 ON TRIM(j.to_facility) = TRIM(mf2.facility_cd)
    -- Join sys_facility for to_facility name if not found in mst_facility
    LEFT JOIN sys_facility sf2 ON TRIM(j.to_facility) = TRIM(sf2.medical_institution_cd)
WHERE
    p.is_del = ''0''
AND
    p.pat_id = @patId

AND
    p.facility_cd = @facilityCd

AND
    to_date(j.period_start, ''YYYYMMDD'') < to_date( @toDate, ''YYYY/MM/DD'')
AND
    j.move_in_out = ''2''
ORDER BY
    j.ctl_no DESC,
    to_date(j.period_start, ''YYYYMMDD'') DESC',2,'[{}]','0','{"applications": [4]}',NULL,'統計調査（転入日情報）',CURRENT_TIMESTAMP,CURRENT_TIMESTAMP,NULL);
