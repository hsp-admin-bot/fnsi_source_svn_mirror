UPDATE
  mst_water_survey_type AS T1
SET
  initial_string =
CASE
  WHEN (initial_string IS NULL) OR (initial_string = '') OR (initial_string = '[]') THEN
    (
      SELECT 
        '[{"text":"","checked":false,"isDefault":false}]'
      FROM mst_water_survey_type AS T2 WHERE T1.survey_type_cd = T2.survey_type_cd
    )
  ELSE
    CASE
      WHEN initial_string NOT LIKE '%"text":""%' THEN
        (
          SELECT 
            '[' || '{"text":"","checked":false,"isDefault":false},' || substring(initial_string, 2, length(initial_string) - 2) || ']'
          FROM mst_water_survey_type AS T2 WHERE T1.survey_type_cd = T2.survey_type_cd
        )
      ELSE
        (
          SELECT 
            initial_string
          FROM mst_water_survey_type AS T2 WHERE T1.survey_type_cd = T2.survey_type_cd
        )
      END
END;