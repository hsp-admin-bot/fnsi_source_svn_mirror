INSERT
	INTO
		V_PAT_DEVICE_SET(
			PATID,
			NAME,
			CTL_NO,
			SET_NAME,
			VALUE,
			UP_DATE,
			MON_VALUE,
			MON_UP_DATE,
			TUE_VALUE,
			TUE_UP_DATE,
			WED_VALUE,
			WED_UP_DATE,
			THU_VALUE,
			THU_UP_DATE,
			FRI_VALUE,
			FRI_UP_DATE,
			SAT_VALUE,
			SAT_UP_DATE,
			SUN_VALUE,
			SUN_UP_DATE
		)
	SELECT
		CASE WHEN LENGTHB(hosppatid) > 12 THEN SUBSTRB(hosppatid, -12) ELSE hosppatid END,
		CASE WHEN LENGTHB(name) > 40 THEN SUBSTRB(name, -40) ELSE name END,
		CASE WHEN LENGTHB(ctlno) > 4 THEN SUBSTRB(ctlno, -4) ELSE ctlno END,
		CASE WHEN LENGTHB(setname) > 100 THEN SUBSTRB(setname, -100) ELSE setname END,
		CASE WHEN REGEXP_LIKE(value, '^-?[0-9]+(\.[0-9]+)?$') THEN value ELSE NULL END,
		TO_DATE("update", 'yyyy-mm-dd hh24:mi:ss' ),		
		CASE WHEN REGEXP_LIKE(monvalue, '^-?[0-9]+(\.[0-9]+)?$') THEN monvalue ELSE NULL END,
		TO_DATE(monupdate, 'yyyy-mm-dd hh24:mi:ss' ),
		CASE WHEN REGEXP_LIKE(tuevalue, '^-?[0-9]+(\.[0-9]+)?$') THEN tuevalue ELSE NULL END,
		TO_DATE(tueupdate, 'yyyy-mm-dd hh24:mi:ss' ),
		CASE WHEN REGEXP_LIKE(wedvalue, '^-?[0-9]+(\.[0-9]+)?$') THEN wedvalue ELSE NULL END,
		TO_DATE(wedupdate, 'yyyy-mm-dd hh24:mi:ss' ),
		CASE WHEN REGEXP_LIKE(thuvalue, '^-?[0-9]+(\.[0-9]+)?$') THEN thuvalue ELSE NULL END,
		TO_DATE(thuupdate, 'yyyy-mm-dd hh24:mi:ss' ),
		CASE WHEN REGEXP_LIKE(frivalue, '^-?[0-9]+(\.[0-9]+)?$') THEN frivalue ELSE NULL END,
		TO_DATE(friupdate, 'yyyy-mm-dd hh24:mi:ss' ),
		CASE WHEN REGEXP_LIKE(satvalue, '^-?[0-9]+(\.[0-9]+)?$') THEN satvalue ELSE NULL END,
		TO_DATE(satupdate, 'yyyy-mm-dd hh24:mi:ss' ),
		CASE WHEN REGEXP_LIKE(sunvalue, '^-?[0-9]+(\.[0-9]+)?$') THEN sunvalue ELSE NULL END,
		TO_DATE(sunupdate, 'yyyy-mm-dd hh24:mi:ss' )
	FROM V_PAT_DEVICE_SET_TEMP

