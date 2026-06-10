INSERT INTO ord_main
(
  ord_no,
  pat_id,
  treat_date,
  ind_treatment_cd,
  ind_treatment_name,
  ind_treat_start_time,
  ind_kur_cd,
  ind_kur_name,
  ind_bed_cd,
  ind_bed_name,
  rst_dialysis_state,
  rst_treatment_cd,
  rst_treatment_name,
  rst_kur_cd,
  rst_kur_name,
  rst_bed_cd,
  rst_bed_name,
  rst_start_date,
  rst_end_date,
  is_del,
  up_date,
  reg_date
) VALUES (
  1,
  1,
  '20190610',
  11,
  '【指示】治療方法名1',
  '0900',
  11,
  '【指示】クール1',
  12,
  '【指示】ベッド1',
  '1',
  21,
  '【実績】治療方法名1',
  21,
  '【実績】クール1',
  22,
  '【実績】ベッド1',
  '2019/06/10 12:00:00.000',
  '2019/06/10 18:00:00.000',
  '0',
  '2019/06/10 12:00:00.000',
  '2019/06/10 18:00:00.000'
),(
  2,
  1,
  '20190620',
  12,
  '【指示】治療方法名2',
  '1000',
  12,
  '【指示】クール2',
  13,
  '【指示】ベッド2',
  '2',
  22,
  '【実績】治療方法名2',
  22,
  '【実績】クール2',
  23,
  '【実績】ベッド2',
  '2019/06/20 12:30:00.000',
  '2019/06/20 18:30:00.000',
  '0',
  '2019/06/20 12:30:00.000',
  '2019/06/20 18:30:00.000'
),(
   3,
   1,
   '20190621',
   12,
   '【指示】治療方法名2',
   '1100',
   12,
   '【指示】クール2',
   13,
   '【指示】ベッド2',
   '3',
   22,
   '【実績】治療方法名2',
   22,
   '【実績】クール2',
   23,
   '【実績】ベッド2',
   '2019/06/21 12:00:00.000',
   '2019/06/21 18:00:00.000',
   '0',
   '2019/06/21 12:00:00.000',
   '2019/06/21 18:00:00.000'
 ),(
    4,
    1,
    '20190620',
    12,
    '【指示】治療方法名2',
    '1200',
    12,
    '【指示】クール2',
    13,
    '【指示】ベッド2',
    '4',
    22,
    '【実績】治療方法名2',
    22,
    '【実績】クール2',
    23,
    '【実績】ベッド2',
    '2019/06/20 12:00:00.000',
    '2019/06/20 18:00:00.000',
    '1',
    '2019/06/20 12:00:00.000',
    '2019/06/20 18:00:00.000'
 ),(
    5,
    2,
    '20190620',
    12,
    '【指示】治療方法名2',
    '1300',
    12,
    '【指示】クール2',
    13,
    '【指示】ベッド2',
    '5',
    22,
    '【実績】治療方法名2',
    22,
    '【実績】クール2',
    23,
    '【実績】ベッド2',
    '2019/06/20 12:00:00.000',
    '2019/06/20 18:00:00.000',
    '0',
    '2019/06/20 12:00:00.000',
    '2019/06/20 18:00:00.000'
 ),(
    6,
    1,
    '20190620',
    12,
    '【指示】治療方法名2',
    '1300',
    12,
    '【指示】クール2',
    13,
    '【指示】ベッド2',
    '0',
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    '0',
    '2019/06/20 12:00:00.000',
    '2019/06/20 18:00:00.000'
 )
;

INSERT INTO mst_room_bed_group
(
  facility_cd,
  room_bed_group_name,
  bed_list,
  reg_date,
  up_date
) VALUES (
  '009999',
  'ルーム名1',
  '[1, 2, 13, 22, 30]',
  '2019/06/20 12:00:00.000',
  '2019/06/20 12:00:00.000'
),(
  '009999',
  'ルーム名2',
  '[1, 2, 3, 22, 30]',
  '2019/06/20 12:00:00.000',
  '2019/06/21 12:00:00.000'
),(
  '009999',
  'ルーム名3',
  '[1, 2, 3, 23, 30]',
  '2019/06/20 12:00:00.000',
  '2019/06/20 12:00:00.000'
)
;

INSERT INTO mst_user (user_id, user_settings, is_provisional, reg_date, up_date) VALUES
  -- getUserAccountInfo
  (2,E'{"theme": 0, "font_size": 3, "is_disp_menu": 1, "use_functions": ["005", "004", "003", "002", "001"], "initial_function": "001", "ind_rst_pattern": 2}',1,NULL,E'2018-11-12 13:58:50.302'),
  (3,E'{"theme": 0, "font_size": 1, "is_disp_menu": 1, "use_functions": ["001", "003", "002", "004", "005"], "initial_function": "001", "ind_rst_pattern": 3}',0,NULL,E'2018-11-12 14:03:06.582')
;

insert into pat_main
(
  pat_id,
  facility_cd,
  is_same,
  is_implant,
  is_infect,
  is_diabetes,
  is_blood_suger_exam,
  in_out_current_state,
  in_out_plan_state,
  in_out_plan_date,
  pat_memo_info,
  addition_info,
  charge_staff_info,
  pat_group_info,
  taboo_allergy_info,
  infect_info,
  implant_info,
  tare_info,
  off_water_info,
  device_set_info,
  acceptance_status_info,
  host_notification_info,
  is_del,
  up_date,
  reg_date,
  is_wheel_chair
) values (
  1,
  '009999',
  '0',
  '0',
  '0',
  '0',
  '0',
  null,
  null,
  null,
  '[]',
  '[]',
  '[]',
  '[]',
  '[]',
  '[]',
  '[]',
  '[]',
  '[]',
  '[]',
  '[]',
  '0',
  '2019/12/09 18:57:05.750',
  '2019/04/05 16:13:41',
  '1'
),(
  2,
  '009999',
  '0',
  '0',
  '0',
  '0',
  '0',
  null,
  null,
  null,
  '[]',
  '[]',
  '[]',
  '[]',
  '[]',
  '[]',
  '[]',
  '[]',
  '[]',
  '[]',
  '[]',
  '[]',
  '0',
  '2019/12/09 18:57:05.750',
  '2019/04/05 16:18:01',
  '0');

insert into mst_kur
(
  kur_cd,
  facility_cd,
  fn_kur_cd,
  kur_name,
  kur_start_time,
  kur_end_time,
  kur_standard_start_time,
  in_hospital_cd_1,
  is_del,
  reg_date,
  up_date
) values (
  11,
  '009999',
  null,
  '【指示】クール1',
  '000000',
  '095959',
  '090000',
  null,
  '0',
  '2019/12/09',
  '2019/12/11 18:59:29'
),(
  21,
  '009999',
  null,
  '【実績】クール1',
  '120000',
  '165959',
  '120000',
  null,
  '0',
  '2019/12/09',
  '2019/12/09'
),(
  12,
  '009999',
  null,
  '【指示】クール2',
  '170000',
  '235959',
  '170000',
  null,
  '0',
  '2019/12/09',
  '2019/12/09'
),(
  22,
  '009999',
  null,
  '【実績】クール2',
  '100000',
  '115959',
  '100000',
  null,
  '0',
  '2019/12/11 18:59:29',
  '2019/12/12 9:47:46'
);

insert into ntss.mst_treatment(
  treatment_cd, 
  facility_cd,
  treatment_name,
  is_disp,
  is_del
) values (
  11,
  '009999',
  '【指示】治療方法名1',
  '1',
  '0'
),(
  12,
  '009999',
  '【指示】治療方法名2',
  '1',
  '0'
),(
  21,
  '009999',
  '【実績】治療方法名1',
  '1',
  '0'
),(
  22,
  '009999',
  '【実績】治療方法名2',
  '1',
  '0'
);

insert into ntss.mst_bed(
  bed_cd, 
  facility_cd,
  bed_name,
  is_disp,
  is_del
) values (
  12,
  '009999',
  '【指示】ベッド1',
  '1',
  '0'
),(
  13,
  '009999',
  '【指示】ベッド2',
  '1',
  '0'
),(
  22,
  '009999',
  '【実績】ベッド1',
  '1',
  '0'
),(
  23,
  '009999',
  '【実績】ベッド2',
  '1',
  '0'
);

insert into ntss.mst_selector(
  facility_cd,
  master_physical_name,
  order_settings,
  reg_date,
  up_date
) values (
  '009999',
  'mst_treatment',
  '{"items": [{"code": 11, "name": "【指示】治療方法名1"},{"code": 12, "name": "【指示】治療方法名2"},{"code": 21, "name": "【実績】治療方法名1"},{"code": 22, "name": "【実績】治療方法名2"}]}',
  '2019/12/18',
  '2019/12/19 13:07:36.621'
),(
  '009999',
  'mst_bed',
  '{"items": [{"code": 12, "name": "【指示】ベッド1"},{"code": 13, "name": "【指示】ベッド2"},{"code": 22, "name": "【実績】ベッド1"},{"code": 23, "name": "【実績】ベッド2"}]}',
  '2019/12/18',
  '2019/12/19 13:07:36.621'
),(
  '009999',
  'mst_kur',
  '{"items": [{"code": 11, "name": "【指示】クール1"},{"code": 12, "name": "【指示】クール2"},{"code": 21, "name": "【実績】クール1"},{"code": 22, "name": "【実績】クール2"}]}',
  '2019/12/18',
  '2019/12/19 13:07:36.621'
);