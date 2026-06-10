insert into pat_obs_rec
  (obs_rec_no, pat_id, facility_cd, rec_date, up_cnt, kind_info, reg_staff_info, up_staff_info,
   obs_rec_info, bbs_ctl_no, ord_no, is_newest, is_del, fn_seq_id, reg_date, up_date)
values
  (0, 1, '000001', '2019/01/01 00:00:00', 0,
  E'{"kind_no": 1, "kind_name": "観察メモ", "kind_class": 0, "kind_update": "2019-01-30T15:00:00.000+0000"}',
  E'{"reg_staff_cd": 21, "reg_staff_name": "tdc1 tdc"}',
  null,
  E'{"detail1": "test", "detail2": "", "detail3": "", "detail4": ""}',
  null, null, '0', '0', null, '2019/02/04 20:00:00.000', '2019/02/04 20:00:00.000')
;