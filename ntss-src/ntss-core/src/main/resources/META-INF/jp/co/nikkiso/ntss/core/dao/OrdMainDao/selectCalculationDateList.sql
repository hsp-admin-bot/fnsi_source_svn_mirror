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
    /*%if null != ordNo*/
      ord_no != /*ordNo*/0
    and
    /*%end*/
      facility_cd = /*facilityCd*/''
    and
      pat_id = /*patId*/0
    /*%if null != treatDate*/
    and
      treat_date <= /*treatDate*/'00000000'
    /*%end*/
    and
      addition_info is not null
    and
      is_del = '0'
  ) AS A
group by
    pat_id, cd
;
