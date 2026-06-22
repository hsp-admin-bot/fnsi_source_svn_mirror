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
			elem AS elems
		FROM
			jsonb_array_elements ( /* examOrderInfo */null :: jsonb) AS elem
		UNION ALL
		SELECT
			elem AS elems
		FROM
			jsonb_array_elements ( exam_order_info ) AS elem
		WHERE elem ->> 'set_cd' != /* setCd */null
		) AS sub
	),
	order_exam_set_info = (
	SELECT
		case when jsonb_agg ( sub.elems ) is not null
		then jsonb_agg ( sub.elems )
		else '[]'
		end
	FROM
		(
		SELECT
			jsonb_set ( elem, '{set_name}',  /* setName */null ) AS elems
		FROM
			jsonb_array_elements ( order_exam_set_info ) AS elem
		WHERE elem ->> 'set_cd' =  /* setCd */null and '1'= /* isDisp */null UNION ALL
		SELECT
			elem AS elems
		FROM
			jsonb_array_elements ( order_exam_set_info ) AS elem
		WHERE elem ->> 'set_cd' != /* setCd */null
		) AS sub
	)
WHERE
	facility_cd = /* facilityCd */null
	AND EXISTS ( SELECT 1 FROM jsonb_array_elements ( exam_order_info ) AS item WHERE item ->> 'set_cd' = /* setCd */null )
	AND reg_exam_date > /* regExamDate */'9999/01/01 00:00:00'
