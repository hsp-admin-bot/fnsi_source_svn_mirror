SELECT 
	ind_treatment_cd,
	ind_kur_cd,
	ind_bed_cd,
	ind_schedule_user_info,
    ind_cond_info,
    ind_medi_info,
	ind_equip_info,
	ind_ind_comment_info,
	facility_cd
FROM ord_main
WHERE ord_no = /*ord_no*/1