-- upd by chamaojia 2026-03-12 [12462] 患者情報共有->患者経過総合ビューア --start
/*%if patShareMode == 0 */
WITH pat_ids AS (
    SELECT /*patId*/0 AS pat_id
    UNION
    SELECT spi.from_pat_id
    FROM shr_pat_info spi
    WHERE spi.to_pat_id = /*patId*/0
      AND spi.is_from_consent = '1'
      AND spi.is_to_consent = '1'
      AND spi.is_pat_consent = '1'
      AND spi.is_disp = '1'
      AND spi.is_del = '0'
)
/*%end*/
SELECT
A.rad_result_cd,
A.pat_id,
A.facility_cd,
A.reg_rad_date
FROM  pat_rad_main AS A
/*%if patShareMode == 0 */
JOIN pat_ids pid ON pid.pat_id = A.pat_id
/*%end*/
WHERE
/*%if patShareMode != 0 */
  A.pat_id = /* patId */1
AND
/*%end*/
  to_char(A.reg_rad_date, 'YYYYMMDD') < /* startDate */'20180220'
AND
  A.is_del = '0'
ORDER BY A.reg_rad_date DESC
;
-- upd by chamaojia 2026-03-12 [12462] 患者情報共有->患者経過総合ビューア --end
