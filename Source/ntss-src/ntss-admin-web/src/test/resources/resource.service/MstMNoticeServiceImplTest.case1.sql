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
  (1,'009999','group1','{"users": [{"user_id": 101, "is_address1_send": true, "is_address2_send": true}, {"user_id": 103, "is_address1_send": true, "is_address2_send": false}, {"user_id": 104, "is_address1_send": false, "is_address2_send": true}, {"user_id": 107, "is_address1_send": true, "is_address2_send": false}, {"user_id": 108, "is_address1_send": true, "is_address2_send": false}]}','1','0','2019/02/01','2019/02/02')
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
  up_date
) 
values
 (1,'009999','alarm1','009999',1,'{"cds": [{"machine_record_cd": 4505}, {"machine_record_cd": 4829}, {"machine_record_cd": 4501}, {"machine_record_cd": 4923}, {"machine_record_cd": 7842}]}','1','0',null,null)
;

