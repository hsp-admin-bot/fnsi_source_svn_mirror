DELETE FROM pat_personal_main
WHERE pat_id = 3000003;

SELECT SETVAL('pat_personal_main_pat_id_seq', 3000002);
