CREATE UNIQUE INDEX unq_mnt_water_survey_02
ON mnt_water_survey(facility_cd, inspection_date)
WHERE is_del = '0';