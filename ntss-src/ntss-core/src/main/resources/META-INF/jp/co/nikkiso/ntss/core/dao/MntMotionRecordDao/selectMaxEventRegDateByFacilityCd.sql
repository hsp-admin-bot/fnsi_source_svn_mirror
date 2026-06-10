-- 特定の施設コードの警報通知の最大イベント発生日時を取得
-- ※型式コード、製造番号が設定されている場合には、装置の最大イベント発生日時を取得する.
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
 /*%if isNkkFacility */
 (service_support_type = '0' or service_support_type = '1' or service_support_type is null)
 /*%else*/
 (is_correction = '0' or is_correction is null)
 /*%end*/
;
