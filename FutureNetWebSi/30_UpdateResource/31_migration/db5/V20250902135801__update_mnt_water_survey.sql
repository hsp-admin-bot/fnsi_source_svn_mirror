-- #11088 結果文字列 text: "0" を text: "" に置換
UPDATE mnt_water_survey mws
SET survey_data = (
  SELECT jsonb_agg(
           CASE
             WHEN elem->>'text' = '0'
               THEN jsonb_set(elem, '{text}', '""'::jsonb)
             ELSE elem
           END
         )
  FROM jsonb_array_elements(mws.survey_data) AS elem
)
WHERE EXISTS (
  SELECT 1
  FROM jsonb_array_elements(mws.survey_data) AS elem
  WHERE elem->>'text' = '0'
);
