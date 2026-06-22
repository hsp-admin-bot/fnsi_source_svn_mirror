DELETE FROM pat_personal_main
WHERE pat_id = 2;

DELETE FROM pat_insurance
WHERE pat_id = 2;

SELECT SETVAL('pat_personal_main_pat_id_seq', 1);