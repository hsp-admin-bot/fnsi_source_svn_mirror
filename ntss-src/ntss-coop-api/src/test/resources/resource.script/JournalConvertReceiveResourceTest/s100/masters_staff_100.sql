DELETE FROM mst_user_authentication
WHERE user_id = 90100;

INSERT INTO mst_user_authentication(
user_id,
facility_cd,
disp_user_id,
user_password,
failure_cnt
) VALUES (
90100,
'F_h100',
'EGMAIN00',
'',
0
);
