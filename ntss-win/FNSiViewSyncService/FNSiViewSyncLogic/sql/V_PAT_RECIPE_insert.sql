INSERT
	INTO
		V_PAT_RECIPE(
			PATID,
			PRESCRIPT_NO,
			UP_DATE,
			EXECUTE_DATE,
			CTL_NO,
			MEDICINE_NAME,
			MEDICINE_CD,
			MEDICINE_CD2,
			QUANTITY,
			UNIT,
			DOSAGE,
			TAKE_MEDICINE_CD,
			TAKE_MEDICINE_NAME,
			DAY_COUNT,
			PRESCRIPTER_CD,
			PRESCRIPTER_NAME,
			NOTE
		)
	SELECT
		CASE WHEN LENGTHB(hosppatid) > 12 THEN SUBSTRB(hosppatid, -12) ELSE hosppatid END,
		prescriptno,
		TO_DATE("update", 'yyyy-mm-dd hh24:mi:ss'),
		CASE WHEN LENGTHB(executedate) > 8 THEN SUBSTRB(executedate, -8) ELSE executedate END,
		CASE WHEN LENGTHB(ctlno) > 3 THEN SUBSTRB(ctlno, -3) ELSE ctlno END,
		CASE WHEN LENGTHB(medicinename) > 80 THEN SUBSTRB(medicinename, -80) ELSE medicinename END,
		CASE WHEN LENGTHB(medicinecd) > 20 THEN SUBSTRB(medicinecd, -20) ELSE medicinecd END,
		CASE WHEN LENGTHB(medicinecd2) > 20 THEN SUBSTRB(medicinecd2, -20) ELSE medicinecd2 END,
		quantity,
		CASE WHEN LENGTHB(unit) > 20 THEN SUBSTRB(unit, -20) ELSE unit END,
		dosage,
		CASE WHEN LENGTHB(takemedicinecd) > 3 THEN SUBSTRB(takemedicinecd, -3) ELSE takemedicinecd END,
		CASE WHEN LENGTHB(takemedicinename) > 40 THEN SUBSTRB(takemedicinename, -40) ELSE takemedicinename END,
		daycount,
		CASE WHEN LENGTHB(prescriptercd) > 10 THEN SUBSTRB(prescriptercd, -10) ELSE prescriptercd END,
		CASE WHEN LENGTHB(prescriptername) > 20 THEN SUBSTRB(prescriptername, -20) ELSE prescriptername END,
		blob_to_varchar2(note, -1024)
    FROM V_PAT_RECIPE_TEMP

