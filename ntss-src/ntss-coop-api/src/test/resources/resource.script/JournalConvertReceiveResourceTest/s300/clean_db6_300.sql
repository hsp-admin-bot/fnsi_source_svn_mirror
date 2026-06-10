DELETE FROM pat_personal_main
WHERE pat_id = 1000300;

DELETE FROM pat_insurance
WHERE pat_id = 1000300;

SELECT SETVAL('pat_personal_main_pat_id_seq', 1000299);
