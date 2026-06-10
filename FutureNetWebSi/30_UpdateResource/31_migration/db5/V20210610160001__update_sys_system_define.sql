-- SES スイッチを追加
UPDATE
  sys_system_define
SET
  value = value::jsonb || json_build_object(
    'ses', 'on',
    'path', '/efs',
    'status', 'off'
  )::jsonb,
  description = 'S3を使わずにローカル環境でファイル保存する。ローカルのファイル格納のパスを指定する。OnPremises有効を設定する。ses=onでSE依頼を有効にする。',
  up_date = current_timestamp
WHERE
  ctl_no = 14
;
-- 施設解約設定(Path変更)
UPDATE
  sys_system_define
SET
  value = value::jsonb || json_build_object(
    'backup_path_template_cancel', '/opt/delete-facility/%FACILITY_CD%/%DATE%/%DB_NAME%_%TABLE_NAME%.csv'
  )::jsonb,
  up_date = current_timestamp
WHERE
  ctl_no = 29
;
