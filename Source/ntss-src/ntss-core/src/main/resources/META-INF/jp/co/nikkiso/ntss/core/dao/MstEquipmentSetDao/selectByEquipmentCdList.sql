--医療材料セット
select
  /*%expand "A" */*
from
  mst_equipment_set A   --テーブル名
where
  A.facility_cd = /* facilityCd */null
and
  A.is_del = '0'
and
  A.is_disp = '1'
/*%if equipmentCdList.size() > 0 */
  and (
  /*%for equipmentCd : equipmentCdList */
    A.set_info::jsonb @> ('[{"cd":' || /* equipmentCd */null || ', "equip_type":' || /* equipType */null || '}]')::jsonb
    /*%if equipmentCd_has_next */
      or
    /*%end */
  /*%end */
  )
/*%end */
;
