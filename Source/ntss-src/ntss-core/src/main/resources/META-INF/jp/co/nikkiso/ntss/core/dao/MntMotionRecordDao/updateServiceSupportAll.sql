-- 警報通知の未受付と１次対応済をサービス対応済に更新
update
  mnt_motion_record
set
  service_support_type = '2',
  service_support_user_id = /*mntMotionRecord.serviceSupportUserId*/1,
  service_support_up_date = current_timestamp,
  up_date = /*mntMotionRecord.upDate*/null
where
  facility_cd = /*mntMotionRecord.facilityCd*/'1'
  and
  machine_type_cd = /*mntMotionRecord.machineTypeCd*/'1'
  and
  machine_serial = /*mntMotionRecord.machineSerial*/'1'
  and
  service_support_type in ('0','1')
  and
--   mod 11042 nkknkk施設の遠隔監視の警報対処不正動作 関 start
--   data_type in ('2')
  data_type = /*mntMotionRecord.dataType*/1
--   mod 11042 nkknkk施設の遠隔監視の警報対処不正動作 関 end
;
