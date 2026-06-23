DELETE from sys_data_set where sql_cd = 75;
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (75, 'select
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
  null as treat_date_end
  -- equipinfo->>''needle_type'' as needle_type
from
  ord_main
    cross join lateral
      json_array_elements (ord_main.ind_ind_comment_info :: json) info
-- 	cross join lateral	
-- 	  json_array_elements (ord_main.ind_equip_info :: json) equipinfo
where
  ord_no = @ordNo

  and is_del = ''0'' order  by   treat_date_start,treat_date_end', 2, '[{"preview": "2011/03/04", "can_calc": "0", "data_code": "treat_date", "data_name": "指示日", "data_type": "DateTime", "conv_table": [], "data_class": "指示コメント", "field_name": "treat_date", "disp_format": "yyyy/mm/dd", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "指示簿です。", "can_calc": "0", "data_code": "content", "data_name": "指示内容", "data_type": "string", "conv_table": [], "data_class": "指示コメント", "field_name": "content", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト医師", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "ind_user_id", "data_name": "指示者", "data_type": "string", "conv_table": [], "data_class": "指示コメント", "field_name": "ind_user_id", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "upd_user_id", "data_name": "更新者", "data_type": "string", "conv_table": [], "data_class": "指示コメント", "field_name": "upd_user_id", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [1, 2, 3, 9, 10, 11]}', '指示：指示簿(指示コメント)　@ordNo使用', '2020-03-27 13:28:00', current_timestamp, NULL);
