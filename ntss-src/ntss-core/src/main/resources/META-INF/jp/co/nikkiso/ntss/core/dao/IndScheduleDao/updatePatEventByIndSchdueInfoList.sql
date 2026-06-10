WITH updates AS (
  SELECT facility_cd, pat_event_cd, treat_date, oldTreatDate, TO_DATE(treat_date, 'YYYYMMDD') - TO_DATE(oldTreatDate, 'YYYYMMDD') AS date_diff
  FROM (
     VALUES
       (null, 0, null, null)
       /*%for isl : indScheduleInfoList */
         /*%for islevntcd : isl.connectedPatEventCdList */
         ,(
           /*isl.facilityCd*/null,
           /*islevntcd*/0,
           /*isl.treatDate*/null,
           /*isl.oldTreatDate*/null
         )
         /*%end*/
      /*%end*/
   ) AS t(facility_cd, pat_event_cd, treat_date, oldTreatDate) WHERE t.treat_date != t.oldTreatDate
), updated_rows AS (
  SELECT
    pat_event.facility_cd,
    pat_event.pat_event_cd,
    CASE WHEN pat_event.event_start_date IS NOT NULL THEN TO_CHAR(TO_DATE(pat_event.event_start_date, 'YYYYMMDD') + u.date_diff * INTERVAL '1 day', 'YYYYMMDD') ELSE pat_event.event_start_date END as event_start_date,
    CASE WHEN pat_event.event_start_date IS NOT NULL AND pat_event.event_end_date IS NOT NULL THEN TO_CHAR(TO_DATE(pat_event.event_end_date, 'YYYYMMDD') + u.date_diff * INTERVAL '1 day', 'YYYYMMDD') ELSE pat_event.event_end_date END as event_end_date,
    CASE
--     mod #10409 施設設定マスタNo7, 8の設定を4にした際の動作不正 関 start
      WHEN arr.obj -> 'result_value' -> 'notice_start_date' IS NOT NULL AND arr.obj -> 'result_value' -> 'notice_end_date' IS NOT NULL
        THEN
        jsonb_set(
          jsonb_set(
            arr.obj,
            '{result_value, notice_start_date}',
            TO_JSONB(TO_TIMESTAMP(arr.obj -> 'result_value' ->> 'notice_start_date', 'YYYY-MM-DD"T"HH24:MI:SS"Z"') + u.date_diff * INTERVAL '1 day')
          ),
          '{result_value, notice_end_date}',
          TO_JSONB(TO_TIMESTAMP(arr.obj -> 'result_value' ->> 'notice_end_date', 'YYYY-MM-DD"T"HH24:MI:SS"Z"') + u.date_diff * INTERVAL '1 day')
        )
      WHEN arr.obj -> 'result_value' -> 'notice_start_date' IS NOT NULL
        THEN
        jsonb_set(
          arr.obj,
          '{result_value, notice_start_date}',
          TO_JSONB(TO_TIMESTAMP(arr.obj -> 'result_value' ->> 'notice_start_date', 'YYYY-MM-DD"T"HH24:MI:SS"Z"') + u.date_diff * INTERVAL '1 day')
        )
      ELSE
        arr.obj
      END AS updated_result,
    arr.obj_index
  FROM pat_event
         JOIN updates u ON pat_event.facility_cd = u.facility_cd AND pat_event.pat_event_cd = u.pat_event_cd
         CROSS JOIN jsonb_array_elements(pat_event.result_params) WITH ORDINALITY AS arr (obj, obj_index)
  WHERE pat_event.is_del = '0'
), updates2 as (
  SELECT facility_cd, pat_event_cd, event_start_date, event_end_date, jsonb_agg(updated_result ORDER BY obj_index) AS result_params
--   mod #10409 施設設定マスタNo7, 8の設定を4にした際の動作不正 関 end
  FROM updated_rows
  GROUP BY facility_cd, pat_event_cd, event_start_date, event_end_date
)
UPDATE pat_event
SET
  event_start_date = u2.event_start_date,
  event_end_date = u2.event_end_date,
  result_params = u2.result_params,
  up_date = transaction_timestamp()
FROM updates2 AS u2
WHERE
  pat_event.facility_cd = /*facilityCd*/null AND
  pat_event.facility_cd = u2.facility_cd AND
  pat_event.pat_event_cd = u2.pat_event_cd AND
  pat_event.is_del = '0'
RETURNING pat_event.*
