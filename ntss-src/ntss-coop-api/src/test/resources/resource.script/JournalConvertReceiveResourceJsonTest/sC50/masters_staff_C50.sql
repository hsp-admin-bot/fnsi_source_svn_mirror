DELETE FROM mst_user_authentication
WHERE facility_cd = 'F_hC50';

INSERT INTO mst_user_authentication(
user_id,
facility_cd,
disp_user_id,
user_password,
failure_cnt
) VALUES (
95000,
'F_hC50',
'EGMAIN00',
'',
0
);
