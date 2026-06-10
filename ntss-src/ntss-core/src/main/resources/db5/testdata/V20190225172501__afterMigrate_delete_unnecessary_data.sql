-- mnt_machine_state の不要なテストデータ削除
DELETE
FROM
  mnt_machine_state
WHERE
  machine_serial = '00999901'
AND
  machine_type_cd = '011'
AND
  facility_cd = '009999'
;
