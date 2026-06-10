select
  facility_cd
  , hash_value
  , reg_date
  , up_date
from
  mst_pat_hash
where
  facility_cd = /*facilityCd*/'1'
;
