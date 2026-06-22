INSERT
	INTO
		V_RST_DIALYSIS_COND_CARD(
		 PATID,
		 DIALYSIS_DATE,
		 DIALYSIS_NO,
		 CTL_NO,
		 UP_DATE,
		 DIALYSIS_ITEM_NAME,
		 VALUE,
		 VALUE_NAME,
		 MED_GENERAL_NAME,
		 UNIT,
		 VALUE_CD2
		)SELECT
		CASE WHEN LENGTHB(hosppatid) > 12 THEN SUBSTRB(hosppatid, -12) ELSE hosppatid END,
		CASE WHEN LENGTHB(dialysisdate) > 8 THEN SUBSTRB(dialysisdate, -8) ELSE dialysisdate END,
		dialysisno,
		CASE WHEN LENGTHB(ctlno) > 3 THEN SUBSTRB(ctlno, -3) ELSE ctlno END,
		TO_DATE("update",'yyyy-mm-dd hh24:mi:ss'),
		CASE WHEN LENGTHB(dialysisitemname) > 40 THEN SUBSTRB(dialysisitemname, -40) ELSE dialysisitemname END,
		CASE WHEN LENGTHB(value) > 20 THEN SUBSTRB(value, -20) ELSE value END,
		CASE WHEN LENGTHB(valuename) > 100 THEN SUBSTRB(valuename, -100) ELSE valuename END,
		CASE WHEN LENGTHB(medgeneralname) > 100 THEN SUBSTRB(medgeneralname, -100) ELSE medgeneralname END,
		CASE WHEN LENGTHB(unit) > 20 THEN SUBSTRB(unit, -20) ELSE unit END, 
		CASE WHEN LENGTHB(valuecd2) > 20 THEN SUBSTRB(valuecd2, -20) ELSE valuecd2 END
		FROM V_RST_DIALYSIS_COND_CARD_TEMP

