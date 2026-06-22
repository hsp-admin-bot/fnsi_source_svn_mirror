select distinct
    om.pat_id
from
    ord_main as om
where
    om.pat_id in /* patIds */(null)
and
    om.facility_cd = /* facilityCd */''
and
    om.is_del = '0'
/*%if ""!= rstDialysisStateFlag && rstDialysisStateFlag == "1" */
and
    om.rst_dialysis_state > '0'
/*%end */
/*%if ""!= rstDialysisStateFlag && rstDialysisStateFlag == "2" */
and
    om.rst_dialysis_state >= '0'
/*%end */
/*%if fromDate != null*/
and
    om.treat_date between /* fromDate */'' and /* toDate */''
/*%end*/
