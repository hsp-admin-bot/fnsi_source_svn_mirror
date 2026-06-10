select
  ordTreat.receive_date
  , ordTreat.treat_condition
  , ordTreat.treat_class
from ord_treat_condition ordTreat
  inner join ord_main ordMain
  on ordMain.ord_no = ordTreat.ord_no
  and ordMain.pat_id = /*patId*/1
where
  ordTreat.receive_date is not null
and
  ordTreat.is_disp = '1'
and
  ordTreat.is_del = '0'
order by
  ordTreat.receive_date desc
;
