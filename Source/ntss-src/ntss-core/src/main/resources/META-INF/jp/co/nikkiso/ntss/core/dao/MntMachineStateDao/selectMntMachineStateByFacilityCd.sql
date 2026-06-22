select
    /*%expand "state" */*
FROM
  mnt_machine_state state
    LEFT OUTER JOIN mst_machine machine
        ON state.facility_cd = machine.facility_cd
        AND state.machine_type_cd = machine.machine_type_cd
        AND state.machine_serial = machine.machine_serial
WHERE
    state.facility_cd = /*facilityCd*/'1'
;
