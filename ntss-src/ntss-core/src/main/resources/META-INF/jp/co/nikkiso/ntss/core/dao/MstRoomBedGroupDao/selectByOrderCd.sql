-- add #9323 帳票「並び替え」機能のオーバーホール　donghao start
--ベッドグループ
  select
  /*%expand "A" */*
  from
    mst_room_bed_group A
    where facility_cd = /*facilityCd*/null

    order by room_bed_group_cd
    /*%if isDesc == true*/
     desc
   /*%end*/
-- add #9323 帳票「並び替え」機能のオーバーホール　donghao end

