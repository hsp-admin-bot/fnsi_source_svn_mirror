DELETE FROM pat_personal_main
WHERE pat_id = 700000022;

DELETE FROM pat_insurance
WHERE pat_id = 700000022;

SELECT SETVAL('pat_personal_main_pat_id_seq', 700000021);