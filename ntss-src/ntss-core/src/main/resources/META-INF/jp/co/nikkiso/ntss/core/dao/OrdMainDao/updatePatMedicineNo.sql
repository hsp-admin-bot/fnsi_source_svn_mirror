insert into	medicine_latest_no
(facility_cd,	pat_id,	medi_info_no,	reg_date,	up_date, is_del, is_disp)
values
  (/*updCond.facilityCd*/'NKKSBR',
   /*updCond.patId*/11438,
   /*updCond.mediInfoNo*/1,
   /*updCond.regDate*/null,
   /*updCond.upDate*/null,
   /*updCond.isDisp*/0,
   /*updCond.isDel*/1)
  on conflict (facility_cd, pat_id)
do update set
  medi_info_no = medicine_latest_no.medi_info_no + /*updCond.mediInfoNo*/1
  ,	up_date = /*updCond.upDate*/null
--returning facility_cd, pat_id, medi_info_no
