SELECT
	c.mainte_category_cd,
	c.category_name,
	d.mainte_detail_cd,
	d.mainte_content_1,
	d.mainte_content_2,
	d.mainte_content_3
FROM
    mst_mainte_category c
    CROSS JOIN LATERAL jsonb_array_elements(c.detail) detail_info
    LEFT JOIN mst_mainte_detail d ON d.mainte_detail_cd::TEXT = detail_info ->> 'code' AND d.mainte_class = /* mainteClass*/''
WHERE
    c.facility_cd = /* facilityCd*/''
AND
    c.mainte_class = /* mainteClass*/''
AND
    c.is_disp = '1'
AND
    c.is_del = '0'
AND
    detail_info ->> 'code' is not null
AND
    detail_info ->> 'isDisp' = '1'
AND
    detail_info ->> 'mainteClass' = /* mainteClass*/''
ORDER BY
    c.mainte_category_cd, d.mainte_detail_cd
