-- add #12548 特定の施設で遠隔監視画面を開くと時間がかかる＆DBの負荷上昇 zhao start
-- 特定の施設コードの警報通知の最大イベント発生日時を取得
-- ※型式コード、製造番号が設定されている場合には、装置の最大イベント発生日時を取得する.
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
    /*%end */
  /*%end */
 )
 /*%end */
 and
 data_type = 2
 and
 /*%if isNkkFacility */
 (service_support_type = '0' or service_support_type = '1' or service_support_type is null)
 /*%else*/
 (is_correction = '0' or is_correction is null)
 /*%end*/
 group by machine_type_cd, machine_serial
;
-- add #12548 特定の施設で遠隔監視画面を開くと時間がかかる＆DBの負荷上昇 zhao end
