SELECT
	dialysis_no 
FROM
(
	{2}
	SELECT 
		distinct b.dialysis_no 
	FROM 
		RST_DIALYSIS_WEIGHT b 
	INNER JOIN RST_DIALYSIS RD on b.dialysis_no = RD.dialysis_no
	WHERE {0} AND {1}
	UNION
	SELECT
		distinct b.dialysis_no
	FROM
		RST_DIALYSIS_WATER_REMOVE b
	INNER JOIN RST_DIALYSIS RD on b.dialysis_no = RD.dialysis_no
	WHERE {0} AND {1}
)