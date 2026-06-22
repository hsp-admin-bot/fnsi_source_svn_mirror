DELETE FROM mst_user_authentication
WHERE user_id = 90602;

INSERT INTO mst_user_authentication(
user_id,
facility_cd,
disp_user_id,
user_password,
failure_cnt
) VALUES (
90602,
'F_h602',
'EGMAIN00',
'',
0
);
