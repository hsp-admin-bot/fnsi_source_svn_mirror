SELECT
	*
FROM
	mst_exam_set
WHERE
	facility_cd = /* facilityCd */null
	and is_disp='1'
	AND EXISTS ( SELECT 1 FROM jsonb_array_elements ( exam_item_info ) AS item WHERE item ->> 'exam_item_cd' = /* examItemCd */null )
