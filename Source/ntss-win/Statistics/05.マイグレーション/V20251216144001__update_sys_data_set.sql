delete from sys_data_set where sql_cd in (-1000022,-1000003,-1000023,-1000024,-1000007,-1000009,-1000025);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1000022, '-- 【SQL_CD=-1000022】
WITH v_exam AS (
    SELECT
        ex.pat_id AS PATID,
        ex.reg_exam_date AS EXAM_DATE,
        -- TO_CHAR(ex.reg_exam_date, ''yyyymmdd'') AS EXAM_DAY,
        ex.reg_order_class AS ORDER_CLASS,
        ed.result AS EXAM_RST,
        ed.item_cd AS EXAM_ITEM_CODE,
        ed.result_date AS RESULT_DATE,
        ROW_NUMBER() OVER (
            PARTITION BY
                ex.reg_exam_date::date, -- 日付型でパーティション分割
                ex.reg_order_class,
                ed.item_cd
            ORDER BY
                ed.result_date DESC,  -- 結果日付で降順に並べ、最新の結果を選択
                ex.up_date DESC  -- 更新日付で降順に並べ、最新の更新を選択
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
        AND ex.reg_exam_date >= TO_DATE(@fromDate, ''YYYY/MM/DD'')  -- 修正：検査依頼（開始日）
        AND ex.result_exam_date < TO_DATE(@toDate, ''YYYY/MM/DD'')  -- 修正：検査結果（終了日）
        -- 変数の値を直接使用
        AND ed.item_cd IN (@cdBun, @bunAfter, @cdCre, @creAfter)
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
                rst_start_date::date, -- 日付型でパーティション分割
                pat_id
            ORDER BY
                rst_start_date
        ) AS NUM
    FROM
        ord_main
    WHERE
        is_del = ''0''
    AND pat_id = @patId            -- 修正：pat_idを絞り込む
    AND facility_cd = @facilityCd
    AND to_date( @fromDate, ''YYYY/MM/DD'') <= rst_start_date   -- 修正：日付を絞り込む
    AND rst_start_date < to_date( @toDate, ''YYYY/MM/DD'')      -- 修正：日付を絞り込む
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
        AND to_date( @fromDate, ''YYYY/MM/DD'') <= p.rst_start_date  -- 修正：日付を絞り込む
        AND p.rst_start_date < to_date( @toDate, ''YYYY/MM/DD'')  -- 修正：日付を絞り込む
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
    INNER JOIN exam_info e2 
        ON e1.PATID = e2.PATID 
        -- AND e1.EXAM_DAY = e2.EXAM_DAY 
        AND e1.EXAM_DATE::date = e2.EXAM_DATE::date
        AND e2.EXAM_ITEM_CODE = @cdBun  -- BUN BEFORE
        AND e2.EXAM_RST ~ ''^\d+(\.\d+)?$'' -- 数値チェック
        AND (
            @orderClass = ''2''  
            OR e2.ORDER_CLASS = ''1'' 
        )
    INNER JOIN exam_info e3 
        ON e1.PATID = e3.PATID 
        -- AND e1.EXAM_DAY = e3.EXAM_DAY 
        AND e1.EXAM_DATE::date = e3.EXAM_DATE::date
        AND e3.EXAM_ITEM_CODE = @bunAfter  -- BUN AFTER
        AND e3.EXAM_RST ~ ''^\d+(\.\d+)?$'' -- 数値チェック
        AND (
            @orderClass = ''2''  
            OR e3.ORDER_CLASS = ''2'' 
        )
    INNER JOIN exam_info e4 
        ON e1.PATID = e4.PATID 
        -- AND e1.EXAM_DAY = e4.EXAM_DAY 
        AND e1.EXAM_DATE::date = e4.EXAM_DATE::date
        AND e4.EXAM_ITEM_CODE = @cdCre  -- CRE BEFORE
        AND e4.EXAM_RST ~ ''^\d+(\.\d+)?$'' -- 数値チェック
        AND (
            @orderClass = ''2''  
            OR e4.ORDER_CLASS = ''1'' 
        )
    INNER JOIN exam_info e5 
        ON e1.PATID = e5.PATID   
        -- AND e1.EXAM_DAY = e5.EXAM_DAY 
        AND e1.EXAM_DATE::date = e5.EXAM_DATE::date
        AND e5.EXAM_ITEM_CODE = @creAfter  -- CRE AFTER
        AND e5.EXAM_RST ~ ''^\d+(\.\d+)?$'' -- 数値チェック
        AND (
            @orderClass = ''2''  
            OR e5.ORDER_CLASS = ''2'' 
        )
    LEFT JOIN dialysis_info r 
        ON e1.PATID = r.PATID 
        -- AND e1.EXAM_DAY = TO_CHAR(r.START_DATE, ''yyyymmdd'') 
        AND e1.EXAM_DATE::date = r.START_DATE::date
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
    LEFT JOIN sys_facility sf ON j.from_facility = sf.medical_institution_cd
    -- Join mst_facility for from_facility name if not found in sys_facility
    LEFT JOIN mst_facility mf ON j.from_facility = mf.facility_cd
    -- Join mst_facility for to_facility name
    LEFT JOIN mst_facility mf2 ON j.to_facility = mf2.facility_cd
    -- Join sys_facility for to_facility name if not found in mst_facility
    LEFT JOIN sys_facility sf2 ON j.to_facility = sf2.medical_institution_cd
    WHERE p.facility_cd =  @facilityCd
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
VALUES(-1000023, '-- 【SQL_CD=-1000023】
WITH filtered_exam AS (
    SELECT
        ex.pat_id AS PAT_ID,
        ex.reg_exam_date AS EXAM_DATE,
        ed.result AS EXAM_RST,
        ed.item_cd AS EXAM_ITEM_CODE,
        ex.up_date AS UP_DATE,
        ed.result_date AS RESULT_DATE,
        ROW_NUMBER() OVER (
            PARTITION BY ex.reg_exam_date, ex.reg_order_class, ed.item_cd
            ORDER BY ed.result_date DESC, ex.up_date DESC
        ) AS rn
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
        AND ed.item_cd = @examCd
        AND ex.reg_exam_date >= to_date(@fromDate, ''YYYY/MM/DD'')::timestamp
        AND ex.result_exam_date < to_date(@toDate, ''YYYY/MM/DD'')::timestamp
        AND (@orderClass = ''9'' OR @orderClass = ex.reg_order_class)
        AND ed.result ~ ''^[0-9]+(\.[0-9]+)?$'' -- 数値以外の文字列を除外
)
SELECT
    EXAM_RST,
    EXAM_DATE
FROM
    filtered_exam
WHERE
    rn = 1  -- 期間内のデータから最新を取得
ORDER BY
    EXAM_DATE DESC',2,'[{}]','0','{"applications": [4]}',NULL,'統計調査（検査1件分の結果）',CURRENT_TIMESTAMP,CURRENT_TIMESTAMP,NULL);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1000024, '-- 【SQL_CD=-1000024】
WITH filtered_exam AS (
    SELECT
        ed.result AS EXAM_RST,
        ex.reg_exam_date AS EXAM_DATE,
        ROW_NUMBER() OVER (
            PARTITION BY ex.reg_exam_date, ex.reg_order_class, ed.item_cd
            ORDER BY ed.result_date DESC, ex.up_date DESC
        ) AS rn
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
        AND ed.item_cd = @examCd
        AND ex.reg_exam_date::date = to_date(@fromDate, ''YYYY/MM/DD'')::date
        AND (@orderClass = ''9'' OR @orderClass = ex.reg_order_class)
        AND ed.result ~ ''^[0-9]+(\.[0-9]+)?$'' -- 数値以外の文字列を除外
)
SELECT
    EXAM_RST,
    EXAM_DATE
FROM
    filtered_exam
WHERE
    rn = 1  -- 最新の1件のみ取得
ORDER BY
    EXAM_DATE DESC',2,'[{}]','0','{"applications": [4]}',NULL,'統計調査（検査1件分の結果を検査日指定で格納）',CURRENT_TIMESTAMP,CURRENT_TIMESTAMP,NULL);

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
    LEFT JOIN mst_facility mf2 ON p.medical_care_info ->> ''facility_cd'' = mf2.facility_cd
    LEFT JOIN sys_facility sf2 ON p.medical_care_info ->> ''facility_cd'' = sf2.medical_institution_cd
WHERE
    p.pat_id = @patId
AND
    p.facility_cd = @facilityCd
AND
    p.is_del = ''0''',2,'[{}]','0','{"applications": [4]}',NULL,'統計調査（患者基本情報取得）',CURRENT_TIMESTAMP,CURRENT_TIMESTAMP,NULL);

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
    LEFT JOIN mst_facility mf2 ON j.to_facility = mf2.facility_cd
    -- Join sys_facility for to_facility name if not found in mst_facility
    LEFT JOIN sys_facility sf2 ON j.to_facility = sf2.medical_institution_cd
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
    LEFT JOIN sys_facility sf ON j.from_facility = sf.medical_institution_cd
    -- Join mst_facility for from_facility name if not found in sys_facility
    LEFT JOIN mst_facility mf ON j.from_facility = mf.facility_cd
    -- Join mst_facility for to_facility name
    LEFT JOIN mst_facility mf2 ON j.to_facility = mf2.facility_cd
    -- Join sys_facility for to_facility name if not found in mst_facility
    LEFT JOIN sys_facility sf2 ON j.to_facility = sf2.medical_institution_cd
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