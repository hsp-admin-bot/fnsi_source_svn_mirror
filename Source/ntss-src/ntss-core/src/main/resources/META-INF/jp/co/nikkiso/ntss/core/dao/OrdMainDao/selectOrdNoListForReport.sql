select
  pat_id,ord_no
from
  ord_main
where
  pat_id IN /*patIdList*/( NULL )
  and
  treat_date = /*treatDate*/'00000000'
;
