-- #11320 【たくしん会：改良】処方の編集操作方法追加
-- prescription_detailから区切「"type": 0」の要素を削除
UPDATE ord_prescription
SET prescription_detail = (
  SELECT jsonb_agg(elem)
  FROM jsonb_array_elements(prescription_detail) elem
  WHERE
    NOT (jsonb_typeof(elem -> 'type') = 'number' AND (elem ->> 'type')::int = 0)  -- `type = 0` を除外
)
WHERE prescription_detail @> '[{"type": 0}]'::jsonb
;