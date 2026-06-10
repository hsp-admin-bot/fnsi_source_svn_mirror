UPDATE
		mnt_mainte_main
SET
		is_disp = '0',
		up_date = current_timestamp
WHERE
		mainte_no in /* mainNoList*/(0)