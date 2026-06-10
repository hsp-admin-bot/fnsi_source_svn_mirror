select
  pat_id
from
  pat_exam_pattern
where
  is_del = '0'

/*%if patIdList.size() > 0 */
  and pat_id in /* patIdList */(null)
/*%end */

--- 施設コード絞り込み(速度改善)
  and facility_cd in /* facilityCdList */(null)
--- 検査依頼パターン
/*%if conditions.exam_pattern !=null */
  and exam_pattern = /* conditions.exam_pattern */null
/*%end*/
--- 指定曜日
/*%if conditions.exam_week.size() > 0 */
  and exam_week in /* conditions.exam_week */(null)
/*%end*/
--- 登録時検査区分
/*%if !conditions.reg_order_class.isEmpty() */
  and reg_order_class = /* conditions.reg_order_class */null
/*%end*/
--- 指定期間開始日
/*%if !conditions.exam_pattern_start_date.isEmpty() */
  and exam_from >= /* conditions.exam_pattern_start_date */null
/*%end*/
--- 指定期間終了日
/*%if !conditions.exam_pattern_end_date.isEmpty() */
  and exam_to <= /* conditions.exam_pattern_end_date */null
/*%end*/
