SELECT
	DIALYSIS_NO
FROM
	(
	SELECT
		s.DIALYSIS_NO,
		row_number ( ) over ( partition BY s.DIALYSIS_NO ORDER BY a.UP_DATE DESC ) AS num1 
	FROM
		RST_DIALYSIS s
		INNER JOIN (
		SELECT
			* 
		FROM
			( 
				SELECT RD.*, row_number ( ) over ( partition BY RD.SEQ_ID ORDER BY RD.UP_DATE DESC ) AS num 
				FROM PAT_LIFE_LIST RD 
				WHERE {0} and {1} ) d 
		WHERE
			d.num = 1 
		) a ON a.PATID = s.PATID 
		AND to_date( a.reg_date || a.reg_time, 'YYYYMMDDHH24MISS' ) BETWEEN s.ENTER_DATE 
		AND s.LEAVE_DATE
		LEFT JOIN (
		SELECT
			* 
		FROM
			( SELECT KIND_ID, KIND_NAME, row_number ( ) over ( partition BY KIND_ID ORDER BY UP_DATE DESC ) AS num FROM MST_LLT_KIND ) mm
		WHERE 
			num = 1 
		) m ON m.KIND_ID = a.KIND_ID
	WHERE
		 a.KIND_ID = (select R_R from SYNC_CONDSET where SERIES_CD=:SERIES_CD)
	) r 
WHERE
	num1 = 1