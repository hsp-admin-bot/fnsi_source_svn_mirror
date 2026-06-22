---add No338患者詳細検索の追加項目 一般撮影検査予定検索 劉全航 start
SELECT DISTINCT
    pat_id
FROM
    (
        SELECT
            pat_id,
            rad_pattern,
            to_char( reg_rad_date, 'HH24:MI' ) AS str_rad_date,
            rad_week,
            rad_from,
            rad_to,
            is_del,
            facility_cd
        FROM
            pat_rad_pattern
        WHERE
            is_del = '0'
    ) AS foo

WHERE
  --- 施設コード絞り込み(速度改善)
   foo.facility_cd in /* facilityCdList */(null)
/*%if patIdList.size() > 0 */
  AND  foo.pat_id IN /* patIdList */(null)
/*%end*/
  -- 	放射線検査依頼パターン
/*%if conditions.radPattern_exam_pattern != null */
  AND foo.rad_pattern = /* conditions.radPattern_exam_pattern*/null
/*%end*/
  -- 	登録時放射線検査日時
/*%if !conditions.patRadPatternRegRadDate.isEmpty() */
  AND foo.str_rad_date = /* conditions.patRadPatternRegRadDate*/null
/*%end*/
  -- 	指定曜日
/*%if conditions.radPattern_exam_week.size() >0 */
  AND foo.rad_week IN /* conditions.radPattern_exam_week*/(null)
/*%end*/
	-- 	指定期間開始日
/*%if conditions.radPattern_exam_pattern_start_date != null */
  AND foo.rad_from >= /* conditions.radPattern_exam_pattern_start_date*/null
/*%end*/
  -- 	指定期間終了日
/*%if conditions.radPattern_exam_pattern_end_date != null */
  AND foo.rad_to <= /* conditions.radPattern_exam_pattern_end_date*/null
/*%end*/
---add No338患者詳細検索の追加項目 一般撮影検査予定検索 劉全航 end

