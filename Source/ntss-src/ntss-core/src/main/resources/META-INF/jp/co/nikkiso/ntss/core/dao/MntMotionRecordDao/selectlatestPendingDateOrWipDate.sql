-- 特定の施設コードの警報通知の最新の未対処イベント発生日時(isCorrection=0)/最新の対処中イベント発生日時(isCorrection=2)を取得
select
 max(event_reg_date)
from
 mnt_motion_record
where
 facility_cd = /*facilityCd*/'1'
 /*%if machineTypeCd != null */
 and
 machine_type_cd = /*machineTypeCd*/'1'
 /*%end*/
 /*%if machineSerial != null */
 and
 machine_serial = trim(/*machineSerial*/'1')
 /*%end*/
 and
 data_type = 2
 and
 is_correction = /*isCorrection*/'0'
;
