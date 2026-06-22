DELETE FROM pat_personal_main
WHERE facility_cd = 'F_h400';

DELETE FROM pat_insurance
WHERE pat_id = 1000400;

SELECT SETVAL('pat_personal_main_pat_id_seq', 1000399);
