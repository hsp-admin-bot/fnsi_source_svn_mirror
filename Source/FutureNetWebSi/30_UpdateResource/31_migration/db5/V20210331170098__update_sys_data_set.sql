UPDATE "ntss"."sys_data_set" 
SET "sql" = 'with addition_info_expand as
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
  ,addition_class
  ,name
  ,in_hospital_cd_1 as rst_addition_in_hospital_cd_1
  ,in_hospital_cd_2 as rst_addition_in_hospital_cd_2
  ,in_hospital_cd_3 as rst_addition_in_hospital_cd_3
from
  tmp left outer join mst_addition on tmp.cd = mst_addition.addition_cd::text and is_disp = ''1'' and is_del = ''0''
order by json_idx
;', "detail" = '[{"preview": "休日", "can_calc": "0", "data_code": "addition_class", "data_name": "種別区分", "data_type": "string", "conv_table": [{"code": "1", "disp": "施設", "item": "施設"}, {"code": "2", "disp": "患者（困）", "item": "患者（困）"}, {"code": "3", "disp": "患者（病）", "item": "患者（病）"}, {"code": "4", "disp": "ろ過", "item": "ろ過"}, {"code": "5", "disp": "長時間", "item": "長時間"}, {"code": "6", "disp": "薬剤", "item": "薬剤"}, {"code": "7", "disp": "処置（イベント）", "item": "処置（イベント）"}, {"code": "8", "disp": "処置（検査）", "item": "処置（検査）"}, {"code": "9", "disp": "導入期", "item": "導入期"}, {"code": "10", "disp": "休日", "item": "休日"}, {"code": "11", "disp": "時間外", "item": "時間外"}, {"code": "12", "disp": "汎用", "item": "汎用"}], "data_class": "加算", "field_name": "addition_class", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "休日加算", "can_calc": "0", "data_code": "name", "data_name": "加算等名称", "data_type": "string", "conv_table": [], "data_class": "加算", "field_name": "name", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_addition_in_hospital_cd_1", "data_name": "加算連携コード１", "data_type": "string", "conv_table": [], "data_class": "加算", "field_name": "rst_addition_in_hospital_cd_1", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_addition_in_hospital_cd_2", "data_name": "加算連携コード２", "data_type": "string", "conv_table": [], "data_class": "加算", "field_name": "rst_addition_in_hospital_cd_2", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_addition_in_hospital_cd_3", "data_name": "加算連携コード３", "data_type": "string", "conv_table": [], "data_class": "加算", "field_name": "rst_addition_in_hospital_cd_3", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}]'
WHERE
	sql_cd = '117';