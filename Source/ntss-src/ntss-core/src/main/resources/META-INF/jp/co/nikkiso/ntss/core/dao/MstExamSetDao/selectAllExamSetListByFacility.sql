with phy_class as (
select
  count(1)
from
  mst_facility F,
  jsonb_array_elements(F.advanced_settings->'func_advcds') func
where
  F.facility_cd = /* facilityCd */null
  and func->>'func_advcd'= 'A12'
)
SELECT
  A.exam_set_cd,
  A.facility_cd,
  A.fn_exam_set_cd,
  A.set_class,
  A.exam_set_name,
  A.exam_set_short_name,
  A.exam_set_class,
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
  A.graph_set,
  A.up_date,
  A.order_class
FROM mst_exam_set A
WHERE
  A.facility_cd = /* facilityCd */null
  and (
    A.exam_set_class IN ('0', '1', '2')
    or ( (select * from phy_class) > 0 and A.exam_set_class = '3')
  )
ORDER BY exam_set_cd
;
