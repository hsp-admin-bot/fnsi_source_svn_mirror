select
    B.machine_record_cd,
    (CASE
         WHEN A.machine_record_message IS NULL THEN B.machine_record_message
         ELSE A.machine_record_message
        END) As machine_record_message,
    B.reg_date,
    B.up_date,
    B.is_default,
    B.up_date,
    B.log_class,
    B.target_model,
    B.disp_flg
from
    mst_machine_record_control A
RIGHT OUTER JOIN mst_machine_record B
ON A.machine_record_cd = B.machine_record_cd
AND
A.facility_cd = /* facilityCd */null
;
