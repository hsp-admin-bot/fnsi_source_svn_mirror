UPDATE
		mnt_mainte_main
SET
		is_disp = '0',
		up_date = current_timestamp
WHERE
		mainte_date = /* temDate*/'1000-01-01'
	AND
		machine_no = /* machineNo*/''
    AND
        mainte_layout_group_cd =/* menteLayoutGroupCd*/''
