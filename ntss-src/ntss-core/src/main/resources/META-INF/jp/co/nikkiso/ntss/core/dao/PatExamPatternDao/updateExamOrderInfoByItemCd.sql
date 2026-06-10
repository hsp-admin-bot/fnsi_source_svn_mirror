UPDATE pat_exam_pattern
SET exam_order_info = (
	SELECT
		case when jsonb_agg ( sub.elems )  is not null
		then jsonb_agg ( sub.elems )
		else '[]'
		end
	FROM
		(
		SELECT
			jsonb_set ( elem, '{exam_item_name}',  /* examItemName */null ) AS elems
		FROM
			jsonb_array_elements ( exam_order_info ) AS elem
		WHERE elem ->> 'exam_item_cd' =  /* examItemCd */null and 1= /* isDisp */null UNION ALL
		SELECT
			elem AS elems
		FROM
			jsonb_array_elements ( exam_order_info ) AS elem
		WHERE elem ->> 'exam_item_cd' != /* examItemCd */null
		) AS sub
	)
WHERE
	facility_cd = /* facilityCd */null
	AND EXISTS ( SELECT 1 FROM jsonb_array_elements ( exam_order_info ) AS item WHERE item ->> 'exam_item_cd' = /* examItemCd */null )
