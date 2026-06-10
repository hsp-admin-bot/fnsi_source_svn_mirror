UPDATE 
	pat_insurance
SET 
	pat_id = /*patInsurance.pat_id*/NULL, 
	facility_cd = /*patInsurance.facility_cd*/NULL, 
	ctl_no = /*patInsurance.ctl_no*/NULL,
	fn_pat_id = /*patInsurance.fn_pat_id*/NULL,
	insu_class = /*patInsurance.insu_class*/NULL,
	insu_name = /*patInsurance.insu_name*/NULL,
	insu_name_short = /*patInsurance.insu_name_short*/NULL,
	start_date = /*patInsurance.start_date*/NULL,
	end_date = /*patInsurance.end_date*/NULL,
	check_date = /*patInsurance.check_date*/NULL,
-- 	mod 10525 保険区分が「セット」のときクラス「処方情報」が出力できない 関 start
	/*%if patInsurance.insu_info != null*/
	insu_info = json_build_object(
		'insu_pat_name', personal_info_encrypt(/*patInsurance.insu_info.get("insu_pat_name")*/NULL),
		'insu_no', personal_info_encrypt(/*patInsurance.insu_info.get("insu_no")*/NULL),
		'insu_kbn', (/*patInsurance.insu_info.get("insu_kbn")*/NULL)::text,
		'insu_pat_mark', personal_info_encrypt(/*patInsurance.insu_info.get("insu_pat_mark")*/NULL),
		'insu_pat_no', personal_info_encrypt(/*patInsurance.insu_info.get("insu_pat_no")*/NULL),
		'cki_class', (/*patInsurance.insu_info.get("cki_class")*/NULL)::text,
		'kki_class', (/*patInsurance.insu_info.get("kki_class")*/NULL)::text,
		'und_six', (/*patInsurance.insu_info.get("und_six")*/NULL)::text,
		'futan-g', (/*patInsurance.insu_info.get("futan-g")*/NULL)::text,
		'futan-n', (/*patInsurance.insu_info.get("futan-n")*/NULL)::text
 	),
 	/*%else*/
 	insu_info = null,
	/*%end*/
	/*%if patInsurance.insu_pub_info != null*/
	insu_pub_info = json_build_object(
		'insu_pub_name', personal_info_encrypt(/*patInsurance.insu_pub_info.get("insu_pub_name")*/NULL),
		'insu_pub_no', personal_info_encrypt(/*patInsurance.insu_pub_info.get("insu_pub_no")*/NULL),
		'insu_pub_pat_no', personal_info_encrypt(/*patInsurance.insu_pub_info.get("insu_pub_pat_no")*/NULL),
		'passbook_no', personal_info_encrypt(/*patInsurance.insu_pub_info.get("passbook_no")*/NULL)
 	),
 	/*%else*/
 	insu_pub_info = null,
	/*%end*/
 	/*%if patInsurance.insu_set_info != null*/
	insu_set_info = json_build_object(
		'insu_cd', (/*patInsurance.insu_set_info.get("insu_cd")*/NULL)::text,
		'insu_pub1_cd', (/*patInsurance.insu_set_info.get("insu_pub1_cd")*/NULL)::text,
		'insu_pub2_cd', (/*patInsurance.insu_set_info.get("insu_pub2_cd")*/NULL)::text,
		'insu_pub3_cd', (/*patInsurance.insu_set_info.get("insu_pub3_cd")*/NULL)::text,
		'insu_pub4_cd', (/*patInsurance.insu_set_info.get("insu_pub4_cd")*/NULl)::text
 	),
 	/*%else*/
 	insu_set_info = null,
	/*%end*/
 	/*%if patInsurance.insu_self_info != null*/
	insu_self_info = json_build_object(
		'insu_self_name', (/*patInsurance.insu_self_info.get("insu_self_name")*/NULL)::text
 	),
 	/*%else*/
 	insu_self_info = null,
	/*%end*/
-- 	mod 10525 保険区分が「セット」のときクラス「処方情報」が出力できない 関 end
	is_selected = /*patInsurance.is_selected*/NULL,
	is_disp = /*patInsurance.is_disp*/'1',
	is_del = /*patInsurance.is_del*/'0',
	up_date = to_timestamp(/*patInsurance.up_date*/NULL, 'YYYY-MM-DD HH24:MI:SS'),
	memo1 = /*patInsurance.memo1*/NULL,
	memo2 = /*patInsurance.memo2*/NULL
WHERE
    insurance_cd = /*patInsurance.insurance_cd*/NULL;