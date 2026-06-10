DELETE FROM mst_user_authentication
WHERE facility_cd = 'F_hC40';

INSERT INTO mst_user_authentication(
user_id,
facility_cd,
disp_user_id,
user_password,
failure_cnt
) VALUES (
94000,
'F_hC40',
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
94010,
'F_hC40',
'EGMAIN10',
'',
0
);
