insert into pat_obs_rec(
  pat_id,
  facility_cd,
  rec_date,
  up_cnt,
  /*%if param.kindInfo == null || param.kindInfo.length() > 0 */
  kind_info,
  /*%end */
  /*%if param.regStaffInfo == null || param.regStaffInfo.length() > 0 */
  reg_staff_info,
  /*%end */
  /*%if param.upStaffInfo == null || param.upStaffInfo.length() > 0 */
  up_staff_info,
  /*%end */
  /*%if param.obsRecInfo == null || param.obsRecInfo.length() > 0 */
  obs_rec_info,
  /*%end */
  bbs_ctl_no,
  ord_no,
  is_newest,
  is_del,
  fn_seq_id,
  reg_date,
  up_date
)
values(
  /*param.patId*/'999999999999',
  /*param.facilityCd*/'999999',
  /*param.recDate*/'1970/01/01 00:00:00',
  /*param.upCnt*/'0',
  /*%if param.kindInfo == null || param.kindInfo.length() > 0 */
  /*param.kindInfo*/'',
  /*%end */
  /*%if param.regStaffInfo == null || param.regStaffInfo.length() > 0 */
  /*param.regStaffInfo*/'',
  /*%end */
  /*%if param.upStaffInfo == null || param.upStaffInfo.length() > 0 */
  /*param.upStaffInfo*/'',
  /*%end */
  /*%if param.obsRecInfo == null || param.obsRecInfo.length() > 0 */
  /*param.obsRecInfo*/'',
  /*%end */
  /*param.bbsCtlNo*/'0',
  /*param.ordNo*/'0',
  /*param.isNewest*/'0',
  /*param.isDel*/'9',
  /*param.fnSeqId*/'0',
  /*param.regDate*/'1970/01/01 00:00:00',
  /*param.upDate*/'1970/01/01 00:00:00'
)