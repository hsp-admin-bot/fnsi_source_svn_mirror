INSERT
	INTO
		V_LOG_DEV_MENTE
		(
		DEVICE_NO,
		DEVICE_NAME,
		DEVICE_SERIAL,
		MEINTE_DATE,
		MEINTE_TIME,
		MEINTE_RESULT,
		MEINTE_GEN,
		MEINTE_MORE,
		MEINTE_YMORE,
		MEINTE_JYO,
		MEINTE_BARA,
		MEINTE_ETCF,
		MEINTE_ETCF2
		)
	SELECT
		CASE WHEN REGEXP_LIKE(deviceno, '^-?[0-9]+(\.[0-9]+)?$') THEN deviceno ELSE NULL END,
		CASE WHEN LENGTHB(devicename) > 40 THEN SUBSTRB(devicename, -40) ELSE devicename END,
		CASE WHEN LENGTHB(deviceserial) > 20 THEN SUBSTRB(deviceserial, -20) ELSE deviceserial END,
		CASE WHEN LENGTHB(meintedate) > 8 THEN SUBSTRB(meintedate, -8) ELSE meintedate END,
		CASE WHEN LENGTHB(meintetime) > 4 THEN SUBSTRB(meintetime, -4) ELSE meintetime END,
		CASE WHEN LENGTHB(meinteresult) > 256 THEN SUBSTRB(meinteresult, -256) ELSE meinteresult END,
		meintegen,
		meintemore,
		meinteymore,
		meintejyo,
		meintebara,
		meinteetcf,
		meinteetcf2
		FROM V_LOG_DEV_MENTE2_TEMP