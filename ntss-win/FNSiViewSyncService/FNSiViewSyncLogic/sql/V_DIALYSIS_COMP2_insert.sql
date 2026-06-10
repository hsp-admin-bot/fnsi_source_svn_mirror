INSERT
	INTO
		V_DIALYSIS_COMP(
			PATID,
			OCCUR_DATE,
			MEASURECLASS,
			REQCODE,
			COMPLAINT,
			TREAT_NAME,
			MEDICINE_CD1,
			MEDICINE_CD2,
			MEDICINE_NAME,
			AMOUNT,
			UNIT,
			PROCEDURE_NAME,
			PROCEDURE_CD1,
			PROCEDURE_CD2,
			TREAT_PERSON_NAME,
			UP_DATE,
			ORD_NO,
			COMP_CD,
			TREAT_CD,
			DIALYSIS_DATE
		)
	SELECT
		CASE WHEN LENGTHB(hosppatid) > 12 THEN SUBSTRB(hosppatid, -12) ELSE hosppatid END,
		TO_DATE(occurdate, 'yyyy-mm-dd hh24:mi:ss'),
		CASE WHEN LENGTHB(measureclass) > 1 THEN SUBSTRB(measureclass, -1) ELSE measureclass END,
		CASE WHEN LENGTHB(reqcode) > 10 THEN SUBSTRB(reqcode, -10) ELSE reqcode END,
		CASE WHEN LENGTHB(complaint) > 256 THEN SUBSTRB(complaint, -256) ELSE complaint END,
		CASE WHEN LENGTHB(treatname) > 256 THEN SUBSTRB(treatname, -256) ELSE treatname END,
		CASE WHEN LENGTHB(medicinecd1) > 20 THEN SUBSTRB(medicinecd1, -20) ELSE medicinecd1 END,
		CASE WHEN LENGTHB(medicinecd2) > 20 THEN SUBSTRB(medicinecd2, -20) ELSE medicinecd2 END,
		CASE WHEN LENGTHB(medicinename) > 80 THEN SUBSTRB(medicinename, -80) ELSE medicinename END,
		amount,
		CASE WHEN LENGTHB(unit) > 20 THEN SUBSTRB(unit, -20) ELSE unit END,
		CASE WHEN LENGTHB(procedurename) > 40 THEN SUBSTRB(procedurename, -40) ELSE procedurename END,
		CASE WHEN LENGTHB(procedurecd1) > 20 THEN SUBSTRB(procedurecd1, -20) ELSE procedurecd1 END,
		CASE WHEN LENGTHB(procedurecd2) > 20 THEN SUBSTRB(procedurecd2, -20) ELSE procedurecd2 END,
		CASE WHEN LENGTHB(treatpersonname) > 20 THEN SUBSTRB(treatpersonname, -20) ELSE treatpersonname END,
		TO_DATE("update", 'yyyy-mm-dd hh24:mi:ss'),
		ordno,
		CASE WHEN LENGTHB(compcd) > 20 THEN SUBSTRB(compcd, -20) ELSE compcd END,
		CASE WHEN LENGTHB(treatcd) > 20 THEN SUBSTRB(treatcd, -20) ELSE treatcd END,
		CASE WHEN LENGTHB(dialysisdate) > 8 THEN SUBSTRB(dialysisdate, -8) ELSE dialysisdate END
	FROM V_DIALYSIS_COMP2_TEMP

