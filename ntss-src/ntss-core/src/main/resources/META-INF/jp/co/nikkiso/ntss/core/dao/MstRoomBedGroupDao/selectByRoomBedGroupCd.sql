--ベッドグループ
  select
    /*%expand */*
  from
    mst_room_bed_group
  where
    room_bed_group_cd = /* roomBedGroupCd */0