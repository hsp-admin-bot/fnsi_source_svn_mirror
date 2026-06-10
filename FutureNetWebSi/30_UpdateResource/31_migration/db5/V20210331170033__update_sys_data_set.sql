UPDATE sys_data_set  SET sql ='select
 a.*
from
  (select
    info->>''dial_diff_cd'' as pat_dial_diff_cd,
	info->>''dial_diff_cd'' as pat_dial_diff_cd1,
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
  a.is_pat_dial_diff = ''1''',
detail='[{"preview": "主", "can_calc": "0", "data_code": "is_main", "data_name": "主たる透析困難", "data_type": "string", "conv_table": [{"code": "0", "disp": "", "item": ""}, {"code": "1", "disp": "主", "item": "主"}], "data_class": "既往歴(透析困難すべて)", "field_name": "is_main", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "あり", "can_calc": "0", "data_code": "is_pat_dial_diff", "data_name": "透析困難有無", "data_type": "string", "conv_table": [{"code": "0", "disp": "なし", "item": "なし"}, {"code": "1", "disp": "あり", "item": "あり"}], "data_class": "既往歴(透析困難すべて)", "field_name": "is_pat_dial_diff", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "車椅子", "can_calc": "0", "conv_sql": {"sql_cd": -3, "field_name": "dialysis_difficulty_name", "target_var": "@dialysisDifficultyCd"}, "data_code": "pat_dial_diff_cd", "data_name": "透析困難理由", "data_type": "string", "conv_table": [], "data_class": "既往歴(透析困難すべて)", "field_name": "pat_dial_diff_cd", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "123456789", "can_calc": "0", "conv_sql": {"sql_cd": -3, "field_name": "in_hospital_cd_1", "target_var": "@dialysisDifficultyCd"}, "data_code": "pat_dial_diff_cd1", "data_name": "透析困難理由連携コード", "data_type": "string", "conv_table": [], "data_class": "既往歴(透析困難すべて)", "field_name": "pat_dial_diff_cd1", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}]' 
 where sql_cd = '42'
