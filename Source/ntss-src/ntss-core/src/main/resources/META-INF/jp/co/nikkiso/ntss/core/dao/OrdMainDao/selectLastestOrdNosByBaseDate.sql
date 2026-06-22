select
	*
from
  ord_main
	where pat_id in/*patIds*/(0)
	and facility_cd = /*facilityCd*/'000000'
	and is_del = '0'
	and treat_date = /*baseDate*/'20241112'
	/*%if null != rstDialysisState*/
	and rst_dialysis_state > '0'
	/*%end*/
;
