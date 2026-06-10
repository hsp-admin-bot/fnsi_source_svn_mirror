INSERT
	INTO
		V_PAT_INOUT(
			PATID,
			CTL_NO,
			REG_DATE,
			INOUT_CD,
			FACILITY_NAME,
			DR_NAME,
			MEMO,
			CODE_NAME
		)
	SELECT
		CASE WHEN LENGTHB(hosppatid) > 12 THEN SUBSTRB(hosppatid, -12) ELSE hosppatid END,
		CASE WHEN LENGTHB(ctlno) > 3 THEN SUBSTRB(ctlno, -3) ELSE ctlno END,
		TO_DATE(regdate, 'yyyy-mm-dd hh24:mi:ss'),
		CASE WHEN LENGTHB(inoutcd) > 1 THEN SUBSTRB(inoutcd, -1) ELSE inoutcd END,
		CASE WHEN LENGTHB(facilityname) > 100 THEN SUBSTRB(facilityname, -100) ELSE facilityname END,
		CASE WHEN LENGTHB(drname) > 20 THEN SUBSTRB(drname, -20) ELSE drname END,
		CASE WHEN LENGTHB(memo) > 256 THEN SUBSTRB(memo, -256) ELSE memo END,
		CASE WHEN LENGTHB(codename) > 4 THEN SUBSTRB(codename, -4) ELSE codename END
	FROM V_PAT_INOUT_TEMP

