select
  exam_item_cd
  , facility_cd
  , fn_exam_item_cd
  , exam_item_name
  , data_type
  , unit
  , normal_value_class
  , normal_value_upper
  , normal_value_lower
  , normal_value_upper_m
  , normal_value_lower_m
  , normal_value_upper_w
  , normal_value_lower_w
  , input_integer_figure
  , input_decimal_figure
  , input_upper
  , input_lower
  , graph_upper
  , graph_lower
  , console_class
  , exam_class
  , in_hospital_cd1
  , sbt_cd1
  , in_hospital_cd2
  , sbt_cd2
  , in_hospital_cd3
  , sbt_cd3
  , spitz_cd
  , jlac10_cd
  , infection_cd
  , default_calc_exam_item_cd
  , free_calc
  , is_disp
  , is_del
  , reg_date
  , up_date
--   add FNSI-fix Bug 関 start
  , dialysis_progress_flag
--   add FNSI-fix Bug 関 end
-- add 11602 検査の「院内／院外」を検査項目マスタに持たせる zkm start
  , is_in_hospital
-- add 11602 検査の「院内／院外」を検査項目マスタに持たせる zkm end
from
  mst_exam_item
where
  exam_item_cd = /*examItemCd*/-1
;
