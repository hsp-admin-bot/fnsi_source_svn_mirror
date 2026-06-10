delete from mst_alarm_notification;
delete from mst_destination_group;
insert into mst_destination_group
(
  destination_group_cd,
  facility_cd,
  destination_group_name,
  destination_target,
  is_disp,
  is_del,
  reg_date,
  up_date
) 
values
  (1,'09999','group1','{"users": [{"user_id": 101, "is_address1_send": false, "is_address2_send": true}, {"user_id": 107, "is_address1_send": true, "is_address2_send": false}, {"user_id": 108, "is_address1_send": true, "is_address2_send": false}, {"user_id": 125, "is_address1_send": true, "is_address2_send": true}]}','1','0','2019/02/01','2019/02/02')
 ,(2,'09999','group2','{"users": [{"user_id": 112, "is_address1_send": true, "is_address2_send": false}, {"user_id": 103, "is_address1_send": true, "is_address2_send": false}, {"user_id": 107, "is_address1_send": true, "is_address2_send": true}]}','1','0','2019/02/01','2019/02/02')
;

insert into mst_alarm_notification
(
  alarm_notification_cd,
  facility_cd,
  alarm_notification_name,
  destination_facility_cd,
  destination_group_cd,
  target_machine_record,
  is_disp,
  is_del,
  reg_date,
  up_date,
  is_notice_mon,
  start_time_mon,
  end_time_mon,
  is_next_day_mon,
  is_notice_tue,
  start_time_tue,
  end_time_tue,
  is_next_day_tue,
  is_notice_wed,
  start_time_wed,
  end_time_wed,
  is_next_day_wed,
  is_notice_thu,
  start_time_thu,
  end_time_thu,
  is_next_day_thu,
  is_notice_fri,
  start_time_fri,
  end_time_fri,
  is_next_day_fri,
  is_notice_sat,
  start_time_sat,
  end_time_sat,
  is_next_day_sat,
  is_notice_sun,
  start_time_sun,
  end_time_sun,
  is_next_day_sun
) 
values
  (1,'09999','alarm1','09999',1,'{"cds": [{"machine_record_cd": "4505"}, {"machine_record_cd": "4829"}, {"machine_record_cd": "4501"}, {"machine_record_cd": "4923"}, {"machine_record_cd": "7842"}]}','1','0',null,null, '1', null, null, '0', '1', '00:00', '23:59', '0', '1', null, null, '0', '1', '00:00', '23:59', '0', '1', null, null, '0', '1', '00:00', '23:59', '0', '1', null, null, '0')
 ,(2,'09999','alarm2','09999',2,'{"cds": [{"machine_record_cd": "4505"}, {"machine_record_cd": "4501"}, {"machine_record_cd": "7842"}, {"machine_record_cd": "AC09"}]}','1','0',null,null, '1', null, null, '0', '1', '00:00', '23:59', '0', '1', null, null, '0', '1', '00:00', '23:59', '0', '1', null, null, '0', '1', '00:00', '23:59', '0', '1', null, null, '0')
;

