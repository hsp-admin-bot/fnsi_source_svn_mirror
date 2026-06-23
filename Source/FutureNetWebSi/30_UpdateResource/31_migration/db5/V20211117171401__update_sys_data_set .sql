UPDATE "ntss"."sys_data_set" SET "sql" = 'SELECT
	occur_date,
	to_number ( monitor_data ->> ''90'', ''999'' ) AS bp_high,
	to_number ( monitor_data ->> ''91'', ''999'' ) AS bp_low,
	to_number ( monitor_data ->> ''92'', ''999'' ) AS bp_ave,
	to_number ( monitor_data ->> ''93'', ''999'' ) AS pulse,
	to_number ( monitor_data ->> ''94'', ''999'' ) AS body_temperature,
	to_number ( monitor_data ->> ''-1'', ''999'' ) AS blood_glucose_level 
FROM
	mni_monitor 
WHERE
	ord_no = @ordNo 
	AND data_type IN ( 0, 2, 4, 5, 6) 
	AND is_del = ''0'' 
ORDER BY
	occur_date;' WHERE "sql_cd" = 103;
