-- mst_treatment_setテーブルを削除し、医材中のneedle_typeを予定する
UPDATE ntss.mst_treatment_set
SET ind_equip_info = (
    SELECT jsonb_agg(
        value #- '{needle_type}'
    )
    FROM jsonb_array_elements(ind_equip_info)
)
WHERE jsonb_typeof(ind_equip_info) = 'array'
AND facility_cd = 'NKKSBR'
AND ind_equip_info != '[]'
