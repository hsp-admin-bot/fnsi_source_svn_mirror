DELETE FROM pat_personal_main
WHERE facility_cd = 'F_h500';

DELETE FROM pat_insurance
WHERE pat_id = 1000500;

SELECT SETVAL('pat_personal_main_pat_id_seq', 1000499);
