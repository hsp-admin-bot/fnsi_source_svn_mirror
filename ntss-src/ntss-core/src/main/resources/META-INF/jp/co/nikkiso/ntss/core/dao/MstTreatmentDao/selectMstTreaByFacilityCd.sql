SELECT report_id FROM  mst_treatment WHERE treatment_cd = (  SELECT
		TO_NUMBER( order_cd ->> 'code', '999999999999' ) AS medic_code
	FROM
		mst_selector
		CROSS JOIN LATERAL jsonb_array_elements ( order_settings -> 'items' ) WITH ORDINALITY AS tmp ( order_cd, index_no )
	WHERE
		facility_cd = /* facilityCd*/'0'
		AND master_physical_name = 'mst_treatment' ORDER BY TO_NUMBER( order_cd ->> 'code', '999999999999' )  LIMIT 1 )
