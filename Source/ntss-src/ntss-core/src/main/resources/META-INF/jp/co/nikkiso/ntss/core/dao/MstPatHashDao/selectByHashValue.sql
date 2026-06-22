select
  facility_cd
  , hash_value
  , reg_date
  , up_date
from
  mst_pat_hash
where
  hash_value = /*hashValue*/'1'
;
