with ord_no_list as (select unnest(string_to_array(/*ordNoList*/null, ',')) as ono)
update ord_schedule
set kur_cd           = 0, up_date = CURRENT_TIMESTAMP
from ord_no_list
where ord_no = ord_no_list.ono::int
  and is_dummy = '0';
