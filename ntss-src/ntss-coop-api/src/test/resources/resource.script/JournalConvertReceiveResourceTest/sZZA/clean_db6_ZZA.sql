DELETE FROM pat_personal_main
WHERE facility_cd = 'F_hZZA';

DELETE FROM pat_insurance
WHERE pat_id = 9900000;

SELECT SETVAL('pat_personal_main_pat_id_seq', 9899999);
