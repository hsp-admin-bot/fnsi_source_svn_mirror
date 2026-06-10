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
select
  A.rad_result_cd,
  A.pat_id,
  A.facility_cd,
  A.fn_pat_id,
  A.reg_rad_date,
  A.reg_order_class,
  A.rad_status,
  A.order_rad_set_info,
  A.cop_order_no1,
  A.cop_order_no2,
  A.is_lock,
  A.ind_user_id,
  A.is_del,
  A.reg_date,
  A.reg_staff,
  A.up_date,
  A.up_staff
from pat_rad_main A
/*%if patShareMode == 0 */
JOIN pat_ids pid ON pid.pat_id = A.pat_id
/*%end*/
where
/*%if patShareMode != 0 */
  pat_id = /*pat_id*/1
and
/*%end*/
  to_char(A.reg_rad_date, 'YYYYMMDD') >= /*dialysis_date_from*/'20180220'
and 
  to_char(A.reg_rad_date, 'YYYYMMDD') <= /*dialysis_date_to*/'20180226'
and
  is_del = '0'
;
-- upd by chamaojia 2026-03-12 [12462] 患者情報共有->患者経過総合ビューア --end
