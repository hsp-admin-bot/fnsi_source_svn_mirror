UPDATE "ntss"."sys_data_set" 
SET "sql" = 'with current_ord AS (
    select pat_id, treat_date, rst_start_date
	from ord_main
	where ord_no = @ordNo
	and is_del = ''0''
	and rst_dialysis_state <>''0''
),
hist_ord_nos as (
  select
    ord_main.ord_no
    ,ord_main.rst_start_date
  from
    ord_main INNER JOIN current_ord ON ord_main.pat_id = current_ord.pat_id
  where	rst_dialysis_state > ''4''
    and ord_main.ord_no <> @ordNo
	and (((current_ord.rst_start_date is not null) and (ord_main.rst_start_date <= current_ord.rst_start_date))
		or
		 ((current_ord.rst_start_date is null) and (ord_main.rst_start_date is not null) and (ord_main.treat_date <= current_ord.treat_date)))
    and is_del = ''0''
  order by rst_start_date desc limit 2
)
, ord_hist_tbl as (
  select rst_start_date
    ,to_number(rst_weight_info->>''weight_before'', ''999.99'') as weight_before
    ,(rst_weight_info->>''weight_before_date'')::timestamp as weight_before_date
    ,to_number(rst_weight_info->>''weight_after'', ''999.99'') as weight_after
    ,(rst_weight_info->>''weight_after_date'')::timestamp as weight_after_date
    ,to_number(rst_weight_info->>''water_removal_rst'', ''999.99'') as water_removal_rst
  from
    ord_main
  where
    ord_no in (select ord_no from hist_ord_nos)
  and is_del = ''0''
  and rst_dialysis_state <>''0''
), ord_array_tbl as (
  select
	array_agg(weight_before order by rst_start_date desc) as array_weight_before
    ,array_agg(weight_before_date order by rst_start_date desc) as array_weight_before_date
    ,array_agg(weight_after order by rst_start_date desc) as array_weight_after
    ,array_agg(weight_after_date order by rst_start_date desc) as array_weight_after_date
    ,array_agg(water_removal_rst order by rst_start_date desc) as array_water_removal_rst
  from
    ord_hist_tbl
)
select array_water_removal_rst[1] as water_removal_rst_prev
  ,array_weight_before[2] as weight_before_prev_prev
  ,array_weight_before_date[2] as weight_before_date_prev_prev
  ,array_weight_after[2] as weight_after_prev_prev
  ,array_weight_after_date[2] as weight_after_date_prev_prev
  ,array_water_removal_rst[2] as water_removal_rst_prev_prev
from
  ord_array_tbl
;'
WHERE
	sql_cd = '99';