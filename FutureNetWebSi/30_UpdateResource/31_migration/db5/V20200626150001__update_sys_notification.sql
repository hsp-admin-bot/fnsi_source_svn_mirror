update
  sys_notification
set
  message = '新規患者：[LASTNAME] [FIRSTNAME] さんが登録されました。' || chr(10) || '【患者ID】[HOSPPATID]',
  available_keys = '[LASTNAME]：患者名(姓)、[FIRSTNAME]：患者名(名)、[PATID]：内部患者ID、[HOSPPATID]：院内患者ID、[FACILITYCD]：施設コード'
where
  notification_no = 1;