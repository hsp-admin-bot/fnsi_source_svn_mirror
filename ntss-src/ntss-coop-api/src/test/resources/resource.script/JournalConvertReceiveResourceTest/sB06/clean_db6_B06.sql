DELETE FROM pat_personal_main
WHERE pat_id = 1001706;

DELETE FROM pat_insurance
WHERE pat_id = 1001706;

SELECT SETVAL('pat_personal_main_pat_id_seq', 1001705);
