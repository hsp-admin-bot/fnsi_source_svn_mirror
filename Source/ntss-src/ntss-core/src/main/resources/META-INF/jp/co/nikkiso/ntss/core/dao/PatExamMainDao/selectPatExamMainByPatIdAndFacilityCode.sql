select
DISTINCT
  A.pat_id,
  A.facility_cd,
  to_char(A.reg_exam_date, 'YYYYMMDD') as str_exam_date
from pat_exam_main A
where
  A.pat_id = /*patId*/null
  and A.exam_status = '1'
  and A.facility_cd = /*facilityCd*/null
  and A.is_del = '0'
  and to_char(A.reg_exam_date,'yyyyMMdd') between /* startDate */'19000101' and /* endDate */'20991231'
;
