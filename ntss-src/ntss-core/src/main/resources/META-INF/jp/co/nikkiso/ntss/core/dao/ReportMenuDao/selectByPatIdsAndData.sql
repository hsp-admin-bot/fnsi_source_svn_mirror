select
    om.pat_id,
    om.ord_no
from
    ord_main as om
left join
    pat_exam_main as pem
on
    om.pat_id = pem.pat_id
and
    om.treat_date = to_char(pem.reg_exam_date, 'YYYYMMDD')
where
    om.pat_id in /* patIds */(null)
and
    om.facility_cd = /* facilityCd */''
/*%if regOrderClassList.size() != 0*/
and pem.reg_order_class in /* regOrderClassList */(null)
/*%end*/
and om.is_del = '0'
/*%if specifyDate != null */
and om.treat_date = /* specifyDate */''
/*%else */
and om.treat_date between /* fromDate */'' and /* toDate */''
/*%end */
