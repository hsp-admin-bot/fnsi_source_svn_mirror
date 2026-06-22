-- ベッド移動時のデータ更新(メインスケジュール)
-- 治療日、クールコード、ベッドコードが変更されます
update ord_schedule
set 
  treat_date = /*newTreatDate*/'',
  kur_cd = /*kurCd*/0,
  bed_cd = /*bedCd*/0,
  up_date = transaction_timestamp()
where
  ord_no = /*ordNo*/0
  and
  facility_cd = /*facilityCd*/''
  and
  treat_date = /*condTreatDate*/''
  and
  is_dummy = '0'  --パラメータ渡し?
