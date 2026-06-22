select
  receive_date
  , treat_condition
  , treat_class
from
  ord_treat_condition
where
  ord_no = /*ordNo*/1
and
  receive_date is not null
and
  is_disp = '1'
and
  is_del = '0'
order by
  receive_date
;
