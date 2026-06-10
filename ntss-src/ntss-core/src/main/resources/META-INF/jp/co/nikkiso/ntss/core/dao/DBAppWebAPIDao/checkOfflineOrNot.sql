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
or
 --通信フォーマットがオフライン、医器工V1～V4かどうかの確認
 Exists
(
  select
    mac.com_format_cd
  from
    mst_machine mac,ord_main ord,mst_bed bed
  where
    bed.facility_cd = ord.facility_cd
    and
    bed.bed_cd = ord.ind_bed_cd
    and
    mac.facility_cd = bed.facility_cd
    and
    mac.machine_no = bed.machine_no
    and
    -- #10889 2024.10.16 mod オフライン判定条件を変更 TDC片口 start
    -- mac.com_format_cd in ('F','V','W','Y','Z')
    mac.com_format_cd = 'F'
    and
    mac.com_type = 0
    -- #10889 2024.10.16 mod オフライン判定条件を変更 TDC片口 end
    and
    ord.ord_no = /*ord_no*/0
)
