INSERT
	INTO
		V_IND_DIALYSIS_COND(
		 PATID,
		 DIALYSIS_DATE,
		 PLURAL,
		 CTL_NO,
		 UP_DATE,
		 DIALYSIS_ITEM_NAME,
		 VALUE,
		 VALUE_NAME,
		 UNIT,
		 VALUE_CD2,
		 INDICATOR_CD,
		 OPE_IND_PLAN,
		 DIALYSIS_NO,
		 DIALYSIS_DATE_NUM
		)SELECT
		CASE WHEN LENGTHB(hosppatid) > 12 THEN SUBSTRB(hosppatid, -12) ELSE hosppatid END,
		CASE WHEN LENGTHB(dialysisdate) > 8 THEN SUBSTRB(dialysisdate, -8) ELSE dialysisdate END,
		plural,
		CASE WHEN LENGTHB(ctlno) > 3 THEN SUBSTRB(ctlno, -3) ELSE ctlno END,
		TO_DATE("update", 'yyyy-mm-dd hh24:mi:ss' ),
		CASE WHEN LENGTHB(dialysisitemname) > 40 THEN SUBSTRB(dialysisitemname, -40) ELSE dialysisitemname END,
		CASE WHEN LENGTHB(value) > 20 THEN SUBSTRB(value, -20) ELSE value END,
		CASE WHEN LENGTHB(valuename) > 100 THEN SUBSTRB(valuename, -100) ELSE valuename END,
		CASE WHEN LENGTHB(unit) > 20 THEN SUBSTRB(unit, -20) ELSE unit END,
		CASE WHEN LENGTHB(valuecd2) > 20 THEN SUBSTRB(valuecd2, -20) ELSE valuecd2 END,
		CASE WHEN LENGTHB(indicatorcd) > 10 THEN SUBSTRB(indicatorcd, -10) ELSE indicatorcd END,
		CASE WHEN LENGTHB(opeindplan) > 1 THEN SUBSTRB(opeindplan, -1) ELSE opeindplan END,
		CASE WHEN LENGTHB(dialysisno) > 20 THEN SUBSTRB(dialysisno, -20) ELSE dialysisno END,
		dialysisdate
		FROM V_IND_DIALYSIS_COND_TEMP

