DELETE FROM mst_user_authentication
WHERE user_id = 99100;

INSERT INTO mst_user_authentication(
user_id,
facility_cd,
disp_user_id,
user_password,
failure_cnt
) VALUES (
99100,
'F_hZZB',
'EGMAIN00',
'',
0
);
