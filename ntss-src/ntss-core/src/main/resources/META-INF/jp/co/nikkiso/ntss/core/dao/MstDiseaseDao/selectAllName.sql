--病名
select
  disease_cd,
  disease_Name,
  -- add 10626 データリストのCTR・DW一括登録修正 房 start
  in_hospital_cd_1
  -- add 10626 データリストのCTR・DW一括登録修正 房 end
from
  mst_disease
where
    disease_cd in /* diseaseCds */(null)
;
