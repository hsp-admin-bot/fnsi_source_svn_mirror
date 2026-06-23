UPDATE mni_monitor
SET machine_serial = TRIM ( machine_serial )
WHERE
    machine_serial :: TEXT LIKE' %'
    OR machine_serial :: TEXT LIKE'% '
;
UPDATE mnt_find_machine
SET machine_serial = TRIM ( machine_serial )
WHERE
    machine_serial :: TEXT LIKE' %'
    OR machine_serial :: TEXT LIKE'% '
;
UPDATE mnt_machine_state
SET machine_serial = TRIM ( machine_serial )
WHERE
    machine_serial :: TEXT LIKE' %'
    OR machine_serial :: TEXT LIKE'% '
;
UPDATE mnt_motion_record
SET machine_serial = TRIM ( machine_serial )
WHERE
    machine_serial :: TEXT LIKE' %'
    OR machine_serial :: TEXT LIKE'% '
;
UPDATE mst_machine
SET machine_serial = TRIM ( machine_serial )
WHERE
    machine_serial :: TEXT LIKE' %'
    OR machine_serial :: TEXT LIKE'% '
;
UPDATE tmp_comm_failure_recovery
SET machine_serial = TRIM ( machine_serial )
WHERE
    machine_serial :: TEXT LIKE' %'
    OR machine_serial :: TEXT LIKE'% '
;
