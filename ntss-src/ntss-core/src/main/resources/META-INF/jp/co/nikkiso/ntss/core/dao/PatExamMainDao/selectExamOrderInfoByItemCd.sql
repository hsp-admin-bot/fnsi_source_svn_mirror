SELECT
exam_main_cd,
facility_cd,
pat_id,
--//add 10125 ケース16 検査項目マスタ編集 zrx start
phy_ord_class,
--//add 10125 ケース16 検査項目マスタ編集 zrx end
reg_exam_date
	FROM
	pat_exam_main
WHERE
	facility_cd = /* facilityCd */null
	AND EXISTS ( SELECT 1 FROM jsonb_array_elements ( exam_order_info ) AS item WHERE item ->> 'item_cd' = /* examItemCd */null )
	AND reg_exam_date > /* regExamDate */'9999/01/01 00:00:00'
