-- #12642
-- mst_job.default_disp_settings のselectedKurIndexList（index）→ kur_cd に変換
WITH kur_order AS (
 SELECT 
  ms.facility_cd, 
  (elem.value->>'code')::bigint AS kur_cd, 
  elem.ordinality AS idx 
 FROM ntss.mst_selector ms, 
 jsonb_array_elements(ms.order_settings->'items') WITH ORDINALITY AS elem(value, ordinality)
 WHERE ms.master_physical_name = 'mst_kur' 
),
target AS (
  SELECT
    j.job_cd,
    j.facility_cd,
    arr.val::int AS old_idx,
    arr.ord
  FROM ntss.mst_job j
  CROSS JOIN LATERAL jsonb_array_elements(
    j.default_disp_settings
      -> 'schedule-list'
      -> 'selectedKurIndexList'
  ) WITH ORDINALITY AS arr(val, ord)
  WHERE
    j.default_disp_settings IS NOT NULL
    AND jsonb_typeof(
      j.default_disp_settings
        -> 'schedule-list'
        -> 'selectedKurIndexList'
    ) = 'array'
),
converted AS (
  SELECT
    t.job_cd,
    jsonb_agg(ko.kur_cd ORDER BY t.ord) AS new_kur_list
  FROM target t
  JOIN kur_order ko
    ON ko.facility_cd = t.facility_cd
   AND ko.idx = t.old_idx
  GROUP BY t.job_cd
)
UPDATE ntss.mst_job j
SET default_disp_settings = jsonb_set(
  j.default_disp_settings,
  '{schedule-list,selectedKurIndexList}',
  c.new_kur_list,
  true
)
FROM converted c
WHERE j.job_cd = c.job_cd;
