select
  ward_cd,
  ward_name,
  -- add 10626 データリストのCTR・DW一括登録修正 房 start
  in_hospital_cd_1
  -- add 10626 データリストのCTR・DW一括登録修正 房 end
from
  mst_ward A
where
    A.ward_cd in /* wardCds */(null)
;
