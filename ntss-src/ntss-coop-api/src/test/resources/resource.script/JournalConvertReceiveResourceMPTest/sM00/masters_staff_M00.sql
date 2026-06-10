DELETE FROM mst_user_authentication
WHERE user_id = 591800;

INSERT INTO mst_user_authentication(
user_id,
facility_cd,
disp_user_id,
user_password,
failure_cnt
) VALUES (
591800,
'F_hM00',
'EGMAIN00',
'',
0
);
