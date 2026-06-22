INSERT
	INTO
		V_IND_DIALYSIS_ADD(
		 PATID,
		 DIALYSIS_DATE,
		 PLURAL,
		 CTL_NO,
		 UP_DATE,
		 ADDITION,
		 INDICATOR_CD,
		 OPE_IND_PLAN,
		 DIALYSIS_NO
		)
	SELECT
		CASE WHEN LENGTHB( hosppatid)  > 12 THEN SUBSTRB( hosppatid, -12) ELSE  hosppatid END,
		CASE WHEN LENGTHB( dialysisdate)  > 8 THEN SUBSTRB( dialysisdate, -8) ELSE  dialysisdate END,
		plural,
		CASE WHEN LENGTHB( ctlno)  > 7 THEN SUBSTRB( ctlno, -7) ELSE  ctlno END,
		TO_DATE( "update",'yyyy-mm-dd hh24:mi:ss'),
		blob_to_varchar2( addition, -1024) ,
		CASE WHEN LENGTHB( indicatorcd)  > 10 THEN SUBSTRB( indicatorcd, -10) ELSE  indicatorcd END,
		CASE WHEN LENGTHB( opeindplan)  > 1 THEN SUBSTRB( opeindplan, -1) ELSE  opeindplan END,
		CASE WHEN LENGTHB( dialysisno)  > 20 THEN SUBSTRB( dialysisno, -20) ELSE  dialysisno END
	FROM V_IND_DIALYSIS_ADD2_TEMP

