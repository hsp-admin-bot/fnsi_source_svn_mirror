DELETE FROM pat_coop_detail
WHERE facility_cd = 'F_hB05';

INSERT INTO pat_coop_detail (
facility_cd,
pat_id,
save_1,
save_2,
save_4,
save_10,
is_disp,
is_del,
reg_date,
up_date
)
VALUES (
'F_hB05',
3000005,
'[{}]',
'[{"abcde":"ABCDE"}]',
'[{}]',
'[{}]',
'1',
'0',
'2020-03-01 12:00:00',
'2020-03-01 12:00:00'
);
