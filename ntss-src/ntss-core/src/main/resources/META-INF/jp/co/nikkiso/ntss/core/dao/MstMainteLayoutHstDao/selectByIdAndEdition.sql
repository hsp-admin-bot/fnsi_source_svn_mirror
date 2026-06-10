SELECT
		/*%expand "A" */*
FROM
		mst_mainte_layout_hst A
WHERE
		mainte_layout_cd = /* mainteLayoutCd*/'0'
	AND edition_no = /* editionNo*/'0'
	AND facility_cd = /* facilityCd*/'000000'
;
