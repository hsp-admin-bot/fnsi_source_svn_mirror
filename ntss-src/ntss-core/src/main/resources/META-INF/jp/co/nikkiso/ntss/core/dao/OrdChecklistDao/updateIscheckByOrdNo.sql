UPDATE
  ord_checklist
SET
  is_check = /*isCheck*/0,
  reg_staff_info = /*regStaffInfo*/null::jsonb,
  occur_date = /*occurDate*/null,
  reg_date = /*regDate*/null,
  up_date = CURRENT_TIMESTAMP
WHERE
  checklist_ctl_no = /*ctlNo*/null
;
