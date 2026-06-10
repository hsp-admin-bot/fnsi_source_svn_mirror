DELETE FROM mst_user_authentication
WHERE user_id = 90300;

INSERT INTO mst_user_authentication(
user_id,
facility_cd,
disp_user_id,
user_password,
failure_cnt
) VALUES (
90300,
'F_h300',
'EGMAIN00',
'',
0
);
