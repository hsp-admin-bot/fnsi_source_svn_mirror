INSERT INTO pat_personal_main(
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
127111111112,
'S_hos4',
personal_info_encrypt(/*pat.pat_last_name*/'TEX'),
personal_info_encrypt(/*pat.pat_last_name*/'SOL'),
'19700101',
0,
'JPN',
'2020-03-01 12:00:00',
'2020-03-01 12:00:00'
);
