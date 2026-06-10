INSERT
	INTO
		V_RST_DIALYSIS_EQUIP(
		 PATID,
		 DIALYSIS_DATE,
		 DIALYSIS_NO,
		 CTL_NO,
		 UP_DATE,
		 EQUIP_CD,
		 EQUIP_CD2,
		 EQUIP_NAME,
		 EQUIP_CLASS_NAME,
		 PUNCTURE_CLASS,
		 AMOUNT,
		 UNIT,
		 COMMENTS
		)SELECT
		CASE WHEN LENGTHB(hosppatid) > 12 THEN SUBSTRB(hosppatid, -12) ELSE hosppatid END,
		CASE WHEN LENGTHB(dialysisdate) > 8 THEN SUBSTRB(dialysisdate, -8) ELSE dialysisdate END,
		dialysisno,
		CASE WHEN LENGTHB(ctlno) > 7 THEN SUBSTRB(ctlno, -7) ELSE ctlno END,
		TO_DATE("update",'yyyy-mm-dd hh24:mi:ss'),
		CASE WHEN LENGTHB(equipcd) > 20 THEN SUBSTRB(equipcd, -20) ELSE equipcd END,
		CASE WHEN LENGTHB(equipcd2) > 20 THEN SUBSTRB(equipcd2, -20) ELSE equipcd2 END,
		CASE WHEN LENGTHB(equipname) > 40 THEN SUBSTRB(equipname, -40) ELSE equipname END,
		CASE WHEN LENGTHB(equipclassname) > 40 THEN SUBSTRB(equipclassname, -40) ELSE equipclassname END,
		CASE WHEN LENGTHB(punctureclass) > 1 THEN SUBSTRB(punctureclass, -1) ELSE punctureclass END,
		amount,
		CASE WHEN LENGTHB(unit) > 20 THEN SUBSTRB(unit, -20) ELSE unit END,
		blob_to_varchar2(comments, -1024)
		FROM V_RST_DIALYSIS_EQUIP_TEMP
