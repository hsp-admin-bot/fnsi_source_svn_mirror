with ord_no_list as (select unnest(string_to_array(/*allOrdNo*/null, ',')) as ono)
delete
from ord_schedule
where ord_no in (select ord_no_list.ono::int from ord_no_list)
  and is_dummy = '1'
