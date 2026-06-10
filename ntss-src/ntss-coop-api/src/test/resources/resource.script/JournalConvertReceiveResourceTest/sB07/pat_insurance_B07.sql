DELETE FROM pat_insurance
WHERE facility_cd = 'F_hB07';

INSERT INTO pat_insurance(
pat_id,
facility_cd,
ctl_no,
insu_class,
insu_name,
start_date,
insu_info,
insu_pub_info,
insu_set_info,
insu_self_info,
is_disp,
is_del,
coop_code,
is_coop,
reg_date,
up_date
)
VALUES(
1001707,
'F_hB07',
135799,
0,
'保険レコードサンプル',
'20010101',
'[{}]',
'[{}]',
'[{}]',
'[{}]',
'1',
'0',
'何か',
'1',
'2020-01-01 12:00:00',
'2020-01-01 12:00:00'
);
