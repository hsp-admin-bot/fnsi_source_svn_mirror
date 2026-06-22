INSERT
	INTO
		V_PAT_INFECT(
			PATID,
			INFECTION_CD,
			INFECTION_NAME,
			UP_DATE,
			INFECT
		)SELECT
		CASE WHEN LENGTHB(hosppatid) > 12 THEN SUBSTRB(hosppatid, -12) ELSE hosppatid END,
		CASE WHEN LENGTHB(infectioncd) > 20 THEN SUBSTRB(infectioncd, -20) ELSE infectioncd END,
		CASE WHEN LENGTHB(infectionname) > 100 THEN SUBSTRB(infectionname, -100) ELSE infectionname END,
		TO_DATE("update", 'yyyy-mm-dd hh24:mi:ss' ),
		CASE WHEN LENGTHB(infect) > 1 THEN SUBSTRB(infect, -1) ELSE infect END
		FROM V_PAT_INFECT_TEMP

