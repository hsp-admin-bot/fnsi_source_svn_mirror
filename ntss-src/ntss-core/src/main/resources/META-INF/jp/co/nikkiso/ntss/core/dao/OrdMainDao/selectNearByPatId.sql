select
ord_no
from
  ord_main
WHERE
  pat_id = /*patId*/'0' and treat_date <= /*treatDate*/'00000000'
order by
rst_end_date IS NULL, rst_end_date DESC
limit 1
;
