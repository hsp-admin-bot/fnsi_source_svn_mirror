DELETE FROM mst_user_authentication
WHERE user_id = 591810;

INSERT INTO mst_user_authentication(
user_id,
facility_cd,
disp_user_id,
user_password,
failure_cnt
) VALUES (
591810,
'F_hM01',
'EGMAIN00',
'',
0
);
