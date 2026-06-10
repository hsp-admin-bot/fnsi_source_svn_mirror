UPDATE
  mst_machine_record
SET
  machine_record_message = REPLACE(machine_record_message, '（ＵＦＲＣ）', '（配管自己診断）') 
WHERE
  machine_record_message LIKE '%（ＵＦＲＣ）%'
;

UPDATE
  mst_machine_record
SET
  machine_record_message = REPLACE(machine_record_message, 'ＵＦＲＣ', '配管') 
WHERE
  machine_record_message LIKE '%ＵＦＲＣ%'
;

UPDATE
  mnt_motion_record
SET
  machine_record_message = REPLACE(machine_record_message, '（UFRC）', '') 
WHERE
  machine_record_message = '配管（UFRC）自己診断'
;