--ベッドグループ
  select
      /*%expand */*
  from
    mst_room_bed_group
  where
   facility_cd = /* facilityCd */'000000'
