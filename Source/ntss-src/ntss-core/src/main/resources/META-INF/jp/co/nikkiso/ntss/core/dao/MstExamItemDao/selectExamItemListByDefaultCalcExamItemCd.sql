select
  exam_item_cd
from
  mst_exam_item
where
  facility_cd = /*facilityCd*/0
and
  default_calc_exam_item_cd = /*defaultCalcExamItemCd*/0
;
