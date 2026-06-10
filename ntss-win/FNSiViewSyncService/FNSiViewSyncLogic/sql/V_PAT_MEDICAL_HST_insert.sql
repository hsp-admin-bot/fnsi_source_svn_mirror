INSERT
	INTO
		V_PAT_MEDICAL_HST(
		 PATID,
		 CTL_NO,
		 UP_DATE,
		 DISEASE_CD,
		 DISEASE_NAME,
		 DISEASE_DATE,
		 RECOVER_DATE,
		 MAIN_DISEASE,
		 STATUS,
		 NOTICE_FLG,
		 DOCTOR_NAME,
		 MEMO
		)SELECT
		CASE WHEN LENGTHB(hosppatid) > 12 THEN SUBSTRB(hosppatid, -12) ELSE hosppatid END,
		ctlno, 
		TO_DATE("update",'yyyy-mm-dd hh24:mi:ss'),
		CASE WHEN LENGTHB(diseasecd) > 20 THEN SUBSTRB(diseasecd, -20) ELSE diseasecd END,
		CASE WHEN LENGTHB(diseasename) > 100 THEN SUBSTRB(diseasename, -100) ELSE diseasename END,
		TO_DATE(diseasedate,'yyyy-mm-dd hh24:mi:ss'),
		TO_DATE(recoverdate,'yyyy-mm-dd hh24:mi:ss'),
		CASE WHEN LENGTHB(maindisease) > 1 THEN SUBSTRB(maindisease, -1) ELSE maindisease END,
		CASE WHEN LENGTHB(status) > 1 THEN SUBSTRB(status, -1) ELSE status END,
		CASE WHEN LENGTHB(noticeflg) > 1 THEN SUBSTRB(noticeflg, -1) ELSE noticeflg END,
		CASE WHEN LENGTHB(doctorname) > 20 THEN SUBSTRB(doctorname, -20) ELSE doctorname END,
		CASE WHEN LENGTHB(memo) > 256 THEN SUBSTRB(memo, -256) ELSE memo END
		FROM V_PAT_MEDICAL_HST_TEMP

