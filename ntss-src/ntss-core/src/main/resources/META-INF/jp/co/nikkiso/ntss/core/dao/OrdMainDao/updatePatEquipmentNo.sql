insert into	equipment_latest_no
(facility_cd,	pat_id,	equip_info_no,	reg_date,	up_date, is_del, is_disp)
values
  (/*updCond.facilityCd*/'NKKSBR',
   /*updCond.patId*/11438,
   /*updCond.equipInfoNo*/1,
   /*updCond.regDate*/null,
   /*updCond.upDate*/null,
   /*updCond.isDisp*/0,
   /*updCond.isDel*/1)
  on conflict (facility_cd, pat_id)
do update set
  equip_info_no = equipment_latest_no.equip_info_no + /*updCond.equipInfoNo*/1
  ,	up_date = /*updCond.upDate*/null
