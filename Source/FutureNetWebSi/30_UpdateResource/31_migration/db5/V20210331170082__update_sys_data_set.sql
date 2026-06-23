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
  info->>''cop_order_no'' as cop_order_no
from
  ord_main
    cross join lateral
      json_array_elements (ord_main.rst_ind_comment_info :: json) info
where
  ord_no = @ordNo and is_del = ''0''
  and rst_dialysis_state <> ''0''
order by no
;'
WHERE
	sql_cd = '98';