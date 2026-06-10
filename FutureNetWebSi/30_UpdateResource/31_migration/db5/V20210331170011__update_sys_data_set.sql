UPDATE "ntss"."sys_data_set" 
SET "sql" = 'WITH current_ord AS (
	SELECT pat_id, treat_date, rst_start_date
	FROM ord_main
	WHERE ord_no = @ordNo
	and is_del = ''0''
	and rst_dialysis_state <>''0''
)
select
  ord.rst_weight_info ->> ''ctr'' as last_ctr
  , ord.rst_weight_info ->> ''ctr_weight'' as last_ctr_weight
  , ord.rst_weight_info ->> ''weight_before'' as last_weight_before
  , ord.rst_weight_info ->> ''weight_after'' as last_weight_after
  , ord.rst_weight_info ->> ''ctr_measure_date'' as last_ctr_measure_date
  , ord.rst_weight_info ->> ''weight_decreased'' as last_weight_decreased
  , ord.rst_weight_info ->> ''weight_after_date'' as last_weight_after_date
  , ord.rst_weight_info ->> ''weight_before_date'' as last_weight_before_date
  , (ord.rst_puncture_user_info ->> ''user_last_name_1'') || (ord.rst_puncture_user_info ->> ''user_first_name_1'') as last_puncture_user_name
from
  ord_main as ord INNER JOIN current_ord ON ord.pat_id = current_ord.pat_id
where
  ord.is_del=''0''
   and ord.rst_dialysis_state <>''0''
   AND ord.treat_date <= current_ord.treat_date
   and (((current_ord.rst_start_date is not null) AND (ord.rst_start_date <= current_ord.rst_start_date))
		OR
		((current_ord.rst_start_date is null) AND (ord.rst_start_date is not null) AND (ord.treat_date <= current_ord.treat_date)))
order by ord.treat_date DESC LIMIT 1 OFFSET 0'
WHERE
	sql_cd = '12';