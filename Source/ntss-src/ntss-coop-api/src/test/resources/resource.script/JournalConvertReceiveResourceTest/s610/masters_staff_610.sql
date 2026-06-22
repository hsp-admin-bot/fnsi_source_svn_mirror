DELETE FROM mst_user_authentication
WHERE user_id = 90610;

INSERT INTO mst_user_authentication(
user_id,
facility_cd,
disp_user_id,
user_password,
failure_cnt
) VALUES (
90610,
'F_h610',
'EGMAIN00',
'',
0
);
