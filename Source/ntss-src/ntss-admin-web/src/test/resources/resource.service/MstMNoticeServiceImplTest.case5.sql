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
  (1,'009999','group1','{"users": [{"user_id": 101, "is_address1_send": false, "is_address2_send": true}, {"user_id": 107, "is_address1_send": true, "is_address2_send": false}, {"user_id": 108, "is_address1_send": true, "is_address2_send": false}, {"user_id": 125, "is_address1_send": true, "is_address2_send": true}]}','1','0','2019/02/01','2019/02/02')
 ,(2,'009999','group2','{"users": [{"user_id": 112, "is_address1_send": true, "is_address2_send": false}, {"user_id": 103, "is_address1_send": true, "is_address2_send": false}, {"user_id": 107, "is_address1_send": true, "is_address2_send": true}]}','1','0','2019/02/01','2019/02/02')
 ,(3,'009997','nkk-group1','{"users": [{"user_id": 201, "is_address1_send": true, "is_address2_send": true}, {"user_id": 203, "is_address1_send": true, "is_address2_send": false}, {"user_id": 204, "is_address1_send": false, "is_address2_send": true}, {"user_id": 207, "is_address1_send": true, "is_address2_send": false}, {"user_id": 208, "is_address1_send": true, "is_address2_send": false}]}','1','0','2019/02/01','2019/02/02')
 ,(4,'009997','nkk-group2','{"users": [{"user_id": 222, "is_address1_send": true, "is_address2_send": false}, {"user_id": 213, "is_address1_send": false, "is_address2_send": true}, {"user_id": 217, "is_address1_send": true, "is_address2_send": true}]}','1','0','2019/02/01','2019/02/02')
 ,(5,'009998','o-group1','{"users": [{"user_id": 301, "is_address1_send": true, "is_address2_send": false}, {"user_id": 302, "is_address1_send": false, "is_address2_send": true}]}','1','0','2019/02/01','2019/02/02')
 ,(6,'009997','o-nkk-group1','{"users": [{"user_id": 201, "is_address1_send": true, "is_address2_send": true}, {"user_id": 222, "is_address1_send": true, "is_address2_send": false}]}','1','0','2019/02/01','2019/02/02')
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
  (1,'009999','alarm1','009999',1,'{"cds": [{"machine_record_cd": "4505"}, {"machine_record_cd": "4829"}, {"machine_record_cd": "4501"}, {"machine_record_cd": "4923"}, {"machine_record_cd": 7842}]}','1','0',null,null)
 ,(2,'009999','alarm2','009999',2,'{"cds": [{"machine_record_cd": "4505"}, {"machine_record_cd": "4501"}, {"machine_record_cd": "7842"}, {"machine_record_cd": "AC09"}]}','1','0',null,null)
 ,(3,'009997','nkk-alarm1','009999',3,'{"cds": [{"machine_record_cd": "4505"}, {"machine_record_cd": "4923"}, {"machine_record_cd": "7842"}, {"machine_record_cd": "A500"}]}','1','0',null,null)
 ,(4,'009997','nkk-alarm2','009999',4,'{"cds": [{"machine_record_cd": "4505"}, {"machine_record_cd": "4923"}, {"machine_record_cd": "A500"}, {"machine_record_cd": "F464"}]}','1','0',null,null)
 ,(5,'009998','o-alarm1','009998',5,'{"cds": [{"machine_record_cd": "4505"}, {"machine_record_cd": "FFFF"}]}','1','0',null,null)
 ,(6,'009997','o-nkk-alarm1','009998',6,'{"cds": [{"machine_record_cd": "4505"}, {"machine_record_cd": "FFFF"}]}','1','0',null,null)
;

