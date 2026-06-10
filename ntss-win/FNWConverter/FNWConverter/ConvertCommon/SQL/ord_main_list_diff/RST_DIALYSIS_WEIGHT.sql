SELECT
	patid 
FROM
(
	{1}
	SELECT 
		distinct RD.patid
	FROM 
		RST_DIALYSIS_WEIGHT b 
	INNER JOIN RST_DIALYSIS RD on b.dialysis_no = RD.dialysis_no
	WHERE {0}
	UNION
	SELECT
		distinct RD.patid
	FROM
		RST_DIALYSIS_WATER_REMOVE b
	INNER JOIN RST_DIALYSIS RD on b.dialysis_no = RD.dialysis_no
	WHERE {0}
)