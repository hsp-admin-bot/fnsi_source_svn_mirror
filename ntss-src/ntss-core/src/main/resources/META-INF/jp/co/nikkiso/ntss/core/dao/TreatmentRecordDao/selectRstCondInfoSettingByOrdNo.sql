WITH ctl_mapping AS (
  SELECT category_no, ctl_no
  FROM (VALUES
    (1, 2), (1,5), (1,6), (1,7), (1,8), (1,13), (1,14),
    (2, 3), (2,4), (2,39),
    (3,15), (3,16), (3,17), (3,18),
    (4,19), (4,20), (4,21), (4,22), (4,23), (4,24),
    (5,25), (5,26), (5,27), (5,28),
    (6,29), (6,30), (6,31), (6,32), (6,33), (6,34), (6,35), (6,36), (6,37), (6,38),
    (7,9), (7,10), (7,11), (7,12)
  ) AS t(category_no, ctl_no)
),
ind_keys AS (
  SELECT key::int AS key, 1 as exists_flag
  FROM ord_main,
  jsonb_each(rst_cond_info)
  WHERE ord_no = /*ordNo*/0
),
special_case AS (
  SELECT bool_or(key = 3) as has_key_3
  FROM ind_keys
),
item_status AS (
  SELECT
    m.category_no,
    m.ctl_no,
    CASE
      WHEN m.ctl_no IN (3,39) THEN
        CASE WHEN (SELECT has_key_3 FROM special_case) THEN '1' ELSE '0' END
      ELSE
        COALESCE(k.exists_flag::text, '0')
    END AS is_use
  FROM ctl_mapping m
  LEFT JOIN ind_keys k ON m.ctl_no = k.key
  ORDER BY m.category_no, array_position(ARRAY[2,5,6,7,8,13,14], m.ctl_no)
),
items_grouped AS (
  SELECT
    category_no,
    jsonb_agg(
      jsonb_build_object(
        'ctl_no', ctl_no::text,
        'is_use', is_use
      ) ORDER BY ctl_no
    ) AS items
  FROM item_status
  GROUP BY category_no
)
SELECT jsonb_agg(
  jsonb_build_object(
    'category_no', category_no,
    'items', items
  ) ORDER BY category_no
) AS treatment_condition_setting,
0 as report_id
FROM items_grouped;
