-- upd by chamaojia 2026-03-12 [12462] 患者情報共有->患者経過総合ビューア --start
/*%if patShareMode == 0 */
WITH pat_ids AS (
    SELECT /*pat_id*/0 AS pat_id
    UNION
    SELECT spi.from_pat_id
    FROM shr_pat_info spi
    WHERE spi.to_pat_id = /*pat_id*/0
      AND spi.is_from_consent = '1'
      AND spi.is_to_consent = '1'
      AND spi.is_pat_consent = '1'
      AND spi.is_disp = '1'
      AND spi.is_del = '0'
)
/*%end*/
SELECT
  A.exam_main_cd,
  A.pat_id,
  A.facility_cd,
  A.reg_exam_date
FROM pat_exam_main A
/*%if patShareMode == 0 */
JOIN pat_ids pid ON pid.pat_id = A.pat_id
/*%end*/
WHERE
/*%if patShareMode != 0 */
  pat_id = /*pat_id*/1
AND
/*%end*/
  TO_CHAR(A.reg_exam_date, 'YYYYMMDD') < /*dialysis_date_from*/'20180220'
AND
  is_del = '0'
-- add #9772 前回検査予定日の日付が不正 蔡 start
AND
  is_order = '1'
-- add #9772 前回検査予定日の日付が不正 蔡 end
ORDER BY
  reg_exam_date DESC
;
-- upd by chamaojia 2026-03-12 [12462] 患者情報共有->患者経過総合ビューア --end
