select
	*
from
  ord_main
	where pat_id in/*patIds*/(0)
	and facility_cd = /*facilityCd*/'000000'
	and is_del = '0'
	/*%if null != specifyDate*/
	and treat_date = /*specifyDate*/'0'
	/*%end*/
	/*%if null != fromDate*/
	and treat_date between /*fromDate*/'0' and /*toDate*/'0'
	/*%end*/
	/*%if null != rstDialysisState*/
	and rst_dialysis_state > '0'
	/*%end*/
;
