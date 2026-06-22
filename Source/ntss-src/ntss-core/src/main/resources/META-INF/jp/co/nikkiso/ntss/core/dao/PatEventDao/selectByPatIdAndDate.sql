--add #12324 紹介状の出力時にpat_eventを参照する zhao start
-- 指定患者、指定時間の患者イベント実績情報を取得
SELECT
  A.pat_event_cd,
  A.pat_id,
  A.facility_cd,
  A.template_cd,
  A.letter_info
FROM
  pat_event A
WHERE
  A.pat_id = /*patId*/null
  AND A.facility_cd = /*facilityCd*/null
  /*%if fromDate != null */
    AND A.event_start_date >= /*fromDate*/null
  /*%end */
  /*%if toDate != null */
    AND A.event_start_date <= /*toDate*/null
  /*%end */
  AND A.is_del = '0'
  AND A.letter_info is not null
ORDER BY A.event_start_date DESC, A.up_date DESC;
-- add #12324 紹介状の出力時にpat_eventを参照する zhao end
