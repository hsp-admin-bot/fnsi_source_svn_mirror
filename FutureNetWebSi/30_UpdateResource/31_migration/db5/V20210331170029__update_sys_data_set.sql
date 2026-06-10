UPDATE sys_data_set 
SET SQL = 'with pat_physical_tbl as (
  select
    to_number( info->>''ctl_no'', ''99999'') as ctl_no,
    info->>''exam_date'' as exam_date,
    info->>''order_class'' as order_class,
    info->>''height'' as height,
    info->>''ctr_weight'' as ctr_weight,
    info->>''breast_dia'' as breast_dia,
    info->>''chest_dia'' as chest_dia,
    info->>''ctr'' as ctr,
    info->>''dw'' as dw,
    info->>''target_weight'' as target_weight,
    info->>''indicator_cd'' as indicator_cd,
    info->>''indicator_start_date'' as indicator_start_date,
    info->>''memo'' as memo,
    info->>''pre_scale_upper'' as pre_scale_upper,
    info->>''pre_scale_lower'' as pre_scale_lower
  from
    pat_unique
    cross join lateral
      json_array_elements (pat_unique.physical_info :: json) info
  where
    pat_id = @patId and  is_del =''0''
)

select
  *
from
  pat_physical_tbl
where
  exam_date::timestamp <= date_trunc(''day'', ''2020/02/13''/*@date*/::timestamp) + ''1 days - 1 milliseconds''
order by
  exam_date, ctl_no' 
WHERE
	sql_cd = '38'