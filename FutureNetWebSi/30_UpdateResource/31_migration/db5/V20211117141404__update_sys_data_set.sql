UPDATE "ntss"."sys_data_set" SET "sql" = 'SELECT
	1 AS OrderNo,
	personal_info_decrypt(user_last_name)       || '' '' || personal_info_decrypt(user_first_name) as user_name,
  personal_info_decrypt(user_last_name_kana)  || '' '' || personal_info_decrypt(user_first_name_kana) as user_name_kana,
  personal_info_decrypt(user_last_name_alpha) || '' '' || personal_info_decrypt(user_first_name_alpha) as user_name_alpha 
FROM
	mst_personal_user 
WHERE
	user_id = TO_NUMBER( CASE WHEN ( @userId ~ ''^([0-9]+[.]?[0-9]*|[.][0-9]+)$'' ) = TRUE THEN @userId ELSE''-1'' END, ''FM9999999'' ) 
	AND is_disp = ''1'' 
	AND is_del = ''0'' 
UNION
SELECT
	2 AS OrderNo,
	@userId AS user_name ,
	''''as user_name_kana,
	''''as user_name_alpha
ORDER BY
	OrderNo ASC 
	LIMIT 1' WHERE "sql_cd" = -2;
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
  a.is_main = ''1''', "detail" = '[{"preview": "あり", "can_calc": "0", "data_code": "is_pat_dial_diff", "data_name": "透析困難有無", "data_type": "string", "conv_table": [{"code": "0", "disp": "なし", "item": "なし"}, {"code": "1", "disp": "あり", "item": "あり"}], "data_class": "既往歴", "field_name": "is_pat_dial_diff", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "主たる透析困難コメントではない", "can_calc": "0", "data_code": "is_main", "data_name": "有無", "data_type": "string", "conv_table": [{"code": "0", "disp": "主たる透析困難コメントではない", "item": "主たる透析困難コメントではない"}, {"code": "1", "disp": "主たる透析困難コメント", "item": "主たる透析困難コメント"}], "data_class": "既往歴", "field_name": "is_main", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "車椅子", "can_calc": "0", "conv_sql": {"sql_cd": -3, "field_name": "dialysis_difficulty_name", "target_var": "@dialysisDifficultyCd"}, "data_code": "dialysis_difficulty_name", "data_name": "透析困難名", "data_type": "string", "conv_table": [], "data_class": "既往歴", "field_name": "pat_dial_diff_cd", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "conv_sql": {"sql_cd": -3, "field_name": "in_hospital_cd_1", "target_var": "@dialysisDifficultyCd"}, "data_code": "in_hospital_cd_1", "data_name": "連携コード1", "data_type": "string", "conv_table": [], "data_class": "既往歴", "field_name": "pat_dial_diff_cd1", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "conv_sql": {"sql_cd": -3, "field_name": "in_hospital_cd_2", "target_var": "@dialysisDifficultyCd"}, "data_code": "in_hospital_cd_2", "data_name": "連携コード2", "data_type": "string", "conv_table": [], "data_class": "既往歴", "field_name": "pat_dial_diff_cd2", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}]' WHERE "sql_cd" = 18;
UPDATE "ntss"."sys_data_set" SET "sql" = 'with pat_medical_hst_tbl as (
  select
    to_number(info->>''ctl_no'', ''99999'') as ctl_no,
    to_number(info->>''disp_order'', ''99999'') as disp_order,
    info->>''is_primary_illness'' as is_primary_illness,
    info->>''is_main_disease'' as is_main_disease,
    info->>''is_notice'' as is_notice,
    to_date(info->>''disease_date'', ''YYYYMMDD'') as disease_date,
    info->>''disease_cd'' as disease_cd,
    info->>''out_come'' as out_come,
    to_date(info->>''out_come_date'', ''YYYYMMDD'') as out_come_date,
    info->>''diagnostician_cd'' as diagnostician_cd,
    info->>''memo'' as memo,
    info->>''diagnosis_facility_cd'' as diagnosis_facility_cd,
    info->>''course_cd'' as course_cd,
    info->>''is_confirmation_biopsy'' as is_confirmation_biopsy,
    info->>''is_diagnosed'' as is_diagnosed,
    info->>''is_dialysis_underlying_disease'' as is_dialysis_underlying_disease,
    info->>''course_is_free'' as course_is_free,
    info->>''diagnostician_is_free'' as diagnostician_is_free
  from
    pat_unique
    cross join lateral
      json_array_elements (pat_unique.medical_hst_info :: json) info
  where
    pat_id = @patId and is_del = ''0''
)
select
  pat_medical_hst_tbl.*,
	disease_tbl.in_hospital_cd_1,
  case when pat_medical_hst_tbl.diagnostician_is_free = ''1'' then pat_medical_hst_tbl.disease_cd
    else disease_tbl.disease_name
  end as disease_name,
  case when mst_facility.facility_name is null then pat_medical_hst_tbl.diagnosis_facility_cd
    else mst_facility.facility_name
  end as facility_name,
  case when pat_medical_hst_tbl.course_is_free = ''1'' then pat_medical_hst_tbl.course_cd
    else course_tbl.course_name
  end as course_name
from
  pat_medical_hst_tbl
  left join  mst_disease as  disease_tbl
    on pat_medical_hst_tbl.disease_cd = disease_tbl.disease_cd::text  and disease_tbl.is_disp = ''1''   and disease_tbl.is_del = ''0''
			 
  left join mst_facility
    on pat_medical_hst_tbl.diagnosis_facility_cd = mst_facility.facility_cd
  left join mst_course as course_tbl
    on pat_medical_hst_tbl.course_cd = course_tbl.course_cd::text   and course_tbl.is_disp = ''1''   and course_tbl.is_del = ''0''

order by
  disp_order, ctl_no
', "detail" = '[{"preview": "インフルエンザ", "can_calc": "0", "data_code": "course_name", "data_name": "病名", "data_type": "string", "conv_table": [], "data_class": "病歴(昇順)", "field_name": "course_name", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/01/22", "can_calc": "0", "data_code": "disease_date", "data_name": "発症日", "data_type": "DateTime", "conv_table": [], "data_class": "病歴(昇順)", "field_name": "disease_date", "disp_format": "yyyy/mm/dd", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "治癒", "can_calc": "0", "data_code": "out_come", "data_name": "転帰", "data_type": "string", "conv_table": [{"code": "0", "disp": "治癒", "item": "治癒"}, {"code": "1", "disp": "死亡", "item": "死亡"}, {"code": "2", "disp": "中止", "item": "中止"}, {"code": "3", "disp": "治療中", "item": "治療中"}], "data_class": "病歴(昇順)", "field_name": "out_come", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/01/30", "can_calc": "0", "data_code": "out_come_date", "data_name": "転帰更新日", "data_type": "DateTime", "conv_table": [], "data_class": "病歴(昇順)", "field_name": "out_come_date", "disp_format": "yyyy/mm/dd", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "済", "can_calc": "0", "data_code": "is_notice", "data_name": "告知", "data_type": "string", "conv_table": [{"code": "0", "disp": "済", "item": "済"}, {"code": "1", "disp": "未", "item": "未"}], "data_class": "病歴(昇順)", "field_name": "is_notice", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト医師２", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "diagnostician_cd", "data_name": "診断医", "data_type": "string", "conv_table": [], "data_class": "病歴(昇順)", "field_name": "diagnostician_cd", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "原疾患", "can_calc": "0", "data_code": "is_primary_illness", "data_name": "原疾患扱い", "data_type": "string", "conv_table": [{"code": "0", "disp": "", "item": "非原疾患"}, {"code": "1", "disp": "原疾患", "item": "原疾患"}], "data_class": "病歴(昇順)", "field_name": "is_primary_illness", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "in_hospital_cd_1", "data_name": "連携コード1", "data_type": "DateTime", "conv_table": [], "data_class": "病歴(昇順)", "field_name": "in_hospital_cd_1", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}]' WHERE "sql_cd" = 27;
UPDATE "ntss"."sys_data_set" SET "sql" = 'with pat_medical_hst_tbl as (
  select
    to_number(info->>''ctl_no'', ''99999'') as ctl_no,
    to_number(info->>''disp_order'', ''99999'') as disp_order,
    info->>''is_primary_illness'' as is_primary_illness,
    info->>''is_main_disease'' as is_main_disease,
    info->>''is_notice'' as is_notice,
    to_date(info->>''disease_date'', ''YYYYMMDD'') as disease_date,
    info->>''disease_cd'' as disease_cd,
    info->>''out_come'' as out_come,
    to_date(info->>''out_come_date'', ''YYYYMMDD'') as out_come_date,
    info->>''diagnostician_cd'' as diagnostician_cd,
    info->>''memo'' as memo,
    info->>''diagnosis_facility_cd'' as diagnosis_facility_cd,
    info->>''course_cd'' as course_cd,
    info->>''is_confirmation_biopsy'' as is_confirmation_biopsy,
    info->>''is_diagnosed'' as is_diagnosed,
    info->>''is_dialysis_underlying_disease'' as is_dialysis_underlying_disease,
    info->>''course_is_free'' as course_is_free,
    info->>''diagnostician_is_free'' as diagnostician_is_free
  from
    pat_unique
    cross join lateral
      json_array_elements (pat_unique.medical_hst_info :: json) info
  where
    pat_id = @patId and is_del = ''0''
)

select
  pat_medical_hst_tbl.*,
	disease_tbl.in_hospital_cd_1,
  case when pat_medical_hst_tbl.diagnostician_is_free = ''1'' then pat_medical_hst_tbl.disease_cd
    else disease_tbl.disease_name
  end as disease_name,
  case when mst_facility.facility_name is null then pat_medical_hst_tbl.diagnosis_facility_cd
    else mst_facility.facility_name
  end as facility_name,
  case when pat_medical_hst_tbl.course_is_free = ''1'' then pat_medical_hst_tbl.course_cd
    else course_tbl.course_name
  end as course_name
from
  pat_medical_hst_tbl
  left join mst_disease as  disease_tbl
    on pat_medical_hst_tbl.disease_cd = disease_tbl.disease_cd::text  and  disease_tbl.is_disp = ''1''  and   disease_tbl.is_del = ''0''
  
  left join mst_facility
    on pat_medical_hst_tbl.diagnosis_facility_cd = mst_facility.facility_cd
  left join mst_course as course_tbl
    on pat_medical_hst_tbl.course_cd = course_tbl.course_cd::text  and   course_tbl.is_disp = ''1''  and   course_tbl.is_del = ''0''

order by
  disp_order desc, ctl_no desc
', "detail" = '[{"preview": "インフルエンザ", "can_calc": "0", "data_code": "course_name", "data_name": "病名", "data_type": "string", "conv_table": [], "data_class": "病歴(降順)", "field_name": "course_name", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/01/22", "can_calc": "0", "data_code": "disease_date", "data_name": "発症日", "data_type": "DateTime", "conv_table": [], "data_class": "病歴(降順)", "field_name": "disease_date", "disp_format": "yyyy/mm/dd", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "治癒", "can_calc": "0", "data_code": "out_come", "data_name": "転帰", "data_type": "string", "conv_table": [{"code": "0", "disp": "治癒", "item": "治癒"}, {"code": "1", "disp": "死亡", "item": "死亡"}, {"code": "2", "disp": "中止", "item": "中止"}, {"code": "3", "disp": "治療中", "item": "治療中"}], "data_class": "病歴(降順)", "field_name": "out_come", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/01/30", "can_calc": "0", "data_code": "out_come_date", "data_name": "転帰更新日", "data_type": "DateTime", "conv_table": [], "data_class": "病歴(降順)", "field_name": "out_come_date", "disp_format": "yyyy/mm/dd", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "済", "can_calc": "0", "data_code": "is_notice", "data_name": "告知", "data_type": "string", "conv_table": [], "data_class": "病歴(降順)", "field_name": "is_notice", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト医師２", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "diagnostician_cd", "data_name": "診断医", "data_type": "string", "conv_table": [], "data_class": "病歴(降順)", "field_name": "diagnostician_cd", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "原疾患", "can_calc": "0", "data_code": "is_primary_illness", "data_name": "原疾患扱い", "data_type": "string", "conv_table": [{"code": "0", "disp": "", "item": "非原疾患"}, {"code": "1", "disp": "原疾患", "item": "原疾患"}], "data_class": "病歴(降順)", "field_name": "is_primary_illness", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "in_hospital_cd_1", "data_name": "連携コード1", "data_type": "string", "conv_table": [], "data_class": "病歴(降順)", "field_name": "in_hospital_cd_1", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}]' WHERE "sql_cd" = 28;
