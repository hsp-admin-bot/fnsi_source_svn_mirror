update pat_obs_rec set
  pat_id = /*param.patId*/9,
  facility_cd = /*param.facilityCd*/'999999',
  rec_date = /*param.recDate*/null,
  up_cnt = /*param.upCnt*/'0',
  /*%if param.kindInfo == null || param.kindInfo.length() > 0 */
  kind_info = /*param.kindInfo*/'',
  /*%end */
  /*%if param.regStaffInfo == null || param.regStaffInfo.length() > 0 */
  reg_staff_info = /*param.regStaffInfo*/'',
  /*%end */
  /*%if param.upStaffInfo == null || param.upStaffInfo.length() > 0 */
  up_staff_info = /*param.upStaffInfo*/'',
  /*%end */
  /*%if param.obsRecInfo == null || param.obsRecInfo.length() > 0 */
  obs_rec_info = /*param.obsRecInfo*/'',
  /*%end */
  bbs_ctl_no = /*param.bbsCtlNo*/'0',
  ord_no = /*param.ordNo*/'0',
  is_newest = /*param.isNewest*/'0',
  is_del = /*param.isDel*/'9',
  fn_seq_id = /*param.fnSeqId*/'0',
  up_date = /*param.upDate*/'1970/01/01 00:00:00'
where
  obs_rec_no = /*param.obsRecNo*/9
  ;