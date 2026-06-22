DELETE FROM mst_user_authentication
WHERE user_id = 92801;

INSERT INTO mst_user_authentication(
user_id,
facility_cd,
disp_user_id,
user_password,
failure_cnt
) VALUES (
92801,
'F_hC11',
'EGMAIN00',
'',
0
);
