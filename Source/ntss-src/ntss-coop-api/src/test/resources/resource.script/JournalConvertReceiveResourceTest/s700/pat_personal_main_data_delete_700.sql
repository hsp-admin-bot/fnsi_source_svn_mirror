DELETE FROM ntss.pat_personal_main WHERE facility_cd = 'F_h700';

SELECT SETVAL('pat_personal_main_pat_id_seq', 1000699);