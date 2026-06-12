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
  A.exam_main_cd,
  A.pat_id,
  A.facility_cd,
  A.ord_no,
  A.fn_pat_id,
  A.reg_exam_date,
  A.reg_order_class,
  A.exam_status,
  A.order_comment,
  A.order_exam_set_info,
  A.exam_order_info,
  A.order_label_info,
  A.data_gen_class,
  A.result_exam_date,
  A.result_comment,
  A.exam_result_info,
  A.cop_order_no1,
  A.cop_order_no2,
  A.is_lock,
  A.ind_user_id,
  A.is_del,
  A.reg_date,
  A.reg_staff,
  A.up_date,
  A.up_staff
from pat_exam_main A
/*%if patShareMode == 0 */
JOIN pat_ids pid ON pid.pat_id = A.pat_id
/*%end*/
where
/*%if patShareMode != 0 */
  pat_id = /*pat_id*/1
and
/*%end*/
  to_char(A.reg_exam_date, 'YYYYMMDD') >= /*dialysis_date_from*/'20180220'
and
  to_char(A.reg_exam_date, 'YYYYMMDD') <= /*dialysis_date_to*/'20180226'
and
  is_del = '0'
order by
  reg_exam_date asc
;
-- upd by chamaojia 2026-03-12 [12462] 患者情報共有->患者経過総合ビューア --end
