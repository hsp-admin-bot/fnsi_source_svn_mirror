UPDATE "ntss"."sys_data_set" 
SET "sql" = 'with tmp1 as
(
  select
    ord_no
    ,jsonb_array_elements(rst_treatment_info) as rti
  from
    ord_main
where
  ord_no = @ordNo and is_del = ''0'' and rst_dialysis_state <>''0''
)
, oxygen_tbl as
(
  select
    *
    ,(rti->>''occur_date'')::timestamp as occur_date
    ,date_trunc(''minute'', (rti->>''occur_date'')::timestamp) as date_trunc_occur_date
  from
    tmp1
  where
    rti->>''treat_class'' = ''3''
)

select
  sum(to_number(rti->>''oxygen_amount'', ''99999.99'')) as total_amount
from
  oxygen_tbl
;'
WHERE
	sql_cd = '116';