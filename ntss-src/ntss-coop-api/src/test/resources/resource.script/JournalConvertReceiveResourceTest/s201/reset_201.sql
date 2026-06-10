SELECT SETVAL('pat_personal_main_pat_id_seq', 1000200);

DELETE FROM pat_personal_main
WHERE facility_cd = 'F_h201';
