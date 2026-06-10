WITH updates AS (
  SELECT *
  FROM (VALUES
     /*%for change : changeList */
    (
      /*facilityCd*/null,
      /*patId*/0,
      /*change.oldTreatWeek*/0,
      /*change.newTreatWeek*/0,
      /*change.patternCd*/0,
      /*change.patternCategory*/0,
      /*change.regScheduleDate*/0
    )
    /*%if(change_has_next)*/,/*%end*/
    /*%end*/
  ) AS t(facility_cd, pat_id, old_exam_week, new_exam_week, exam_pattern_cd, exam_pattern, reg_exam_date)
)
UPDATE pat_exam_pattern p
SET
  exam_week = u.new_exam_week,
  reg_exam_date = u.reg_exam_date::timestamp,
  ind_user_id = /*indUserId*/0,
  up_staff = /*updUserId*/0,
  up_date = CURRENT_TIMESTAMP
FROM updates u
WHERE p.facility_cd = u.facility_cd
  AND p.pat_id = u.pat_id
  AND p.exam_week = u.old_exam_week
  AND p.exam_pattern_cd = u.exam_pattern_cd
  AND p.exam_pattern = u.exam_pattern
  AND p.is_del = '0';
