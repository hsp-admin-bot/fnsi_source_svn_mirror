UPDATE "ntss"."sys_data_set" 
SET "sql" = 'select
facility_cd,
to_date(treat_date, ''yyyymmdd'') as treat_date,

info->>''no'' as no,
info->>''content'' as content,

info->>''ind_user_id'' as ind_user_id,
info->>''ind_user_last_name'' as ind_user_last_name,
info->>''ind_user_first_name'' as ind_user_first_name,
info->>''upd_user_id'' as upd_user_id,
info->>''upd_user_last_name'' as upd_user_last_name,
info->>''upd_user_first_name'' as upd_user_first_name,
info->>''input_class'' as input_class,
info->>''is_editable'' as is_editable,
info->>''cop_order_no'' as cop_order_no,
ind_treat_start_time as treat_date_start,
null as treat_date_end,
equipinfo->>''needle_type'' as needle_type
from
ord_main
cross join lateral
json_array_elements (ord_main.ind_ind_comment_info :: json) info
cross join lateral	
json_array_elements (ord_main.ind_equip_info :: json) equipinfo
where
ord_no = @ordNo
and is_del = ''0''
and rst_dialysis_state = ''0''',
detail = '[{"preview": "2011/03/04", "can_calc": "0", "data_code": "treat_date", "data_name": "指示日", "data_type": "DateTime", "conv_table": [], "data_class": "指示簿", "field_name": "treat_date", "disp_format": "yyyy/mm/dd", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "指示簿です。", "can_calc": "0", "data_code": "content", "data_name": "指示内容", "data_type": "string", "conv_table": [], "data_class": "指示簿", "field_name": "content", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト医師", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "ind_user_id", "data_name": "指示者", "data_type": "string", "conv_table": [], "data_class": "指示簿", "field_name": "ind_user_id", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "upd_user_id", "data_name": "更新者", "data_type": "string", "conv_table": [], "data_class": "指示簿", "field_name": "upd_user_id", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "A針", "can_calc": "0", "data_code": "needle_type", "data_name": "穿刺針区分", "data_type": "string", "conv_table": [], "data_class": "指示簿", "field_name": "needle_type", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/03/04", "can_calc": "0", "data_code": "treat_date_start", "data_name": "指示開始日", "data_type": "DateTime", "conv_table": [], "data_class": "指示簿", "field_name": "treat_date_start", "disp_format": "yyyy/mm/dd", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/03/04", "can_calc": "0", "data_code": "treat_date_end", "data_name": "指示終了日", "data_type": "DateTime", "conv_table": [], "data_class": "指示簿", "field_name": "treat_date_end", "disp_format": "yyyy/mm/dd", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}]' 
WHERE
	"sql_cd" = 75;