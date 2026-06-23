UPDATE "ntss"."sys_data_set" SET "sql" = 'with addition_info_expand as
(
  select
    ord_no
    ,json_idx
    ,addinfo
  from
    ord_main
    cross join lateral jsonb_array_elements(addition_info) with ordinality as tmp(addinfo, json_idx)
  where
    is_del = ''0''
    and ord_no = @ordNo
    and rst_dialysis_state <>''0''
)
, tmp as
(
  select
    ord_no
    ,addinfo->>''cd'' as cd
    ,addinfo->>''name'' as name
    ,json_idx
    ,addinfo
  from
    addition_info_expand
)

select
  ord_no
  ,name
  ,in_hospital_cd_1 as rst_addition_in_hospital_cd_1
  ,in_hospital_cd_2 as rst_addition_in_hospital_cd_2
  ,in_hospital_cd_3 as rst_addition_in_hospital_cd_3
  ,case
	  when addition_class =''1'' then ''施設''
		when addition_class =''2'' then ''患者（困）''
		when addition_class =''3'' then ''患者（病）''
		when addition_class =''4'' then ''ろ過''
		when addition_class =''5'' then ''長時間''
		when addition_class =''6'' then ''薬剤''
		when addition_class =''7'' then ''処置（イベント）''
		when addition_class =''8'' then ''処置（検査）''
		when addition_class =''9'' then ''導入期''
		when addition_class =''10'' then ''休日''
		when addition_class =''11'' then ''時間外''
		when addition_class =''12'' then ''汎用''
	 else  ''''
	end as addition_class_name,
	mst_addition.addition_name
from
  tmp left outer join mst_addition on tmp.cd = mst_addition.addition_cd::text and is_disp = ''1'' and is_del = ''0''
order by json_idx
;', "detail" = '[{"preview": "休日", "can_calc": "0", "data_code": "addition_class", "data_name": "種別区分", "data_type": "string", "conv_table": [{"code": "1", "disp": "施設", "item": "施設"}, {"code": "2", "disp": "患者（困）", "item": "患者（困）"}, {"code": "3", "disp": "患者（病）", "item": "患者（病）"}, {"code": "4", "disp": "ろ過", "item": "ろ過"}, {"code": "5", "disp": "長時間", "item": "長時間"}, {"code": "6", "disp": "薬剤", "item": "薬剤"}, {"code": "7", "disp": "処置（イベント）", "item": "処置（イベント）"}, {"code": "8", "disp": "処置（検査）", "item": "処置（検査）"}, {"code": "9", "disp": "導入期", "item": "導入期"}, {"code": "10", "disp": "休日", "item": "休日"}, {"code": "11", "disp": "時間外", "item": "時間外"}, {"code": "12", "disp": "汎用", "item": "汎用"}], "data_class": "加算", "field_name": "addition_class", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "休日加算", "can_calc": "0", "data_code": "name", "data_name": "加算等名称", "data_type": "string", "conv_table": [], "data_class": "加算", "field_name": "name", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_addition_in_hospital_cd_1", "data_name": "加算連携コード１", "data_type": "string", "conv_table": [], "data_class": "加算", "field_name": "rst_addition_in_hospital_cd_1", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_addition_in_hospital_cd_2", "data_name": "加算連携コード２", "data_type": "string", "conv_table": [], "data_class": "加算", "field_name": "rst_addition_in_hospital_cd_2", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_addition_in_hospital_cd_3", "data_name": "加算連携コード３", "data_type": "string", "conv_table": [], "data_class": "加算", "field_name": "rst_addition_in_hospital_cd_3", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "addition_name", "data_name": "加算等名称", "data_type": "string", "conv_table": [], "data_class": "加算", "field_name": "addition_name", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}]' WHERE "sql_cd" = 117;
UPDATE "ntss"."sys_data_set" SET "sql" = 'SELECT
  personal_info_decrypt(opp.insu_no) as insu_no, --保険者番号
  personal_info_decrypt(opp.insu_pat_mark) as insu_pat_mark, --被保険者証記号
  personal_info_decrypt(opp.insu_pat_no) as insu_pat_no, --被保険者証番号
  personal_info_decrypt(opp.insu_pub_no) as insu_pub_no, --公費負担者番号
  personal_info_decrypt(opp.insu_pub_pat_no) as insu_pub_pat_no, --公費負担受給者番号
  opp.insu_kbn,--保険区分
  opp.remarks, --備考欄情報
  opp.insu_dr_id, --保険医ID
  personal_info_decrypt(opp.insu_dr_name) as insu_dr_name,--保険医名称
  personal_info_decrypt(opp.insu_dr_sign) as insu_dr_sign,--保険医署名
  personal_info_decrypt(mpu.anesthesiologist_license_no) as anesthesiologist_license_no,--麻薬施用者番号
  pi.insu_name --保険名称
FROM
 ord_personal_prescription opp
 LEFT JOIN mst_personal_user mpu ON opp.insu_dr_id = mpu.user_id and mpu.is_del =''0'' and mpu.is_disp =''1''
 LEFT JOIN pat_insurance pi ON opp.insurance_cd = pi.insurance_cd  and pi.is_del =''0'' and pi.is_disp =''1''
WHERE
opp.is_del =''0'' and opp.is_disp =''1''  
and opp.ord_prescription_no = @ordPrescriptionNo
 ' WHERE "sql_cd" = 137;
UPDATE "ntss"."sys_data_set" SET "sql" = 'with pat_other_contact_tbl as (
  select
    to_number(info->>''ctl_no'', ''99999'') as ctl_no,
    to_number(info->>''disp_order'', ''99999'') as disp_order,
     personal_info_decrypt(info->>''is_key_person'')as is_key_parson,
    --info->>''pat_id'' as pat_id
    trim(both ''"'' from personal_info_decrypt(info->>''last_name'')) || '' ''
      || trim(both ''"'' from personal_info_decrypt(info->>''first_name'')) as other_name,
    trim(both ''"'' from personal_info_decrypt(info->>''last_name_kana'')) ||'' ''
      || trim(both ''"'' from personal_info_decrypt(info->>''first_name_kana'')) as other_name_kana,
    info->>''relation_cd'' as relation_cd,
    trim(both ''"'' from personal_info_decrypt(info->>''relation_name'')) as relation_name,
    trim(both ''"'' from personal_info_decrypt(info->>''zip_cd'')) as zip_cd,
    trim(both ''"'' from personal_info_decrypt(info->>''address'')) as address,
    trim(both ''"'' from personal_info_decrypt(info->>''tel1'')) as tel1,
    trim(both ''"'' from personal_info_decrypt(info->>''tel2'')) as tel2,
    trim(both ''"'' from personal_info_decrypt(info->>''fax'')) as fax,
    trim(both ''"'' from personal_info_decrypt(info->>''e_mail'')) as e_mail,
    trim(both ''"'' from personal_info_decrypt(info->>''work_name'')) as work_name,
    trim(both ''"'' from personal_info_decrypt(info->>''work_tel'')) as work_tel,
    trim(both ''"'' from personal_info_decrypt(info->>''memo1'')) as memo1,
    trim(both ''"'' from personal_info_decrypt(info->>''memo2'')) as memo2
  from
    pat_personal_main
    cross join lateral
      json_array_elements (pat_personal_main.other_contact_info :: json) info
  where
    pat_id = @patId  and is_del = ''0''
)

select
  *
from
  pat_other_contact_tbl
order by
  disp_order, ctl_no
' WHERE "sql_cd" = 40;
UPDATE "ntss"."sys_data_set" SET "sql" = 'select
 a.*
from
  (select
    info->>''dial_diff_cd'' as pat_dial_diff_cd,
    info->>''dial_diff_cd'' as pat_dial_diff_cd1,
		 info->>''dial_diff_cd'' as pat_dial_diff_cd2,
    info->>''is_dial_diff'' as is_pat_dial_diff,
    info->>''is_main'' as is_main
  from
    pat_personal_main
  cross join lateral
    json_array_elements (pat_personal_main.dial_diff_com_info :: json) info
  where
    is_del = ''0''
  and
    pat_id = @patId
  ) a
where
  a.is_pat_dial_diff = ''1''', "detail" = '[{"preview": "主", "can_calc": "0", "data_code": "is_main", "data_name": "主たる透析困難", "data_type": "string", "conv_table": [{"code": "0", "disp": "", "item": ""}, {"code": "1", "disp": "主", "item": "主"}], "data_class": "既往歴(透析困難すべて)", "field_name": "is_main", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "あり", "can_calc": "0", "data_code": "is_pat_dial_diff", "data_name": "透析困難有無", "data_type": "string", "conv_table": [{"code": "0", "disp": "なし", "item": "なし"}, {"code": "1", "disp": "あり", "item": "あり"}], "data_class": "既往歴(透析困難すべて)", "field_name": "is_pat_dial_diff", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "車椅子", "can_calc": "0", "conv_sql": {"sql_cd": -3, "field_name": "dialysis_difficulty_name", "target_var": "@dialysisDifficultyCd"}, "data_code": "pat_dial_diff_cd", "data_name": "透析困難理由", "data_type": "string", "conv_table": [], "data_class": "既往歴(透析困難すべて)", "field_name": "pat_dial_diff_cd", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "123456789", "can_calc": "0", "conv_sql": {"sql_cd": -3, "field_name": "in_hospital_cd_1", "target_var": "@dialysisDifficultyCd"}, "data_code": "pat_dial_diff_cd1", "data_name": "透析困難理由連携コード1", "data_type": "string", "conv_table": [], "data_class": "既往歴(透析困難すべて)", "field_name": "pat_dial_diff_cd1", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "123456789", "can_calc": "0", "conv_sql": {"sql_cd": -3, "field_name": "in_hospital_cd_2", "target_var": "@dialysisDifficultyCd"}, "data_code": "in_hospital_cd_2", "data_name": "透析困難理由連携コード2", "data_type": "string", "conv_table": [], "data_class": "既往歴(透析困難すべて)", "field_name": "pat_dial_diff_cd2", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}]' WHERE "sql_cd" = 42;
