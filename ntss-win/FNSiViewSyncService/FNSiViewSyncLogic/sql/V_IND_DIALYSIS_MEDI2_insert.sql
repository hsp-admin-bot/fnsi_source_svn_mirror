INSERT
	INTO
		V_IND_DIALYSIS_MEDI(
		 PATID,
		 DIALYSIS_DATE,
		 PLURAL,
		 CTL_NO,
		 UP_DATE,
		 MEDICINE_CD,
		 MEDICINE_CD2,
		 MEDICINE_NAME,
		 MEDI_CLASS_NAME,
		 AMOUNT,
		 UNIT,
		 TIMING_NAME,
		 PROCEDURE_CD,
		 PROCEDURE_CD2,
		 PROCEDURE_NAME,
		 COMMENTS,
		 INDICATOR_CD,
		 OPE_IND_PLAN,
		 DIALYSIS_NO
		)
	SELECT
		CASE WHEN LENGTHB(hosppatid) > 12 THEN SUBSTRB(hosppatid, -12) ELSE hosppatid END,
		CASE WHEN LENGTHB(dialysisdate) > 8 THEN SUBSTRB(dialysisdate, -8) ELSE dialysisdate END,
		plural,
		CASE WHEN LENGTHB(ctlno) > 7 THEN SUBSTRB(ctlno, -7) ELSE ctlno END,
		TO_DATE("update",'yyyy-mm-dd hh24:mi:ss'),
		CASE WHEN LENGTHB(medicinecd) > 20 THEN SUBSTRB(medicinecd, -20) ELSE medicinecd END,
		CASE WHEN LENGTHB(medicinecd2) > 20 THEN SUBSTRB(medicinecd2, -20) ELSE medicinecd2 END,
		CASE WHEN LENGTHB(medicinename) > 80 THEN SUBSTRB(medicinename, -80) ELSE medicinename END,
		CASE WHEN LENGTHB(mediclassname) > 40 THEN SUBSTRB(mediclassname, -40) ELSE mediclassname END,
		amount,
		CASE WHEN LENGTHB(unit) > 20 THEN SUBSTRB(unit, -20) ELSE unit END,
		CASE WHEN LENGTHB(timingname) > 40 THEN SUBSTRB(timingname, -40) ELSE timingname END,
		CASE WHEN LENGTHB(procedurecd) > 20 THEN SUBSTRB(procedurecd, -20) ELSE procedurecd END,
		CASE WHEN LENGTHB(procedurecd2) > 20 THEN SUBSTRB(procedurecd2, -20) ELSE procedurecd2 END,
		CASE WHEN LENGTHB(procedurename) > 40 THEN SUBSTRB(procedurename, -40) ELSE procedurename END,
		blob_to_varchar2(comments, -1024),
		CASE WHEN LENGTHB(indicatorcd) > 10 THEN SUBSTRB(indicatorcd, -10) ELSE indicatorcd END,
		CASE WHEN LENGTHB(opeindplan) > 1 THEN SUBSTRB(opeindplan, -1) ELSE opeindplan END,
		CASE WHEN LENGTHB(dialysisno) > 20 THEN SUBSTRB(dialysisno, -20) ELSE dialysisno END
	FROM V_IND_DIALYSIS_MEDI2_TEMP

