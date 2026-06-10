DELETE FROM pat_personal_main
WHERE facility_cd = 'F_hA12';

DELETE FROM pat_personal_main
WHERE pat_id = 11012;

INSERT INTO pat_personal_main(
pat_id,
hosp_pat_id,
facility_cd,
pat_last_name,
pat_first_name,
nationality,
pat_sex
)
VALUES (
11012,
'0009770089',
'F_hA12',
personal_info_encrypt('かかか'),
personal_info_encrypt('ききき'),
'UK',
1
);
