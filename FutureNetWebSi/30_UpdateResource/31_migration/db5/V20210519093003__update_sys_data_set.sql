UPDATE "ntss"."sys_data_set" SET "sql" = 'select
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
  and is_del = ''0'''
	WHERE "sql_cd" = 75;
