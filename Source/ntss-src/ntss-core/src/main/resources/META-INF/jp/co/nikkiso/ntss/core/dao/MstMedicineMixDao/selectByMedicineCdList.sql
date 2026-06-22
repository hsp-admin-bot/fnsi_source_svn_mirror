--調製薬剤マスタ
select
  /*%expand "A" */*
from
  mst_medicine_mix A   --テーブル名
where
  A.facility_cd = /* facilityCd */null
and
  A.is_del = '0'
and
  A.is_disp = '1'
/*%if medicineCdList.size() > 0 */
  and (
  /*%for medicineCd : medicineCdList */
    A.mix_info::jsonb @> ('[{"cd":' || /* medicineCd */null || '}]')::jsonb
    /*%if medicineCd_has_next */
      or
    /*%end */
  /*%end */
  )
/*%end */
;
