-- mst_bed(ベッドマスタ)+mst_machine(装置マスタ)一覧取得用SQL
select
  A.bed_cd
-- del #10280 ベッドマスタに不要なカラムが存在する dengshen start
--   , A.bed_no
-- del #10280 ベッドマスタに不要なカラムが存在する dengshen end
  , A.bed_name
  , B.machine_no
  , B.machine_type_cd
  , B.machine_serial
  , B.machine_name
  , C.machine_type
  , C.model
from
  --テーブル名
  mst_bed A
  inner join
    mst_machine B
  on A.machine_no = B.machine_no
  inner join
    mst_machine_type C
  on B.machine_type_cd = C.machine_type_cd
where
  A.facility_cd = /*facilityCd*/'999900'
and
  A.is_del = '0'
and
  A.is_disp = '1'
and
  B.is_del = '0'
and
  B.is_disp = '1'

;
