DELETE FROM mst_user_authentication
WHERE facility_cd = 'F_hC51';

INSERT INTO mst_user_authentication(
user_id,
facility_cd,
disp_user_id,
user_password,
failure_cnt
) VALUES (
95001,
'F_hC51',
'EGMAIN00',
'',
0
);
