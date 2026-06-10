-- 身体情報のDW変更時に、
-- 画面指定検査日時～DWが登録されている最新の身体情報の検査日時の期間にある
-- rst_dialysis_state＞0の透析予定件数を検索する。
SELECT
    count(*)
FROM
    ord_main A,
    ( SELECT
        pat_id,
        lastdw_exam_date
    FROM
        pat_unique
    CROSS JOIN
        jsonb_array_elements(pat_unique.physical_info) as physical_info_rows,
        jsonb_extract_path_text(physical_info_rows, 'dw') as dw,
        to_date(jsonb_extract_path_text(physical_info_rows, 'exam_date'), 'YYYY-MM-DD') as lastdw_exam_date
    WHERE
        pat_id = /*patId*/1
    AND
        dw IS NOT NULL
    ORDER BY
        lastdw_exam_date desc
    LIMIT 1 ) B
WHERE
    A.pat_id = /*patId*/1
AND
    A.treat_date >= /*startDate*/'20210601'
AND
    A.treat_date <= to_char(B.lastdw_exam_date, 'YYYYMMDD')
AND
    A.rst_dialysis_state > '0'