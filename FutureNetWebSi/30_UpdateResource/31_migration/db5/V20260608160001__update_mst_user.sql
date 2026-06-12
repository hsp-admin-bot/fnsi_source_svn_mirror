-- #12642
-- mst_user.user_settings のselectedKurIndexList（index）→ kur_cd に変換
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
    u.user_id,
    u.facility_cd,
    arr.val::int AS old_idx,
    arr.ord
  FROM ntss.mst_user u
  CROSS JOIN LATERAL jsonb_array_elements(
    u.user_settings
      -> 'default_setting'
      -> 'schedule-list'
      -> 'selectedKurIndexList'
  ) WITH ORDINALITY AS arr(val, ord)
  WHERE
    u.user_settings ? 'default_setting'
    AND jsonb_typeof(
      u.user_settings
        -> 'default_setting'
        -> 'schedule-list'
        -> 'selectedKurIndexList'
    ) = 'array'
),
converted AS (
  SELECT
    t.user_id,
    jsonb_agg(ko.kur_cd ORDER BY t.ord) AS new_kur_list
  FROM target t
  JOIN kur_order ko
    ON ko.facility_cd = t.facility_cd
   AND ko.idx = t.old_idx
  GROUP BY t.user_id
)
UPDATE ntss.mst_user u
SET user_settings = jsonb_set(
  u.user_settings,
  '{default_setting,schedule-list,selectedKurIndexList}',
  c.new_kur_list,
  true
)
FROM converted c
WHERE u.user_id = c.user_id;
