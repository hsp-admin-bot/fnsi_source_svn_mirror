UPDATE
  ord_checklist
set
  rst_checklist_info = jsonb_set(rst_checklist_info, '{amount}',/*amount*/null)
where
  checklist_ctl_no = /*ctlNo*/null
;
