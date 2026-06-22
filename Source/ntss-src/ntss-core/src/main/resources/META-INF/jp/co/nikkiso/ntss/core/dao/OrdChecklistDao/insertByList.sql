INSERT INTO ord_checklist
(
  ord_no,
  is_check,
  rst_class,
  list_cd,
  func_class,
  rst_checklist_info,
  reg_staff_info,
  is_disp,
  is_del,
  occur_date,
  reg_date,
  up_date,
  facility_cd
)
VALUES
/*%for ord : list */
(
  /*ord.ordNo*/null,
  /*ord.isCheck*/null,
  /*ord.rstClass*/null,
  /*ord.listCd*/null,
  /*ord.funcClass*/null,
  /*ord.rstChecklistInfo*/null,
  /*ord.regStaffInfo*/null,
  /*ord.isDisp*/null,
  /*ord.isDel*/null,
  /*ord.occurDate*/null,
  CURRENT_TIMESTAMP,
  CURRENT_TIMESTAMP,
  /*ord.facilityCd*/null
)
    /*%if ord_has_next */
    /*# "," */
    /*%end */
/*%end*/
