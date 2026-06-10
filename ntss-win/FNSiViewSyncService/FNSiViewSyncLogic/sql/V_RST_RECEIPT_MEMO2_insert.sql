INSERT
	INTO
		V_RST_RECEIPT_MEMO(
		 PATID,
		 DIALYSIS_DATE,
		 DIALYSIS_NO,
		 CTL_NO,
		 UP_DATE,
		 DIVISION,
		 CODE,
		 CODE_UPDATE,
		 ADD_FLG,
		 ITEM_NAME,
		 MAIN_DIAL_DIFF,
		 IN_HOSPITAL_CD,
		 IN_HOSPITAL_CD2
		)SELECT
		CASE WHEN LENGTHB(hosppatid) > 12 THEN SUBSTRB(hosppatid, -12) ELSE hosppatid END,
		CASE WHEN LENGTHB(dialysisdate) > 8 THEN SUBSTRB(dialysisdate, -8) ELSE dialysisdate END,
		CASE WHEN LENGTHB(dialysisno) > 12 THEN SUBSTRB(dialysisno, -12) ELSE dialysisno END,
		CASE WHEN LENGTHB(ctlno) > 7 THEN to_char(SUBSTRB(ctlno, -7), 'FM0000000') ELSE to_char(ctlno, 'FM0000000') END,
		TO_DATE("update",'yyyy-mm-dd hh24:mi:ss'),
		CASE WHEN LENGTHB(division) > 1 THEN SUBSTRB(division, -1) ELSE division END,
		CASE WHEN LENGTHB(code) > 4 THEN SUBSTRB(code, -4) ELSE code END,
		TO_DATE(codeupdate,'yyyy-mm-dd hh24:mi:ss'),
		CASE WHEN LENGTHB(addflg) > 1 THEN SUBSTRB(addflg, -1) ELSE addflg END,
		CASE WHEN LENGTHB(itemname) > 256 THEN SUBSTRB(itemname, -256) ELSE itemname END,
		CASE WHEN LENGTHB(maindialdiff) > 1 THEN SUBSTRB(maindialdiff, -1) ELSE maindialdiff END,
		CASE WHEN LENGTHB(inhospitalcd) > 20 THEN SUBSTRB(inhospitalcd, -20) ELSE inhospitalcd END,
		CASE WHEN LENGTHB(inhospitalcd2) > 20 THEN SUBSTRB(inhospitalcd2, -20) ELSE inhospitalcd2 END
		FROM V_RST_RECEIPT_MEMO2_TEMP