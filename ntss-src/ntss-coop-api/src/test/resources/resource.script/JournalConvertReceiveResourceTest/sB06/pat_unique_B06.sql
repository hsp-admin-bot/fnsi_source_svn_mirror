DELETE FROM pat_unique
WHERE pat_id = 3000006;

INSERT INTO pat_unique (
pat_id,
medical_hst_info,
physical_info,
is_del,
up_date,
reg_date
)
VALUES (
3000006,
'[{}]',
'[{}]',
'0',
'2020-03-11 13:49:00',
'2020-03-11 13:49:00'
);
