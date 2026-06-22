DELETE FROM mst_user_authentication
WHERE user_id BETWEEN 92900 AND 92999;

INSERT INTO mst_user_authentication(
user_id,
facility_cd,
disp_user_id,
user_password,
failure_cnt
) VALUES (
91910,
'F_hD01',
'12345678',
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
91911,
'F_hD01',
'12341234',
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
91912,
'F_hD01',
'53106812',
'',
0
);
