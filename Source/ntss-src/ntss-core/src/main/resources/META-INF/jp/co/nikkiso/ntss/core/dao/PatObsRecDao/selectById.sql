SELECT
  /*%expand */*
FROM
  pat_obs_rec
WHERE
  pat_id = /*patId*/0
AND
  facility_cd = /*facilityCd*/''
