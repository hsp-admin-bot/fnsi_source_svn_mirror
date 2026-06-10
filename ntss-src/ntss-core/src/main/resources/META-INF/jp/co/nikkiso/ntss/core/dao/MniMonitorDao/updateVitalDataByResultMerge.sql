update
  mni_monitor
set
  ord_no = /*ordNo*/0,
  pat_id = /*patId*/null,
  up_date = /*upDate*/null,
  upd_staff_id = /*updStaffId*/null
where
  ord_no = /*targetOrdNo*/0
  and data_type in (2, 4, 5, 6)
;
