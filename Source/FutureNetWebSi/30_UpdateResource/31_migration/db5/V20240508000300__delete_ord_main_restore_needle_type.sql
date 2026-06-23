-- ord_main_restoreテーブルを削除し、医材と実際の医材のneedle_typeを予定する
UPDATE ntss.ord_main_restore
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
