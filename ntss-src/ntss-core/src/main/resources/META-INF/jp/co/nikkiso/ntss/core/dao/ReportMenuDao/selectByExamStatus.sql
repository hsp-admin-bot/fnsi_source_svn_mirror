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