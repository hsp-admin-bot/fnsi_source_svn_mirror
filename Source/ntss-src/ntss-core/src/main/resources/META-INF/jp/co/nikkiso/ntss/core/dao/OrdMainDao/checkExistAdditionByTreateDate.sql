select
  case 
    when count(*) >= 1  then true
    when count(*) = 0  then false
  end
from ntss.ord_main o
  join lateral jsonb_array_elements(o.addition_info) exp on exp->>'cd' =/*additionCd*/'' 
where 
/*%if mStartDate != null */
  o.treat_date <= /*treatDate*/null
  and o.treat_date >= /*mStartDate*/null
/*%else */
  o.treat_date = /*treatDate*/null
/*%end*/
  and o.pat_id = /*patId*/0
  and o.facility_cd = /*facilityCd*/''
  and o.is_del = '0'
;