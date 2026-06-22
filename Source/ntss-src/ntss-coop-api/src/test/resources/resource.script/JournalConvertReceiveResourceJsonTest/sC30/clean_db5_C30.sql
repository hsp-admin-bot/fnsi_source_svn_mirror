DELETE FROM pat_main
WHERE facility_cd = 'F_hC30';

DELETE FROM pat_exam_main
WHERE facility_cd = 'F_hC30';

DELETE FROM pat_obs_rec
WHERE facility_cd = 'F_hC30';

DELETE FROM pat_unique
WHERE pat_id = 1004800;

DELETE FROM pat_coop_detail
WHERE facility_cd = 'F_hC30';
