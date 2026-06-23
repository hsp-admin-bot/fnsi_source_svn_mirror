UPDATE "ntss"."sys_data_set" 
SET "sql" = '

with tmp1 as
(
  select
    ord_no
    ,jsonb_array_elements(rst_treatment_info) as rti
  from
    ord_main
where
  ord_no = @ordNo and is_del = ''0''
  and rst_dialysis_state <>''0''
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
, tmp2 as
(
  select
    ord_no
    ,jsonb_array_elements(rst_treat_staff_info) as rtsi
  from
    ord_main
where
  ord_no = @ordNo and is_del = ''0''
  and rst_dialysis_state <>''0''
)
, staff_tbl as
(
  select
    *
    ,date_trunc(''minute'', (rtsi->>''occur_date'')::timestamp) as date_trunc_occur_date
  from
    tmp2
)

select
  oxygen_tbl.ord_no
  ,case
    when bit_length(rti->>''oxygen_start'') <> 0 then occur_date else null -- 開始
  end as start_date
  ,case
    when bit_length(rti->>''oxygen_amount'') <> 0 then occur_date else null -- 終了
  end as end_date
  ,case
    when bit_length(rti->>''oxygen_start'') <> 0 then rtsi->>''treat_staff_name'' else null -- 開始
  end as start_staff
  ,case
    when bit_length(rti->>''oxygen_amount'') <> 0 then rtsi->>''treat_staff_name'' else null -- 終了
  end as end_staff
  ,case
    when bit_length(rti->>''oxygen_speed'') <> 0 then rti->>''oxygen_speed'' else null
  end as speed
  ,case
    when bit_length(rti->>''oxygen_amount'') <> 0 then rti->>''oxygen_amount'' else null
  end as amount
from
  oxygen_tbl
  left outer join staff_tbl
    on oxygen_tbl.ord_no = staff_tbl.ord_no and oxygen_tbl.date_trunc_occur_date = staff_tbl.date_trunc_occur_date
order by
  ord_no, occur_date
;


'
WHERE
	sql_cd = '115';