DELETE FROM pat_personal_main
WHERE pat_id=11111113;

INSERT INTO pat_personal_main(
pat_id,
hosp_pat_id,
facility_cd,
pat_last_name,
pat_first_name,
pat_birthday,
pat_sex,
nationality,
reg_date,
up_date
)
VALUES(
11111113,
1111111113,
'F_h003',
personal_info_encrypt(/*pat.pat_last_name*/'TEX'),
personal_info_encrypt(/*pat.pat_last_name*/'SOL'),
'19700101',
0,
'JPN',
'2020-03-01 12:00:00',
'2020-03-01 12:00:00'
);
