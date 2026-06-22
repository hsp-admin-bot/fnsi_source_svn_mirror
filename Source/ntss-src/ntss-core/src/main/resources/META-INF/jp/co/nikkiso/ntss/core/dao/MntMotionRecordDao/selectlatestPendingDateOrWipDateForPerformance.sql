--add #12548 特定の施設で遠隔監視画面を開くと時間がかかる＆DBの負荷上昇 zhao start
-- 特定の施設コードの警報通知の最新の未対処イベント発生日時(isCorrection=0)/最新の対処中イベント発生日時(isCorrection=2)を取得
select
 machine_type_cd, machine_serial,
 max(event_reg_date) AS event_reg_date
from
 mnt_motion_record
where
 facility_cd = /*facilityCd*/'1'
 /*%if !mntMotionRecordList.isEmpty() */
 and (machine_type_cd,machine_serial) IN (
  /*%for condition:mntMotionRecordList */
    (/* condition.machineTypeCd */'1', /* trim(condition.machineSerial) */'1')
    /*%if condition_has_next */
      ,
    /*%end*/
  /*%end*/
 )
 /*%end*/
 and
 data_type = 2
 and
 is_correction = /*isCorrection*/'0'
 group by machine_type_cd, machine_serial
;
-- add #12548 特定の施設で遠隔監視画面を開くと時間がかかる＆DBの負荷上昇 zhao end
