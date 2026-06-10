select
  ord_no
from
  ord_main
where
  pat_id = /*patId*/-1
and
  facility_cd = /*facilityCd*/'000000'
and
  rst_dialysis_state in ('1','2','3', '4', '5', '6')
and
  is_del = '0'
order by
  rst_start_date desc
  , up_date desc
limit 1
;
