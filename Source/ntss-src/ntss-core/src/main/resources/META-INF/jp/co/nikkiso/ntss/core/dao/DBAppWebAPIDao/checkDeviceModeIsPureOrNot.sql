select
 --治療モードが特殊浄化かどうかの確認
Exists
(
  select
    tre.device_mode
  from 
    mst_treatment tre,ord_main ord
  where
    tre.facility_cd = ord.facility_cd
    and
    tre.treatment_cd = ord.ind_treatment_cd
    and
      tre.device_mode = 9
    and
    ord.ord_no = /*ord_no*/0
)
