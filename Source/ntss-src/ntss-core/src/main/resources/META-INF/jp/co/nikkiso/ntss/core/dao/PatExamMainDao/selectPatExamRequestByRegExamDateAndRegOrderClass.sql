select
    DISTINCT
    to_char(A.reg_exam_date, 'YYYYMMDD') as str_exam_date
from pat_exam_main A
where
    A.pat_id = /*patId*/null
  and
      A.is_order = '1'
  and
      A.facility_cd = /*facilityCd*/null
  and
      A.is_del = '0'
  and
      to_char(A.reg_exam_date,'yyyyMMdd') between /* startDate */'19000101' and /* endDate */'20991231'
/*%if weeksArry.get(0) != 0 */
  and
      case when extract(DOW from A.reg_exam_date) = 0 then 7
      else extract(DOW FROM A.reg_exam_date) end in /* weeksArry */()
/*%end */
/*%if regOrderClass.size() != 0 */
  and
      A.reg_order_class in /* regOrderClass */()
/*%end*/
order by
    str_exam_date
;
