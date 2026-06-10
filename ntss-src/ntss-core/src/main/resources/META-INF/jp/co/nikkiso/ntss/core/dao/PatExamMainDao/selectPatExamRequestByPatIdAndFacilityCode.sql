select
  A.pat_id,
  A.facility_cd,
  to_char(A.reg_exam_date, 'YYYYMMDD') as str_exam_date,
  reg_order_class,
  order_exam_set_info
from pat_exam_main A
where
  A.pat_id = /*patId*/null
  and A.is_order = '1'
  and A.facility_cd = /*facilityCd*/null
  and A.is_del = '0'
  and to_char(A.reg_exam_date,'yyyyMMdd') between /* startDate */'19000101' and /* endDate */'20991231'
;
