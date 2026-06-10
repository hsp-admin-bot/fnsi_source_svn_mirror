SELECT
    pat_id
FROM
    pat_insurance
WHERE
        is_del = '0'
/*%if patIdList.size() > 0 */
  AND pat_id in /* patIdList */(null)
/*%end */
  AND facility_cd in /* facilityCdList */(null)
/*%if !conditions.insurance_check_date.isEmpty() */
/*%if conditions.insurance_check_date == "1" */
-- mod 6935 患者詳細検索＞保険当月未確認の動作不正 周安寧 start
--   当月未確認
--   AND (
--         (check_date IS NOT NULL AND check_date != '' AND SUBSTR(check_date,5,2)::INT < (SELECT EXTRACT(MONTH FROM CURRENT_DATE) - 1) AND end_date IS NOT NULL AND end_date != '' AND SUBSTR(end_date,5,2)::INT >= (SELECT EXTRACT(MONTH FROM CURRENT_DATE)-1))
--         OR ((check_date IS NULL OR check_date = '') AND end_date IS NOT NULL AND end_date != '' AND SUBSTR(end_date,5,2)::INT >= (SELECT EXTRACT(MONTH FROM CURRENT_DATE)))
--         OR ((check_date IS NULL OR check_date = '') AND start_date IS NOT NULL AND start_date != '' AND SUBSTR(start_date,5,2)::INT < (SELECT EXTRACT(MONTH FROM CURRENT_DATE)) AND (end_date IS NULL OR end_date = ''))
--     )
-- 	未確認判定ロジック
--普通の確認
  AND(
  --（確認日の年月＜＝当月‐1）　＆　（終了日の年月　＞＝当月）
  (check_date IS NOT NULL AND check_date != '' AND  SUBSTR(check_date,1,6) <= (SELECT to_char(CURRENT_DATE -INTERVAL'1 month','yyyyMM'))
  AND end_date IS NOT NULL AND end_date != '' AND SUBSTR(end_date,1,6) >= (SELECT to_char(CURRENT_DATE,'yyyyMM')) )
  --確認日が空白　　＆　（終了日の年月　＞＝今月)
  OR ((check_date IS NULL OR check_date = '') AND end_date IS NOT NULL AND end_date != '' AND SUBSTR(end_date,1,6) >= (SELECT to_char(CURRENT_DATE,'yyyyMM'))
  )
  --確認日が空白　＆　　（開始日の年月　＜　今月　)　＆　終了日が空白
  OR ((check_date IS NULL OR check_date = '') AND start_date IS NOT NULL AND start_date != '' AND SUBSTR(start_date,1,6) < (SELECT to_char(CURRENT_DATE,'yyyyMM'))
    AND (end_date IS NULL OR end_date = ''))
  )
  -- mod 6935 患者詳細検索＞保険当月未確認の動作不正 周安寧 end
/*%end*/
/*%if conditions.insurance_check_date == "0" */
-- mod 6935 患者詳細検索＞保険当月未確認の動作不正 周安寧 start
-- 	当月確認
--   AND (
--         ((end_date IS NOT NULL AND end_date != '' AND SUBSTR(end_date,5,2)::INT >= (SELECT EXTRACT(MONTH FROM CURRENT_DATE))) OR
--          start_date IS NOT NULL AND start_date != '' AND SUBSTR(start_date,5,2)::INT < (SELECT EXTRACT(MONTH FROM CURRENT_DATE)) AND (end_date IS NULL OR end_date = '')) AND
--         check_date IS NOT NULL AND check_date != '' AND SUBSTR(check_date,5,2)::INT = (SELECT EXTRACT(MONTH FROM CURRENT_DATE))
--     )
  AND (
  --（終了日の年月　＞＝今月）　＆（確認日の年月＝今月）　
  (end_date IS NOT NULL AND end_date != '' AND SUBSTR(end_date,1,6) >= (SELECT to_char(CURRENT_DATE,'yyyyMM'))
  AND check_date IS NOT NULL AND check_date != '' AND  SUBSTR(check_date,1,6) = (SELECT to_char(CURRENT_DATE,'yyyyMM')))
  --（開始日の年月　＜　今月）　＆（確認日の年月＝今月）
  OR  (start_date IS NOT NULL AND start_date != '' AND SUBSTR(start_date,1,6) < (SELECT to_char(CURRENT_DATE,'yyyyMM'))
  AND  check_date IS NOT NULL AND check_date != '' AND  SUBSTR(check_date,1,6) = (SELECT to_char(CURRENT_DATE,'yyyyMM')))
  )
  -- mod 6935 患者詳細検索＞保険当月未確認の動作不正 周安寧 end
/*%end*/
/*%end */
