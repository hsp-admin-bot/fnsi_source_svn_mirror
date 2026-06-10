SELECT
rad_result_cd,
facility_cd,
pat_id,
reg_rad_date
	FROM
	pat_rad_main
WHERE
	facility_cd = /* facilityCd */null
	AND EXISTS ( SELECT 1 FROM jsonb_array_elements ( order_rad_set_info ) AS item WHERE item ->> 'rad_set_cd' = /* setCd */null )
	AND reg_rad_date > /* regRadDate */'9999/01/01 00:00:00'
