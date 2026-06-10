-- mod #9738 患者経過総合ビューアで検査依頼、一般撮影検査依頼、招待状、処方、患者イベントのデータが正常に表示されない zy start
-- SELECT count(op2.ord_prescription_no) || '/' || count(op1.ord_prescription_no) AS syohou,
-- op1.issue_date
-- from ord_main od,
--      ord_prescription op1
-- left join
-- 		 ord_prescription op2
-- 		 on op1.ord_prescription_no = op2.ord_prescription_no
-- 		 and op2.issue_state = '1'
-- where od.treat_date = op1.issue_date
--   and od.pat_id = op1.pat_id
--   and od.facility_cd = op1.facility_cd
--   and od.facility_cd = /*facilityCd*/'996996'
--   and od.is_del = '0'
--   and op1.is_del = '0'
--   and od.pat_id = /*patId*/null
--   group by op1.issue_date
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
SELECT count(op2.ord_prescription_no) || '/' || count(op1.ord_prescription_no) AS syohou,
op1.issue_date
from ord_prescription op1
/*%if patShareMode == 0 */
JOIN pat_ids pid ON pid.pat_id = op1.pat_id AND pid.facility_cd = op1.facility_cd
/*%end*/
left join
		 ord_prescription op2
		 on op1.ord_prescription_no = op2.ord_prescription_no
		 and op2.issue_state = '1'
where op1.is_del = '0'
/*%if patShareMode != 0 */
  and op1.facility_cd = /*facilityCd*/'996996'
  and op1.pat_id = /*patId*/null
/*%end*/
  and op1.issue_date >= /*startDate*/'20100220'
  and op1.issue_date <= /*endDate*/'20100220'
  group by op1.issue_date
-- upd by chamaojia 2026-03-14 [12462] 患者情報共有->患者経過総合ビューア --end
-- mod #9738 患者経過総合ビューアで検査依頼、一般撮影検査依頼、招待状、処方、患者イベントのデータが正常に表示されない zy end
