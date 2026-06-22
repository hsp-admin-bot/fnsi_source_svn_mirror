INSERT
	INTO
		V_RST_DIALYSIS_ADD(
			PATID,
			DIALYSIS_DATE,
			DIALYSIS_NO,
			CTL_NO,
			UP_DATE,
			EFFECT_FLG,
			EFFECT_DATE,
			ADDITION,
			STAFF_CD,
			STAFF_NAME
		)SELECT
		CASE WHEN LENGTHB(hosppatid) > 12 THEN SUBSTRB(hosppatid, -12) ELSE hosppatid END,
		CASE WHEN LENGTHB(dialysisdate) > 8 THEN SUBSTRB(dialysisdate, -8) ELSE dialysisdate END,
		dialysisno,
		CASE WHEN LENGTHB(ctlno) > 7 THEN SUBSTRB(ctlno, -7) ELSE ctlno END,
		TO_DATE("update",'yyyy-mm-dd hh24:mi:ss'),
		CASE WHEN LENGTHB(effectflg) > 1 THEN SUBSTRB(effectflg, -1) ELSE effectflg END,
		TO_DATE(effectdate,'yyyy-mm-dd hh24:mi:ss'),
		blob_to_varchar2(addition, -1024),
		CASE WHEN LENGTHB(staffcd) > 10 THEN SUBSTRB(staffcd, -10) ELSE staffcd END,
		CASE WHEN LENGTHB(staffname) > 20 THEN SUBSTRB(staffname, -20) ELSE staffname END
		FROM V_RST_DIALYSIS_ADD_TEMP

