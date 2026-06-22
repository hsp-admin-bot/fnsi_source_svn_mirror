select treat_date,string_agg(pat_id::VARCHAR, ',') as pat_id_list
from ord_main o
-- mod 11702 施設カレンダーで過去の集計件数が変わってしまう zkm start
-- where o.treat_date in/*treatDateList*/(0)
where o.rst_dialysis_state = '0'
  AND o.treat_date in/*treatDateList*/(0)
-- mod 11702 施設カレンダーで過去の集計件数が変わってしまう zkm end
group by treat_date
