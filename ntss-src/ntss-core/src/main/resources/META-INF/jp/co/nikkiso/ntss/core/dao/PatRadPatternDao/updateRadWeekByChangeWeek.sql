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
  ) AS t(facility_cd, pat_id, old_rad_week, new_rad_week, rad_pattern_cd, rad_pattern, reg_rad_date)
)
UPDATE pat_rad_pattern p
SET
  rad_week = u.new_rad_week,
  reg_rad_date = u.reg_rad_date::timestamp,
  ind_user_id = /*indUserId*/0,
  up_staff = /*updUserId*/0,
  up_date = CURRENT_TIMESTAMP
FROM updates u
WHERE p.facility_cd = u.facility_cd
  AND p.pat_id = u.pat_id
  AND p.rad_week = u.old_rad_week
  AND p.rad_pattern_cd = u.rad_pattern_cd
  AND p.rad_pattern = u.rad_pattern
  AND p.is_del = '0';
