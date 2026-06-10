DELETE FROM pat_personal_main
WHERE facility_cd = 'F_hA13';

DELETE FROM pat_insurance
WHERE pat_id = 1001613;

SELECT SETVAL('pat_personal_main_pat_id_seq', 1001612);
