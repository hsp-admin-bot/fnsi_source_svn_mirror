UPDATE pat_rad_main
SET order_rad_set_info = (
	SELECT
		case when jsonb_agg ( sub.elems ) is not null
		then jsonb_agg ( sub.elems )
		else '[]'
		end
	FROM
		(
		SELECT
			jsonb_set ( elem, '{rad_set_name}',  /* setName */null ) AS elems
		FROM
			jsonb_array_elements ( order_rad_set_info ) AS elem
		WHERE elem ->> 'rad_set_cd' =  /* setCd */null and '1'= /* isDisp */null UNION ALL
		SELECT
			elem AS elems
		FROM
			jsonb_array_elements ( order_rad_set_info ) AS elem
		WHERE elem ->> 'rad_set_cd' != /* setCd */null
		) AS sub
	)
WHERE
	facility_cd = /* facilityCd */null
	AND EXISTS ( SELECT 1 FROM jsonb_array_elements ( order_rad_set_info ) AS item WHERE item ->> 'rad_set_cd' = /* setCd */null )
	AND reg_rad_date > /* regRadDate */'9999/01/01 00:00:00'
