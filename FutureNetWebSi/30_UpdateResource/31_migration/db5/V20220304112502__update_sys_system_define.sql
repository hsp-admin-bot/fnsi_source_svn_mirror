-- sys_system_define - ctl_no = 4 の value にデータを追加(既存値は維持)
UPDATE
  sys_system_define
SET
  value = value::jsonb || json_build_object(
    'urlCL', 'https://fnsi.nksfn.com/ntss-admin-web/#/?key='
  )::jsonb,
  up_date = now()
WHERE
  ctl_no = 4
AND
  value->>'urlCL' IS NULL
;
