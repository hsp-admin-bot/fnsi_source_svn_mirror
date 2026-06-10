select
  pat_id,
  addition_info->'cd' as cd,
  max(treat_date) as last_date
from
  (
    select
      pat_id,
      jsonb_array_elements(addition_info) as addition_info,
      treat_date
    from
      ord_main
    where
      facility_cd = /*facilityCd*/''
    and
      pat_id in /*patIds*/(NULL)
    and
      addition_info is not null
    and
      is_del = '0'
  ) AS A
group by
  pat_id, cd
;
