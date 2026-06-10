select distinct
    om.ord_no
from
    ord_main as om
left join
    pat_exam_main as pem
on
    om.pat_id = pem.pat_id
where
    om.pat_id in /* patIds */(null)
and
    om.facility_cd = /* facilityCd */''
    /*%if regOrderClassList.size() != 0*/
and pem.reg_order_class in /* regOrderClassList */(null)
    /*%end*/
and om.is_del = '0'
/*%if fromDate != null*/
and om.treat_date between /* fromDate */'' and /* toDate */''
/*%end*/
