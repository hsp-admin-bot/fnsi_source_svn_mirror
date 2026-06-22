DELETE FROM pat_insurance
WHERE insurance_cd = 621;

INSERT INTO
    pat_insurance
	(
	insurance_cd,
	pat_id,
	facility_cd,
	ctl_no,
	fn_pat_id,
	insu_class,
	insu_name,
	insu_name_short,
	start_date,
	end_date,
	check_date,
	insu_info,
	insu_pub_info,
	insu_set_info,
	insu_self_info,
	is_selected,
	is_disp,
	is_del,
	coop_code,
	is_coop,
	reg_date,
	up_date
	)
VALUES
	(
		/*patInsurance.insurance_cd*/621,
		/*patInsurance.pat_id*/1000621,
		/*patInsurance.facility_cd*/'F_h621',
		/*patInsurance.ctl_no*/1,
		/*patInsurance.fn_pat_id*/NULL,
		/*patInsurance.insu_class*/0,
		/*patInsurance.insu_name*/'',
		/*patInsurance.insu_name_short*/'',
		/*patInsurance.start_date*/NULL,
		/*patInsurance.end_date*/NULL,
		/*patInsurance.check_date*/NULL,
		json_build_object(
			'insu_pat_name', personal_info_encrypt(/*patInsurance.insu_info.get("insu_pat_name")*/NULL),
			'is_main_insu', (/*patInsurance.insu_info.get("is_main_insu")*/NULL)::text,
			'insu_no', (/*patInsurance.insu_info.get("insu_no")*/NULL)::text,
			'insu_kbn', (/*patInsurance.insu_info.get("insu_kbn")*/NULL)::text,
			'insu_pat_mark', personal_info_encrypt(/*patInsurance.insu_info.get("insu_pat_mark")*/NULL),
			'insu_pat_no', personal_info_encrypt(/*patInsurance.insu_info.get("insu_pat_no")*/NULL),
			'cki_class', (/*patInsurance.insu_info.get("cki_class")*/NULL)::text,
			'kki_class', (/*patInsurance.insu_info.get("kki_class")*/NULL)::text,
			'und_six', (/*patInsurance.insu_info.get("und_six")*/NULL)::text,
			'futan-g', (/*patInsurance.insu_info.get("futan-g")*/NULL)::text,
			'futan-n', (/*patInsurance.insu_info.get("futan-n")*/NULL)::text
 		),
		json_build_object(
			'insu_pub_name', personal_info_encrypt(/*patInsurance.insu_pub_info.get("insu_pub_name")*/NULL),
			'insu_pub_no', personal_info_encrypt(/*patInsurance.insu_pub_info.get("insu_pub_no")*/NULL),
			'insu_pub_pat_no', personal_info_encrypt(/*patInsurance.insu_pub_info.get("insu_pub_pat_no")*/NULL)
 		),
		json_build_object(
			'insu_cd', (/*patInsurance.insu_set_info.get("insu_cd")*/NULL)::text,
			'insu_pub1_cd', (/*patInsurance.insu_set_info.get("insu_pub1_cd")*/NULL)::text,
			'insu_pub2_cd', (/*patInsurance.insu_set_info.get("insu_pub2_cd")*/NULL)::text,
			'insu_pub3_cd', (/*patInsurance.insu_set_info.get("insu_pub3_cd")*/NULL)::text,
			'insu_pub4_cd', (/*patInsurance.insu_set_info.get("insu_pub4_cd")*/NULL)::text
 		),
		json_build_object(
			'insu_self_name', (/*patInsurance.insu_self_info.get("insu_self_name")*/NULL)::text,
			'insu_self_date', (/*patInsurance.insu_self_info.get("insu_self_date")*/NULL)::text
		),
		/*patInsurance.is_selected*/NULL,
		/*patInsurance.is_disp*/'1',
		/*patInsurance.is_del*/'0',
		'06121212',
		'1',
		to_timestamp(/*patInsurance.reg_date*/NULL, 'YYYYMMDD'),
		to_timestamp(/*patInsurance.up_date*/NULL, 'YYYYMMDD')
	);