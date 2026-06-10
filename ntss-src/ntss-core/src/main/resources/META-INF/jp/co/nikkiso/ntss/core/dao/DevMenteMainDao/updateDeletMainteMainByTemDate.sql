UPDATE
		mnt_mainte_main
SET
		is_disp = '0',
		up_date = current_timestamp
WHERE
  mainte_date = /* temDate*/'1000-01-01'
  AND mainte_class = '2' -- 定期点検
  AND machine_no in /* machineNoList*/(0)
  AND (mainte_ans_1 IS NULL OR mainte_ans_1 = '') -- 点検結果未登録
  AND  NOT EXISTS (
    SELECT
      1
    FROM
      jsonb_array_elements(detail) as outer_elem
    , jsonb_array_elements(outer_elem) as inner_elem
    WHERE inner_elem ->> 'judge' <> ''
	)
;