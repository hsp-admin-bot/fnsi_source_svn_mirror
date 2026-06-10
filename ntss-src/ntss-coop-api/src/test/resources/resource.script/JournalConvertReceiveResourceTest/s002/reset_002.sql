SELECT SETVAL('pat_personal_main_pat_id_seq', 1000001);

DELETE FROM pat_personal_main
WHERE facility_cd = 'F_h002';