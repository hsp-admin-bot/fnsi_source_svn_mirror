DELETE FROM pat_main
WHERE facility_cd = 'F_h700';

DELETE FROM pat_exam_main
WHERE facility_cd = 'F_h700';

DELETE FROM pat_obs_rec
WHERE facility_cd = 'F_h700';

DELETE FROM pat_unique
WHERE pat_id = 1000700;

DELETE FROM pat_coop_detail
WHERE facility_cd = 'F_h700';