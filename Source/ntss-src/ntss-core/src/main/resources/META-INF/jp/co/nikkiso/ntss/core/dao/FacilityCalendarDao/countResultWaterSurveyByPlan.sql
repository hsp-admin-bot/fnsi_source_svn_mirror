SELECT date(inspection_date) AS date,
       count(item_survey_data) AS rst_count
FROM mnt_water_survey,
     jsonb_array_elements(survey_data) item_survey_data
WHERE date(inspection_date) >= /*startDate*/NULL
  AND date(inspection_date) <= /*endDate*/NULL
  AND is_del = '0'
  AND is_disp = '1'
  AND facility_cd = /*facilityCd*/NULL
  -- mod 検査中+実績 数修正 chen start
  --AND (item_survey_data ->> 'plan' = /*plan*/NULL OR
  AND ((item_survey_data ->> 'memo' <> NULL AND item_survey_data ->> 'memo' <> '') OR
       item_survey_data ->> 'text' <> '0' OR
       item_survey_data ->> 'time' <> '' OR
       (item_survey_data ->> 'value' <> NULL AND item_survey_data ->> 'value' <> '') OR
       TO_NUMBER(item_survey_data ->> 'picker', '99999999') <> 0 OR
       TO_NUMBER(item_survey_data ->> 'inspector', '99999999') <> 0)
  -- mod 検査中+実績 数修正 chen end
GROUP BY date(inspection_date)
