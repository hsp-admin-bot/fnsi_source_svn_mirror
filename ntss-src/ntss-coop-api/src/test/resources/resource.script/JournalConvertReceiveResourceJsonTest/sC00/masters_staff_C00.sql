DELETE FROM mst_user_authentication
WHERE user_id = 91800;

INSERT INTO mst_user_authentication(
user_id,
facility_cd,
disp_user_id,
user_password,
failure_cnt
) VALUES (
91800,
'F_hC00',
'EGMAIN00',
'',
0
);
