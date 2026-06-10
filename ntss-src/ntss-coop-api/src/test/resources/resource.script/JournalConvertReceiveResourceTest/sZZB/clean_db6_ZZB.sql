DELETE FROM pat_personal_main
WHERE facility_cd = 'F_hZZB';

DELETE FROM pat_insurance
WHERE pat_id = 9900001;

SELECT SETVAL('pat_personal_main_pat_id_seq', 9900000);
