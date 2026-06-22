DELETE FROM pat_main
WHERE facility_cd = 'F_hB02';

DELETE FROM pat_exam_main
WHERE facility_cd = 'F_hB02';

DELETE FROM pat_obs_rec
WHERE facility_cd = 'F_hB02';

DELETE FROM pat_unique
WHERE pat_id = 1001702;

DELETE FROM pat_coop_detail
WHERE facility_cd = 'F_hB02';
