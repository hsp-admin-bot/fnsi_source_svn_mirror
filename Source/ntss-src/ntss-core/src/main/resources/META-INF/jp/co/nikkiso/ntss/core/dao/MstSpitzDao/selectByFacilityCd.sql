select
  spitz_cd
  , facility_cd
  , spitz_name
  , label_print
-- del 11602 検査の「院内／院外」を検査項目マスタに持たせる zkm start
--   , is_in_hospital
-- del 11602 検査の「院内／院外」を検査項目マスタに持たせる zkm end
  , is_disp
  , is_del
from
  mst_spitz
where
  facility_cd = /*facilityCd*/1
;