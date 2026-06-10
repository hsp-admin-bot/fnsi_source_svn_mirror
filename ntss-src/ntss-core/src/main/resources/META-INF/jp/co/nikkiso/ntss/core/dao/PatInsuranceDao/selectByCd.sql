-- add #10245 帳票用患者情報履歴mongoDBのマスタ変更影響問題 limingzhe start
SELECT
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
  json_build_object(
    'insu_pat_name', personal_info_decrypt((insu_info::json->>'insu_pat_name')::text),
		'insu_no', personal_info_decrypt((insu_info::json->>'insu_no')::text),
		'insu_kbn', (insu_info::json->>'insu_kbn')::text,
		'insu_pat_mark', personal_info_decrypt((insu_info::json->>'insu_pat_mark')::text),
		'insu_pat_no', personal_info_decrypt((insu_info::json->>'insu_pat_no')::text),
		'cki_class', (insu_info::json->>'cki_class')::text,
		'kki_class', (insu_info::json->>'kki_class')::text,
		'und_six', (insu_info::json->>'und_six')::text,
		'futan-g', (insu_info::json->>'futan-g')::text,
		'futan-n', (insu_info::json->>'futan-n')::text
 	) as insu_info,
  json_build_object(
    'insu_pub_name', personal_info_decrypt((insu_pub_info::json->>'insu_pub_name')::text),
		'insu_pub_no', personal_info_decrypt((insu_pub_info::json->>'insu_pub_no')::text),
		'insu_pub_pat_no', personal_info_decrypt((insu_pub_info::json->>'insu_pub_pat_no')::text),
		'passbook_no', personal_info_decrypt((insu_pub_info::json->>'passbook_no')::text)
 	) as insu_pub_info,
  json_build_object(
		'insu_cd', (insu_set_info::json->>'insu_cd')::text,
		'insu_pub1_cd', (insu_set_info::json->>'insu_pub1_cd')::text,
		'insu_pub2_cd', (insu_set_info::json->>'insu_pub2_cd')::text,
		'insu_pub3_cd', (insu_set_info::json->>'insu_pub3_cd')::text,
    'insu_pub4_cd', (insu_set_info::json->>'insu_pub4_cd')::text
 	) as insu_set_info,
  json_build_object(
		'insu_self_name', (insu_self_info::json->>'insu_self_name')::text
 	) as insu_self_info,
  is_selected,
  is_disp,
  is_del,
  reg_date,
  up_date,
  coop_code,
  is_coop,
  up_date as old_up_date,
  memo1,
  memo2
FROM
  pat_insurance as pi
WHERE
  pi.insurance_cd = /*insuCd*/NULL
;
-- add #10245 帳票用患者情報履歴mongoDBのマスタ変更影響問題 limingzhe end
