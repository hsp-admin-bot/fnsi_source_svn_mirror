DELETE FROM mst_user_authentication
WHERE facility_cd = 'F_hC41';

INSERT INTO mst_user_authentication(
user_id,
facility_cd,
disp_user_id,
user_password,
failure_cnt
) VALUES (
94001,
'F_hC41',
'EGMAIN00',
'',
0
);

INSERT INTO mst_user_authentication(
user_id,
facility_cd,
disp_user_id,
user_password,
failure_cnt
) VALUES (
94011,
'F_hC41',
'EGMAIN10',
'',
0
);
