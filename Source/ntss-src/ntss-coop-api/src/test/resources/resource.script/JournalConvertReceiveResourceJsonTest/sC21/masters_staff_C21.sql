DELETE FROM mst_user_authentication
WHERE user_id = 93801;

INSERT INTO mst_user_authentication(
user_id,
facility_cd,
disp_user_id,
user_password,
failure_cnt
) VALUES (
93801,
'F_hC21',
'EGMAIN00',
'',
0
);
