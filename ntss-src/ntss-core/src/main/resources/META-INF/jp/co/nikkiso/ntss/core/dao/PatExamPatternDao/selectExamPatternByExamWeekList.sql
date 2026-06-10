SELECT *
FROM pat_exam_pattern
WHERE facility_cd = /* facilityCd */NULL
  AND pat_id = /* patId */NULL
  AND exam_week IN /* examWeekList */(NULL)
  AND is_del = '0';
