SELECT COUNT(survey_point_cd) AS ind_count
FROM
    mst_water_survey_point
WHERE is_del = '0' AND facility_cd = /*facilityCd*/NULL AND is_disp = '1'