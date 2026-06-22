INSERT
	INTO
		V_PAT_CONTACT(
			PATID,
			NAME,
			CTL_NO,
			UP_DATE,
			REG_DATE,
			RELATION_NAME,
			RNAME,
			ZIPCODE,
			ADDRESS,
			ADDRESS_DETAIL,
			TELNO1,
			TELNO2,
			MEMO
		)SELECT
		CASE WHEN LENGTHB(hosppatid) > 12 THEN SUBSTRB(hosppatid, -12) ELSE hosppatid END,
		CASE WHEN LENGTHB(name) > 40 THEN SUBSTRB(name, -40) ELSE name END,
		ctlno,
		TO_DATE("update", 'yyyy-mm-dd hh24:mi:ss' ),
		TO_DATE(regdate, 'yyyy-mm-dd hh24:mi:ss' ),
		CASE WHEN LENGTHB(relationname) > 50 THEN SUBSTRB(relationname, -50) ELSE relationname END,
		CASE WHEN LENGTHB(rname) > 40 THEN SUBSTRB(rname, -40) ELSE rname END,
		CASE WHEN LENGTHB(zipcode) > 8 THEN SUBSTRB(zipcode, -8) ELSE zipcode END,
		CASE WHEN LENGTHB(address) > 256 THEN SUBSTRB(address, 1, 256) ELSE address END,
		CASE WHEN LENGTHB(address) > 256 THEN SUBSTRB(address, 257, 256) ELSE '' END,
		CASE WHEN LENGTHB(telno1) > 25 THEN SUBSTRB(telno1, -25) ELSE telno1 END,
		CASE WHEN LENGTHB(telno2) > 25 THEN SUBSTRB(telno2, -25) ELSE telno2 END,
		blob_to_varchar2(memo, -2048)
		FROM V_PAT_CONTACT_TEMP

