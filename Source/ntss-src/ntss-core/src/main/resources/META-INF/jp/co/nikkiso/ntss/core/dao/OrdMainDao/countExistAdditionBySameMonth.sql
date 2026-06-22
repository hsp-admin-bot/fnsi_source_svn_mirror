select
  count(*)
from
  ord_main A
  join lateral jsonb_array_elements(A.addition_info) exp on exp->>'cd' = /*additionCd*/'',
  (
    select
      treat_date
    from
      ord_main B
    where
      ord_no = /*ordNo*/0
  ) t
where
  pat_id = /*patId*/0
  and facility_cd = /*facilityCd*/''
  and substring(A.treat_date from 1 for 4)::bigint = substring(t.treat_date from 1 for 4)::bigint
  and substring(A.treat_date from 5 for 2)::bigint = substring(t.treat_date from 5 for 2)::bigint
;