select
 --- 患者の治療状況が治療中以降かどうか false:治療済み
not Exists
(
  --- 治療済みの選択
  select
    rst_dialysis_state
  from 
    ord_main
  where
    facility_cd = /*facility_cd*/''
    and
    ord_no = /*ord_no*/0
    and
    cast(rst_dialysis_state as Integer) >= 3
)
