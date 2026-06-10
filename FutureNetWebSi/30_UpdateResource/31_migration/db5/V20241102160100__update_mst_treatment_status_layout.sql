--#9312 治療状況リスト，マップの表示が不正
--view_item.data_classの設定ルール修正
UPDATE mst_treatment_status_layout
SET
  dcs_view_items = (
    SELECT jsonb_agg(
             jsonb_set(
               elem,
               '{data_class}',
               (CASE
                  WHEN (elem->>'data_class')::bigint <= -10000
                    THEN to_jsonb(-10000 - (
                    SELECT SUM(ascii(substring(elem->>'key_name', i, 1)) * (10 ^ (2 * (length(elem->>'key_name') - i))))
                    FROM generate_series(1, length(elem->>'key_name')) AS i
                  ))
                  ELSE elem->'data_class'
                 END)
             )
           )
    FROM jsonb_array_elements(dcs_view_items) AS elem
  ),
  dab_view_items = (
    SELECT jsonb_agg(
             jsonb_set(
               elem,
               '{data_class}',
               (CASE
                  WHEN (elem->>'data_class')::bigint <= -10000
                    THEN to_jsonb(-10000 - (
                    SELECT SUM(ascii(substring(elem->>'key_name', i, 1)) * (10 ^ (2 * (length(elem->>'key_name') - i))))
                    FROM generate_series(1, length(elem->>'key_name')) AS i
                  ))
                  ELSE elem->'data_class'
                 END)
             )
           )
    FROM jsonb_array_elements(dab_view_items) AS elem
  ),
  dad_view_items = (
    SELECT jsonb_agg(
             jsonb_set(
               elem,
               '{data_class}',
               (CASE
                  WHEN (elem->>'data_class')::bigint <= -10000
                    THEN to_jsonb(-10000 - (
                    SELECT SUM(ascii(substring(elem->>'key_name', i, 1)) * (10 ^ (2 * (length(elem->>'key_name') - i))))
                    FROM generate_series(1, length(elem->>'key_name')) AS i
                  ))
                  ELSE elem->'data_class'
                 END)
             )
           )
    FROM jsonb_array_elements(dad_view_items) AS elem
  ),
  dro_view_items = (
    SELECT jsonb_agg(
             jsonb_set(
               elem,
               '{data_class}',
               (CASE
                  WHEN (elem->>'data_class')::bigint <= -10000
                    THEN to_jsonb(-10000 - (
                    SELECT SUM(ascii(substring(elem->>'key_name', i, 1)) * (10 ^ (2 * (length(elem->>'key_name') - i))))
                    FROM generate_series(1, length(elem->>'key_name')) AS i
                  ))
                  ELSE elem->'data_class'
                 END)
             )
           )
    FROM jsonb_array_elements(dro_view_items) AS elem
  ) where is_disp = '1' and is_del = '0';
