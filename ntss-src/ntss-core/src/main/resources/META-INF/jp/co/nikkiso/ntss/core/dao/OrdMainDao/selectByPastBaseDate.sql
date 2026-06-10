select
/*%expand "A" */*
from
  ord_main A 
  inner join ( 
    select distinct
      (treat_date) as treat_date 
    from
      ord_main 
    where
      pat_id = /*patId*/0 
      and treat_date <= /*baseDate*/'20190311' 
    order by
      treat_date desc
    limit
      /*period*/0
  ) B 
    on A.treat_date = B.treat_date 
    and A.pat_id = /*patId*/0
    and A.facility_cd = /*facilityCd*/'000000'
    order by A.treat_date;