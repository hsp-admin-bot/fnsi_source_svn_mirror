SELECT
	c.mainte_category_cd,
	c.edition_no,
	c.category_name,
	c.mainte_class,
	c.detail,
	c.up_date
FROM
	mst_mainte_category AS c,
	(
		SELECT
			mos.code, row_number() over() as index
		FROM
			mst_selector mss
			CROSS JOIN lateral jsonb_to_recordset(mss.order_settings->'items') as mos
			(
				code bigint,
				name text
			)
		WHERE
			mss.facility_cd = /* facilityCd */'000000'
			AND
			mss.master_physical_name = 'mst_mainte_category'
	) ms
WHERE
	c.mainte_category_cd = ms.code
	AND
	c.facility_cd = /* facilityCd */'000000'
  /*%if mainteClass != null */
  AND
  c.mainte_class = /* mainteClass */'0'
  /*%end */
	AND
	c.is_disp = '1'
	AND
	c.is_del = '0'
ORDER BY ms.index
