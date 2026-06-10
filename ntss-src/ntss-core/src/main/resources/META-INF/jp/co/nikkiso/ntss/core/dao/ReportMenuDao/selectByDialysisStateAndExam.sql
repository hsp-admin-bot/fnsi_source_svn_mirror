select distinct
    om.pat_id
from
    ord_main as om
where
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
and
    om.pat_id in (
        select distinct
            pem.pat_id
        from
            pat_exam_main as pem
        where
            pem.pat_id in /* patIds */(null)
        and
            pem.facility_cd = /* facilityCd */''
        and
            pem.is_del = '0'
        /*%if ""!= examStatusFlag && examStatusFlag == "1" */
        and
            pem.exam_status = '0'
        /*%end */
        /*%if ""!= examStatusFlag && examStatusFlag == "2" */
        and
            pem.exam_status >= '0'
        /*%end */
        /*%if examFromDate != null*/
        and
            pem.reg_exam_date between /* examFromDate */'' and /* examToDate */''
        /*%end*/
    )
