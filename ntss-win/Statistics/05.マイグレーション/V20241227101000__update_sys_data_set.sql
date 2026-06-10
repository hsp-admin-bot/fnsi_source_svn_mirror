delete from sys_data_set where sql_cd in (-1000022);

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
                ed.result_date DESC,  -- 修正：結果日付で降順に並べ、最新の結果を選択
                ex.up_date DESC  -- 修正：更新日付で降順に並べ、最新の更新を選択
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
                TO_CHAR(rst_start_date, ''YYYYMMDD''),
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
        AND e1.EXAM_DAY = e2.EXAM_DAY 
        AND e2.EXAM_ITEM_CODE = @cdBun  -- BUN BEFORE
        AND e2.EXAM_RST ~ ''^\d+(\.\d+)?$'' -- 数値チェック
        AND (
            @orderClass = ''2''  
            OR e2.ORDER_CLASS = ''1'' 
        )
    INNER JOIN exam_info e3 
        ON e1.PATID = e3.PATID 
        AND e1.EXAM_DAY = e3.EXAM_DAY 
        AND e3.EXAM_ITEM_CODE = @bunAfter  -- BUN AFTER
        AND e3.EXAM_RST ~ ''^\d+(\.\d+)?$'' -- 数値チェック
        AND (
            @orderClass = ''2''  
            OR e3.ORDER_CLASS = ''2'' 
        )
    INNER JOIN exam_info e4 
        ON e1.PATID = e4.PATID 
        AND e1.EXAM_DAY = e4.EXAM_DAY 
        AND e4.EXAM_ITEM_CODE = @cdCre  -- CRE BEFORE
        AND e4.EXAM_RST ~ ''^\d+(\.\d+)?$'' -- 数値チェック
        AND (
            @orderClass = ''2''  
            OR e4.ORDER_CLASS = ''1'' 
        )
    INNER JOIN exam_info e5 
        ON e1.PATID = e5.PATID   
        AND e1.EXAM_DAY = e5.EXAM_DAY 
        AND e5.EXAM_ITEM_CODE = @creAfter  -- CRE AFTER
        AND e5.EXAM_RST ~ ''^\d+(\.\d+)?$'' -- 数値チェック
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
