select
  facility_cd
  , master_physical_name
  , order_settings
  , reg_date
  , up_date
from
  mst_selector
where
  facility_cd = /*facilityCd*/'1'
/*%if masterPhysicalNameList.size() > 0 */
  and master_physical_name in /* masterPhysicalNameList */(null)
/*%end*/
;
