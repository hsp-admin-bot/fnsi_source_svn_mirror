-- 身体情報のDW変更時に、
-- 画面指定検査日時～DWが登録されている最新の身体情報の検査日時の期間にある
SELECT
	ord_no
FROM
	ord_main A,
	(
		(
            SELECT
                pat_id,
                to_char(lastdw_exam_date, 'YYYYMMDD') as lastdw_exam_date
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
            AND lastdw_exam_date > /*startDate*/'20210601'
		)
		UNION
		(
		    SELECT 1, '20991231'
		)
		ORDER BY
			lastdw_exam_date
		LIMIT 1
	) B
WHERE
	A.pat_id = /*patId*/1
--mod #10185 DW一括登録時に連携イベントが発生しない zhaoqi 20240105 start
  AND A.treat_date >= to_char(now(), 'YYYYMMDD')
  AND A.ind_kur_cd <> '0'
--mod #10185 DW一括登録時に連携イベントが発生しない zhaoqi 20240105 end
AND
    A.treat_date < B.lastdw_exam_date
AND
    A.rst_dialysis_state = '0'
