select *
from pat_exam_main
where pat_id = /* patId */null
  and to_char(reg_exam_date, 'YYYY/MM/DD') in /* dateList */(null);
