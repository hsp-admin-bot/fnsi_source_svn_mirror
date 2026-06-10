-- upd by chamaojia 2026-03-14 [12462] 患者情報共有->患者経過総合ビューア --start
/*%if patShareMode == 0 */
WITH pat_ids AS (
    SELECT /*patId*/0 AS pat_id
         , /*facilityCd*/null AS facility_cd
    UNION
    SELECT spi.from_pat_id
         , spi.from_facility_cd
    FROM shr_pat_info spi
    WHERE spi.to_pat_id = /*patId*/0
      AND spi.to_facility_cd = /*facilityCd*/null
      AND spi.is_from_consent = '1'
      AND spi.is_to_consent = '1'
      AND spi.is_pat_consent = '1'
      AND spi.is_disp = '1'
      AND spi.is_del = '0'
)
/*%end*/
SELECT
  A.pat_id,
  A.event_start_date,
  A.category_cd,
  A.sub_category_cd,
  A.letter_info,
  B.facility_name AS template_name
  ,A.report_date
FROM
  pat_event A
  /*%if patShareMode == 0 */
  JOIN pat_ids pid ON pid.pat_id = A.pat_id AND pid.facility_cd = A.facility_cd
  /*%end*/
  left outer join sys_facility B
	ON  A.letter_info ->> 'to_medical_institution_cd' = B.medical_institution_cd
WHERE
/*%if patShareMode != 0 */
  A.pat_id = /*patId*/null
AND
  A.facility_cd = /*facilityCd*/null
AND
/*%end*/
  replace(A.report_date, '-', '') >= /*dialysis_date_from*/'20100220'
AND
  replace(A.report_date, '-', '') <= /*dialysis_date_to*/'20300226'
AND
  A.is_del = '0'
AND
  a.use_type = 3
;
-- upd by chamaojia 2026-03-14 [12462] 患者情報共有->患者経過総合ビューア --end
