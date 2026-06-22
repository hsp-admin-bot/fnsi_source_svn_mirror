select
ord_no,
facility_cd,
ind_cond_info,
-- add FNSI-分類不一致判断の追加 徐 start
ind_va_cd,
ind_bed_cd,
pat_id,
ind_medi_info,
ind_equip_info,
rst_dialysis_state
-- add FNSI-分類不一致判断の追加 徐 end
from
ord_main
where
ord_no = /*ordNo*/0
/*%if null != ordNos*/
or
  ord_no = /*ordNos*/0
/*%end*/
