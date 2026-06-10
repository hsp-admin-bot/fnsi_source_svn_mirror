select
  mfh.facility_cd as facility_cd
from
  mst_facility_hash mfh
where
  hash_value in /* hashValueList */(null)
union all
select
  '0' as facility_cd
 where not exists
 (select *
  from mst_facility_hash
  where hash_value in /* hashValueList */(null));
