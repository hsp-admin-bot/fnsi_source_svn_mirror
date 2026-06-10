select
  motion.motion_record_no,
  motion.event_reg_date,
  motion.data_type,
  motion.test_type,
  motion.contents,
  motion.machine_type_cd,
  motion.machine_serial

from
  mnt_motion_record motion

where
  motion.facility_cd = /*facilityCd*/'1'
  /*%if "" != fromDate || "" != toDate */
  and
  -- mod 11892 【因島】データリスト「装置情報(自己診断)」テンプレート出力結果のフォーマットおよびパフォーマンス不正 zkm start
--   to_char(motion.event_reg_date, 'yyyyMMdd') between /*fromDate*/'19000101' and /*toDate*/'99991230'
  motion.event_reg_date between to_timestamp(/*fromDate*/'19000101', 'YYYYMMDD')
      and to_timestamp(/*toDate*/'99991230', 'YYYYMMDD') + interval '1 day' - interval '1 millisecond'
  -- mod 11892 【因島】データリスト「装置情報(自己診断)」テンプレート出力結果のフォーマットおよびパフォーマンス不正 zkm end
  /*%end */
  and data_type = 4

order by
  motion.event_reg_date asc
;
