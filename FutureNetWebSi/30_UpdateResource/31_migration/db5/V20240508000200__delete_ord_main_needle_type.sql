-- ord_mainテーブルを削除し、医療材料と実際の医療材料のneedle_typeを予定する
UPDATE ntss.ord_main
SET ind_equip_info = (
    SELECT jsonb_agg(
        value #- '{needle_type}'
    )
    FROM jsonb_array_elements(ind_equip_info)
),
rst_equip_info = (
    SELECT jsonb_agg(
        value #- '{needle_type}'
    )
    FROM jsonb_array_elements(rst_equip_info)
)
WHERE
-- jsonb_typeof(ind_equip_info) = 'array' AND jsonb_typeof(rst_equip_info) = 'array'
-- AND
facility_cd = 'NKKSBR'
