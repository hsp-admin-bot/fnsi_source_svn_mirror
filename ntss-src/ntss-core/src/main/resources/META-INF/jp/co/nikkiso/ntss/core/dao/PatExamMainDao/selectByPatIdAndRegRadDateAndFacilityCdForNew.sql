SELECT
  /*%expand "A"*/*
FROM pat_exam_main A
WHERE A.is_del = '0'
AND A.pat_id = /* patId */null
AND to_char(A.reg_exam_date,'YYYY-MM-DD') = /* regExamDate */null
AND A.facility_cd = /* facilityCd */null
--add #7154 exam_ord連携のord_noが正しくsys_coop_journalに登録されない 20220818 zhaoqi start
AND A.reg_order_class = /*regOrderClass*/null
AND A.phy_ord_class is null
--add #7154 exam_ord連携のord_noが正しくsys_coop_journalに登録されない 20220818 zhaoqi end
ORDER BY A.up_date DESC LIMIT 1
