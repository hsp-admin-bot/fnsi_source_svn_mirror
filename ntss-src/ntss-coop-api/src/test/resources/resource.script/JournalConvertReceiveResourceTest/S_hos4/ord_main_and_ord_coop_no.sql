DELETE FROM ord_main
WHERE ord_no = '2';

SELECT SETVAL('ord_main_ord_no_seq', 1);

DELETE FROM ord_coop_no
WHERE facility_cd = 'S_hos4';

INSERT INTO ord_main
(
  pat_id
  ,fn_pat_id
  ,treat_date
  ,treat_week
  ,facility_cd
  ,facility_name
  ,ind_va_cd
  ,ind_treatment_cd
  ,ind_treatment_name
  ,ind_kur_cd
  ,ind_kur_name
  ,ind_treat_start_time
  ,ind_bed_cd
  ,ind_bed_name
  ,ind_schedule_user_info
  ,ind_cond_info
  ,ind_medi_info
  ,ind_equip_info
  ,ind_ind_comment_info
  ,ind_tare_info
  ,ind_off_water_info
  ,ind_device_set_info
  ,is_del
  ,up_date
  ,reg_date
)
values(
  3000002
  ,'111'
  ,'20180702'
  ,3
  ,'S_hos4'
  ,'施設なまえ'
  ,1
  ,2
  ,'とりーとなまえ'
  ,3
  ,'クール名'
  ,1100
  ,4
  ,'ベッド名'
  ,'{}'
  ,'{}'
  ,'{}'
  ,'{}'
  ,'{}'
  ,'{}'
  ,'{}'
  ,'{}'
  ,'0'
  ,'2019/12/13 5:44:54'
  ,'2019/12/13 5:44:54'
);

INSERT INTO ord_coop_no
(
  facility_cd
  ,pat_id
  ,ord_no
  ,coop_cd
  ,coop_ord_no
  ,is_disp
  ,is_del
  ,user_id
  ,reg_date
  ,up_date
)
values
(
  'S_hos4'
  ,3000002
  ,2
  ,'is_dial'
  ,'111111'
  ,'1'
  ,'0'
  ,123
  ,'2019/12/13 5:44:54'
  ,'2019/12/13 5:44:54'
)
;