SELECT DISTINCT
  pat_id
FROM
  pat_rad_main
WHERE
  is_del = '0'
  --- 施設コード絞り込み(速度改善)
  AND facility_cd in /* facilityCdList */(null)
/*%if patIdList.size() > 0 */
  AND pat_id IN /* patIdList */(null)
/*%end*/

/*%if conditions.radPattern_exam_week.size() >0 */
  --- 曜日（登録時放射線検査日時）
  AND CASE WHEN extract(DOW FROM reg_rad_date) = 0 THEN 7
  ELSE extract(DOW FROM reg_rad_date) END IN /* conditions.radPattern_exam_week*/(null)
/*%end*/

/*%if !conditions.radPattern_exam_pattern_start_date.isEmpty() */
	--- 指示期間（開始日）（登録時放射線検査日時）
  AND to_char(reg_rad_date,'yyyy-MM-dd') >= /* conditions.radPattern_exam_pattern_start_date*/null
/*%end*/
/*%if !conditions.radPattern_exam_pattern_end_date.isEmpty() */
	--- 指示期間（終了日）（登録時放射線検査日時）
  AND to_char(reg_rad_date,'yyyy-MM-dd') <= /* conditions.radPattern_exam_pattern_end_date*/null
/*%end*/

