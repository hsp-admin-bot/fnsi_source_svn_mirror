select
  pat_id
from
  pat_exam_main
where
  is_del = '0'

/*%if patIdList.size() > 0 */
  and pat_id in /* patIdList */(null)
/*%end */

  --- 施設コード絞り込み(速度改善)
  and facility_cd in /* facilityCdList */(null)

/*%if conditions.exam_week.size() > 0 */
  --- 曜日（登録時検査日時）
  and case when extract(DOW from reg_exam_date) = 0 then 7
  else extract(DOW FROM reg_exam_date) end in /* conditions.exam_week */(null)
/*%end*/

/*%if !conditions.reg_order_class.isEmpty() */
  --- タイミング（登録時検査区分）
  and reg_order_class = /* conditions.reg_order_class */null
/*%end*/

/*%if !conditions.exam_pattern_start_date.isEmpty() && !conditions.exam_pattern_end_date.isEmpty() */
  --- 指示期間（登録時検査日時）
  and to_char(reg_exam_date,'YYYY-MM-DD') >= /* conditions.exam_pattern_start_date */null
  and to_char(reg_exam_date,'YYYY-MM-DD') <= /* conditions.exam_pattern_end_date */null
  and order_exam_set_info != '[]'
/*%end*/
/*%if !conditions.exam_pattern_start_date.isEmpty() && conditions.exam_pattern_end_date.isEmpty() */
  --- 指示期間（開始日のみ）（登録時検査日時）
  and to_char(reg_exam_date,'YYYY-MM-DD') >= /* conditions.exam_pattern_start_date */null
  and order_exam_set_info != '[]'
/*%end*/
/*%if conditions.exam_pattern_start_date.isEmpty() && !conditions.exam_pattern_end_date.isEmpty() */
  --- 指示期間（終了日のみ）（登録時検査日時）
  and to_char(reg_exam_date,'YYYY-MM-DD') <= /* conditions.exam_pattern_end_date */null
  and order_exam_set_info != '[]'
/*%end*/

/*%if !conditions.exam_set_cd.isEmpty() */
  --- 検査セット（検査依頼セット情報）
  and (
  /*%for examsetcd : conditions.exam_set_cd */
    json_array_contains_array_value(COALESCE(order_exam_set_info, '[]'), 'set_cd', /* examsetcd */null)
    /*%if examsetcd_has_next */
    or
    /*%end */
  /*%end */
  )
/*%end */
