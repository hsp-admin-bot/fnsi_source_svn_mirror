DELETE FROM "ntss"."sys_data_set" WHERE sql_cd IN (-1);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-1, 'select
  hosp_pat_id,
  personal_info_decrypt(pat_last_name)||'' ''||personal_info_decrypt(pat_first_name) as pat_name,
  personal_info_decrypt(pat_last_name_kana)||'' ''||personal_info_decrypt(pat_first_name_kana) as pat_name_kana,
  personal_info_decrypt(pat_last_name_alpha)||'' ''||personal_info_decrypt(pat_first_name_alpha) as pat_name_alpha,
  personal_info_decrypt(pat_last_name) as pat_last_name,
  pat_birthday,
  case when pat_birthday is null then null
    else date_part(''year'',age(''now'', to_date(pat_birthday, ''YYYYMMDD'')))
  end as pat_age,
  pat_sex,
  pat_blood_type_abo,
  pat_blood_type_rh,
  pat_blood_type_abo * 10 +  pat_blood_type_rh as pat_blood_type_abo_rh,
  in_out_class,
  trim(both ''"'' from personal_info_decrypt(pat_contact_info->>''zip_cd'')) as pat_zip,
  trim(both ''"'' from personal_info_decrypt(pat_contact_info->>''address'')) as pat_address,
  trim(both ''"'' from personal_info_decrypt(pat_contact_info->>''tel1'')) as pat_tel1,
  trim(both ''"'' from personal_info_decrypt(pat_contact_info->>''tel2'')) as pat_tel2,
  trim(both ''"'' from personal_info_decrypt(pat_contact_info->>''fax'')) as pat_fax,
  trim(both ''"'' from personal_info_decrypt(pat_contact_info->>''e_mail'')) as pat_e_mail,
  trim(both ''"'' from personal_info_decrypt(pat_contact_info->>''work_name'')) as pat_work_name,
  trim(both ''"'' from personal_info_decrypt(pat_contact_info->>''work_tel'')) as pat_work_tel,
  trim(both ''"'' from personal_info_decrypt(pat_contact_info->>''memo1'')) as pat_memo1,
  trim(both ''"'' from personal_info_decrypt(pat_contact_info->>''memo2'')) as pat_memo2,
  severity_cd,
  transport_cd,
  is_die,
  die_date,
  die_cd
from
  pat_personal_main
where
  is_del = ''0''
and
  pat_id = @patId', 3, '[]', '0', '{"applications": []}', '{"classes": []}', '患者個人情報 @patId使用', '2020-03-31 23:14:57.873', CURRENT_TIMESTAMP, NULL);
DELETE FROM "ntss"."sys_data_set" WHERE sql_cd IN (152);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (152, 'with mb as (
  select * from mst_bed where facility_cd = @facilityCd and is_disp = ''1'' and is_del = ''0'' and machine_no is not null
)
, mk as (
  select kur_cd, kur_name, kur_start_time from mst_kur where facility_cd = @facilityCd and is_del = ''0''
)
, treat_date_records as (
  select
    to_char(generate_series, ''yyyymmdd'') as treat_date
  from
    generate_series(date_trunc(''day'', ( @fromDate )::timestamp), date_trunc(''day'', ( @toDate )::timestamp) + ''1 days - 1 milliseconds'', ''1 day'')
)
, sche_cells as (
  select
    *
  from
    mb, mk, treat_date_records
)
, om as (
  select
    ord_main.*,
		pat_main.is_same as first_name_is_same
  from
    ord_main
		left join pat_main
    on pat_main.pat_id = ord_main.pat_id
  where
    ord_main.facility_cd = @facilityCd
  and
    ord_main.treat_date between to_char(date_trunc(''day'', ( @fromDate )::timestamp), ''yyyymmdd'') and to_char(date_trunc(''day'', ( @toDate )::timestamp) + ''1 days - 1 milliseconds'', ''yyyymmdd'')
  and
    ord_main.is_del = ''0''
)
, bed_disp_order_tbl as (
  select
    one_json->>''code'' as bed_cd
    --,one_json->>''name'' as bed_name
    ,json_idx as bed_disp_order
  from
    mst_selector
    cross join lateral jsonb_array_elements(order_settings->''items'') with ordinality as tmp(one_json, json_idx)
  where
    facility_cd = @facilityCd and master_physical_name = ''mst_bed''
)

select
  om.first_name_is_same
	,pat_id as pat_last_name_id
	,pat_id as in_out_class
  ,pat_id
  ,lpad(bed_disp_order::text, 19, ''0'') as bed_disp_order
  ,sche_cells.bed_name
  ,sche_cells.bed_cd
  ,sche_cells.treat_date
  ,sche_cells.kur_name
	,mb.in_hospital_cd_1
	,mb.in_hospital_cd_2
from
  sche_cells
  left outer join om
    on sche_cells.treat_date = om.treat_date
      and sche_cells.bed_cd = om.ind_bed_cd
      and sche_cells.kur_cd = om.ind_kur_cd
  left outer join bed_disp_order_tbl
    on sche_cells.bed_cd::text = bed_disp_order_tbl.bed_cd::text
	left join  mb
   on 	   mb.bed_cd=sche_cells.bed_cd
order by
  bed_disp_order nulls last, sche_cells.treat_date, kur_start_time
;', 2, '[{"preview": "テスト患者姓", "can_calc": "0", "conv_sql": {"sql_cd": -1, "field_name": "pat_last_name", "target_var": "@patId"}, "data_code": "pat_last_name", "data_name": "患者名（姓のみ）", "data_type": "string", "conv_table": [], "data_class": "スケジュール表", "field_name": "pat_last_name_id", "disp_format": "", "data_category": "スケジュール表", "facility_table": "", "facility_filter_type": "0"}, {"preview": "なし", "can_calc": "0", "data_code": "first_name_is_same", "data_name": "患者名（姓のみ）+同姓フラグ", "data_type": "string", "conv_table": [{"code": "0", "disp": "なし", "item": "なし"}, {"code": "1", "disp": "あり", "item": "あり"}], "data_class": "スケジュール表", "field_name": "first_name_is_same", "disp_format": "", "data_category": "スケジュール表", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト患者", "can_calc": "0", "conv_sql": {"sql_cd": -1, "field_name": "pat_name", "target_var": "@patId"}, "data_code": "pat_name", "data_name": "患者名", "data_type": "string", "conv_table": [], "data_class": "スケジュール表", "field_name": "pat_id", "disp_format": "", "data_category": "スケジュール表", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "conv_sql": {"sql_cd": -1, "field_name": "in_out_class", "target_var": "@patId"}, "data_code": "in_out_class", "data_name": "入外区分", "data_type": "string", "conv_table": [{"code": "0", "disp": "外来", "item": "外来"}, {"code": "1", "disp": "入院", "item": "入院"}, {"code": "2", "disp": "死亡", "item": "死亡"}, {"code": "3", "disp": "(不在)", "item": "(不在)"}], "data_class": "スケジュール表", "field_name": "in_out_class", "disp_format": "", "data_category": "スケジュール表", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0000000000000000010", "can_calc": "0", "data_code": "bed_disp_order", "data_name": "ベッド表示順", "data_type": "string", "conv_table": [], "data_class": "スケジュール表", "field_name": "bed_disp_order", "disp_format": "", "data_category": "スケジュール表", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テストベッド０１", "can_calc": "0", "data_code": "bed_name", "data_name": "ベッド名", "data_type": "string", "conv_table": [], "data_class": "スケジュール表", "field_name": "bed_name", "disp_format": "", "data_category": "スケジュール表", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "in_hospital_cd_1", "data_name": "連携コード1", "data_type": "string", "conv_table": [], "data_class": "スケジュール表", "field_name": "in_hospital_cd_1", "disp_format": "", "data_category": "スケジュール表", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "in_hospital_cd_2", "data_name": "連携コード2", "data_type": "string", "conv_table": [], "data_class": "スケジュール表", "field_name": "in_hospital_cd_2", "disp_format": "", "data_category": "スケジュール表", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020/04/07", "can_calc": "0", "data_code": "treat_date", "data_name": "透析日", "data_type": "DateTime", "conv_table": [], "data_class": "スケジュール表", "field_name": "treat_date", "disp_format": "yyyy/mm/dd", "data_category": "スケジュール表", "facility_table": "", "facility_filter_type": "0"}, {"preview": "午前", "can_calc": "0", "data_code": "kur_name", "data_name": "クール名", "data_type": "string", "conv_table": [], "data_class": "スケジュール表", "field_name": "kur_name", "disp_format": "", "data_category": "スケジュール表", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [11]}', '２次元スゲージュル表　@facilityCd  @fromdate  @todate', '2021-05-10 16:40:02', CURRENT_TIMESTAMP, NULL);

