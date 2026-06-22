select
  rst_edition
  ,rst_dialysis_state
from
  ord_main_restore
where
  ord_no = /*ordNo*/1
  order by up_date desc limit 1
;