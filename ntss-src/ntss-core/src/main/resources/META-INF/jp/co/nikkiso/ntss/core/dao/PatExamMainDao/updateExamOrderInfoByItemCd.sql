UPDATE pat_exam_main
SET exam_order_info = (
	SELECT
		case when jsonb_agg ( sub.elems )  is not null
		then jsonb_agg ( sub.elems )
		else '[]'
		end
	FROM
		(
		SELECT
			jsonb_set ( elem, '{item_name}',   /* examItemName */null  ) AS elems
		FROM
			jsonb_array_elements ( exam_order_info ) AS elem
		WHERE elem ->> 'item_cd' =  /* examItemCd */null and 1= /* isDisp */null UNION ALL
		SELECT
			elem AS elems
		FROM
			jsonb_array_elements ( exam_order_info ) AS elem
		WHERE elem ->> 'item_cd' != /* examItemCd */null
		) AS sub
	)
WHERE
	facility_cd = /* facilityCd */null
	AND EXISTS ( SELECT 1 FROM jsonb_array_elements ( exam_order_info ) AS item WHERE item ->> 'item_cd' = /* examItemCd */null )
	AND reg_exam_date > /* regExamDate */'9999/01/01 00:00:00'
