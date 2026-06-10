DELETE FROM pat_main
WHERE facility_cd = 'F_h302';

DELETE FROM pat_exam_main
WHERE facility_cd = 'F_h302';

DELETE FROM pat_obs_rec
WHERE facility_cd = 'F_h302';

DELETE FROM pat_unique
WHERE pat_id = 1000302;

DELETE FROM pat_coop_detail
WHERE facility_cd = 'F_h302';
