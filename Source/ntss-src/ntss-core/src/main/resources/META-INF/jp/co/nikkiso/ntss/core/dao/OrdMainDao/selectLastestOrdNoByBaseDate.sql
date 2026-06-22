select
	A.*
from
  ord_main A
  inner join (
    select distinct
      (treat_date) as treat_date
    from
      ord_main
    where
      pat_id = /*patId*/0
      and facility_cd = /*facilityCd*/'000000'
      and is_del = '0'
      /*%if null != rstDialysisState*/
      and rst_dialysis_state > '0'
      /*%end*/
      and treat_date <= /*baseDate*/'20241112'
    order by treat_date desc limit 1
  ) B
	on A.treat_date = B.treat_date
	and A.pat_id = /*patId*/0
	and A.facility_cd = /*facilityCd*/'000000'
	and A.is_del = '0'
	/*%if null != rstDialysisState*/
	and A.rst_dialysis_state > '0'
	/*%end*/
order by A.treat_date;
