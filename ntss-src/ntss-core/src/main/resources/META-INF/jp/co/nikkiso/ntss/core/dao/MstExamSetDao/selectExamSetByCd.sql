SELECT
A.exam_set_cd,
A.facility_cd,
A.fn_exam_set_cd,
A.set_class,
A.exam_set_name,
A.exam_set_short_name,
A.exam_set_class,
-- del 11602 検査の「院内／院外」を検査項目マスタに持たせる zkm start
-- A.is_in_hospital,
-- del 11602 検査の「院内／院外」を検査項目マスタに持たせる zkm end
A.can_emergency,
A.other_exam_time,
A.exam_item_info,
A.in_hospital_cd1,
A.sbt_cd1,
A.in_hospital_cd2,
A.sbt_cd2,
A.in_hospital_cd3,
A.sbt_cd3,
A.label_info,
A.is_disp,
A.is_del,
A.reg_date,
A.up_date
FROM mst_exam_set A
WHERE 
/*%if null != examSetCd */
  A.exam_set_cd = /* examSetCd */null
/*%end */
;