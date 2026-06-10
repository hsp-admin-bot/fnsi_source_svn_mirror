-- 指定患者、指定時間範囲の患者イベント実績情報を取得
SELECT
  A.pat_event_cd,
  A.pat_id,
  A.facility_cd,
  A.event_start_date,
  A.sub_category_cd
FROM
  pat_event A
WHERE
  A.pat_id = /*patId*/2741
AND
  A.use_type = 2
AND
  A.event_start_date >= /*dialysis_date_from*/'20100220'
AND
  A.event_start_date <= /*dialysis_date_to*/'20300226'
AND
  A.is_del = '0'
ORDER BY A.pat_event_cd, A.sub_category_cd
;
