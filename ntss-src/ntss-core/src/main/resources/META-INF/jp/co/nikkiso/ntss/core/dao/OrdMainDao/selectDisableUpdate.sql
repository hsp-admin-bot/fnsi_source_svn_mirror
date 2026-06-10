select
  ord_no as ord_no,
  treat_date as treat_date,
  treat_week as treat_week,
  ind_bed_name as bed_name,
  ind_kur_name as kur_name,
  rst_dialysis_state as dialysis_state
from
  ord_main
where
  pat_id = /*pat_id*/0
and
  treat_date <= /*fromDate*/'20180226'
and
  rst_dialysis_state in ('3', '4', '5')
order by
  treat_date